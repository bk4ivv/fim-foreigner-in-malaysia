// Community design: guest reading, verified optional accounts, and private-by-default profile data.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'community_backend_config.dart';

class CommunityPortalPage extends StatefulWidget {
  const CommunityPortalPage({
    super.key,
    required this.selectedLanguage,
    required this.textDirection,
  });

  final String selectedLanguage;
  final TextDirection textDirection;

  @override
  State<CommunityPortalPage> createState() => _CommunityPortalPageState();
}

class _CommunityPortalPageState extends State<CommunityPortalPage> {
  final _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;
  var _refresh = 0;

  _CommunityCopy get _copy => _CommunityCopy(widget.selectedLanguage);
  User? get _user => _client.auth.currentUser;
  bool get _isVerified => _user?.emailConfirmedAt != null;

  @override
  void initState() {
    super.initState();
    _authSubscription = _client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() => _refresh++);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadUpdates() async {
    final rows = await _client
        .from('official_updates')
        .select('id,title,body,language,published_at')
        .eq('state', 'published')
        .order('published_at', ascending: false)
        .limit(8);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> _loadPosts() async {
    final rows = await _client
        .from('community_posts')
        .select(
          'id,author_id,body,language,created_at,profiles!community_posts_author_id_fkey(display_name,avatar_path)',
        )
        .eq('moderation_state', 'published')
        .order('created_at', ascending: false)
        .limit(40);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _user;
    if (user == null) return null;
    return _client
        .from('profiles')
        .select('id,display_name,avatar_path,community_state,role')
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<void> _openParticipation() async {
    if (_user == null || !_isVerified) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CommunityAccountHubPage(
            selectedLanguage: widget.selectedLanguage,
            textDirection: widget.textDirection,
          ),
        ),
      );
      if (mounted) setState(() => _refresh++);
      return;
    }
    final profile = await _loadProfile();
    if (!mounted) return;
    if (profile == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CommunityAccountHubPage(
            selectedLanguage: widget.selectedLanguage,
            textDirection: widget.textDirection,
          ),
        ),
      );
    } else if (profile['community_state'] != 'active') {
      _message(_copy.accessUnavailable);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _CommunityComposerPage(
            selectedLanguage: widget.selectedLanguage,
            textDirection: widget.textDirection,
          ),
        ),
      );
    }
    if (mounted) setState(() => _refresh++);
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Directionality(
      textDirection: widget.textDirection,
      child: RefreshIndicator(
        onRefresh: () async => setState(() => _refresh++),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 104),
          children: [
            _CommunityHero(
              copy: copy,
              isSignedIn: _user != null,
              isVerified: _isVerified,
              onAccount: _openParticipation,
              onCompose: _openParticipation,
            ),
            const SizedBox(height: 16),
            _SafetyNotice(copy: copy, onSurface: onSurface),
            const SizedBox(height: 22),
            _CommunitySectionLabel(copy.officialUpdates),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('updates-$_refresh'),
              future: _loadUpdates(),
              builder: (context, snapshot) => _AsyncCommunityArea(
                snapshot: snapshot,
                emptyTitle: copy.noOfficialUpdates,
                emptyBody: copy.officialUpdatesEmpty,
                itemBuilder: (item) => _OfficialUpdateCard(update: item),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _CommunitySectionLabel(copy.community)),
                TextButton.icon(
                  onPressed: _openParticipation,
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: Text(copy.write),
                ),
              ],
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('posts-$_refresh'),
              future: _loadPosts(),
              builder: (context, snapshot) => _AsyncCommunityArea(
                snapshot: snapshot,
                emptyTitle: copy.communityReady,
                emptyBody: copy.communityEmpty,
                itemBuilder: (item) => _CommunityPostCard(
                  post: item,
                  copy: copy,
                  onChanged: () => setState(() => _refresh++),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityAccountHubPage extends StatefulWidget {
  const CommunityAccountHubPage({
    super.key,
    required this.selectedLanguage,
    required this.textDirection,
  });

  final String selectedLanguage;
  final TextDirection textDirection;

  @override
  State<CommunityAccountHubPage> createState() =>
      _CommunityAccountHubPageState();
}

class _CommunityAccountHubPageState extends State<CommunityAccountHubPage> {
  final _client = Supabase.instance.client;
  var _refresh = 0;

  _CommunityCopy get _copy => _CommunityCopy(widget.selectedLanguage);
  User? get _user => _client.auth.currentUser;
  bool get _isVerified => _user?.emailConfirmedAt != null;

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _user;
    if (user == null) return null;
    return _client
        .from('profiles')
        .select('id,display_name,avatar_path,community_state,role')
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<void> _resendConfirmation() async {
    final email = _user?.email;
    if (email == null) return;
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: CommunityBackendConfig.emailRedirectUrl,
      );
      _message(_copy.confirmationSent);
    } on AuthException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CommunityProfileEditorPage(
          selectedLanguage: widget.selectedLanguage,
          textDirection: widget.textDirection,
        ),
      ),
    );
    if (mounted) setState(() => _refresh++);
  }

  Future<void> _signOut() async {
    await _client.auth.signOut();
    if (mounted) setState(() => _refresh++);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    return Directionality(
      textDirection: widget.textDirection,
      child: Scaffold(
        appBar: AppBar(title: Text(copy.account)),
        body: _user == null
            ? _CommunityEmailPasswordPage(
                selectedLanguage: widget.selectedLanguage,
                textDirection: widget.textDirection,
                onAccountStateChanged: () => setState(() => _refresh++),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  if (!_isVerified)
                    _VerificationCard(
                      copy: copy,
                      onResend: _resendConfirmation,
                    ),
                  if (!_isVerified) const SizedBox(height: 14),
                  FutureBuilder<Map<String, dynamic>?>(
                    key: ValueKey('account-$_refresh'),
                    future: _loadProfile(),
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _AccountSummaryCard(
                        copy: copy,
                        profile: profile,
                        email: _user?.email ?? '',
                        verified: _isVerified,
                        onEdit: _isVerified ? _openEditor : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _PrivateDataNotice(copy: copy),
                  const SizedBox(height: 16),
                  if (_isVerified)
                    OutlinedButton.icon(
                      onPressed: () => _requestDeletion(context, copy),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(copy.requestDeletion),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(copy.signOut),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _requestDeletion(
    BuildContext context,
    _CommunityCopy copy,
  ) async {
    final note = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(copy.requestDeletion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(copy.deletionBody),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              maxLength: 500,
              decoration: InputDecoration(labelText: copy.optionalNote),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(copy.requestDeletion),
          ),
        ],
      ),
    );
    if (approved != true || _user == null) return;
    try {
      await _client.from('account_deletion_requests').upsert({
        'user_id': _user!.id,
        'note': note.text.trim().isEmpty ? null : note.text.trim(),
        'state': 'pending',
      });
      if (context.mounted) _message(copy.deletionSubmitted);
    } on PostgrestException catch (error) {
      if (context.mounted) _message(error.message);
    }
  }
}

class _CommunityEmailPasswordPage extends StatefulWidget {
  const _CommunityEmailPasswordPage({
    required this.selectedLanguage,
    required this.textDirection,
    required this.onAccountStateChanged,
  });

  final String selectedLanguage;
  final TextDirection textDirection;
  final VoidCallback onAccountStateChanged;

  @override
  State<_CommunityEmailPasswordPage> createState() =>
      _CommunityEmailPasswordPageState();
}

class _CommunityEmailPasswordPageState
    extends State<_CommunityEmailPasswordPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  var _createMode = true;
  var _busy = false;
  var _showPassword = false;
  var _showPasswordConfirmation = false;
  String? _verificationEmail;

  _CommunityCopy get _copy => _CommunityCopy(widget.selectedLanguage);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@')) return _message(_copy.validEmail);
    if (password.length < 8) return _message(_copy.passwordRule);
    if (_createMode && password != _passwordConfirmation.text) {
      return _message(_copy.passwordsDoNotMatch);
    }
    setState(() => _busy = true);
    try {
      if (_createMode) {
        final result = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: CommunityBackendConfig.emailRedirectUrl,
        );
        if (!mounted) return;
        if (result.user?.identities?.isEmpty ?? false) {
          setState(() {
            _createMode = false;
            _password.clear();
            _passwordConfirmation.clear();
          });
          _message(_copy.accountExistsSignIn);
          return;
        }
        if (result.session == null) {
          setState(() => _verificationEmail = email);
        } else {
          _message(_copy.accountCreated);
          widget.onAccountStateChanged();
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        _message(_copy.signedIn);
        widget.onAccountStateChanged();
      }
    } on AuthException catch (error) {
      _message(
        error.code == 'invalid_credentials'
            ? _copy.incorrectCredentials
            : error.message,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _email.text.trim();
    if (!email.contains('@')) return _message(_copy.validEmail);
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: CommunityBackendConfig.emailRedirectUrl,
      );
      if (mounted) _message(_copy.passwordResetSent);
    } on AuthException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resendConfirmation() async {
    final email = _verificationEmail;
    if (email == null) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: CommunityBackendConfig.emailRedirectUrl,
      );
      if (mounted) _message(_copy.confirmationSent);
    } on AuthException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    if (_verificationEmail != null) {
      return _AccountVerificationStep(
        copy: copy,
        email: _verificationEmail!,
        busy: _busy,
        onResend: _resendConfirmation,
        onVerified: () => setState(() {
          _verificationEmail = null;
          _createMode = false;
        }),
      );
    }
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        _AccountStepRail(copy: copy, currentStep: 1),
        const SizedBox(height: 22),
        _AccountIdentityHeader(
          icon: _createMode
              ? Icons.person_add_alt_1_rounded
              : Icons.lock_open_rounded,
          eyebrow: _createMode ? copy.community : copy.welcomeBack,
          title: _createMode ? copy.joinCommunity : copy.signIn,
          body: _createMode ? copy.socialAuthBody : copy.signInBody,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: onSurface.withValues(alpha: 0.14)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: copy.email,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: !_showPassword,
                onChanged: (_) => setState(() {}),
                autofillHints: [
                  _createMode
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                decoration: InputDecoration(
                  labelText: copy.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _showPassword
                        ? copy.hidePassword
                        : copy.showPassword,
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_createMode) ...[
                const SizedBox(height: 9),
                _PasswordStrengthHint(password: _password.text, copy: copy),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordConfirmation,
                  obscureText: !_showPasswordConfirmation,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: copy.confirmPassword,
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    suffixIcon: IconButton(
                      tooltip: _showPasswordConfirmation
                          ? copy.hidePassword
                          : copy.showPassword,
                      onPressed: () => setState(
                        () => _showPasswordConfirmation =
                            !_showPasswordConfirmation,
                      ),
                      icon: Icon(
                        _showPasswordConfirmation
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _busy
                      ? copy.pleaseWait
                      : (_createMode ? copy.createAccount : copy.signIn),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _createMode = !_createMode),
                child: Text(_createMode ? copy.haveAccount : copy.needAccount),
              ),
              if (!_createMode)
                TextButton(
                  onPressed: _busy ? null : _sendPasswordReset,
                  child: Text(copy.forgotPassword),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          copy.emailDeliveryHelp,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.68),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _message(copy.guestAccessMessage),
          icon: const Icon(Icons.person_outline_rounded),
          label: Text(copy.continueGuest),
        ),
        const SizedBox(height: 10),
        _PrivateDataNotice(copy: copy),
      ],
    );
  }
}

