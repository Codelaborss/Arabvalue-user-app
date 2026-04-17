import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shimmer_animation/shimmer_animation.dart'; // <--- Ensure this import matches your package name
import 'package:sixam_mart/features/rental_module/common/widgets/taxi_cart_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/screens/vehicle_favourite_screen.dart';
import 'package:sixam_mart/features/search/screens/search_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/taxi_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:sixam_mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/parcel_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/category/screens/category_bottom_screen.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/order/screens/order_screen.dart';
import 'package:sixam_mart/features/favourite/screens/favourite_screen.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;

  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  static DashboardScreenState? instance;

  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    instance = this;

    _isLogin = AuthHelper.isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
            () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const CategoryBottomScreen(),
      const FavouriteScreen(),
      const OrderScreen(),
      const SearchScreen(queryText: ''),
      const MenuScreen(),
    ];
  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
                    const Dialog(child: StoreRegistrationSuccessBottomSheet()))
                .then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const StoreRegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().showSuggestedLocation(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return GetBuilder<SplashController>(builder: (splashController) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (_pageIndex != 0) {
            _setPage(0);
          } else {
            if (!ResponsiveHelper.isDesktop(context) &&
                Get.find<SplashController>().module != null &&
                Get.find<SplashController>().configModel!.module == null) {
              Get.find<SplashController>().setModule(null);
              Get.find<StoreController>().resetStoreData();
            } else {
              if (_canExit) {
                if (GetPlatform.isAndroid) {
                  SystemNavigator.pop();
                } else if (GetPlatform.isIOS) {
                  exit(0);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('back_press_again_to_exit'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
                _canExit = true;
                Timer(const Duration(seconds: 2), () {
                  _canExit = false;
                });
              }
            }
          }
        },
        child: GetBuilder<OrderController>(builder: (orderController) {
          return SafeArea(
            top: false,
            bottom: GetPlatform.isAndroid,
            child: Scaffold(
              key: _scaffoldKey,
              body: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _screens.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _screens[index];
                    },
                  ),
                  ResponsiveHelper.isDesktop(context) || keyboardVisible
                      ? const SizedBox()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: GetBuilder<SplashController>(
                              builder: (splashController) {
                            bool isParcel = splashController.module != null &&
                                splashController.configModel!.moduleConfig!
                                    .module!.isParcel!;
                            bool isTaxiWithCache = ((splashController.module !=
                                            null &&
                                        splashController.module!.moduleType
                                                .toString() ==
                                            AppConstants.taxi) ||
                                    (splashController.cacheModule != null &&
                                        splashController.cacheModule!.moduleType
                                                .toString() ==
                                            AppConstants.taxi)) &&
                                TaxiHelper.haveTaxiModule();
                            bool isTaxi = (splashController.module != null &&
                                splashController.module!.moduleType
                                        .toString() ==
                                    AppConstants.taxi);
                            isParcel = isParcel && !isTaxiWithCache;

                            _screens = [
                              const HomeScreen(),
                              isParcel
                                  ? const AddressScreen(fromDashboard: true)
                                  : isTaxi
                                      ? const VehicleFavouriteScreen()
                                      : const CategoryBottomScreen(),
                              const FavouriteScreen(),
                              OrderScreen(index: isTaxi ? 1 : 0),
                              const SearchScreen(queryText: ''),
                              const MenuScreen(),
                            ];

                            return Container(
                              width: size.width,
                              height: GetPlatform.isIOS ? 80 : 65,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(
                                        Dimensions.radiusLarge)),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 7,
                                    left: size.width * 0.53 - 30,
                                    child: ResponsiveHelper.isDesktop(context)
                                        ? const SizedBox()
                                        : (widget.fromSplash &&
                                                Get.find<LocationController>()
                                                    .showLocationSuggestion &&
                                                active)
                                            ? const SizedBox()
                                            : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 45,
                                                    height: 43,
                                                    child: FloatingActionButton(
                                                      onPressed: () {
                                                        _setPage(0);
                                                      },
                                                      backgroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape: CircleBorder(
                                                        side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            width: 4),
                                                      ),
                                                      child:
                                                          FutureBuilder<String>(
                                                        future: Get.find<
                                                                AuthController>()
                                                            .authServiceInterface
                                                            .getAppLogoUrl(),
                                                        builder: (context,
                                                            snapshot) {
                                                          // --- Loading State (Shimmer) ---
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Shimmer(
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              interval:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          100),
                                                              color:
                                                                  Colors.white,
                                                              colorOpacity: 0.6,
                                                              enabled: true,
                                                              direction:
                                                                  const ShimmerDirection
                                                                      .fromLTRB(),
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          // --- Data Loaded ---
                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data!
                                                                  .isNotEmpty) {
                                                            return ClipOval(
                                                              child:
                                                                  Image.network(
                                                                snapshot.data!,
                                                                width: 40,
                                                                height: 40,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Image
                                                                      .asset(
                                                                    Images.logo,
                                                                    width: 40,
                                                                    height: 40,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                },
                                                                loadingBuilder:
                                                                    (context,
                                                                        child,
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null)
                                                                    return child;
                                                                  return Shimmer(
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            2),
                                                                    interval: const Duration(
                                                                        milliseconds:
                                                                            100),
                                                                    color: Colors
                                                                        .white,
                                                                    colorOpacity:
                                                                        0.6,
                                                                    enabled:
                                                                        true,
                                                                    direction:
                                                                        const ShimmerDirection
                                                                            .fromLTRB(),
                                                                    child:
                                                                        Container(
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[300],
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          }

                                                          // --- Fallback ---
                                                          return ClipOval(
                                                            child: Image.asset(
                                                              Images.logo,
                                                              width: 30,
                                                              height: 30,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'home'.tr,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _pageIndex == 0
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ),
                                  ResponsiveHelper.isDesktop(context)
                                      ? const SizedBox()
                                      : (widget.fromSplash &&
                                              Get.find<LocationController>()
                                                  .showLocationSuggestion &&
                                              active)
                                          ? const SizedBox()
                                          : Center(
                                              child: SizedBox(
                                                width: size.width,
                                                height: 80,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      BottomNavItemWidget(
                                                        title: isParcel
                                                            ? 'address'.tr
                                                            : isTaxi
                                                                ? 'wishlist'.tr
                                                                : 'categories'
                                                                    .tr,
                                                        selectedIcon: isParcel
                                                            ? Images
                                                                .addressSelect
                                                            : Images.categories,
                                                        unSelectedIcon: isParcel
                                                            ? Images
                                                                .addressUnselect
                                                            : Images.categories,
                                                        isSelected:
                                                            _pageIndex == 1,
                                                        onTap: () =>
                                                            _setPage(1),
                                                      ),

                                                      BottomNavItemWidget(
                                                        title: 'my_orders'.tr,
                                                        selectedIcon:
                                                            Images.orders,
                                                        unSelectedIcon:
                                                            Images.orders,
                                                        isSelected:
                                                            _pageIndex == 3,
                                                        onTap: () =>
                                                            _setPage(3),
                                                      ),

                                                      Container(
                                                          width:
                                                              size.width * 0.2),

                                                      BottomNavItemWidget(
                                                        title: 'favourite'.tr,
                                                        selectedIcon: Images
                                                            .favouriteSelect,
                                                        unSelectedIcon: Images
                                                            .favouriteUnselect,
                                                        isSelected:
                                                            _pageIndex == 2,
                                                        onTap: () {
                                                          _setPage(2);
                                                        },
                                                      ),

                                                      // Search
                                                      BottomNavItemWidget(
                                                        title: 'search'.tr,
                                                        selectedIcon:
                                                            Images.searchIcon,
                                                        unSelectedIcon:
                                                            Images.searchIcon,
                                                        isSelected:
                                                            _pageIndex == 4,
                                                        onTap: () {
                                                          _setPage(4);
                                                        },
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                ],
                              ),
                            );
                          }),
                        ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  /// Public alias so external widgets can navigate to a page
  void setPage(int pageIndex) => _setPage(pageIndex);

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}
