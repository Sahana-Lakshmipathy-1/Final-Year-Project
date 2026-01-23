import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumora/theme/app_theme.dart';

// 1. Import BOTH pages
import 'package:lumora/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lumora Wellness",

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.bg,
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppTheme.primary,
          secondary: AppTheme.primary,
          background: AppTheme.bg,
          surface: AppTheme.cardBg,
          error: AppTheme.danger,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTheme.h2,
          iconTheme: AppTheme.iconMuted,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppTheme.ghostButton,
        ),
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
        switchTheme: AppTheme.switchTheme,
        iconTheme: AppTheme.iconMuted,
        dividerTheme: DividerThemeData(
          color: AppTheme.borderSoft,
          thickness: 1,
          space: 32,
        ),
      ),

      // -----------------------------------------------------------
      // 🚀 ENTRY POINT
      // -----------------------------------------------------------
      // Start at LoginPage.
      // Once they log in, we push them to MainScreen (which has the Navbar).
      home: const LoginPage(),

      // OR: Use this temporarily if you want to skip login during dev:
      // home: const MainScreen(),
    );
  }
}
