import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/email_verified_page.dart';
import 'pages/request_reset_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/dashboard_page.dart';

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
    GoRoute(
      path: '/reset-login',
      builder: (context, state) => RequestResetPage(
        onGoToLogin: () => context.go('/login'),
      ),
    ),
    GoRoute(
      path: '/reset-password/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return ResetPasswordPage(
          resetToken: token,
          onSuccess: () => context.go('/login'),
          onGoToLogin: () => context.go('/login'),
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardPage(
        onSignOut: () => context.go('/login'),
      ),
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
