import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KULMIS ERP premium authentication palette (reference design).
abstract final class KulmisAuthTheme {
  static const navy = Color(0xFF041F4A);
  static const teal = Color(0xFF19D3B4);
  static const deepCyan = Color(0xFF0B5D6B);
  static const softBg = Color(0xFFF4F7FB);
  static const formBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const inputPlaceholder = Color(0xFF94A3B8);
  static const inputIcon = Color(0xFF7C8DA5);
  static const textSoftOnDark = Color(0xB3FFFFFF);
  static const borderLight = Color(0xFFE2E8F0);
  static const inputFill = Color(0xFFF8FAFC);
  static const glassFill = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x24FFFFFF);

  static const systemName = 'KULMIS ERP';
  static const shortName = 'KULMIS';

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, Color(0xFF062A52), deepCyan],
    stops: [0.0, 0.55, 1.0],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF14C9A8), teal],
  );

  static List<BoxShadow> get inputShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: navy.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static TextStyle headingOnDark({double size = 42}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.8,
        color: Colors.white,
      );

  static TextStyle bodyOnDark({double size = 15}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: textSoftOnDark,
      );

  static TextStyle formTitle() => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.5,
        color: textDark,
      );

  static TextStyle formSubtitle() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textMuted,
      );

  static TextStyle inputLabel() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDark,
      );

  static TextStyle inputHint() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: inputPlaceholder,
        height: 1.35,
      );

  static TextStyle inputValue() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.35,
      );
}
