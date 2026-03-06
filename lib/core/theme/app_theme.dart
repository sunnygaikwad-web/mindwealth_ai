import 'package:flutter/cupertino.dart';
import 'package:mindwealth_ai/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBg,
    barBackgroundColor: AppColors.darkBg.withAlpha(240),
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.darkText,
      textStyle: GoogleFonts.poppins(color: AppColors.darkText, fontSize: 16),
      navTitleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      navLargeTitleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkText,
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
      tabLabelTextStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  static CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBg,
    barBackgroundColor: AppColors.lightBg.withAlpha(240),
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.lightText,
      textStyle: GoogleFonts.poppins(color: AppColors.lightText, fontSize: 16),
      navTitleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      navLargeTitleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightText,
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
      tabLabelTextStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
