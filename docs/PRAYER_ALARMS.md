# Prayer times and reminders

FIM now keeps a `Your religion` preference in Settings. Prayer times and reminder controls are shown only when the user selects Islam. Choosing another option hides the prayer card and cancels previously scheduled FIM prayer reminders.

The reminder system uses Android local notifications. It requests notification permission only when the user turns reminders on. Five daily reminders are supported: Fajr, Dhuhr, Asr, Maghrib, and Isha. The default times are editable because prayer times vary by Malaysian location and date; users should compare them with the official [e-Solat Malaysia](https://www.e-solat.gov.my/) timetable before enabling reminders.

Reminders use Android's inexact-while-idle schedule mode. This avoids requesting the special Alarms & reminders access for a feature that does not need second-level precision, while still allowing notifications when the device is idle. Android notification permission and reboot rescheduling are declared in the manifest.

The implementation uses `flutter_local_notifications` and the Malaysia timezone `Asia/Kuala_Lumpur`. The app does not claim to calculate official prayer times locally; e-Solat remains the source users should use to verify the displayed times.

## References

- Android notification permission: https://developer.android.com/develop/ui/views/notifications/notification-permission
- Android alarm guidance: https://developer.android.com/develop/background-work/services/alarms
- Android 14 exact-alarm behavior: https://developer.android.com/about/versions/14/changes/schedule-exact-alarms
- Flutter local notifications setup and scheduling: https://pub.dev/packages/flutter_local_notifications
