import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.light100,
      primaryColor: AppColors.violet100,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.violet100,
        // onPrimary: AppColors.textDark,
        // surface: AppColors.cardBackground,
        // onSurface: AppColors.violet100,
        // error: AppColors.error,
        onError: Colors.white,
        onPrimary: AppColors.light100,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            displayMedium: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            headlineSmall: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            bodyMedium: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            headlineLarge: GoogleFonts.inter(
              color: AppColors.dark25,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            headlineMedium: GoogleFonts.inter(
              color: AppColors.dark25,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            labelLarge: GoogleFonts.inter(
              color: AppColors.dark75,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light100,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark75),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.dark75,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light40,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.dark75, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.light20, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.light20, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.violet100, width: 0.9),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.violet100;
          }
          return AppColors.light20;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.violet100, width: 0.9),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dark25,
        thickness: 1,
        space: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.violet100.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.violet100;
          }
          return Colors.white;
        }),

        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade200;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.violet100.withValues(alpha: 0.5);
          }
          return AppColors.violet20;
        }),

        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.transparent;
        }),
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.light100),
      dropdownMenuTheme: DropdownMenuThemeData(
        
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.light20
      )
    );
  }
}
