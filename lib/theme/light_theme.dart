// theme/light_theme.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/dynamic_theme_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData light({Color? color}) {
  // Default colors
  Color primaryColor = color ?? const Color(0xFF002e80);
  Color secondaryColor = const Color(0xFF002e80);
  Color backgroundColor = const Color(0xFFFFFFFF);
  Color textColor = const Color(0xFF4f14f0);
  Color buttonColor = const Color(0xFF002e80);
  Color buttonTextColor = const Color(0xFFFFFFFF);
  Color navbarColor = const Color(0xFF002e80);
  Color navbarTextColor = const Color(0xFFFFFFFF);

  try {
    if (Get.isRegistered<DynamicThemeController>()) {
      final themeController = Get.find<DynamicThemeController>();
      if (themeController.isThemeLoaded) {
        primaryColor = themeController.primaryColor;
        secondaryColor = themeController.secondaryColor;
        backgroundColor = themeController.backgroundColor;
        textColor = themeController.textColor;
        buttonColor = themeController.buttonColor;
        buttonTextColor = themeController.buttonTextColor;
        navbarColor = themeController.navbarColor;
        navbarTextColor = themeController.navbarTextColor;

        print('====> 🎨 Using API Theme Colors:');
        print('       Primary: ${primaryColor.value.toRadixString(16)}');
        print('       Secondary: ${secondaryColor.value.toRadixString(16)}');
        print('       Button: ${buttonColor.value.toRadixString(16)}');
      } else {
        print('====> ℹ️ Using Default Colors');
      }
    }
  } catch (e) {
    print('====> ⚠️ DynamicTheme not available, using defaults');
  }

  return ThemeData(
    fontFamily: AppConstants.fontFamily,
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    disabledColor: const Color(0xFF9F9F9F),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    cardColor: backgroundColor,
    shadowColor: Colors.black.withValues(alpha: 0.03),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: buttonColor),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    )
        .copyWith(surface: backgroundColor)
        .copyWith(error: const Color(0xFFE84D4F)),
    popupMenuTheme: PopupMenuThemeData(
      color: backgroundColor,
      surfaceTintColor: backgroundColor,
    ),
    dialogTheme: DialogThemeData(surfaceTintColor: backgroundColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
      backgroundColor: buttonColor,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      surfaceTintColor: Colors.white,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: navbarColor,
      foregroundColor: navbarTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: navbarTextColor),
      titleTextStyle: TextStyle(
        color: navbarTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0.2,
      color: Color(0xFFA0A4A8),
    ),
    tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
    ),
  );
}
