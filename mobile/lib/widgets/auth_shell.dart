import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// The full-screen diagonal gradient background used on every auth page.
/// Mirrors the web CSS linear-gradient(120deg, #e8f56e 0% … #0a0f2e 100%).
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.lime,
            AppColors.lime,
            AppColors.limePale,
            AppColors.limePale,
            Color(0xFFF7FCD0),
            Color(0xFFF7FCD0),
            Colors.white,
            Colors.white,
            Color(0xFFC0C8D8),
            Color(0xFFC0C8D8),
            Color(0xFF7080A0),
            Color(0xFF7080A0),
            AppColors.navy,
            AppColors.navy,
          ],
          stops: [0.0, 0.70, 0.70, 0.72, 0.72, 0.74, 0.74, 0.76, 0.76, 0.78, 0.78, 0.80, 0.80, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

/// The dark card that holds auth form content.
/// Equivalent to the web `NewAuthCard` component.
class AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback? onSubmit;

  const AuthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      // Shift slightly left to match `md:pr-[30%]` — card sits in lime zone.
      alignment: const Alignment(-0.4, 0.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder — matches the web `w-10 h-10 rounded-md` box.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.125)),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: const Color(0xFFD1D5DB),
                ),
              ),
              const SizedBox(height: 24),

              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled text-field row used for every input in the auth forms.
class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String placeholder;
  final TextInputType keyboardType;
  final Color? borderColor;
  final VoidCallback? onEditingComplete;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.placeholder = '',
    this.keyboardType = TextInputType.text,
    this.borderColor,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD1D5DB),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onEditingComplete: onEditingComplete,
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: Colors.white),
          cursorColor: AppColors.lime,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: AppColors.inputDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Colors.white.withOpacity(0.125),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.lime,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lime CTA button matching `bg-[#e8f56e]` web style.
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          disabledBackgroundColor: AppColors.lime.withOpacity(0.5),
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.navy,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.navy,
                ),
              ),
      ),
    );
  }
}

/// Red error banner matching web `NewErrorBanner`.
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF87171).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF87171).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: const Color(0xFFF87171),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status banner for loading / success states matching web `NewStatusBanner`.
enum StatusType { loading, success }

class StatusBanner extends StatelessWidget {
  final StatusType type;
  final String message;

  const StatusBanner({super.key, required this.type, required this.message});

  @override
  Widget build(BuildContext context) {
    final isLoading = type == StatusType.loading;
    final color = isLoading ? const Color(0xFFD1D5DB) : AppColors.lime;
    final bgColor = isLoading ? Colors.white.withOpacity(0.03) : AppColors.lime.withOpacity(0.08);
    final borderColor = isLoading ? Colors.white.withOpacity(0.08) : AppColors.lime.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.lime,
              ),
            )
          else
            const Icon(Icons.check_circle_outline, color: AppColors.lime, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline link text matching `text-[#e8f56e]` anchor style.
class AuthLink extends StatelessWidget {
  final String prefix;
  final String linkLabel;
  final VoidCallback onTap;

  const AuthLink({
    super.key,
    this.prefix = '',
    required this.linkLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          if (prefix.isNotEmpty)
            Text(
              prefix,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: const Color(0xFFD1D5DB),
              ),
            ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppColors.lime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
