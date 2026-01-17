import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumora/theme/app_theme.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Health App",

      theme: ThemeData(
        brightness: Brightness.dark,

        // 🌌 Global background
        scaffoldBackgroundColor: AppTheme.bg,

        // ✍️ Global font
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),

        // 🎨 Primary color
        colorScheme: ColorScheme.dark(
          primary: AppTheme.primary,
          secondary: AppTheme.primary,
          background: AppTheme.bg,
          surface: AppTheme.cardBg,
          error: AppTheme.danger,
        ),

        // 🔝 AppBar styling
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTheme.h2,
          iconTheme: AppTheme.iconMuted,
        ),

        // 🔘 Elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButton,
        ),

        // 👻 Outlined / ghost buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppTheme.ghostButton,
        ),

        // ✍️ Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.cardBgAlt,
          labelStyle: AppTheme.caption,
          border: OutlineInputBorder(
            borderRadius: AppTheme.radiusMedium,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTheme.radiusMedium,
            borderSide: BorderSide(color: AppTheme.borderSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.radiusMedium,
            borderSide: BorderSide(color: AppTheme.primary),
          ),
        ),

        // ☑️ Switch theme
        switchTheme: AppTheme.switchTheme,

        // 🔲 Icons
        iconTheme: AppTheme.iconMuted,

        // 🧱 Divider
        dividerTheme: DividerThemeData(
          color: AppTheme.borderSoft,
          thickness: 1,
          space: 32,
        ),
      ),

      home: const MainScreen(), // ✅ Entry point
    );
  }
}
