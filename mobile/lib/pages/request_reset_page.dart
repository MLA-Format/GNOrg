import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';

/// Request-password-reset page — Flutter port of `web/src/pages/RequestReset.tsx`.
///
/// Accepts an email address, POSTs to /api/request-password-reset, and shows
/// a success message regardless of whether the email exists (mirrors the web's
/// anti-enumeration behaviour).
class RequestResetPage extends StatefulWidget {
  /// Called when the user taps "Sign in".
  final VoidCallback onGoToLogin;

  const RequestResetPage({super.key, required this.onGoToLogin});

  @override
  State<RequestResetPage> createState() => _RequestResetPageState();
}

class _RequestResetPageState extends State<RequestResetPage> {
  final _emailCtrl = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _sent = false;

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }

    setState(() {
      _error = '';
      _loading = true;
    });

    final err = await AuthService.requestPasswordReset(email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() => _sent = true);
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Reset password',
          subtitle: 'Enter your email to receive a reset link',
          children: [
            if (_sent) ...[
              const StatusBanner(
                type: StatusType.success,
                message:
                    'If that email is registered, a reset link is on its way.',
              ),
              const SizedBox(height: 20),
            ] else ...[
              AuthField(
                label: 'Email',
                controller: _emailCtrl,
                placeholder: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: _handleSubmit,
              ),
              const SizedBox(height: 20),
              if (_error.isNotEmpty) ...[
                ErrorBanner(message: _error),
                const SizedBox(height: 20),
              ],
              AuthButton(
                label: 'Send reset link',
                onPressed: _handleSubmit,
                loading: _loading,
              ),
              const SizedBox(height: 20),
            ],
            AuthLink(
              prefix: 'Remember your password?  ',
              linkLabel: 'Sign in',
              onTap: widget.onGoToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