class _AccountStepRail extends StatelessWidget {
  const _AccountStepRail({required this.copy, required this.currentStep});

  final _CommunityCopy copy;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final labels = [copy.stepAccount, copy.stepVerify, copy.stepProfile];
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : scheme.primary.withValues(
                                alpha: index < currentStep ? 0.72 : 0.18,
                              ),
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index + 1 <= currentStep
                            ? scheme.primary
                            : Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      child: index + 1 < currentStep
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: scheme.onPrimary,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index + 1 <= currentStep
                                    ? scheme.onPrimary
                                    : onSurface,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == labels.length - 1
                            ? Colors.transparent
                            : scheme.primary.withValues(
                                alpha: index + 1 < currentStep ? 0.72 : 0.18,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface.withValues(
                      alpha: index + 1 <= currentStep ? 1 : 0.55,
                    ),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AccountIdentityHeader extends StatelessWidget {
  const _AccountIdentityHeader({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            icon,
            color: scheme.onPrimary,
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                body,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.68),
                  fontSize: 12,
                  height: 1.38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthHint extends StatelessWidget {
  const _PasswordStrengthHint({required this.password, required this.copy});

  final String password;
  final _CommunityCopy copy;

  @override
  Widget build(BuildContext context) {
    final score = password.length >= 12
        ? 3
        : password.length >= 8
        ? 2
        : password.isEmpty
        ? 0
        : 1;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: index < score
                    ? onSurface
                    : onSurface.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (index < 2) const SizedBox(width: 4),
        ],
        const SizedBox(width: 9),
        Text(
          score == 3 ? copy.passwordStrong : copy.passwordHint,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.62),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AccountVerificationStep extends StatelessWidget {
  const _AccountVerificationStep({
    required this.copy,
    required this.email,
    required this.busy,
    required this.onResend,
    required this.onVerified,
  });

  final _CommunityCopy copy;
  final String email;
  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        _AccountStepRail(copy: copy, currentStep: 2),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: onSurface.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: onSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                copy.verifyEmailTitle,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(copy.verifyEmailBody, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  email,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onVerified,
                icon: const Icon(Icons.login_rounded),
                label: Text(copy.iVerifiedSignIn),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: busy ? null : onResend,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(copy.resendConfirmation),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(copy.guestAccessMessage))),
          icon: const Icon(Icons.person_outline_rounded),
          label: Text(copy.continueGuest),
        ),
      ],
    );
  }
}

