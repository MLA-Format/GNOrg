import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Login page — Flutter port of `web/src/pages/login.tsx`.
///
/// Checks for a stored valid JWT on mount; if found, skips login.
/// On success stores the token and invokes [onSuccess].
class LoginPage extends StatefulWidget {
  /// Called when login succeeds (navigate to dashboard).
  final VoidCallback onSuccess;

  /// Called when user taps "Create one" (navigate to register).
  final VoidCallback onGoToRegister;

  /// Called when user taps "Forgot password?".
  final VoidCallback onForgotPassword;

  const LoginPage({
    super.key,
    required this.onSuccess,
    required this.onGoToRegister,
    required this.onForgotPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _error = '';
  bool _loading = false;

  // ── Auto-redirect if already authenticated ─────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await AuthService.getValidToken();
    if (!mounted) return;
    if (token != null) widget.onSuccess();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    setState(() {
      _error = '';
      _loading = true;
    });

    final err = await AuthService.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      widget.onSuccess();
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Welcome back',
          subtitle: 'Sign in to continue to your account',
          children: [
            // Username field
            AuthField(
              label: 'Username',
              controller: _usernameCtrl,
              placeholder: 'your_username',
            ),
            const SizedBox(height: 16),

            // Password field with "Forgot password?" row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PASSWORD',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD1D5DB),
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onForgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppColors.lime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AuthField(
                  label: '',          // label rendered above in the Row
                  controller: _passwordCtrl,
                  placeholder: '••••••••',
                  obscure: true,
                  onEditingComplete: _handleSubmit,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Error banner
            if (_error.isNotEmpty) ...[
              ErrorBanner(message: _error),
              const SizedBox(height: 20),
            ],

            // Submit button
            AuthButton(
              label: 'Sign in',
              onPressed: _handleSubmit,
              loading: _loading,
            ),
            const SizedBox(height: 20),

            // Footer link
            AuthLink(
              prefix: "Don't have an account?  ",
              linkLabel: 'Create one',
              onTap: widget.onGoToRegister,
            ),
          ],
        ),
      ),
    );
  }
}
