// common/controllers/theme_controller.dart
import 'package:flutter/services.dart';
import 'package:sixam_mart/common/controllers/dynamic_theme_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
 

class ThemeController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool _darkTheme = false;
  Color? _lightColor;
  Color? _darkColor;

  bool get darkTheme => _darkTheme;
  Color? get darkColor => _darkColor;
  Color? get lightColor => _lightColor;

  String _lightMap = '[]';
  String get lightMap => _lightMap;

  String _darkMap = '[]';
  String get darkMap => _darkMap;

  String _lightMapTaxi = '[]';
  String get lightMapTaxi => _lightMapTaxi;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences.setBool(AppConstants.theme, _darkTheme);
    update();
  }

  void changeTheme(Color lightColor, Color darkColor) {
    _lightColor = lightColor;
    _darkColor = darkColor;
    update();
  }

  void _loadCurrentTheme() async {
    _lightMap = await rootBundle.loadString('assets/map/light_map.json');
    _darkMap = await rootBundle.loadString('assets/map/dark_map.json');
    _lightMapTaxi = await rootBundle.loadString('assets/map/light_taxi.json');
    _darkTheme = sharedPreferences.getBool(AppConstants.theme) ?? false;
    
    
    try {
      if (Get.isRegistered<DynamicThemeController>()) {
        await Get.find<DynamicThemeController>().loadThemeFromStorage();
        print('====> ✅ Dynamic Theme Loaded from ThemeController');
      }
    } catch (e) {
      print('====> ⚠️ Dynamic Theme not available yet: $e');
    }
    
    update();
  }
  
   Future<void> reloadDynamicTheme() async {
    try {
      if (Get.isRegistered<DynamicThemeController>()) {
        await Get.find<DynamicThemeController>().reloadTheme();
        update();   
        print('====> ✅ Dynamic Theme Reloaded');
      }
    } catch (e) {
      print('====> ⚠️ Could not reload dynamic theme: $e');
    }
  }
}