// main.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert'; // Add this import
import 'package:http/http.dart' as http; // Add this import
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/controllers/dynamic_theme_controller.dart'; // Add this
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/notification_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/cookies_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();

  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD0Z911mOoWCVkeGdjhIKwWFPRgvd6ZyAw",
            authDomain: "stackmart-500c7.firebaseapp.com",
            projectId: "stackmart-500c7",
            storageBucket: "stackmart-500c7.appspot.com",
            messagingSenderId: "491987943015",
            appId: "1:491987943015:web:d8bc7ab8dbc9991c8f1ec2"));
  } else if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCc3OCd5I2xSlnftZ4bFAbuCzMhgQHLivA",
        appId: "1:491987943015:android:a6fb4303cc4bf3d18f1ec2",
        messagingSenderId: "491987943015",
        projectId: "stackmart-500c7",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  void _route() async {
    await _fetchClientTheme();

    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();

      if (AddressHelper.getUserAddressFromSharedPref() != null &&
          AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if (!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
        await Get.find<AuthController>().guestLogin();
      }

      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }

      Get.find<SplashController>().getConfigData(
          loadLandingData: (GetPlatform.isWeb &&
              AddressHelper.getUserAddressFromSharedPref() == null),
          fromMainFunction: true);
    }
  }

  Future<void> _fetchClientTheme() async {
    try {
      print('====> 🔍 Fetching Client Theme from API...');

      final response = await http.get(
        Uri.parse('https://fortestingweb.com/api/v1/client/8'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        print('====> ✅ Client API Response Received');

        if (data['apps'] != null && data['apps'].isNotEmpty) {
          List<dynamic> apps = data['apps'];

          var targetApp = apps.firstWhere(
            (app) => app['status'] == 'active',
            orElse: () => apps[0],
          );

          print('====> 📱 App Found: ${targetApp['app_name']}');

          if (targetApp['themes'] != null && targetApp['themes'].isNotEmpty) {
            List<dynamic> themes = targetApp['themes'];

            var activeTheme = themes.firstWhere(
              (theme) {
                var colorCodes = theme['color_codes'] ?? theme['colorCodes'];
                return theme['status'] == 'active' &&
                    colorCodes != null &&
                    colorCodes.isNotEmpty;
              },
              orElse: () => themes[0],
            );

            print(
                '====> 🎨 Active Theme Selected for Application: ${activeTheme['name']}');

            String appDataJson = jsonEncode(targetApp);
            await Get.find<AuthController>()
                .authServiceInterface
                .saveClientAppData(appDataJson);

            String themesJson = jsonEncode(themes);
            await Get.find<AuthController>()
                .authServiceInterface
                .saveClientAppThemes(themesJson);

            print('====> ✅ Client Theme Saved to Priority 2!');

            if (Get.isRegistered<DynamicThemeController>()) {
              await Get.find<DynamicThemeController>().reloadTheme();
              print('====> ✅ Theme Applied from Client API!');
            }
          } else {
            print('====> ⚠️ No themes found in Client API');
          }
        } else {
          print('====> ⚠️ No apps found in Client API response');
        }
      } else {
        print('====> ❌ Client API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('====> ⚠️ Client theme fetch failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null)
              ? const SizedBox()
              : GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch
                    },
                  ),
                  theme: themeController.darkTheme ? dark() : light(),
                  locale: localizeController.locale,
                  translations: Messages(languages: widget.languages),
                  fallbackLocale: Locale(
                      AppConstants.languages[0].languageCode!,
                      AppConstants.languages[0].countryCode),
                  initialRoute: GetPlatform.isWeb
                      ? RouteHelper.getInitialRoute()
                      : RouteHelper.getSplashRoute(widget.body),
                  getPages: RouteHelper.routes,
                  defaultTransition: Transition.topLevel,
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (BuildContext context, widget) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1)),
                        child: Material(
                          child: SafeArea(
                            top: false,
                            bottom: GetPlatform.isAndroid,
                            child: Stack(children: [
                              widget!,
                              GetBuilder<SplashController>(
                                  builder: (splashController) {
                                if (!splashController.savedCookiesData &&
                                    !splashController.getAcceptCookiesStatus(
                                        splashController.configModel != null
                                            ? splashController
                                                .configModel!.cookiesText!
                                            : '')) {
                                  return ResponsiveHelper.isWeb()
                                      ? const Align(
                                          alignment: Alignment.bottomCenter,
                                          child: CookiesView())
                                      : const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              })
                            ]),
                          ),
                        ));
                  },
                );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
