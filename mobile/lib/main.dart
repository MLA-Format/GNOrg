import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/email_verified_page.dart';

void main() {
  runApp(const GNOrgApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(
        onSuccess: () => context.go('/dashboard'),
        onGoToRegister: () => context.go('/register'),
        onForgotPassword: () => context.go('/reset-login'),
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(
        onSuccess: () => context.go('/login'),
        onGoToLogin: () => context.go('/login'),
      ),
    ),
    GoRoute(
      path: '/verify-email/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return EmailVerifiedPage(
          verificationToken: token,
          onSuccess: () => context.go('/login'),
          onGoToLogin: () => context.go('/login'),
        );
      },
    ),
    // Placeholder routes referenced by the auth pages:
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const _PlaceholderPage(label: 'Dashboard'),
    ),
    GoRoute(
      path: '/reset-login',
      builder: (context, state) => const _PlaceholderPage(label: 'Reset Password'),
    ),
  ],
);

class GNOrgApp extends StatelessWidget {
  const GNOrgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GNOrg',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}

/// Temporary placeholder for routes not yet implemented.
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
