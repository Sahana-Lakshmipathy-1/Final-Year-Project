import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /* ============================================================
   🎯 COLOR SYSTEM (Dark-first wellness UI)
  ============================================================ */

  static const Color bg = Color(0xFF0D0D25);

  static const Color cardBg = Color(0xFF151533);
  static const Color cardBgAlt = Color(0xFF2A2A4A);

  static const Color primary = Color(0xFF6C63FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  static const Color textWhite = Color(0xFFEFEFFF);
  static const Color textGrey = Color(0xFFB3B3C3);
  static const Color textMuted = Color(0xFF8E8EA9);
  static const Color textDark = Color(0xFF1A1034);

  static const Color borderSoft = Color(0x1AFFFFFF);

  /* ============================================================
   🌈 GRADIENTS
  ============================================================ */

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF8B6BFF),
    ],
  );

  /* ============================================================
   🧱 RADIUS SYSTEM (Design tokens)
  ============================================================ */

  static final BorderRadius radiusXS = BorderRadius.circular(8);
  static final BorderRadius radiusSmall = BorderRadius.circular(10);
  static final BorderRadius radiusMedium = BorderRadius.circular(16);
  static final BorderRadius radiusLarge = BorderRadius.circular(24);
  static final BorderRadius radiusXL = BorderRadius.circular(28);

  /* ============================================================
   🌫 SHADOWS
  ============================================================ */

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /* ============================================================
   🧩 SURFACE DECORATIONS
  ============================================================ */

  static BoxDecoration card = BoxDecoration(
    color: cardBg,
    borderRadius: radiusMedium,
    border: Border.all(color: borderSoft),
  );

  static BoxDecoration elevatedCard = BoxDecoration(
    gradient: const LinearGradient(
      colors: [cardBgAlt, cardBg],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: radiusLarge,
    border: Border.all(color: borderSoft),
    boxShadow: softShadow,
  );

  /* ============================================================
   ✍️ TYPOGRAPHY SYSTEM (Outfit)
  ============================================================ */

  // Hero / Page titles
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textWhite,
    height: 1.2,
  );

  /// Section headers (e.g. "Quick actions", "Explore")
  static TextStyle sectionTitle = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textWhite,
    letterSpacing: 0.2,
  );

  // Section titles (dark background)
  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textWhite,
  );

  // Section titles (light surface / gradient cards)
  static TextStyle h2Dark = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textDark,
  );

  // Card titles / emphasis
  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textWhite,
  );

  // Standard body
  static TextStyle body = GoogleFonts.outfit(
    fontSize: 16,
    color: textWhite,
  );

  // Body on light surface
  static TextStyle bodyDark = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  // Secondary text
  static TextStyle bodyMuted = GoogleFonts.outfit(
    fontSize: 14,
    color: textGrey,
  );

  // Small meta
  static TextStyle caption = GoogleFonts.outfit(
    fontSize: 12,
    color: textMuted,
    fontWeight: FontWeight.w600,
  );

  // CTA text on bright buttons
  static TextStyle ctaDark = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: textDark,
    letterSpacing: 0.3,
  );

  /* ============================================================
   🔘 BUTTON STYLES
  ============================================================ */

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textWhite,
    shape: RoundedRectangleBorder(borderRadius: radiusMedium),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    elevation: 6,
  );

  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: danger,
    foregroundColor: textWhite,
    shape: RoundedRectangleBorder(borderRadius: radiusMedium),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );

  static ButtonStyle ghostButton = OutlinedButton.styleFrom(
    foregroundColor: textWhite,
    side: BorderSide(color: borderSoft),
    shape: RoundedRectangleBorder(borderRadius: radiusMedium),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );

  /* ============================================================
   ✍️ INPUTS & FORMS
  ============================================================ */

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: caption,
      filled: true,
      fillColor: cardBgAlt,
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: primary),
      ),
    );
  }

  /* ============================================================
   ☑️ SWITCH / CHECKBOX
  ============================================================ */

  static SwitchThemeData switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.all(textWhite),
    trackColor: MaterialStateProperty.resolveWith(
      (states) => states.contains(MaterialState.selected) ? primary : textMuted,
    ),
  );

  /* ============================================================
   ⏳ LOADERS
  ============================================================ */

  static Widget loader({double size = 32}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: primary,
      ),
    );
  }

  /* ============================================================
   🏷 CHIPS / TAGS
  ============================================================ */

  static Chip chip(String label, {Color? color}) {
    final c = color ?? primary;
    return Chip(
      label: Text(label, style: caption.copyWith(color: c)),
      backgroundColor: c.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: radiusSmall),
    );
  }

  /* ============================================================
   🧱 DIVIDERS
  ============================================================ */

  static Divider divider = Divider(
    color: borderSoft,
    thickness: 1,
    height: 32,
  );

  /* ============================================================
   🔲 ICON THEMES
  ============================================================ */

  static IconThemeData iconPrimary = const IconThemeData(
    color: primary,
    size: 24,
  );

  static IconThemeData iconMuted = const IconThemeData(
    color: textMuted,
    size: 22,
  );

  /* ============================================================
   📭 EMPTY STATES
  ============================================================ */

  static Widget emptyState({
    required String title,
    required String subtitle,
    IconData icon = Icons.inbox,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: textMuted),
        const SizedBox(height: 16),
        Text(title, style: h2),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: bodyMuted,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
