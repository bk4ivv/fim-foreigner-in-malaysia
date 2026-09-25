# Android release signing setup

This project intentionally excludes the production keystore and `android/key.properties`. The Play Store release must be signed with the existing upload key for the FIM application.

## Local configuration

Create `android/key.properties` locally:

```properties
storePassword=YOUR_UPLOAD_KEYSTORE_PASSWORD
keyPassword=YOUR_UPLOAD_KEY_PASSWORD
keyAlias=YOUR_UPLOAD_KEY_ALIAS
storeFile=/absolute/path/to/your/upload-keystore.jks
```

Keep both files private:

```bash
chmod 600 android/key.properties /absolute/path/to/your/upload-keystore.jks
```

Then build:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## CI configuration

For GitHub Actions, store the keystore as an encrypted Base64 secret and inject `android/key.properties` only during the workflow. Store passwords and aliases as separate encrypted secrets. Delete temporary files after the build. Never place a keystore, password, or `key.properties` in the repository or in an issue, pull request, or chat message.

## Recovery warning

If the original upload key is unavailable, stop before publishing. Ask the Play Console account owner to confirm whether Play App Signing is enabled and follow Google’s official upload-key reset process. A newly generated key is not automatically interchangeable with the old one.