class _CommunityProfileEditorPage extends StatefulWidget {
  const _CommunityProfileEditorPage({
    required this.selectedLanguage,
    required this.textDirection,
  });

  final String selectedLanguage;
  final TextDirection textDirection;

  @override
  State<_CommunityProfileEditorPage> createState() =>
      _CommunityProfileEditorPageState();
}

class _CommunityProfileEditorPageState
    extends State<_CommunityProfileEditorPage> {
  final _client = Supabase.instance.client;
  final _displayName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _picker = ImagePicker();
  DateTime? _dob;
  Uint8List? _avatarBytes;
  String? _avatarName;
  String? _existingAvatar;
  var _loading = true;
  var _saving = false;

  _CommunityCopy get _copy => _CommunityCopy(widget.selectedLanguage);
  User get _user => _client.auth.currentUser!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _client
            .from('profiles')
            .select('display_name,avatar_path')
            .eq('id', _user.id)
            .maybeSingle(),
        _client
            .from('profile_private_data')
            .select('date_of_birth,address,phone_number')
            .eq('user_id', _user.id)
            .maybeSingle(),
      ]);
      final publicProfile = results[0];
      final privateProfile = results[1];
      _displayName.text = publicProfile?['display_name'] as String? ?? '';
      _existingAvatar = publicProfile?['avatar_path'] as String?;
      _address.text = privateProfile?['address'] as String? ?? '';
      _phone.text = privateProfile?['phone_number'] as String? ?? '';
      final rawDate = privateProfile?['date_of_birth'] as String?;
      if (rawDate != null) {
        _dob = DateTime.tryParse(rawDate);
      }
    } on PostgrestException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _avatarName = file.name;
    });
  }

  Future<void> _chooseDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (value != null && mounted) setState(() => _dob = value);
  }

  Future<void> _save() async {
    final name = _displayName.text.trim();
    if (name.length < 3 || name.length > 32) {
      return _message(_copy.displayNameRule);
    }
    setState(() => _saving = true);
    try {
      var avatarPath = _existingAvatar;
      if (_avatarBytes != null) {
        final extension = _avatarName?.split('.').last.toLowerCase();
        final safeExtension = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)
            ? extension!
            : 'jpg';
        final objectPath = '${_user.id}/avatar.$safeExtension';
        final contentType = safeExtension == 'png'
            ? 'image/png'
            : safeExtension == 'webp'
            ? 'image/webp'
            : 'image/jpeg';
        await _client.storage
            .from('profile-avatars')
            .uploadBinary(
              objectPath,
              _avatarBytes!,
              fileOptions: FileOptions(upsert: true, contentType: contentType),
            );
        avatarPath = _client.storage
            .from('profile-avatars')
            .getPublicUrl(objectPath);
      }
      await _client.from('profiles').upsert({
        'id': _user.id,
        'display_name': name,
        'avatar_path': avatarPath,
        'preferred_language': widget.selectedLanguage,
        'preferred_theme': 'system',
        'community_state': 'active',
        'role': 'member',
      });
      await _client.from('profile_private_data').upsert({
        'user_id': _user.id,
        'date_of_birth': _dob?.toIso8601String().substring(0, 10),
        'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
        'phone_number': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      });
      if (mounted) {
        _message(_copy.profileSaved);
        Navigator.of(context).pop();
      }
    } on StorageException catch (error) {
      _message(error.message);
    } on PostgrestException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    return Directionality(
      textDirection: widget.textDirection,
      child: Scaffold(
        appBar: AppBar(title: Text(copy.editProfile)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  _AccountStepRail(copy: copy, currentStep: 3),
                  const SizedBox(height: 22),
                  _AccountIdentityHeader(
                    icon: Icons.account_circle_outlined,
                    eyebrow: copy.stepProfile,
                    title: copy.completeProfile,
                    body: copy.finishProfileBody,
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.10),
                          backgroundImage: _avatarBytes != null
                              ? MemoryImage(_avatarBytes!)
                              : (_existingAvatar?.isNotEmpty ?? false
                                        ? NetworkImage(_existingAvatar!)
                                        : null)
                                    as ImageProvider?,
                          child:
                              _avatarBytes == null &&
                                  (_existingAvatar?.isEmpty ?? true)
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  size: 42,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            onPressed: _pickAvatar,
                            tooltip: copy.profilePhoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    copy.publicProfile,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(copy.publicProfileBody),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _displayName,
                    maxLength: 32,
                    decoration: InputDecoration(
                      labelText: copy.displayName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    copy.privateProfile,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(copy.privateProfileBody),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(copy.email),
                    subtitle: Text(_user.email ?? ''),
                    trailing: const Icon(Icons.verified_user_outlined),
                  ),
                  OutlinedButton.icon(
                    onPressed: _chooseDate,
                    icon: const Icon(Icons.cake_outlined),
                    label: Text(
                      _dob == null
                          ? copy.dateOfBirth
                          : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: copy.address,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 32,
                    decoration: InputDecoration(
                      labelText: copy.phone,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? copy.pleaseWait : copy.saveProfile),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CommunityComposerPage extends StatefulWidget {
  const _CommunityComposerPage({
    required this.selectedLanguage,
    required this.textDirection,
  });

  final String selectedLanguage;
  final TextDirection textDirection;

  @override
  State<_CommunityComposerPage> createState() => _CommunityComposerPageState();
}

class _CommunityComposerPageState extends State<_CommunityComposerPage> {
  final _body = TextEditingController();
  var _posting = false;

  _CommunityCopy get _copy => _CommunityCopy(widget.selectedLanguage);

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _body.text.trim();
    final problem = _communitySafetyProblem(body, maxLength: 1000, copy: _copy);
    if (problem != null) {
      return _message(problem);
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.emailConfirmedAt == null) {
      return _message(_copy.verifyToParticipate);
    }
    setState(() => _posting = true);
    try {
      await Supabase.instance.client.from('community_posts').insert({
        'author_id': user.id,
        'body': body,
        'language': widget.selectedLanguage,
      });
      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  void _message(String value) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    return Directionality(
      textDirection: widget.textDirection,
      child: Scaffold(
        appBar: AppBar(title: Text(copy.writePost)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ComposerSafetyCopy(copy: copy),
            const SizedBox(height: 16),
            TextField(
              controller: _body,
              maxLength: 1000,
              minLines: 7,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: copy.postHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _posting ? null : _submit,
              icon: _posting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_posting ? copy.pleaseWait : copy.publish),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.copy,
    required this.onChanged,
  });

  final Map<String, dynamic> post;
  final _CommunityCopy copy;
  final VoidCallback onChanged;

  String get _authorName {
    final profile = post['profiles'];
    if (profile is Map) {
      return profile['display_name'] as String? ?? copy.member;
    }
    return copy.member;
  }

  String? get _avatar {
    final profile = post['profiles'];
    return profile is Map ? profile['avatar_path'] as String? : null;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isOwner =
        Supabase.instance.client.auth.currentUser?.id == post['author_id'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onSurface.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: onSurface.withValues(alpha: 0.10),
                backgroundImage: _avatar?.isNotEmpty == true
                    ? NetworkImage(_avatar!)
                    : null,
                child: _avatar?.isNotEmpty == true
                    ? null
                    : Icon(
                        Icons.person_outline_rounded,
                        color: onSurface,
                        size: 19,
                      ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authorName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _formatDate(post['created_at']),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'comments') {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            _CommunityCommentsPage(post: post, copy: copy),
                      ),
                    );
                    onChanged();
                  } else if (value == 'report') {
                    await _showReportSheet(
                      context,
                      copy: copy,
                      targetType: 'post',
                      targetId: post['id'] as String,
                    );
                  } else if (value == 'block') {
                    await _blockUser(
                      context,
                      copy: copy,
                      blockedId: post['author_id'] as String,
                    );
                    onChanged();
                  } else if (value == 'delete') {
                    await Supabase.instance.client
                        .from('community_posts')
                        .delete()
                        .eq('id', post['id'] as String);
                    onChanged();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'comments', child: Text(copy.comments)),
                  if (isOwner)
                    PopupMenuItem(value: 'delete', child: Text(copy.deleteMine))
                  else ...[
                    PopupMenuItem(value: 'report', child: Text(copy.report)),
                    PopupMenuItem(value: 'block', child: Text(copy.blockUser)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            post['body'] as String,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      _CommunityCommentsPage(post: post, copy: copy),
                ),
              );
              onChanged();
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
            label: Text(copy.comments),
          ),
        ],
      ),
    );
  }
}

class _CommunityCommentsPage extends StatefulWidget {
  const _CommunityCommentsPage({required this.post, required this.copy});

  final Map<String, dynamic> post;
  final _CommunityCopy copy;

  @override
  State<_CommunityCommentsPage> createState() => _CommunityCommentsPageState();
}

class _CommunityCommentsPageState extends State<_CommunityCommentsPage> {
  final _client = Supabase.instance.client;
  final _comment = TextEditingController();
  var _refresh = 0;
  var _sending = false;

  bool get _canParticipate =>
      _client.auth.currentUser?.emailConfirmedAt != null;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadComments() async {
    final rows = await _client
        .from('community_comments')
        .select(
          'id,author_id,body,created_at,profiles!community_comments_author_id_fkey(display_name,avatar_path)',
        )
        .eq('post_id', widget.post['id'] as String)
        .eq('moderation_state', 'published')
        .order('created_at')
        .limit(80);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> _send() async {
    final text = _comment.text.trim();
    final problem = _communitySafetyProblem(
      text,
      maxLength: 600,
      copy: widget.copy,
    );
    if (problem != null) {
      return _message(problem);
    }
    final user = _client.auth.currentUser;
    if (user == null || user.emailConfirmedAt == null) {
      return _message(widget.copy.verifyToParticipate);
    }
    setState(() => _sending = true);
    try {
      await _client.from('community_comments').insert({
        'post_id': widget.post['id'],
        'author_id': user.id,
        'body': text,
      });
      _comment.clear();
      setState(() => _refresh++);
    } on PostgrestException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _message(String value) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.copy.comments)),
    body: Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_refresh),
            future: _loadComments(),
            builder: (context, snapshot) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              children: [
                _CommunityPostCard(
                  post: widget.post,
                  copy: widget.copy,
                  onChanged: () {},
                ),
                const SizedBox(height: 18),
                _CommunitySectionLabel(widget.copy.comments),
                const SizedBox(height: 10),
                _AsyncCommunityArea(
                  snapshot: snapshot,
                  emptyTitle: widget.copy.noComments,
                  emptyBody: widget.copy.commentsEmpty,
                  itemBuilder: (item) => _CommentCard(
                    comment: item,
                    copy: widget.copy,
                    onChanged: () => setState(() => _refresh++),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comment,
                    enabled: _canParticipate,
                    maxLength: 600,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _canParticipate
                          ? widget.copy.commentHint
                          : widget.copy.verifyToParticipate,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: !_canParticipate || _sending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.copy,
    required this.onChanged,
  });

  final Map<String, dynamic> comment;
  final _CommunityCopy copy;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final profile = comment['profiles'];
    final name = profile is Map
        ? profile['display_name'] as String? ?? copy.member
        : copy.member;
    final avatar = profile is Map ? profile['avatar_path'] as String? : null;
    final isOwner =
        Supabase.instance.client.auth.currentUser?.id == comment['author_id'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface
              .withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: avatar?.isNotEmpty == true
                    ? NetworkImage(avatar!)
                    : null,
                child: avatar?.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person_outline_rounded, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _formatDate(comment['created_at']),
                style: const TextStyle(fontSize: 10),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'report') {
                    await _showReportSheet(
                      context,
                      copy: copy,
                      targetType: 'comment',
                      targetId: comment['id'] as String,
                    );
                  }
                  if (value == 'delete') {
                    await Supabase.instance.client
                        .from('community_comments')
                        .delete()
                        .eq('id', comment['id'] as String);
                    onChanged();
                  }
                },
                itemBuilder: (_) => [
                  if (isOwner)
                    PopupMenuItem(value: 'delete', child: Text(copy.deleteMine))
                  else
                    PopupMenuItem(value: 'report', child: Text(copy.report)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment['body'] as String,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CommunityHero extends StatelessWidget {
  const _CommunityHero({
    required this.copy,
    required this.isSignedIn,
    required this.isVerified,
    required this.onAccount,
    required this.onCompose,
  });

  final _CommunityCopy copy;
  final bool isSignedIn;
  final bool isVerified;
  final VoidCallback onAccount;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroChip(label: copy.community),
          const SizedBox(height: 13),
          Text(
            copy.heroTitle,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy.heroBody,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCompose,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(
                    isSignedIn && isVerified
                        ? copy.writePost
                        : copy.createOrSignIn,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onAccount,
                tooltip: copy.account,
                icon: Icon(
                  isSignedIn
                      ? Icons.person_outline_rounded
                      : Icons.person_add_alt_1_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.copy, required this.onSurface});
  final _CommunityCopy copy;
  final Color onSurface;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: onSurface.withValues(alpha: 0.14)),
    ),
    child: Row(
      children: [
        Icon(Icons.shield_outlined, color: onSurface),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            copy.safety,
            style: TextStyle(color: onSurface, fontSize: 12.5, height: 1.42),
          ),
        ),
      ],
    ),
  );
}

