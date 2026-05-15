import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository_interface.dart';

class DynamicThemeController extends GetxController implements GetxService {
  final AuthRepositoryInterface authRepositoryInterface;

  DynamicThemeController({required this.authRepositoryInterface});

  Color _primaryColor = const Color(0xFF002e80);
  Color _secondaryColor = const Color(0xFF002e80);
  Color _backgroundColor = const Color(0xFFFFFFFF);
  Color _textColor = const Color(0xFF002e80);
  Color _buttonColor = const Color(0xFF002e80);
  Color _buttonTextColor = const Color(0xFFFFFFFF);
  Color _navbarColor = const Color(0xFF002e80);
  Color _navbarTextColor = const Color(0xFFFFFFFF);

  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get textColor => _textColor;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  Color get navbarColor => _navbarColor;
  Color get navbarTextColor => _navbarTextColor;

  bool _isThemeLoaded = false;
  bool get isThemeLoaded => _isThemeLoaded;

  @override
  void onInit() {
    super.onInit();
    loadThemeFromStorage();
  }

  Future<void> loadThemeFromStorage() async {
    try {
      String clientThemesJson =
          await authRepositoryInterface.getClientAppThemes();

      if (clientThemesJson.isNotEmpty &&
          clientThemesJson != '[]' &&
          clientThemesJson != 'null') {
        print('====> 🔍 Checking Client API Theme (Priority 1)...');

        List<dynamic> themes = jsonDecode(clientThemesJson);
        if (themes.isNotEmpty) {
          // Try to find an active theme that actually has color codes
          var targetTheme = themes.firstWhere(
            (theme) {
              var colorCodes = theme['color_codes'] ?? theme['colorCodes'];
              return theme['status'] == 'active' &&
                  colorCodes != null &&
                  colorCodes.isNotEmpty;
            },
            orElse: () => null,
          );

          if (targetTheme != null) {
            _applyTheme(targetTheme);
            _isThemeLoaded = true;
            update();
            print('====> ✅ Client API Theme Applied! (Priority 1)');
            return;
          } else {
            print(
                '====> ⚠️ Found active themes but none with color codes in Priority 1');
          }
        }
      }

      String loginThemesJson = await authRepositoryInterface.getAppThemes();

      if (loginThemesJson.isNotEmpty &&
          loginThemesJson != '[]' &&
          loginThemesJson != 'null') {
        print('====> 🔍 Checking Login Theme (Priority 2)...');

        List<dynamic> themes = jsonDecode(loginThemesJson);
        if (themes.isNotEmpty) {
          // Try to find an active theme that actually has color codes
          var targetTheme = themes.firstWhere(
            (theme) {
              var colorCodes = theme['color_codes'] ?? theme['colorCodes'];
              return theme['status'] == 'active' &&
                  colorCodes != null &&
                  colorCodes.isNotEmpty;
            },
            orElse: () => null,
          );

          if (targetTheme != null) {
            _applyTheme(targetTheme);
            _isThemeLoaded = true;
            update();
            print('====> ✅ Login Theme Applied! (Priority 2)');
            return;
          } else {
            print(
                '====> ⚠️ Found active themes but none with color codes in Priority 2');
          }
        }
      }

      print('====> ⚠️ No themes found - Using default colors (Priority 3)');
      _isThemeLoaded = true;
      update();
    } catch (e) {
      print('====> ❌ Theme Load Error: $e');
      _isThemeLoaded = true;
      update();
    }
  }

  void _applyTheme(Map<String, dynamic> theme) {
    try {
      var colorCodes = theme['color_codes'];

      if (colorCodes == null) {
        colorCodes = theme['colorCodes'];
      }

      if (colorCodes == null || colorCodes.isEmpty) {
        print('====> ⚠️ No color codes in theme - Using defaults');
        return;
      }

      List<dynamic> colorCodesList = colorCodes;
      int colorsApplied = 0;

      for (var colorData in colorCodesList) {
        String colorType = colorData['color_type'] ?? '';
        String hexColor = colorData['color_code'] ?? '';

        if (colorType.isEmpty || hexColor.isEmpty) {
          continue;
        }

        Color? color = _hexToColor(hexColor);
        if (color == null) continue;

        switch (colorType) {
          case 'primary_color':
            _primaryColor = color;
            colorsApplied++;
            break;
          case 'secondary_color':
            _secondaryColor = color;
            colorsApplied++;
            break;
          case 'background_color':
            _backgroundColor = color;
            colorsApplied++;
            break;
          case 'text_color':
            _textColor = color;
            colorsApplied++;
            break;
          case 'button_color':
            _buttonColor = color;
            colorsApplied++;
            break;
          case 'button_text_color':
            _buttonTextColor = color;
            colorsApplied++;
            break;
          case 'navbar_color':
            _navbarColor = color;
            colorsApplied++;
            break;
          case 'navbar_text_color':
            _navbarTextColor = color;
            colorsApplied++;
            break;
          default:
            print('====> ⚠️ Unknown color_type: $colorType');
        }
      }

      print('====> 🎨 Colors Applied: $colorsApplied');
      print('       Primary: #${_primaryColor.value.toRadixString(16)}');
      print('       Secondary: #${_secondaryColor.value.toRadixString(16)}');
      print('       Button: #${_buttonColor.value.toRadixString(16)}');
      print('       Navbar: #${_navbarColor.value.toRadixString(16)}');
    } catch (e) {
      print('====> ❌ Error applying theme: $e');
    }
  }

  Color? _hexToColor(String hexString) {
    try {
      hexString = hexString.trim().replaceAll('#', '');

      if (hexString.length != 6 && hexString.length != 8) {
        print('====> ⚠️ Invalid hex length: $hexString');
        return null;
      }

      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }

      int? colorValue = int.tryParse(hexString, radix: 16);
      if (colorValue == null) {
        print('====> ⚠️ Cannot parse hex: $hexString');
        return null;
      }

      return Color(colorValue);
    } catch (e) {
      print('====> ❌ Hex conversion error: $e');
      return null;
    }
  }

  Future<void> reloadTheme() async {
    print('====> 🔄 Reloading theme...');
    await loadThemeFromStorage();
  }

  void resetToDefaults() {
    _primaryColor = const Color(0xFF002e80);
    _secondaryColor = const Color(0xFF002e80);
    _backgroundColor = const Color(0xFFFFFFFF);
    _textColor = const Color(0xFF002e80);
    _buttonColor = const Color(0xFF002e80);
    _buttonTextColor = const Color(0xFFFFFFFF);
    _navbarColor = const Color(0xFF002e80);
    _navbarTextColor = const Color(0xFFFFFFFF);
    update();
    print('====> ✅ Reset to default colors');
  }

  Future<void> clearThemeOnLogout() async {
    // await authRepositoryInterface.clearAppThemes();
    // await authRepositoryInterface.clearClientAppThemes();
    // await authRepositoryInterface.clearClientAppData();
    // resetToDefaults();
    // _isThemeLoaded = false;
    // update();
    print('====> ✅ Themes Persisted on Logout');
  }
}
