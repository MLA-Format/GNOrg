import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';
import '../theme.dart';

/// "New password" page — Flutter port of `web/src/pages/ResetPassword.tsx`.
///
/// Receives the [resetToken] from a deep-link URL parameter
/// (`/reset-password/:token`). On success counts down 5 s then calls [onSuccess].
class ResetPasswordPage extends StatefulWidget {
  final String resetToken;
  final VoidCallback onSuccess;
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
  final _pw1Ctrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _success = false;
  int _countdown = 5;
  Timer? _timer;

  // ── Validation ─────────────────────────────────────────────────────────────

  void _onPw2Changed() {
    if (_pw2Ctrl.text.isNotEmpty && _pw1Ctrl.text != _pw2Ctrl.text) {
      if (_error != 'Password mismatch') setState(() => _error = 'Password mismatch');
    } else {
      if (_error == 'Password mismatch') setState(() => _error = '');
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (_error.isNotEmpty || _pw1Ctrl.text.isEmpty || _pw1Ctrl.text != _pw2Ctrl.text) return;

    setState(() {
      _error = '';
      _loading = true;
    });

    final err = await AuthService.resetPassword(
      token: widget.resetToken,
      password: _pw1Ctrl.text,
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

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countdown <= 1) { t.cancel(); widget.onSuccess(); return; }
      setState(() => _countdown--);
    });
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pw2Ctrl.addListener(_onPw2Changed);
    _pw1Ctrl.addListener(_onPw2Changed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pw1Ctrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'New password',
          subtitle: 'Choose a strong password for your account',
          children: [
            if (_success) ...[
              StatusBanner(
                type: StatusType.success,
                message: 'Password reset successful. Redirecting to login in ${_countdown}s...',
              ),
            ] else ...[
              // New password field
              AuthField(
                label: 'New Password',
                controller: _pw1Ctrl,
                placeholder: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 16),

              // Confirm password field — border changes colour to signal match/mismatch
              _ConfirmField(
                controller: _pw2Ctrl,
                pw1: _pw1Ctrl.text,
                onEditingComplete: _handleSubmit,
              ),
              const SizedBox(height: 20),

              if (_error.isNotEmpty) ...[
                ErrorBanner(message: _error),
                const SizedBox(height: 20),
              ],

              AuthButton(
                label: 'Reset Password',
                onPressed: _handleSubmit,
                loading: _loading,
              ),
            ],

            const SizedBox(height: 20),

            AuthLink(
              prefix: 'Remembered it?  ',
              linkLabel: 'Sign in',
              onTap: widget.onGoToLogin,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm-password field with live border colour ─────────────────────────────

class _ConfirmField extends StatefulWidget {
  final TextEditingController controller;
  final String pw1;
  final VoidCallback? onEditingComplete;

  const _ConfirmField({
    required this.controller,
    required this.pw1,
    this.onEditingComplete,
  });

  @override
  State<_ConfirmField> createState() => _ConfirmFieldState();
}

class _ConfirmFieldState extends State<_ConfirmField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    Color borderColor;
    if (text.isEmpty) {
      borderColor = Colors.white.withOpacity(0.125);
    } else if (text == widget.pw1) {
      borderColor = AppColors.lime;
    } else {
      borderColor = const Color(0xFFF87171);
    }

    return AuthField(
      label: 'Confirm Password',
      controller: widget.controller,
      placeholder: '••••••••',
      obscure: true,
      borderColor: borderColor,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