class _CommunitySectionLabel extends StatelessWidget {
  const _CommunitySectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.7,
    ),
  );
}

class _AsyncCommunityArea extends StatelessWidget {
  const _AsyncCommunityArea({
    required this.snapshot,
    required this.emptyTitle,
    required this.emptyBody,
    required this.itemBuilder,
  });
  final AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(Map<String, dynamic>) itemBuilder;
  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (snapshot.hasError) {
      return _EmptyCommunityCard(
        title: 'Unable to load',
        body: 'Please check your connection and refresh.',
      );
    }
    final values = snapshot.data ?? const [];
    if (values.isEmpty) {
      return _EmptyCommunityCard(title: emptyTitle, body: emptyBody);
    }
    return Column(
      children: [
        for (final value in values) ...[
          itemBuilder(value),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _EmptyCommunityCard extends StatelessWidget {
  const _EmptyCommunityCard({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14),
      ),
    ),
    child: Column(
      children: [
        Icon(
          Icons.forum_outlined,
          color: Theme.of(context).colorScheme.onSurface
              .withValues(alpha: 0.70),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(body, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _OfficialUpdateCard extends StatelessWidget {
  const _OfficialUpdateCard({required this.update});
  final Map<String, dynamic> update;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          update['title'] as String,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(update['body'] as String, style: const TextStyle(height: 1.42)),
        const SizedBox(height: 8),
        Text(
          _formatDate(update['published_at']),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.copy,
    required this.profile,
    required this.email,
    required this.verified,
    required this.onEdit,
  });
  final _CommunityCopy copy;
  final Map<String, dynamic>? profile;
  final String email;
  final bool verified;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    final avatar = profile?['avatar_path'] as String?;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface
              .withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: avatar?.isNotEmpty == true
                    ? NetworkImage(avatar!)
                    : null,
                child: avatar?.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?['display_name'] as String? ??
                          copy.completeProfile,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            verified ? copy.verifiedAccount : copy.verificationNeeded,
            style: TextStyle(
              color: verified
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.manage_accounts_outlined),
            label: Text(
              profile == null ? copy.completeProfile : copy.editProfile,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.copy, required this.onResend});
  final _CommunityCopy copy;
  final VoidCallback onResend;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.45),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.verificationNeeded,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(copy.verificationBody),
        TextButton.icon(
          onPressed: onResend,
          icon: const Icon(Icons.mark_email_read_outlined),
          label: Text(copy.resendConfirmation),
        ),
      ],
    ),
  );
}

class _PrivateDataNotice extends StatelessWidget {
  const _PrivateDataNotice({required this.copy});
  final _CommunityCopy copy;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            copy.privateNotice,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _ComposerSafetyCopy extends StatelessWidget {
  const _ComposerSafetyCopy({required this.copy});
  final _CommunityCopy copy;
  @override
  Widget build(BuildContext context) =>
      Text(copy.safety, style: const TextStyle(fontSize: 12, height: 1.45));
}

Future<void> _showReportSheet(
  BuildContext context, {
  required _CommunityCopy copy,
  required String targetType,
  required String targetId,
}) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null || user.emailConfirmedAt == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(copy.verifyToParticipate)));
    return;
  }
  final reasons = <String>[
    copy.reasonScam,
    copy.reasonHarassment,
    copy.reasonPrivateData,
    copy.reasonOther,
  ];
  final reason = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in reasons)
            ListTile(
              title: Text(item),
              onTap: () => Navigator.pop(sheet, item),
            ),
        ],
      ),
    ),
  );
  if (reason == null) {
    return;
  }
  try {
    await Supabase.instance.client.from('content_reports').insert({
      'reporter_id': user.id,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(copy.reportSubmitted)));
    }
  } on PostgrestException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

