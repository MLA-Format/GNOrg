import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_shell.dart';

/// Registration page — Flutter port of `web/src/pages/UserReg.tsx`.
///
/// Fields: email, username, password, confirm password.
/// Validates email format and password match before submitting.
/// On success navigates to `/login` (caller handles routing).
class RegisterPage extends StatefulWidget {
  /// Called when the user successfully registers.
  final VoidCallback onSuccess;

  /// Called when the user taps "Sign in".
  final VoidCallback onGoToLogin;

  const RegisterPage({
    super.key,
    required this.onSuccess,
    required this.onGoToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _password1Ctrl = TextEditingController();
  final _password2Ctrl = TextEditingController();

  String _error = '';
  bool _loading = false;

  // Tracks which API error code is currently displayed so field-change listeners
  // can clear only the relevant error (mirrors the web `lastApiError` ref).
  String _apiErrorCode = '';

  static const _errorMessages = {
    'USER_TAKEN': 'That username is already taken.',
    'EMAIL_TAKEN': 'An account with that email already exists.',
    'PASSWORD_TOO_SHORT': 'Password must be at least 8 characters.',
  };

  // ── Validation ─────────────────────────────────────────────────────────────

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Format/mismatch validation. Does not clear active API errors so that
  /// changing the password field doesn't wipe a USER_TAKEN notice.
  void _runFormatValidation() {
    final email = _emailCtrl.text;
    final pw1 = _password1Ctrl.text;
    final pw2 = _password2Ctrl.text;

    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email');
      _apiErrorCode = '';
      return;
    }
    if (pw2.isNotEmpty && pw1 != pw2) {
      setState(() => _error = 'Password mismatch');
      _apiErrorCode = '';
      return;
    }
    if (_apiErrorCode.isEmpty) setState(() => _error = '');
  }

  /// Called when the email field changes — clears EMAIL_TAKEN, then validates.
  void _onEmailChange() {
    if (_apiErrorCode == 'EMAIL_TAKEN') {
      setState(() => _error = '');
      _apiErrorCode = '';
    }
    _runFormatValidation();
  }

  /// Called when the username field changes — clears USER_TAKEN.
  void _onUsernameChange() {
    if (_apiErrorCode == 'USER_TAKEN') {
      setState(() => _error = '');
      _apiErrorCode = '';
    }
  }

  // ── Password confirm field border colour ───────────────────────────────────

  Color? get _confirmBorderColor {
    final pw1 = _password1Ctrl.text;
    final pw2 = _password2Ctrl.text;
    if (pw2.isEmpty) return null;
    return pw1 == pw2 ? const Color(0xFFE8F56E) : const Color(0xFFF87171);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    _runFormatValidation();
    if (_error.isNotEmpty) return;

    setState(() => _loading = true);

    final err = await AuthService.register(
      email: _emailCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _password1Ctrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      if (_errorMessages.containsKey(err)) {
        _apiErrorCode = err;
        setState(() => _error = _errorMessages[err]!);
      } else {
        _apiErrorCode = '';
        setState(() => _error = err);
      }
    } else {
      widget.onSuccess();
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChange);
    _usernameCtrl.addListener(_onUsernameChange);
    _password1Ctrl.addListener(_runFormatValidation);
    _password2Ctrl.addListener(_runFormatValidation);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _password1Ctrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          title: 'Create account',
          subtitle: 'Fill in your details to get started',
          children: [
            // Fields
            AuthField(
              label: 'Email',
              controller: _emailCtrl,
              placeholder: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              maxLength: 254,
            ),
            const SizedBox(height: 16),

            AuthField(
              label: 'Username',
              controller: _usernameCtrl,
              placeholder: 'your_username',
              maxLength: 30,
            ),
            const SizedBox(height: 16),

            AuthField(
              label: 'Password',
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

            // Error banner
            if (_error.isNotEmpty) ...[
              ErrorBanner(message: _error),
              const SizedBox(height: 20),
            ],

            // Submit button
            AuthButton(
              label: 'Create Account',
              onPressed: _handleSubmit,
              loading: _loading,
            ),
            const SizedBox(height: 20),

            // Footer link
            AuthLink(
              prefix: 'Already have an account?  ',
              linkLabel: 'Sign in',
              onTap: widget.onGoToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
