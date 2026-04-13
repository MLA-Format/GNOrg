import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';

/// "Forgot password" page — Flutter port of `web/src/pages/RequestReset.tsx`.
///
/// User enters their email; on success shows a confirmation banner.
class RequestResetPage extends StatefulWidget {
  /// Called when user taps "Sign in".
  final VoidCallback onGoToLogin;

  const RequestResetPage({super.key, required this.onGoToLogin});

  @override
  State<RequestResetPage> createState() => _RequestResetPageState();
}

class _RequestResetPageState extends State<RequestResetPage> {
  final _emailCtrl = TextEditingController();

  String _error = '';
  bool _loading = false;
  bool _submitted = false;

  Future<void> _handleSubmit() async {
    setState(() {
      _error = '';
      _loading = true;
    });

    final err = await AuthService.requestPasswordReset(
      email: _emailCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() => _submitted = true);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Reset password',
          subtitle: "Enter your email and we'll send you a reset link",
          children: [
            if (_submitted) ...[
              const StatusBanner(
                type: StatusType.success,
                message: 'Reset link sent — check your inbox.',
              ),
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
                label: 'Send Reset Link',
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
