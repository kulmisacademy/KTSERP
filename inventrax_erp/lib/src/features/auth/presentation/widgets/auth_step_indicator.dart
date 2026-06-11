import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/kulmis_auth_theme.dart';

/// Multi-step registration progress indicator.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (i) {
            final active = i <= currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < steps.length - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: active
                      ? KulmisAuthTheme.teal
                      : KulmisAuthTheme.borderLight,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(steps.length, (i) {
            final active = i == currentStep;
            final done = i < currentStep;
            return Expanded(
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? KulmisAuthTheme.textDark
                      : KulmisAuthTheme.textMuted,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
