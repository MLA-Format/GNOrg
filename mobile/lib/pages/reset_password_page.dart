import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';

/// Reset-password page — Flutter port of `web/src/pages/ResetPassword.tsx`.
///
/// Accepts the [resetToken] from the deep-link URL parameter, validates the
/// two password fields, then POSTs to /api/reset-password/:token.
/// On success starts a 5-second countdown then calls [onSuccess].
class ResetPasswordPage extends StatefulWidget {
  /// The JWT reset token from the email link (`:token` route param).
  final String resetToken;

  /// Called after the 5-second countdown on success (navigate to login).
  final VoidCallback onSuccess;

  /// Called when the user taps "Back to sign in".
  final VoidCallback onGoToLogin;

  const ResetPasswordPage({
    super.key,
    required this.resetToken,
    required this.onSuccess,
    required this.onGoToLogin,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password1Ctrl = TextEditingController();
  final _password2Ctrl = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _success = false;
  int _countdown = 5;
  Timer? _countdownTimer;

  // ── Init / Dispose ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Rebuild on each keystroke so the confirm-field border updates live.
    _password1Ctrl.addListener(() => setState(() {}));
    _password2Ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password1Ctrl.dispose();
    _password2Ctrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Confirm-field border colour ────────────────────────────────────────────

  Color? get _confirmBorderColor {
    final pw2 = _password2Ctrl.text;
    if (pw2.isEmpty) return null;
    return _password1Ctrl.text == pw2
        ? const Color(0xFFE8F56E)
        : const Color(0xFFF87171);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (_password1Ctrl.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (_password1Ctrl.text != _password2Ctrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _error = '';
      _loading = true;
    });

    final err = await AuthService.resetPassword(
      token: widget.resetToken,
      password: _password1Ctrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() => _success = true);
      _startCountdown();
    }
  }

  // ── 5-second redirect countdown ────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        widget.onSuccess();
        return;
      }
      setState(() => _countdown--);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Set new password',
          subtitle: 'Choose a new password for your account',
          children: [
            if (_success) ...[
              StatusBanner(
                type: StatusType.success,
                message:
                    'Password updated! Returning to sign in in ${_countdown}s...',
              ),
              const SizedBox(height: 20),
              AuthLink(
                linkLabel: 'Back to sign in',
                onTap: widget.onGoToLogin,
              ),
            ] else ...[
              AuthField(
                label: 'New Password',
                controller: _password1Ctrl,
                placeholder: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 16),
              AuthField(
                label: 'Confirm Password',
                controller: _password2Ctrl,
                placeholder: '••••••••',
                obscure: true,
                borderColor: _confirmBorderColor,
                onEditingComplete: _handleSubmit,
              ),
              const SizedBox(height: 20),
              if (_error.isNotEmpty) ...[
                ErrorBanner(message: _error),
                const SizedBox(height: 20),
              ],
              AuthButton(
                label: 'Reset password',
                onPressed: _handleSubmit,
                loading: _loading,
              ),
              const SizedBox(height: 20),
              AuthLink(
                prefix: 'Remember your password?  ',
                linkLabel: 'Sign in',
                onTap: widget.onGoToLogin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