Future<void> _blockUser(
  BuildContext context, {
  required _CommunityCopy copy,
  required String blockedId,
}) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null || user.emailConfirmedAt == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(copy.verifyToParticipate)));
    return;
  }
  try {
    await Supabase.instance.client.from('user_blocks').upsert({
      'blocker_id': user.id,
      'blocked_id': blockedId,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(copy.userBlocked)));
    }
  } on PostgrestException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

String? _communitySafetyProblem(
  String value, {
  required int maxLength,
  required _CommunityCopy copy,
}) {
  if (value.isEmpty) {
    return copy.writeSomething;
  }
  if (value.length > maxLength) {
    return copy.messageTooLong(maxLength);
  }
  final lower = value.toLowerCase();
  const banned = [
    'passport number',
    'visa number',
    'bank account',
    'credit card',
    'medical record',
    'nombor pasport',
    'ভিসা নম্বর',
    'পাসপোর্ট নম্বর',
    'ব্যাংক অ্যাকাউন্ট',
  ];
  if (banned.any(lower.contains)) return copy.privateDataWarning;
  return null;
}

String _formatDate(dynamic value) {
  final date = value is String ? DateTime.tryParse(value)?.toLocal() : null;
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _CommunityCopy {
  const _CommunityCopy(String language) : bangla = language == 'bangla';
  final bool bangla;
  String get community => bangla ? 'কমিউনিটি' : 'Community';
  String get account => bangla ? 'আমার অ্যাকাউন্ট' : 'My account';
  String get stepAccount => bangla ? 'অ্যাকাউন্ট' : 'Account';
  String get stepVerify => bangla ? 'যাচাই' : 'Verify';
  String get stepProfile => bangla ? 'প্রোফাইল' : 'Profile';
  String get welcomeBack => bangla ? 'আবার স্বাগতম' : 'Welcome back';
  String get joinCommunity =>
      bangla ? 'কমিউনিটিতে অংশ নিন' : 'Join the Community';
  String get socialAuthBody => bangla
      ? 'পোস্ট, মন্তব্য ও নিজের কমিউনিটি প্রোফাইলের জন্য একটি ঐচ্ছিক অ্যাকাউন্ট তৈরি করুন।'
      : 'Create an optional account to post, comment, and manage your Community profile.';
  String get signInBody => bangla
      ? 'আপনার যাচাইকৃত অ্যাকাউন্ট দিয়ে নিরাপদে সাইন ইন করুন।'
      : 'Sign in securely with your verified account.';
  String get continueGuest =>
      bangla ? 'অ্যাকাউন্ট ছাড়াই চালিয়ে যান' : 'Continue as guest';
  String get guestAccessMessage => bangla
      ? 'ভিসা, সহায়তা, শেখা ও কমিউনিটি পড়তে কোনো অ্যাকাউন্ট লাগে না।'
      : 'Visa, help, learning, and Community reading never require an account.';
  String get officialUpdates => bangla ? 'অফিসিয়াল আপডেট' : 'OFFICIAL UPDATES';
  String get heroTitle =>
      bangla ? 'কর্মীরা কর্মীদের পাশে।' : 'Workers helping workers.';
  String get heroBody => bangla
      ? 'অ্যাকাউন্ট ছাড়াই কমিউনিটি পড়ুন। পোস্ট, মন্তব্য ও রিপোর্টের জন্য যাচাইকৃত ইমেইল অ্যাকাউন্ট ব্যবহার করুন।'
      : 'Read Community content without an account. Use a verified email account when you want to post, comment, report, or manage your profile.';
  String get safety => bangla
      ? 'পাসপোর্ট বা ভিসা নম্বর, ব্যাংক তথ্য, চিকিৎসা তথ্য, ঠিকানা বা ব্যক্তিগত যোগাযোগের তথ্য শেয়ার করবেন না। কমিউনিটির লেখা সরকারি অভিবাসন, চিকিৎসা বা আইনি পরামর্শ নয়।'
      : 'Do not share passports, visa numbers, bank details, medical information, addresses, or private contact details. Community posts are not official immigration, medical, or legal advice.';
  String get createOrSignIn =>
      bangla ? 'অ্যাকাউন্ট খুলুন বা সাইন ইন করুন' : 'Create or sign in';
  String get writePost => bangla ? 'পোস্ট লিখুন' : 'Write a post';
  String get write => bangla ? 'লিখুন' : 'Write';
  String get noOfficialUpdates =>
      bangla ? 'এখনও কোনো অফিসিয়াল আপডেট নেই' : 'No official updates yet';
  String get officialUpdatesEmpty => bangla
      ? 'যাচাইকৃত অ্যাপ ঘোষণা এখানে দেখা যাবে।'
      : 'Verified app announcements will appear here.';
  String get communityReady =>
      bangla ? 'কমিউনিটি প্রস্তুত' : 'The Community is ready';
  String get communityEmpty => bangla
      ? 'আপনার যাচাইকৃত অ্যাকাউন্ট দিয়ে প্রথম সহায়ক, ব্যক্তিগত তথ্যবিহীন পরামর্শটি শেয়ার করুন।'
      : 'Use a verified account to share the first helpful worker tip without personal data.';
  String get accessUnavailable => bangla
      ? 'আপনার কমিউনিটি অ্যাক্সেস এখন উপলভ্য নয়।'
      : 'Your Community access is currently unavailable.';
  String get email => bangla ? 'ইমেইল' : 'Email';
  String get password => bangla ? 'পাসওয়ার্ড' : 'Password';
  String get createAccount =>
      bangla ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create account';
  String get signIn => bangla ? 'সাইন ইন করুন' : 'Sign in';
  String get authBody => bangla
      ? 'অ্যাকাউন্ট সম্পূর্ণ ঐচ্ছিক। কর্মী সেবা ব্যবহার করতে কোনো সাইন ইন প্রয়োজন নেই। ইমেইল নিশ্চিত করার পর কমিউনিটিতে অংশ নিতে পারবেন।'
      : 'An account is optional. Worker services never require sign-in. Confirm your email before you can participate in the Community.';
  String get passwordHint => bangla
      ? 'কমপক্ষে ৮ অক্ষরের একটি শক্তিশালী পাসওয়ার্ড ব্যবহার করুন।'
      : 'Use a strong password with at least 8 characters.';
  String get passwordStrong =>
      bangla ? 'শক্তিশালী পাসওয়ার্ড' : 'Strong password';
  String get confirmPassword =>
      bangla ? 'পাসওয়ার্ড আবার লিখুন' : 'Confirm password';
  String get passwordsDoNotMatch =>
      bangla ? 'দুটি পাসওয়ার্ড একই নয়।' : 'The two passwords do not match.';
  String get showPassword => bangla ? 'পাসওয়ার্ড দেখান' : 'Show password';
  String get hidePassword => bangla ? 'পাসওয়ার্ড লুকান' : 'Hide password';
  String get forgotPassword =>
      bangla ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot password?';
  String get passwordResetSent => bangla
      ? 'এই ইমেইলে পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে।'
      : 'A password-reset link was sent to this email.';
  String get accountExistsSignIn => bangla
      ? 'এই ইমেইলে আগে থেকেই একটি অ্যাকাউন্ট আছে। সাইন ইন করুন অথবা পাসওয়ার্ড রিসেট করুন।'
      : 'An account already exists for this email. Sign in or reset your password.';
  String get incorrectCredentials => bangla
      ? 'ইমেইল বা পাসওয়ার্ড মেলেনি। সঠিক ইমেইল দিন অথবা পাসওয়ার্ড রিসেট করুন।'
      : 'That email or password does not match. Check it carefully or reset your password.';
  String get emailDeliveryHelp => bangla
      ? 'ইমেইল না পেলে Spam/Junk ফোল্ডার দেখুন। আগে অ্যাকাউন্ট খুলে থাকলে আবার তৈরি না করে সাইন ইন বা পাসওয়ার্ড রিসেট ব্যবহার করুন।'
      : 'If email does not arrive, check Spam/Junk. If you already created an account, use Sign in or password reset instead of creating it again.';
  String get validEmail =>
      bangla ? 'একটি বৈধ ইমেইল লিখুন।' : 'Enter a valid email address.';
  String get passwordRule => bangla
      ? 'পাসওয়ার্ডে কমপক্ষে ৮টি অক্ষর থাকতে হবে।'
      : 'Your password must have at least 8 characters.';
  String get confirmationSent => bangla
      ? 'আপনার ইমেইলে নিশ্চিতকরণ লিংক পাঠানো হয়েছে। লিংকে চাপ দেওয়ার পর আবার সাইন ইন করুন।'
      : 'A confirmation link was sent to your email. Open it, then sign in again.';
  String get accountCreated =>
      bangla ? 'অ্যাকাউন্ট তৈরি হয়েছে।' : 'Account created.';
  String get signedIn => bangla ? 'সাইন ইন হয়েছে।' : 'Signed in.';
  String get haveAccount => bangla
      ? 'আগে থেকেই অ্যাকাউন্ট আছে? সাইন ইন করুন'
      : 'Already have an account? Sign in';
  String get needAccount =>
      bangla ? 'অ্যাকাউন্ট নেই? তৈরি করুন' : 'Need an account? Create one';
  String get pleaseWait => bangla ? 'অপেক্ষা করুন…' : 'Please wait…';
  String get verificationNeeded =>
      bangla ? 'ইমেইল নিশ্চিতকরণ প্রয়োজন' : 'Email confirmation needed';
  String get verificationBody => bangla
      ? 'আপনার ইমেইলের নিশ্চিতকরণ লিংকে চাপ দিন। তারপর অ্যাপে ফিরে এসে সাইন ইন করুন।'
      : 'Open the confirmation link sent to your email, then return to the app and sign in.';
  String get verifyEmailTitle =>
      bangla ? 'আপনার ইমেইল নিশ্চিত করুন' : 'Confirm your email address';
  String get verifyEmailBody => bangla
      ? 'নিচের ইমেইলে একটি নিশ্চিতকরণ লিংক পাঠানো হয়েছে। লিংকে চাপ দিন, তারপর সাইন ইন করুন।'
      : 'A confirmation link was sent to the email below. Open it, then sign in to continue.';
  String get iVerifiedSignIn => bangla
      ? 'আমি নিশ্চিত করেছি — সাইন ইন করুন'
      : 'I verified my email — Sign in';
  String get resendConfirmation =>
      bangla ? 'নিশ্চিতকরণ ইমেইল আবার পাঠান' : 'Resend confirmation email';
  String get verifiedAccount =>
      bangla ? 'যাচাইকৃত অ্যাকাউন্ট' : 'Verified account';
  String get completeProfile =>
      bangla ? 'প্রোফাইল সম্পূর্ণ করুন' : 'Complete profile';
  String get finishProfileBody => bangla
      ? 'প্রথমে কমিউনিটিতে দেখা যাবে এমন নাম ও ছবি বেছে নিন। ব্যক্তিগত তথ্য চাইলে পরে যোগ করতে পারেন।'
      : 'Choose the name and photo people may see in Community. Add private details only if you want to.';
  String get editProfile => bangla ? 'প্রোফাইল সম্পাদনা' : 'Edit profile';
  String get publicProfile =>
      bangla ? 'পাবলিক কমিউনিটি প্রোফাইল' : 'Public Community profile';
  String get publicProfileBody => bangla
      ? 'শুধু আপনার ডিসপ্লে নাম ও বাছাই করা ছবি অন্যরা দেখতে পাবে।'
      : 'Only your display name and optional selected photo can be seen by other Community members.';
  String get privateProfile =>
      bangla ? 'ব্যক্তিগত তথ্য' : 'Private information';
  String get privateProfileBody => bangla
      ? 'জন্মতারিখ, ঠিকানা ও ফোন নম্বর শুধুই আপনার জন্য। এগুলো পোস্ট বা মন্তব্যে দেখানো হবে না।'
      : 'Date of birth, address, and phone are private to you. They never appear on posts or comments.';
  String get profilePhoto => bangla ? 'প্রোফাইল ছবি' : 'Profile photo';
  String get displayName => bangla ? 'ডিসপ্লে নাম' : 'Display name';
  String get displayNameRule => bangla
      ? '৩ থেকে ৩২ অক্ষরের একটি ডিসপ্লে নাম দিন।'
      : 'Choose a display name from 3 to 32 characters.';
  String get dateOfBirth => bangla ? 'জন্মতারিখ' : 'Date of birth';
  String get address => bangla ? 'ঠিকানা' : 'Address';
  String get phone => bangla ? 'ফোন নম্বর' : 'Phone number';
  String get saveProfile => bangla ? 'প্রোফাইল সংরক্ষণ করুন' : 'Save profile';
  String get profileSaved =>
      bangla ? 'প্রোফাইল সংরক্ষণ হয়েছে।' : 'Profile saved.';
  String get privateNotice => bangla
      ? 'পাসওয়ার্ড আমরা পড়ি বা সংরক্ষণ করি না। ইমেইল, জন্মতারিখ, ঠিকানা ও ফোন নম্বর পাবলিক কমিউনিটিতে দেখানো হয় না।'
      : 'We do not read or store your password. Your email, date of birth, address, and phone number are never shown in the public Community.';
  String get requestDeletion => bangla
      ? 'অ্যাকাউন্ট ও কমিউনিটি তথ্য মুছে ফেলার অনুরোধ'
      : 'Request account and Community-data deletion';
  String get deletionBody => bangla
      ? 'অনুরোধটি নিরাপদে পর্যালোচনা করা হবে। নোটে কোনো পরিচয়পত্র বা অ্যাকাউন্ট নম্বর লিখবেন না।'
      : 'Your request will be reviewed securely. Do not include identity documents or account numbers in the note.';
  String get optionalNote => bangla ? 'ঐচ্ছিক নোট' : 'Optional note';
  String get cancel => bangla ? 'বাতিল' : 'Cancel';
  String get deletionSubmitted => bangla
      ? 'মুছে ফেলার অনুরোধ পাঠানো হয়েছে।'
      : 'Deletion request submitted.';
  String get signOut => bangla ? 'সাইন আউট' : 'Sign out';
  String get verifyToParticipate => bangla
      ? 'পোস্ট, মন্তব্য বা রিপোর্ট করার আগে আপনার ইমেইল নিশ্চিত করুন।'
      : 'Confirm your email before posting, commenting, or reporting.';
  String get postHint => bangla
      ? 'সহায়ক ও সম্মানজনক কর্মী পরামর্শ লিখুন…'
      : 'Share a useful, respectful worker tip…';
  String get publish => bangla ? 'পোস্ট প্রকাশ করুন' : 'Publish post';
  String get comments => bangla ? 'মন্তব্য' : 'Comments';
  String get commentHint =>
      bangla ? 'সম্মানজনক মন্তব্য লিখুন…' : 'Write a respectful comment…';
  String get noComments => bangla ? 'এখনও কোনো মন্তব্য নেই' : 'No comments yet';
  String get commentsEmpty => bangla
      ? 'মন্তব্য করলে সম্মানজনক ও সহায়ক থাকুন।'
      : 'Be respectful and helpful if you choose to respond.';
  String get member => bangla ? 'কমিউনিটি সদস্য' : 'Community member';
  String get deleteMine => bangla ? 'আমার লেখা মুছুন' : 'Delete my post';
  String get report => bangla ? 'রিপোর্ট করুন' : 'Report';
  String get blockUser => bangla ? 'ব্যবহারকারী ব্লক করুন' : 'Block user';
  String get reportSubmitted => bangla
      ? 'রিপোর্ট পর্যালোচনার জন্য পাঠানো হয়েছে।'
      : 'Report submitted for review.';
  String get userBlocked =>
      bangla ? 'ব্যবহারকারী ব্লক করা হয়েছে।' : 'User blocked.';
  String get reasonScam => bangla
      ? 'প্রতারক বা বিভ্রান্তিকর তথ্য'
      : 'Scam or misleading information';
  String get reasonHarassment =>
      bangla ? 'হয়রানি বা ঘৃণা' : 'Harassment or hate';
  String get reasonPrivateData =>
      bangla ? 'ব্যক্তিগত তথ্য প্রকাশ' : 'Private information shared';
  String get reasonOther => bangla ? 'অন্যান্য' : 'Other';
  String get writeSomething => bangla
      ? 'প্রকাশ করার আগে কিছু লিখুন।'
      : 'Write something before publishing.';
  String messageTooLong(int max) => bangla
      ? 'বার্তাটি $max অক্ষরের মধ্যে রাখুন।'
      : 'Keep this message under $max characters.';
  String get privateDataWarning => bangla
      ? 'এই বার্তায় সংবেদনশীল ব্যক্তিগত তথ্য থাকতে পারে। পাসপোর্ট, ভিসা বা ব্যাংক তথ্য পোস্ট করবেন না।'
      : 'This message may contain sensitive personal information. Do not post passport, visa, or bank details.';
}
