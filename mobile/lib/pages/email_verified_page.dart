import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';

/// Email verification page — Flutter port of `web/src/pages/EmailVerified.tsx`.
///
/// Accepts the [verificationToken] extracted from the deep-link / URL parameter.
/// States: loading → success (5 s countdown then [onSuccess]) or error.
class EmailVerifiedPage extends StatefulWidget {
  /// The JWT verification token from the email link (`:token` route param).
  final String verificationToken;

  /// Called after the 5-second countdown on success (navigate to login/dashboard).
  final VoidCallback onSuccess;

  /// Called when the user taps "Back to sign in".
  final VoidCallback onGoToLogin;

  const EmailVerifiedPage({
    super.key,
    required this.verificationToken,
    required this.onSuccess,
    required this.onGoToLogin,
  });

  @override
  State<EmailVerifiedPage> createState() => _EmailVerifiedPageState();
}

enum _Status { loading, success, error }

class _EmailVerifiedPageState extends State<EmailVerifiedPage> {
  _Status _status = _Status.loading;
  int _countdown = 5;
  Timer? _countdownTimer;

  // ── Verify on mount ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final err = await AuthService.verifyEmail(widget.verificationToken);
    if (!mounted) return;

    if (err == null) {
      setState(() => _status = _Status.success);
      _startCountdown();
    } else {
      setState(() => _status = _Status.error);
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

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Email verification',
          subtitle: 'Verifying your account, please wait',
          children: [
            // Status banner
            if (_status == _Status.loading)
              const StatusBanner(
                type: StatusType.loading,
                message: 'Verifying your email...',
              ),

            if (_status == _Status.success)
              StatusBanner(
                type: StatusType.success,
                message: 'Email verified! Redirecting to dashboard in ${_countdown}s...',
              ),

            if (_status == _Status.error)
              const ErrorBanner(
                message: 'Invalid or expired verification link.',
              ),

            const SizedBox(height: 20),

            // Back to sign in link
            AuthLink(
              linkLabel: 'Back to sign in',
              onTap: widget.onGoToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
