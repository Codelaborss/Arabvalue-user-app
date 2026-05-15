import 'package:flutter/foundation.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/profile_incomplete_dialog.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/widgets/bottom_section.dart';
import 'package:sixam_mart/features/checkout/widgets/top_section.dart';
import 'package:flutter/material.dart';

String _formatExactPrice(double value) {
  bool isRightSide =
      Get.find<SplashController>().configModel!.currencySymbolDirection ==
          'right';
  String symbol = Get.find<SplashController>().configModel!.currencySymbol!;
  String priceStr = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  return isRightSide ? '$priceStr $symbol' : '$symbol$priceStr';
}

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;
  final bool isBuyNow; // Track if this is a Buy Now checkout
  const CheckoutScreen(
      {super.key,
      required this.fromCart,
      required this.cartList,
      required this.storeId,
      this.isBuyNow = false,
      this.isGift = false,
      this.isGiftVoucher = false}); // Default to false
  final bool isGift;
  final bool isGiftVoucher;

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final ScrollController _scrollController = ScrollController();
  final JustTheController tooltipController1 = JustTheController();
  final JustTheController tooltipController2 = JustTheController();
  final JustTheController tooltipController3 = JustTheController();

  double? _taxPercent = 0;
  bool orderPlaced = false; // Track if order was placed
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  List<CartModel?>? _cartList;
  bool _isWalletActive = false;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool canCheckSmall = false;
  double? _payableAmount = 0;
  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;
  bool isPassedVariationPrice = false;

  final TextEditingController guestContactPersonNameController =
      TextEditingController();
  final TextEditingController guestContactPersonNumberController =
      TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestPasswordController = TextEditingController();
  final TextEditingController guestConfirmPasswordController =
      TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode guestPasswordNode = FocusNode();
  final FocusNode guestConfirmPasswordNode = FocusNode();

  bool _firstTimeCheckPayment = false;
  bool _calledOrderTax = false;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<CheckoutController>().resetOrderTax();
    Get.find<CheckoutController>().initAdditionData();
    AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();
    Get.find<CheckoutController>().streetNumberController.text =
        addressModel?.streetNumber ?? '';
    Get.find<CheckoutController>().houseController.text =
        addressModel?.house ?? '';
    Get.find<CheckoutController>().floorController.text =
        addressModel?.floor ?? '';
    Get.find<CheckoutController>().couponController.text = '';

    Get.find<CheckoutController>().clearPrevData();
    Get.find<CheckoutController>().getDmTipMostTapped();
    Get.find<CheckoutController>()
        .setPreferenceTimeForView('', isUpdate: false);

    Get.find<CheckoutController>().getOfflineMethodList();

    if (Get.find<CheckoutController>().isCreateAccount) {
      Get.find<CheckoutController>().toggleCreateAccount(willUpdate: false);
    }

    if (Get.find<CheckoutController>().isPartialPay) {
      Get.find<CheckoutController>().changePartialPayment(isUpdate: false);
    }

    if (isLoggedIn) {
      if (Get.find<ProfileController>().userInfoModel == null) {
        Get.find<ProfileController>().getUserInfo();
      }

      Get.find<CouponController>().getCouponList();

      if (Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList();
      }
    }

    if (widget.storeId == null) {
      _cartList = [];
      if (GetPlatform.isWeb) {
        await Get.find<CartController>().getCartDataOnline();
      }
      widget.fromCart
          ? _cartList!.addAll(Get.find<CartController>().cartList)
          : _cartList!.addAll(widget.cartList!);
      if (_cartList != null &&
          _cartList!.isNotEmpty &&
          _cartList![0]?.item != null) {
        await Get.find<CheckoutController>()
            .initCheckoutData(_cartList![0]!.item!.storeId);

        // Auto-select Delivery Mode for Vouchers
        if (_cartList![0]!.item!.type == 'voucher' || widget.isGiftVoucher) {
          String? voucherId = _cartList![0]!.item!.voucherIds;
          print('DEBUG: checking voucherId: "$voucherId"');

          // Let's check the exact string matching logic based on typical data
          if (voucherId != null &&
              voucherId.toLowerCase().contains('delivery')) {
            // If it has "delivery" in the name, we default to delivery
            Get.find<CheckoutController>()
                .setOrderType('delivery', notify: true);
          } else {
            // For everything else (In-store, Gift, Flat, etc.)
            Get.find<CheckoutController>()
                .setOrderType('take_away', notify: true);
          }
        }
      }
    }
    if (widget.storeId != null) {
      await Get.find<CheckoutController>().initCheckoutData(widget.storeId);
      Get.find<CouponController>().removeCouponData(false);

      // Auto-select Delivery Mode for Vouchers (Buy Now)
      if (widget.cartList != null &&
          widget.cartList!.isNotEmpty &&
          widget.cartList![0]?.item != null &&
          (widget.cartList![0]!.item!.type == 'voucher' ||
              widget.isGiftVoucher)) {
        String? voucherId = widget.cartList![0]!.item!.voucherIds;
        print('DEBUG (BuyNow): checking voucherId: "$voucherId"');

        if (voucherId != null && voucherId.toLowerCase().contains('delivery')) {
          Get.find<CheckoutController>().setOrderType('delivery', notify: true);
        } else {
          Get.find<CheckoutController>()
              .setOrderType('take_away', notify: true);
        }
      }
    }
    Get.find<CheckoutController>()
        .pickPrescriptionImage(isRemove: true, isCamera: false);
    _isWalletActive =
        Get.find<SplashController>().configModel!.customerWalletStatus == 1;
    Get.find<CheckoutController>().updateTips(
      Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty
          ? int.parse(Get.find<CheckoutController>().getSharedPrefDmTipIndex())
          : 0,
      notify: false,
    );
    Get.find<CheckoutController>().tipController.text =
        Get.find<CheckoutController>().selectedTips != -1
            ? AppConstants.tips[Get.find<CheckoutController>().selectedTips]
            : '';
  }

  void _setSinglePaymentActive() {
    if ((!_firstTimeCheckPayment &&
            !_isCashOnDeliveryActive! &&
            _isDigitalPaymentActive! &&
            Get.find<SplashController>()
                    .configModel!
                    .activePaymentMethodList!
                    .length ==
                1) &&
        ((!_isWalletActive && AuthHelper.isLoggedIn()) ||
            !AuthHelper.isLoggedIn())) {
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.find<CheckoutController>().setPaymentMethod(2, isUpdate: false);
        Get.find<CheckoutController>().changeDigitalPaymentName(
            Get.find<SplashController>()
                .configModel!
                .activePaymentMethodList![0]
                .getWay!,
            willUpdate: false);
        _firstTimeCheckPayment = true;
      });
    }
  }

  bool _isVoucherItem(List<CartModel?>? cartList) {
    if (cartList == null) return false;
    for (var cart in cartList) {
      final item = cart?.item;
      // Treat bundle vouchers that contain nested products the same as BOGO/Mix/Single-X.
      if (item != null && item.type == 'voucher') {
        if ((item.product?.isNotEmpty ?? false) ||
            item.bundleType == 'bogo_free' ||
            item.bundleType == 'simple x' ||
            item.bundleType == 'mix_match') {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();

    print(
        '🔍 Checkout dispose: isBuyNow=${widget.isBuyNow}, orderPlaced=$orderPlaced');

    // If this is a Buy Now checkout and order was not placed, clear cart
    if (widget.isBuyNow && !orderPlaced) {
      print('✅ Conditions met for auto-clear');
      // Use Future.microtask to clear cart after dispose completes
      Future.microtask(() {
        print('🧹 Buy Now: Auto-clearing cart (order not placed)');
        Get.find<CartController>().clearCartOnline().then((success) {
          print('🧹 Cart clear result: $success');
        });
      });
    } else {
      print(
          '❌ Skipping auto-clear: isBuyNow=${widget.isBuyNow}, orderPlaced=$orderPlaced');
    }

    guestContactPersonNameController.dispose();
    guestContactPersonNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Module? module =
        Get.find<SplashController>().configModel!.moduleConfig!.module;
    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() &&
        Get.find<SplashController>().configModel!.guestCheckoutStatus!;
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();

    return WillPopScope(
      onWillPop: () async {
        // If this is a Buy Now checkout, clear cart when user backs out
        if (widget.isBuyNow) {
          await Get.find<CartController>().clearCartOnline();
        }
        return true; // Allow back navigation
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'checkout'.tr, bgColor: Colors.white),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: guestCheckoutPermission || AuthHelper.isLoggedIn()
            ? GetBuilder<CheckoutController>(builder: (checkoutController) {
                List<DropdownItem<int>> addressList = _getDropdownAddressList(
                    context: context,
                    addressList: Get.find<AddressController>().addressList,
                    store: checkoutController.store);
                address = _getAddressList(
                    addressList: Get.find<AddressController>().addressList,
                    store: checkoutController.store);

                bool todayClosed = false;
                bool tomorrowClosed = false;
                Pivot? moduleData =
                    _getModuleData(store: checkoutController.store);
                _isCashOnDeliveryActive =
                    _checkCODActive(store: checkoutController.store);
                _isDigitalPaymentActive =
                    _checkDigitalPaymentActive(store: checkoutController.store);
                _isOfflinePaymentActive = Get.find<SplashController>()
                        .configModel!
                        .offlinePaymentStatus! &&
                    _checkZoneOfflinePaymentOnOff(
                        addressModel:
                            AddressHelper.getUserAddressFromSharedPref(),
                        checkoutController: checkoutController);
                if (checkoutController.store != null) {
                  todayClosed = checkoutController.isStoreClosed(
                      true,
                      checkoutController.store!.active!,
                      checkoutController.store!.schedules);
                  tomorrowClosed = checkoutController.isStoreClosed(
                      false,
                      checkoutController.store!.active!,
                      checkoutController.store!.schedules);
                  _taxPercent = checkoutController.store!.tax;
                }
                return GetBuilder<CouponController>(
                    builder: (couponController) {
                  double? maxCodOrderAmount;

                  if (moduleData != null) {
                    maxCodOrderAmount = moduleData.maximumCodOrderAmount;
                  }
                  double price = _calculatePrice(
                      store: checkoutController.store, cartList: _cartList);
                  double addOns = _calculateAddonsPrice(
                      store: checkoutController.store, cartList: _cartList);
                  double variations = _calculateVariationPrice(
                      store: checkoutController.store,
                      cartList: _cartList,
                      calculateWithoutDiscount: true);
                  double? itemDiscountPrice = _calculateDiscountPrice(
                      store: checkoutController.store,
                      cartList: _cartList,
                      price: price,
                      addOns: addOns,
                      calStoreDiscount: false);
                  double? storeDiscountPrice = _calculateDiscountPrice(
                      store: checkoutController.store,
                      cartList: _cartList,
                      price: price,
                      addOns: addOns,
                      calStoreDiscount: true);

                  double extraDiscount = _getExtraDiscountPrice(
                      storeDiscountPrice, itemDiscountPrice);
                  double? discount =
                      _getDiscountPrice(storeDiscountPrice, itemDiscountPrice);
                  double? displayDiscount = discount;
                  double couponDiscount = couponController.discount ?? 0;

                  double subTotal = _calculateSubTotal(
                      price: price,
                      addOns: addOns,
                      variations: variations,
                      cartList: _cartList);

                  // ── BOGO Free Discount ─────────────────────────────────
                  // For bogo_free vouchers: the cheaper product is free.
                  // Add min(priceA, priceB) to both discount AND subTotal.
                  double bogoFreeDiscount = 0;
                  if (_cartList != null && _cartList!.isNotEmpty) {
                    bool isBogoFree = _cartList!.any((c) =>
                        c != null &&
                        c.item?.type == 'voucher' &&
                        c.item?.bundleType == 'bogo_free');

                    if (isBogoFree) {
                      // Get non-voucher cart items (the actual products)
                      List<CartModel> productItems = _cartList!
                          .where((c) => c != null && c.item?.type != 'voucher')
                          .cast<CartModel>()
                          .toList();

                      if (productItems.length >= 2) {
                        // Effective price = selected variation price OR base price
                        double effectivePrice(CartModel c) {
                          if (c.item?.foodVariations != null &&
                              c.item!.foodVariations!.isNotEmpty &&
                              c.foodVariations != null &&
                              c.foodVariations!.isNotEmpty) {
                            for (int i = 0; i < c.foodVariations!.length; i++) {
                              if (c.foodVariations![i].contains(true) &&
                                  c.item!.foodVariations!.length > i &&
                                  c.item!.foodVariations![i].variationValues !=
                                      null) {
                                for (int j = 0;
                                    j <
                                        c.item!.foodVariations![i]
                                            .variationValues!.length;
                                    j++) {
                                  if (c.foodVariations![i].length > j &&
                                      (c.foodVariations![i][j] ?? false)) {
                                    return c.item!.foodVariations![i]
                                            .variationValues![j].optionPrice ??
                                        0;
                                  }
                                }
                              }
                            }
                          }
                          return c.item?.price ?? 0;
                        }

                        double priceA = effectivePrice(productItems[0]);
                        double priceB = effectivePrice(productItems[1]);
                        double originalBogoFreeDiscount =
                            priceA <= priceB ? priceA : priceB;
                        bogoFreeDiscount = originalBogoFreeDiscount;

                        // Adjust BOGO discount for Customer Commission
                        double expensivePrice =
                            priceA > priceB ? priceA : priceB;
                        if (checkoutController.store?.commissionPaidBy ==
                                'customer' &&
                            checkoutController.store?.comission != null &&
                            checkoutController.store!.comission! > 0) {
                          double commissionAmount = expensivePrice *
                              (checkoutController.store!.comission! / 100);
                          bogoFreeDiscount =
                              bogoFreeDiscount - commissionAmount;
                          if (bogoFreeDiscount < 0) bogoFreeDiscount = 0;
                        }

                        displayDiscount =
                            (displayDiscount ?? 0) + bogoFreeDiscount;
                        subTotal = subTotal + originalBogoFreeDiscount;

                        if (kDebugMode) {
                          print(
                              '[BOGO_FREE] priceA=$priceA, priceB=$priceB, bogoFreeDiscount=$bogoFreeDiscount, totalDisplayDiscount=$displayDiscount');
                        }
                      }
                    }
                  }
                  // ────────────────────────────────────────────────────────

                  if (kDebugMode) {
                    print('===== [CHECKOUT DISCOUNT DEBUG] =====');
                    print('  itemDiscountPrice: $itemDiscountPrice');
                    print('  storeDiscountPrice: $storeDiscountPrice');
                    print('  final display discount (UI): $displayDiscount');
                    print('  actual payment discount: $discount');
                    print('  couponDiscount: $couponDiscount');
                    if (_cartList != null) {
                      for (var c in _cartList!) {
                        if (c != null && c.item != null) {
                          print(
                              '  Cart item: ${c.item!.name} | type: ${c.item!.type} | bundleType: ${c.item!.bundleType} | discountAmount: ${c.discountAmount} | item.discount: ${c.item!.discount}');
                        }
                      }
                    }
                    print('=====================================');
                  }

                  // Detect cash back voucher early for UI display
                  bool isCashBackVoucher = false;
                  if (_cartList != null && _cartList!.isNotEmpty) {
                    for (CartModel? cart in _cartList!) {
                      if (cart != null &&
                          cart.item != null &&
                          cart.item!.type == 'voucher' &&
                          cart.item!.offerType?.toLowerCase() == 'cash back') {
                        isCashBackVoucher = true;
                        break;
                      }
                    }
                  }
                  if (widget.isGiftVoucher) {
                    isCashBackVoucher = true;
                  }

                  // BOGO subTotal update is now handled inside the BOGO block above using originalBogoFreeDiscount

                  double referralDiscount = _calculateReferralDiscount(
                      subTotal, discount, couponDiscount);

                  double orderAmount = _calculateOrderAmount(
                    price: price,
                    variations: variations,
                    discount: discount ?? 0,
                    addOns: addOns,
                    couponDiscount: couponDiscount,
                    cartList: _cartList,
                    referralDiscount: referralDiscount,
                  );

                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (checkoutController.isFirstTime ||
                        ((couponController.discount ?? 0) > 0 &&
                            !checkoutController.isFirstTime &&
                            !_calledOrderTax)) {
                      if ((couponController.discount ?? 0) > 0) {
                        _calledOrderTax = true;
                      }
                      List<OnlineCart> carts = [];

                      if (widget.storeId == null && _cartList != null) {
                        for (int index = 0;
                            index < _cartList!.length;
                            index++) {
                          CartModel? cart = _cartList![index];
                          if (cart == null || cart.item == null) continue;
                          List<int?> addOnIdList = [];
                          List<int?> addOnQtyList = [];
                          if (cart.addOnIds != null) {
                            for (var addOn in cart.addOnIds!) {
                              addOnIdList.add(addOn.id);
                              addOnQtyList.add(addOn.quantity);
                            }
                          }

                          List<OrderVariation> variations = [];
                          if ((Get.find<SplashController>()
                                      .getModuleConfig(cart.item!.moduleType)
                                      .newVariation ==
                                  true) &&
                              cart.item!.foodVariations != null &&
                              cart.foodVariations != null) {
                            for (int i = 0;
                                i < cart.item!.foodVariations!.length;
                                i++) {
                              if (cart.foodVariations!.length > i &&
                                  cart.foodVariations![i].contains(true)) {
                                List<OrderVariationValue> values = [];
                                if (cart.item!.foodVariations![i]
                                        .variationValues !=
                                    null) {
                                  for (int j = 0;
                                      j <
                                          cart.item!.foodVariations![i]
                                              .variationValues!.length;
                                      j++) {
                                    if (cart.foodVariations![i].length > j &&
                                        (cart.foodVariations![i][j] ?? false)) {
                                      double originalPrice = cart
                                              .item!
                                              .foodVariations![i]
                                              .variationValues![j]
                                              .optionPrice ??
                                          0;

                                      double finalPrice = originalPrice;

                                      // Check for voucher discount (either own or from parent voucher in group)
                                      double? voucherDiscount;
                                      String? voucherDiscountType;

                                      if (cart.item!.type == 'voucher') {
                                        voucherDiscount = cart.item!.discount;
                                        voucherDiscountType =
                                            cart.item!.discountType;
                                      } else if (cart.cartGroupId != null &&
                                          _cartList != null) {
                                        // Find parent voucher in the same group
                                        for (var c in _cartList!) {
                                          if (c != null &&
                                              c.cartGroupId ==
                                                  cart.cartGroupId &&
                                              c.item?.type == 'voucher') {
                                            print(
                                                'DEBUG [TaxPayload]: Found Parent Voucher for ${cart.item!.name}');
                                            voucherDiscount = c.item?.discount;
                                            voucherDiscountType =
                                                c.item?.discountType;
                                            break;
                                          }
                                        }
                                      }

                                      if (voucherDiscount != null &&
                                          voucherDiscount > 0) {
                                        // Adjust for Customer Commission in Tax Payload
                                        if (checkoutController
                                                    .store?.commissionPaidBy ==
                                                'customer' &&
                                            checkoutController
                                                    .store?.comission !=
                                                null &&
                                            checkoutController
                                                    .store!.comission! >
                                                0) {
                                          double priceForFormula =
                                              originalPrice;
                                          if (priceForFormula == 0 &&
                                              cart.item!.bundleType ==
                                                  'simple x') {
                                            priceForFormula =
                                                cart.item!.actualPrice ??
                                                    cart.item!.price ??
                                                    0;
                                          }

                                          if (priceForFormula > 0) {
                                            double dAmount = 0;
                                            if (voucherDiscountType ==
                                                'percent') {
                                              dAmount = priceForFormula *
                                                  (voucherDiscount / 100);
                                            } else {
                                              dAmount = voucherDiscount;
                                            }
                                            double afterD =
                                                priceForFormula - dAmount;
                                            double comm = afterD *
                                                (checkoutController
                                                        .store!.comission! /
                                                    100);
                                            voucherDiscount =
                                                ((dAmount - comm) /
                                                        priceForFormula) *
                                                    100;
                                            voucherDiscountType = 'percent';
                                          }
                                        }

                                        finalPrice =
                                            PriceConverter.convertWithDiscount(
                                                  originalPrice,
                                                  voucherDiscount,
                                                  voucherDiscountType,
                                                  isFoodVariation: true,
                                                ) ??
                                                originalPrice;
                                      }

                                      values.add(OrderVariationValue(
                                        label: cart.item!.foodVariations![i]
                                            .variationValues![j].level,
                                        optionPrice: finalPrice.toString(),
                                      ));
                                    }
                                  }
                                }
                                variations.add(OrderVariation(
                                  name: cart.item!.foodVariations![i].name,
                                  type: cart.item!.foodVariations![i]
                                              .multiSelect ??
                                          false
                                      ? 'multi'
                                      : 'single',
                                  min: cart.item!.foodVariations![i].min ?? 0,
                                  max: cart.item!.foodVariations![i].max ?? 0,
                                  required:
                                      (cart.item!.foodVariations![i].required ??
                                              false)
                                          ? 'on'
                                          : 'off',
                                  values: values,
                                ));
                              }
                            }
                          }
                          // Determine price: 0 if product has food_variations, otherwise discountedPrice
                          double priceForPayload = cart.discountedPrice ?? 0;
                          if (cart.item!.foodVariations != null &&
                              cart.item!.foodVariations!.isNotEmpty) {
                            priceForPayload = 0;
                          }

                          carts.add(OnlineCart(
                            cart.id,
                            cart.item!.id,
                            (cart.isCampaign ?? false) ? cart.item!.id : null,
                            priceForPayload.toString(),
                            '',
                            (Get.find<SplashController>()
                                        .getModuleConfig(cart.item!.moduleType)
                                        .newVariation ==
                                    true)
                                ? null
                                : cart.variation,
                            (Get.find<SplashController>()
                                        .getModuleConfig(cart.item!.moduleType)
                                        .newVariation ==
                                    true)
                                ? variations
                                : null,
                            cart.quantity,
                            addOnIdList,
                            cart.addOns,
                            addOnQtyList,
                            'Item',
                            itemType: !widget.fromCart
                                ? "AppModelsItemCampaign"
                                : null,
                            discountAmount: cart.discountAmount,
                          ));
                        }
                      }

                      double? couponDiscountAmount =
                          Get.find<CouponController>().discount;
                      String? couponCode;
                      if ((couponDiscountAmount ?? 0) > 0 ||
                          (Get.find<CouponController>().coupon != null &&
                              Get.find<CouponController>().freeDelivery)) {
                        couponCode = Get.find<CouponController>().coupon?.code;
                      }

                      int? storeId = widget.storeId;
                      if (storeId == null &&
                          _cartList != null &&
                          _cartList!.isNotEmpty &&
                          _cartList![0]?.item != null) {
                        storeId = _cartList![0]!.item!.storeId;
                      }

                      bool hasFlatVoucher = false;
                      if (_cartList != null && _cartList!.isNotEmpty) {
                        for (CartModel? cart in _cartList!) {
                          if (cart != null &&
                              cart.item != null &&
                              cart.item!.type == 'voucher' &&
                              cart.item!.bundleType != 'bogo_free' &&
                              cart.item!.bundleType != 'simple x' &&
                              cart.item!.bundleType != 'mix_match' &&
                              cart.item!.bundleType != 'gift' &&
                              cart.giftDetails == null &&
                              !(cart.item!.product?.isNotEmpty ?? false)) {
                            hasFlatVoucher = true;
                            break;
                          }
                        }
                      }

                      PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                        cart: carts,
                        couponDiscountAmount: couponDiscountAmount,
                        distance: checkoutController.distance,
                        orderAmount: widget.storeId == null ? subTotal : 0,
                        orderNote: checkoutController.noteController.text,
                        orderType:
                            hasFlatVoucher ? "" : checkoutController.orderType,
                        paymentMethod:
                            checkoutController.paymentMethodIndex == 0
                                ? 'cash_on_delivery'
                                : checkoutController.paymentMethodIndex == 1
                                    ? 'wallet'
                                    : checkoutController.paymentMethodIndex == 2
                                        ? 'digital_payment'
                                        : 'offline_payment',
                        couponCode: couponCode,
                        storeId: storeId,
                        discountAmount: discount ?? 0,
                        receiverDetails: null,
                        parcelCategoryId: null,
                        chargePayer: null,
                        dmTips: (checkoutController.orderType == 'take_away' ||
                                checkoutController.tipController.text ==
                                    'not_now')
                            ? ''
                            : checkoutController.tipController.text.trim(),
                        cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                        unavailableItemNote:
                            Get.find<CartController>().notAvailableIndex != -1
                                ? Get.find<CartController>().notAvailableList[
                                    Get.find<CartController>()
                                        .notAvailableIndex]
                                : '',
                        deliveryInstruction:
                            checkoutController.selectedInstruction != -1
                                ? AppConstants.deliveryInstructionList[
                                    checkoutController.selectedInstruction]
                                : '',
                        partialPayment: checkoutController.isPartialPay ? 1 : 0,
                        guestId: isGuestLogIn
                            ? int.parse(AuthHelper.getGuestId())
                            : 0,
                        isBuyNow: widget.fromCart ? 0 : 1,
                        extraPackagingAmount: Get.find<CartController>()
                                .needExtraPackage
                            ? checkoutController.store?.extraPackagingAmount ??
                                0
                            : 0,
                        createNewUser:
                            checkoutController.isCreateAccount ? 1 : 0,
                        password: guestPasswordController.text,
                        isPrescriptionOrder:
                            widget.storeId == null ? false : true,
                      );

                      checkoutController.getOrderTax(placeOrderBody);
                    }
                  });

                  double additionalCharge = Get.find<SplashController>()
                          .configModel!
                          .additionalChargeStatus!
                      ? Get.find<SplashController>()
                          .configModel!
                          .additionCharge!
                      : 0;
                  double originalCharge = _calculateOriginalDeliveryCharge(
                    store: checkoutController.store,
                    address: AddressHelper.getUserAddressFromSharedPref()!,
                    distance: checkoutController.distance,
                    extraCharge: checkoutController.extraCharge,
                    surgePrice: checkoutController.surgePrice?.price,
                    surgePriceType: checkoutController.surgePrice?.priceType,
                  );
                  double deliveryCharge = _calculateDeliveryCharge(
                    store: checkoutController.store,
                    address: AddressHelper.getUserAddressFromSharedPref()!,
                    distance: checkoutController.distance,
                    extraCharge: checkoutController.extraCharge,
                    orderType: checkoutController.orderType!,
                    orderAmount: orderAmount,
                    surgePrice: checkoutController.surgePrice?.price,
                    surgePriceType: checkoutController.surgePrice?.priceType,
                  );

                  if (checkoutController.orderType != 'take_away' &&
                      checkoutController.store != null) {
                    _deliveryChargeForView =
                        (checkoutController.orderType == 'delivery'
                                ? checkoutController.store!.freeDelivery!
                                : true)
                            ? 'free'.tr
                            : deliveryCharge != -1
                                ? PriceConverter.convertPrice(deliveryCharge)
                                : 'calculating'.tr;
                  }

                  double extraPackagingCharge = widget.storeId != null
                      ? 0
                      : _calculateExtraPackagingCharge(checkoutController);

                  double giftBonus = 0;
                  if (widget.isGiftVoucher && _cartList != null) {
                    for (var cart in _cartList!) {
                      if (cart != null &&
                          cart.giftDetails != null &&
                          cart.giftDetails!.bonus != null) {
                        giftBonus += cart.giftDetails!.bonus!;
                      }
                    }
                  }

                  bool isFlatDiscount = false;
                  if (_cartList != null && _cartList!.isNotEmpty) {
                    var item = _cartList!.first?.item;
                    if (item != null &&
                        item.voucherIds != null &&
                        item.voucherIds!.contains('Flat discount')) {
                      isFlatDiscount = true;
                    }
                  }

                  // ── Commission Amount Calculation (Checkout) ─────────────
                  // When commission_paid_by == 'customer', calculate the
                  // commission portion that the customer is covering so we
                  // can display it as a separate line item in the UI.
                  //
                  // Logic: Identify the 'Net Amount' (Price - Discount) that
                  // belongs to vouchers. We do this by taking the total net
                  // amount and subtracting the non-voucher part.
                  double commissionAmount = 0;
                  if (checkoutController.store?.comission != null &&
                      checkoutController.store!.comission! > 0 &&
                      _cartList != null) {
                    double commRate = checkoutController.store!.comission!;

                    double totalNetAmount = subTotal - displayDiscount;
                    double nonVoucherNetAmount = 0;
                    double totalAddOnPrice = 0;
                    double giftCommission = 0;

                    for (CartModel? cart in _cartList!) {
                      if (cart == null || cart.item == null) continue;

                      if (cart.addOns != null && cart.addOns!.isNotEmpty) {
                        for (int i = 0; i < cart.addOns!.length; i++) {
                          totalAddOnPrice += (cart.addOns![i].price! *
                              cart.addOnIds![i].quantity!);
                        }
                      }

                      bool isGift = cart.item!.bundleType == 'gift';
                      bool isVoucherPart = cart.item!.type == 'voucher' ||
                          cart.cartGroupId != null;

                      if (isGift) {
                        // SPECIAL LOGIC FOR GIFTS ONLY: Direct calculation from API rate on SubTotal
                        double giftRate =
                            cart.item!.storeCommission ?? commRate;
                        double itemP = _calculatePrice(
                            store: checkoutController.store, cartList: [cart]);

                        giftCommission += (itemP * giftRate) / 100;
                      } else if (!isVoucherPart) {
                        double itemP = _calculatePrice(
                            store: checkoutController.store, cartList: [cart]);
                        double itemD = _calculateDiscountPrice(
                          store: checkoutController.store,
                          cartList: [cart],
                          price: itemP,
                          addOns: 0,
                          calStoreDiscount: true,
                        );
                        nonVoucherNetAmount += (itemP - itemD);
                      }
                    }

                    // For standard vouchers, we go back to using Net Amount (SubTotal - Discount)
                    double voucherNetAmount =
                        totalNetAmount - nonVoucherNetAmount - totalAddOnPrice;

                    // Subtract gift net amount from standard voucher base to avoid double counting
                    for (CartModel? cart in _cartList!) {
                      if (cart?.item?.bundleType == 'gift') {
                        double itemP = _calculatePrice(
                            store: checkoutController.store, cartList: [cart]);
                        double itemD = _calculateDiscountPrice(
                            store: checkoutController.store,
                            cartList: [cart],
                            price: itemP,
                            addOns: 0,
                            calStoreDiscount: true);
                        voucherNetAmount -= (itemP - itemD);
                      }
                    }

                    if (voucherNetAmount > 0) {
                      if (checkoutController.store?.commissionPaidBy ==
                          'customer') {
                        // Reverse formula for standard customer-paid vouchers
                        commissionAmount =
                            (voucherNetAmount * commRate) / (100 + commRate);
                      } else {
                        // Direct formula for store-paid vouchers
                        commissionAmount = (voucherNetAmount * commRate) / 100;
                      }
                    }

                    // Add the specially calculated Gift commission (SubTotal based)
                    commissionAmount += giftCommission;

                    commissionAmount =
                        double.parse(commissionAmount.toStringAsFixed(2));
                  }
                  // ────────────────────────────────────────────────────────

                  double total = _calculateTotal(
                    subTotal: subTotal,
                    deliveryCharge: deliveryCharge,
                    discount: displayDiscount,
                    couponDiscount: couponDiscount,
                    taxIncluded: (checkoutController.taxIncluded == 1),
                    tax: checkoutController.orderTax!,
                    orderType: checkoutController.orderType!,
                    tips: checkoutController.tips,
                    additionalCharge: additionalCharge,
                    extraPackagingCharge: extraPackagingCharge,
                    isCashBack: isCashBackVoucher || widget.isGiftVoucher,
                  );

                  bool isPrescriptionRequired = _checkPrescriptionRequired();

                  total = total - referralDiscount;

                  double subTotalForUI = subTotal;

                  if (widget.storeId != null) {
                    checkoutController.setPaymentMethod(0, isUpdate: false);
                  }
                  checkoutController.setTotalAmount(total -
                      (checkoutController.isPartialPay
                          ? Get.find<ProfileController>()
                              .userInfoModel!
                              .walletBalance!
                          : 0));

                  if (_payableAmount != checkoutController.viewTotalPrice &&
                      checkoutController.distance != null &&
                      isLoggedIn) {
                    _payableAmount = checkoutController.viewTotalPrice;
                    showCashBackSnackBar();
                  }

                  _setSinglePaymentActive();

                  return (checkoutController.distance != null &&
                          checkoutController.store != null)
                      ? Column(
                          children: [
                            ResponsiveHelper.isDesktop(context)
                                ? Container(
                                    height: 64,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.10),
                                    child: Center(
                                        child: Text('checkout'.tr,
                                            style: robotoMedium)),
                                  )
                                : const SizedBox(),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: FooterView(
                                  child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: ResponsiveHelper.isDesktop(context)
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeLarge),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 6,
                                                  child: TopSection(
                                                    checkoutController:
                                                        checkoutController,
                                                    charge: originalCharge,
                                                    deliveryCharge:
                                                        deliveryCharge,
                                                    addressList: addressList,
                                                    tomorrowClosed:
                                                        tomorrowClosed,
                                                    todayClosed: todayClosed,
                                                    module: module,
                                                    price: price,
                                                    discount: displayDiscount,
                                                    addOns: addOns,
                                                    address: address,
                                                    cartList: _cartList,
                                                    isCashOnDeliveryActive:
                                                        _isCashOnDeliveryActive!,
                                                    isDigitalPaymentActive:
                                                        _isDigitalPaymentActive!,
                                                    isWalletActive:
                                                        _isWalletActive,
                                                    storeId: widget.storeId,
                                                    total: total,
                                                    isOfflinePaymentActive:
                                                        _isOfflinePaymentActive,
                                                    guestNameTextEditingController:
                                                        guestContactPersonNameController,
                                                    guestNumberTextEditingController:
                                                        guestContactPersonNumberController,
                                                    guestNumberNode:
                                                        guestNumberNode,
                                                    guestEmailController:
                                                        guestEmailController,
                                                    guestEmailNode:
                                                        guestEmailNode,
                                                    tooltipController1:
                                                        tooltipController1,
                                                    tooltipController2:
                                                        tooltipController2,
                                                    dmTipsTooltipController:
                                                        tooltipController3,
                                                    guestPasswordController:
                                                        guestPasswordController,
                                                    guestConfirmPasswordController:
                                                        guestConfirmPasswordController,
                                                    guestPasswordNode:
                                                        guestPasswordNode,
                                                    guestConfirmPasswordNode:
                                                        guestConfirmPasswordNode,
                                                    variationPrice:
                                                        isPassedVariationPrice
                                                            ? variations
                                                            : 0,
                                                    deliveryChargeForView:
                                                        _deliveryChargeForView,
                                                    badWeatherCharge:
                                                        badWeatherChargeForToolTip,
                                                    extraChargeForToolTip:
                                                        extraChargeForToolTip,
                                                  )),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeLarge),
                                              Expanded(
                                                  flex: 4,
                                                  child: BottomSection(
                                                    checkoutController:
                                                        checkoutController,
                                                    total: total,
                                                    module: module!,
                                                    subTotal: subTotalForUI,
                                                    discount: displayDiscount,
                                                    couponController:
                                                        couponController,
                                                    taxIncluded:
                                                        (checkoutController
                                                                .taxIncluded ==
                                                            1),
                                                    tax: checkoutController
                                                        .orderTax!,
                                                    deliveryCharge:
                                                        deliveryCharge,
                                                    todayClosed: todayClosed,
                                                    tomorrowClosed:
                                                        tomorrowClosed,
                                                    orderAmount: orderAmount,
                                                    maxCodOrderAmount:
                                                        maxCodOrderAmount,
                                                    storeId: widget.storeId,
                                                    taxPercent: _taxPercent,
                                                    price: price,
                                                    addOns: addOns,
                                                    isPrescriptionRequired:
                                                        isPrescriptionRequired,
                                                    checkoutButton:
                                                        _orderPlaceButton(
                                                      checkoutController,
                                                      todayClosed,
                                                      tomorrowClosed,
                                                      orderAmount,
                                                      deliveryCharge,
                                                      checkoutController
                                                          .orderTax!,
                                                      displayDiscount,
                                                      total,
                                                      maxCodOrderAmount,
                                                      isPrescriptionRequired,
                                                      couponDiscount,
                                                      referralDiscount,
                                                      commissionAmount,
                                                      isCashBack:
                                                          isCashBackVoucher,
                                                      bonusValue: giftBonus,
                                                    ),
                                                    referralDiscount:
                                                        referralDiscount,
                                                    variationPrice:
                                                        isPassedVariationPrice
                                                            ? variations
                                                            : 0,
                                                    extraDiscount:
                                                        extraDiscount,
                                                    isGift: widget.isGift,
                                                    isGiftVoucher:
                                                        widget.isGiftVoucher,
                                                    isBuyNow: widget.isBuyNow,
                                                    isCashBack:
                                                        isCashBackVoucher,
                                                    bonus: giftBonus,
                                                    isVoucherItem:
                                                        _isVoucherItem(
                                                            _cartList),
                                                    isFlatDiscount:
                                                        isFlatDiscount,
                                                    commissionAmount:
                                                        commissionAmount,
                                                  )),
                                            ]),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            TopSection(
                                              checkoutController:
                                                  checkoutController,
                                              charge: originalCharge,
                                              deliveryCharge: deliveryCharge,
                                              addressList: addressList,
                                              tomorrowClosed: tomorrowClosed,
                                              todayClosed: todayClosed,
                                              module: module,
                                              price: price,
                                              discount: displayDiscount,
                                              addOns: addOns,
                                              address: address,
                                              cartList: _cartList,
                                              isCashOnDeliveryActive:
                                                  _isCashOnDeliveryActive!,
                                              isDigitalPaymentActive:
                                                  _isDigitalPaymentActive!,
                                              isWalletActive: _isWalletActive,
                                              storeId: widget.storeId,
                                              total: total,
                                              isOfflinePaymentActive:
                                                  _isOfflinePaymentActive,
                                              guestNameTextEditingController:
                                                  guestContactPersonNameController,
                                              guestNumberTextEditingController:
                                                  guestContactPersonNumberController,
                                              guestNumberNode: guestNumberNode,
                                              guestEmailController:
                                                  guestEmailController,
                                              guestEmailNode: guestEmailNode,
                                              tooltipController1:
                                                  tooltipController1,
                                              tooltipController2:
                                                  tooltipController2,
                                              dmTipsTooltipController:
                                                  tooltipController3,
                                              guestPasswordController:
                                                  guestPasswordController,
                                              guestConfirmPasswordController:
                                                  guestConfirmPasswordController,
                                              guestPasswordNode:
                                                  guestPasswordNode,
                                              guestConfirmPasswordNode:
                                                  guestConfirmPasswordNode,
                                              variationPrice:
                                                  isPassedVariationPrice
                                                      ? variations
                                                      : 0,
                                              deliveryChargeForView:
                                                  _deliveryChargeForView,
                                              badWeatherCharge:
                                                  badWeatherChargeForToolTip,
                                              extraChargeForToolTip:
                                                  extraChargeForToolTip,
                                            ),
                                            BottomSection(
                                              checkoutController:
                                                  checkoutController,
                                              total: total,
                                              module: module!,
                                              subTotal: subTotalForUI,
                                              discount: displayDiscount,
                                              couponController:
                                                  couponController,
                                              taxIncluded: (checkoutController
                                                      .taxIncluded ==
                                                  1),
                                              tax: checkoutController.orderTax!,
                                              deliveryCharge: deliveryCharge,
                                              todayClosed: todayClosed,
                                              tomorrowClosed: tomorrowClosed,
                                              orderAmount: orderAmount,
                                              maxCodOrderAmount:
                                                  maxCodOrderAmount,
                                              storeId: widget.storeId,
                                              taxPercent: _taxPercent,
                                              price: price,
                                              addOns: addOns,
                                              isPrescriptionRequired:
                                                  isPrescriptionRequired,
                                              checkoutButton: _orderPlaceButton(
                                                checkoutController,
                                                todayClosed,
                                                tomorrowClosed,
                                                orderAmount,
                                                deliveryCharge,
                                                checkoutController.orderTax!,
                                                displayDiscount,
                                                total,
                                                maxCodOrderAmount,
                                                isPrescriptionRequired,
                                                couponDiscount,
                                                referralDiscount,
                                                commissionAmount,
                                                isCashBack: isCashBackVoucher,
                                                bonusValue: giftBonus,
                                              ),
                                              referralDiscount:
                                                  referralDiscount,
                                              variationPrice:
                                                  isPassedVariationPrice
                                                      ? variations
                                                      : 0,
                                              extraDiscount: extraDiscount,
                                              isGift: widget.isGift,
                                              isGiftVoucher:
                                                  widget.isGiftVoucher,
                                              isBuyNow: widget.isBuyNow,
                                              isCashBack: isCashBackVoucher,
                                              bonus: giftBonus,
                                              isVoucherItem:
                                                  _isVoucherItem(_cartList),
                                              isFlatDiscount: isFlatDiscount,
                                              commissionAmount:
                                                  commissionAmount,
                                            )
                                          ]),
                              )),
                            )),
                            ResponsiveHelper.isDesktop(context)
                                ? const SizedBox()
                                : _orderPlaceButton(
                                    checkoutController,
                                    todayClosed,
                                    tomorrowClosed,
                                    orderAmount,
                                    deliveryCharge,
                                    checkoutController.orderTax!,
                                    displayDiscount,
                                    total,
                                    maxCodOrderAmount,
                                    isPrescriptionRequired,
                                    couponDiscount,
                                    referralDiscount,
                                    commissionAmount,
                                    isCashBack: isCashBackVoucher,
                                    bonusValue: giftBonus,
                                    isSticky: true,
                                  ),
                          ],
                        )
                      : const CheckoutScreenShimmerView();
                });
              })
            : NotLoggedInScreen(callBack: (value) {
                initCall();
                setState(() {});
              }),
      ), // Close the WillPopScope child (Scaffold)
    ); // Close the WillPopScope
  }

  Widget _orderPlaceButton(
      CheckoutController checkoutController,
      bool todayClosed,
      bool tomorrowClosed,
      double orderAmount,
      double? deliveryCharge,
      double tax,
      double? discount,
      double total,
      double? maxCodOrderAmount,
      bool isPrescriptionRequired,
      double couponDiscount,
      double referralDiscount,
      double commissionAmount,
      {bool isSticky = false,
      bool isCashBack = false,
      double bonusValue = 0}) {
    final VoidCallback? onPressed = checkoutController.acceptTerms
        ? () {
            bool isAvailable = true;
            DateTime scheduleStartDate = DateTime.now();
            DateTime scheduleEndDate = DateTime.now();
            bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
            if (checkoutController.timeSlots == null ||
                checkoutController.timeSlots!.isEmpty) {
              isAvailable = false;
            } else {
              DateTime date = checkoutController.selectedDateSlot == 0
                  ? DateTime.now()
                  : DateTime.now().add(const Duration(days: 1));
              DateTime startTime = checkoutController
                  .timeSlots![checkoutController.selectedTimeSlot].startTime!;
              DateTime endTime = checkoutController
                  .timeSlots![checkoutController.selectedTimeSlot].endTime!;
              scheduleStartDate = DateTime(date.year, date.month, date.day,
                  startTime.hour, startTime.minute + 1);
              scheduleEndDate = DateTime(date.year, date.month, date.day,
                  endTime.hour, endTime.minute + 1);
              if (_cartList != null) {
                for (CartModel? cart in _cartList!) {
                  if (!DateConverter.isAvailable(
                        cart!.item!.availableTimeStarts,
                        cart.item!.availableTimeEnds,
                        time: checkoutController.store!.scheduleOrder!
                            ? scheduleStartDate
                            : null,
                      ) &&
                      !DateConverter.isAvailable(
                        cart.item!.availableTimeStarts,
                        cart.item!.availableTimeEnds,
                        time: checkoutController.store!.scheduleOrder!
                            ? scheduleEndDate
                            : null,
                      )) {
                    isAvailable = false;
                    break;
                  }
                }
              }
            }

            if (Get.find<ProfileController>().userInfoModel == null ||
                (Get.find<ProfileController>().userInfoModel!.fName == null ||
                    Get.find<ProfileController>()
                        .userInfoModel!
                        .fName!
                        .isEmpty) ||
                (Get.find<ProfileController>().userInfoModel!.phone == null ||
                    Get.find<ProfileController>()
                        .userInfoModel!
                        .phone!
                        .isEmpty) ||
                (Get.find<ProfileController>().userInfoModel!.email == null ||
                    Get.find<ProfileController>()
                        .userInfoModel!
                        .email!
                        .isEmpty)) {
              Get.dialog(ProfileIncompleteDialog(
                onYesPressed: () {
                  Get.back();
                  Get.find<ProfileController>().setFromCheckout(true);
                  Get.toNamed(RouteHelper.getUpdateProfileRoute());
                },
              ));
            } else if (isGuestLogIn &&
                checkoutController.guestAddress == null &&
                checkoutController.orderType != 'take_away') {
              showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
            } else if (isGuestLogIn &&
                checkoutController.orderType == 'take_away' &&
                guestContactPersonNameController.text.isEmpty) {
              showCustomSnackBar('please_enter_contact_person_name'.tr);
            } else if (isGuestLogIn &&
                checkoutController.orderType == 'take_away' &&
                guestContactPersonNumberController.text.isEmpty) {
              showCustomSnackBar('please_enter_contact_person_number'.tr);
            } else if (isGuestLogIn &&
                checkoutController.orderType == 'take_away' &&
                guestEmailController.text.isEmpty) {
              showCustomSnackBar('please_enter_contact_person_email'.tr);
            } else if (isGuestLogIn &&
                checkoutController.isCreateAccount &&
                guestPasswordController.text.isEmpty) {
              showCustomSnackBar('enter_password'.tr);
            } else if (isGuestLogIn &&
                checkoutController.isCreateAccount &&
                guestConfirmPasswordController.text.isEmpty) {
              showCustomSnackBar('enter_confirm_password'.tr);
            } else if (isGuestLogIn &&
                checkoutController.isCreateAccount &&
                (guestPasswordController.text !=
                    guestConfirmPasswordController.text)) {
              showCustomSnackBar('confirm_password_does_not_matched'.tr);
            } else if (isPrescriptionRequired &&
                checkoutController.pickedPrescriptions.isEmpty) {
              showCustomSnackBar(
                  'you_must_upload_prescription_for_this_order'.tr);
            } else if (!_isCashOnDeliveryActive! &&
                !_isDigitalPaymentActive! &&
                !_isWalletActive) {
              showCustomSnackBar('no_payment_method_is_enabled'.tr);
            } else if (checkoutController.paymentMethodIndex == -1) {
              if (ResponsiveHelper.isDesktop(context)) {
                Get.dialog(Dialog(
                    backgroundColor: Colors.transparent,
                    child: PaymentMethodBottomSheet(
                      isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                      isDigitalPaymentActive: _isDigitalPaymentActive!,
                      isWalletActive: _isWalletActive,
                      storeId: widget.storeId,
                      totalPrice: total,
                      isOfflinePaymentActive: _isOfflinePaymentActive,
                    )));
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => PaymentMethodBottomSheet(
                    isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                    isDigitalPaymentActive: _isDigitalPaymentActive!,
                    isWalletActive: _isWalletActive,
                    storeId: widget.storeId,
                    totalPrice: total,
                    isOfflinePaymentActive: _isOfflinePaymentActive,
                  ),
                );
              }
            } else if (orderAmount < checkoutController.store!.minimumOrder! &&
                widget.storeId == null) {
              showCustomSnackBar(
                  '${'minimum_order_amount_is'.tr} ${checkoutController.store!.minimumOrder}');
            } else if (checkoutController.tipController.text.isNotEmpty &&
                checkoutController.tipController.text != 'not_now' &&
                double.parse(checkoutController.tipController.text.trim()) <
                    0) {
              showCustomSnackBar('tips_can_not_be_negative'.tr);
            } else if ((checkoutController.selectedDateSlot == 0 &&
                    todayClosed) ||
                (checkoutController.selectedDateSlot == 1 && tomorrowClosed)) {
              showCustomSnackBar(Get.find<SplashController>()
                      .configModel!
                      .moduleConfig!
                      .module!
                      .showRestaurantText!
                  ? 'restaurant_is_closed'.tr
                  : 'store_is_closed'.tr);
            } else if (checkoutController.paymentMethodIndex == 0 &&
                _isCashOnDeliveryActive! &&
                maxCodOrderAmount != null &&
                maxCodOrderAmount != 0 &&
                (total > maxCodOrderAmount) &&
                widget.storeId == null) {
              showCustomSnackBar(
                  '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
            } else if (checkoutController.paymentMethodIndex != 0 &&
                widget.storeId != null) {
              showCustomSnackBar('payment_method_is_not_available'.tr);
            } else if (checkoutController.timeSlots == null ||
                checkoutController.timeSlots!.isEmpty) {
              if (checkoutController.store!.scheduleOrder!) {
                showCustomSnackBar('select_a_time'.tr);
              } else {
                showCustomSnackBar(Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .showRestaurantText!
                    ? 'restaurant_is_closed'.tr
                    : 'store_is_closed'.tr);
              }
            } else if (!isAvailable) {
              showCustomSnackBar(
                  'one_or_more_products_are_not_available_for_this_selected_time'
                      .tr);
            } else if (checkoutController.orderType != 'take_away' &&
                checkoutController.distance == -1 &&
                deliveryCharge == -1) {
              showCustomSnackBar('delivery_fee_not_set_yet'.tr);
            } else if (widget.storeId != null &&
                checkoutController.pickedPrescriptions.isEmpty) {
              showCustomSnackBar('please_upload_your_prescription_images'.tr);
            } else if (!checkoutController.acceptTerms) {
              showCustomSnackBar(
                  'please_accept_privacy_policy_trams_conditions_refund_policy_first'
                      .tr);
            } else {
              AddressModel? finalAddress = isGuestLogIn
                  ? checkoutController.guestAddress
                  : address[checkoutController.addressIndex!];

              if (isGuestLogIn && checkoutController.orderType == 'take_away') {
                String number = checkoutController.countryDialCode! +
                    guestContactPersonNumberController.text;
                finalAddress = AddressModel(
                  contactPersonName: guestContactPersonNameController.text,
                  contactPersonNumber: number,
                  address:
                      AddressHelper.getUserAddressFromSharedPref()!.address!,
                  latitude:
                      AddressHelper.getUserAddressFromSharedPref()!.latitude,
                  longitude:
                      AddressHelper.getUserAddressFromSharedPref()!.longitude,
                  zoneId: AddressHelper.getUserAddressFromSharedPref()!.zoneId,
                  email: guestEmailController.text,
                );
              }

              if (!isGuestLogIn &&
                  finalAddress!.contactPersonNumber == 'null') {
                finalAddress.contactPersonNumber =
                    Get.find<ProfileController>().userInfoModel!.phone;
              }

              if (widget.storeId == null) {
                List<OnlineCart> carts = [];
                GiftDetails? globalGiftDetails;

                // Group BOGO items to handle max pricing in payload
                Map<String, List<CartModel>> bogoGroups = {};
                var activeCartList =
                    (_cartList ?? []).whereType<CartModel>().toList();

                for (var cart in activeCartList) {
                  if (cart.cartGroupId != null) {
                    bool isBogo = false;
                    for (var cm in activeCartList) {
                      if (cm.cartGroupId == cart.cartGroupId &&
                          cm.item?.type == 'voucher' &&
                          cm.item?.bundleType == 'bogo_free') {
                        isBogo = true;
                        break;
                      }
                    }
                    if (isBogo) {
                      bogoGroups
                          .putIfAbsent(cart.cartGroupId!, () => [])
                          .add(cart);
                    }
                  }
                }

                // Map to store which items are "free"
                Map<int, bool> freeItems = {};
                bogoGroups.forEach((groupId, items) {
                  double maxTotal = 0;
                  CartModel? maxItem;

                  for (var cartModel in items) {
                    if (cartModel.item!.type == 'voucher') continue;

                    double? discount = cartModel.item!.discount;
                    String? discountType = cartModel.item!.discountType;

                    // Apply voucher discount context
                    for (CartModel cm in activeCartList) {
                      if (cm.cartGroupId == groupId &&
                          cm.item?.type == 'voucher') {
                        discount = cm.item!.discount;
                        discountType = cm.item!.discountType;
                        break;
                      }
                    }

                    bool isFoodVariation = Get.find<SplashController>()
                        .getModuleConfig(cartModel.item!.moduleType)
                        .newVariation!;
                    double itemAddonsPrice = 0;
                    if (cartModel.addOnIds != null) {
                      List<AddOns> addOnList = Get.find<CartController>()
                          .addOnsList[_cartList!.indexOf(cartModel)];
                      for (int i = 0; i < addOnList.length; i++) {
                        itemAddonsPrice += (addOnList[i].price ?? 0) *
                            (cartModel.addOnIds![i].quantity ?? 1) *
                            (cartModel.quantity ?? 1);
                      }
                    }

                    double itemVariationPrice = 0;
                    if (isFoodVariation &&
                        cartModel.item!.foodVariations != null) {
                      for (int i = 0;
                          i < cartModel.item!.foodVariations!.length;
                          i++) {
                        for (int j = 0;
                            j <
                                cartModel.item!.foodVariations![i]
                                    .variationValues!.length;
                            j++) {
                          if (cartModel.foodVariations![i][j]!) {
                            itemVariationPrice +=
                                (PriceConverter.convertWithDiscount(
                                            cartModel
                                                    .item!
                                                    .foodVariations![i]
                                                    .variationValues![j]
                                                    .optionPrice ??
                                                0,
                                            discount,
                                            discountType,
                                            isFoodVariation: true) ??
                                        0) *
                                    cartModel.quantity!;
                          }
                        }
                      }
                    }

                    double itemBasePrice = (PriceConverter.convertWithDiscount(
                            cartModel.item!.price!, discount, discountType)! *
                        cartModel.quantity!);
                    double itemTotal =
                        itemBasePrice + itemAddonsPrice + itemVariationPrice;

                    if (itemTotal > maxTotal) {
                      maxTotal = itemTotal;
                      maxItem = cartModel;
                    } else if (itemTotal == maxTotal && maxItem == null) {
                      maxItem = cartModel;
                    }
                  }

                  for (var cm in items) {
                    if (cm != maxItem && cm.item!.type != 'voucher') {
                      freeItems[cm.id!] = true;
                    }
                  }
                });

                for (int index = 0; index < _cartList!.length; index++) {
                  CartModel cart = _cartList![index]!;
                  bool isFreeBogoItem = freeItems.containsKey(cart.id);

                  List<int?> addOnIdList = [];
                  List<int?> addOnQtyList = [];
                  for (var addOn in cart.addOnIds!) {
                    addOnIdList.add(addOn.id);
                    addOnQtyList.add(addOn.quantity);
                  }

                  List<OrderVariation> variations = [];
                  if (Get.find<SplashController>()
                      .getModuleConfig(cart.item!.moduleType)
                      .newVariation!) {
                    for (int i = 0;
                        i < cart.item!.foodVariations!.length;
                        i++) {
                      if (cart.foodVariations![i].contains(true)) {
                        List<OrderVariationValue> values = [];
                        if (cart.item!.foodVariations![i].variationValues !=
                            null) {
                          for (int j = 0;
                              j <
                                  cart.item!.foodVariations![i].variationValues!
                                      .length;
                              j++) {
                            if (cart.foodVariations![i][j]!) {
                              double originalPrice = cart
                                      .item!
                                      .foodVariations![i]
                                      .variationValues![j]
                                      .optionPrice ??
                                  0;

                              double finalPrice =
                                  isFreeBogoItem ? 0 : originalPrice;

                              // Check for voucher discount if not already free
                              if (!isFreeBogoItem) {
                                double? voucherDiscount;
                                String? voucherDiscountType;

                                if (cart.item!.type == 'voucher') {
                                  voucherDiscount = cart.item!.discount;
                                  voucherDiscountType = cart.item!.discountType;
                                } else if (cart.cartGroupId != null) {
                                  for (var c in activeCartList) {
                                    if (c.cartGroupId == cart.cartGroupId &&
                                        c.item?.type == 'voucher') {
                                      voucherDiscount = c.item?.discount;
                                      voucherDiscountType =
                                          c.item?.discountType;
                                      break;
                                    }
                                  }
                                }

                                if (voucherDiscount != null &&
                                    voucherDiscount > 0) {
                                  finalPrice =
                                      PriceConverter.convertWithDiscount(
                                            originalPrice,
                                            voucherDiscount,
                                            voucherDiscountType,
                                            isFoodVariation: true,
                                          ) ??
                                          originalPrice;
                                }
                              }

                              values.add(OrderVariationValue(
                                label: cart.item!.foodVariations![i]
                                    .variationValues![j].level,
                                optionPrice: finalPrice.toString(),
                              ));
                            }
                          }
                        }
                        variations.add(OrderVariation(
                          name: cart.item!.foodVariations![i].name,
                          type:
                              cart.item!.foodVariations![i].multiSelect ?? false
                                  ? 'multi'
                                  : 'single',
                          min: cart.item!.foodVariations![i].min ?? 0,
                          max: cart.item!.foodVariations![i].max ?? 0,
                          required:
                              (cart.item!.foodVariations![i].required ?? false)
                                  ? 'on'
                                  : 'off',
                          values: values,
                        ));
                      }
                    }
                  }

                  // Handle add-ons for free items
                  List<AddOns>? addOnsForPayload;
                  if (isFreeBogoItem && cart.addOns != null) {
                    addOnsForPayload = cart.addOns!
                        .map((a) => AddOns(id: a.id, name: a.name, price: 0))
                        .toList();
                  } else {
                    addOnsForPayload = cart.addOns;
                  }

                  carts.add(OnlineCart(
                    cart.id,
                    cart.item!.id,
                    cart.isCampaign! ? cart.item!.id : null,
                    ((cart.item!.type == 'voucher' &&
                                    cart.item!.bundleType != 'simple x') ||
                                isFreeBogoItem
                            ? 0.0
                            : cart.discountedPrice)
                        .toString(),
                    '',
                    Get.find<SplashController>()
                            .getModuleConfig(cart.item!.moduleType)
                            .newVariation!
                        ? null
                        : cart.variation,
                    Get.find<SplashController>()
                            .getModuleConfig(cart.item!.moduleType)
                            .newVariation!
                        ? variations
                        : null,
                    cart.quantity,
                    addOnIdList,
                    addOnsForPayload,
                    addOnQtyList,
                    'Item',
                    itemType: cart.isCampaign! ? "AppModelsItemCampaign" : null,
                    giftDetails: cart.giftDetails ??
                        (widget.isGift
                            ? GiftDetails(
                                senderName:
                                    '${Get.find<ProfileController>().userInfoModel!.fName} ${Get.find<ProfileController>().userInfoModel!.lName}',
                                recipientName: checkoutController
                                    .giftNameController.text
                                    .trim(),
                                message: checkoutController
                                    .giftMessageController.text
                                    .trim(),
                              )
                            : null),
                    discountAmount: cart.discountAmount,
                  ));

                  if (globalGiftDetails == null &&
                      carts[carts.length - 1].giftDetails != null) {
                    globalGiftDetails = carts[carts.length - 1].giftDetails;
                  }
                }

                // Detect if this is a cash back voucher and calculate orderAmountForAPI
                bool isCashBackVoucher = false;
                if (_cartList != null && _cartList!.isNotEmpty) {
                  for (CartModel? cart in _cartList!) {
                    if (cart != null &&
                        cart.item != null &&
                        cart.item!.type == 'voucher' &&
                        cart.item!.offerType?.toLowerCase() == 'cash back') {
                      isCashBackVoucher = true;
                      break;
                    }
                  }
                }
                if (widget.isGiftVoucher) {
                  isCashBackVoucher = true;
                }

                // For cash back vouchers, send full amount (without discount) to API
                // For regular vouchers, send discounted amount as usual
                double orderAmountForAPI = orderAmount;
                if (isCashBackVoucher) {
                  // Add back the discount to get full amount
                  orderAmountForAPI = orderAmount + (discount ?? 0);
                  print('[CASHBACK_DEBUG] isCashBack: $isCashBackVoucher');
                  print(
                      '[CASHBACK_DEBUG] orderAmount (discounted): $orderAmount');
                  print('[CASHBACK_DEBUG] discount: $discount');
                  print(
                      '[CASHBACK_DEBUG] orderAmountForAPI (full): $orderAmountForAPI');
                }

                print(
                    '[ORDER_DEBUG] Final orderAmountForAPI before PlaceOrderBodyModel: $orderAmountForAPI');

                // Detect if this is a flat voucher
                bool hasFlatVoucher = false;
                if (_cartList != null && _cartList!.isNotEmpty) {
                  for (CartModel? cart in _cartList!) {
                    if (cart != null &&
                        cart.item != null &&
                        cart.item!.type == 'voucher' &&
                        cart.item!.bundleType != 'bogo_free' &&
                        cart.item!.bundleType != 'simple x' &&
                        cart.item!.bundleType != 'mix_match' &&
                        cart.item!.bundleType != 'gift' &&
                        cart.giftDetails == null &&
                        !(cart.item!.product?.isNotEmpty ?? false)) {
                      hasFlatVoucher = true;
                      break;
                    }
                  }
                }

                PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                  cart: carts,
                  giftDetails: globalGiftDetails,
                  couponDiscountAmount: Get.find<CouponController>().discount,
                  distance: checkoutController.distance,
                  scheduleAt: !checkoutController.store!.scheduleOrder!
                      ? null
                      : (checkoutController.selectedDateSlot == 0 &&
                              checkoutController.selectedTimeSlot == 0)
                          ? null
                          : DateConverter.dateToDateAndTime(scheduleEndDate),
                  orderAmount: orderAmountForAPI,
                  commissionAmount: commissionAmount,
                  orderNote: checkoutController.noteController.text,
                  orderType: hasFlatVoucher ? "" : checkoutController.orderType,
                  paymentMethod: checkoutController.paymentMethodIndex == 0
                      ? 'cash_on_delivery'
                      : checkoutController.paymentMethodIndex == 1
                          ? 'wallet'
                          : checkoutController.paymentMethodIndex == 2
                              ? 'digital_payment'
                              : 'offline_payment',
                  couponCode: (Get.find<CouponController>().discount! > 0 ||
                          (Get.find<CouponController>().coupon != null &&
                              Get.find<CouponController>().freeDelivery))
                      ? Get.find<CouponController>().coupon!.code
                      : null,
                  storeId: _cartList![0]!.item!.storeId,
                  address: finalAddress!.address,
                  latitude: finalAddress.latitude,
                  longitude: finalAddress.longitude,
                  senderZoneId: null,
                  addressType: finalAddress.addressType,
                  contactPersonName: finalAddress.contactPersonName ??
                      '${Get.find<ProfileController>().userInfoModel!.fName} '
                          '${Get.find<ProfileController>().userInfoModel!.lName}',
                  contactPersonNumber: finalAddress.contactPersonNumber ??
                      Get.find<ProfileController>().userInfoModel!.phone,
                  streetNumber: isGuestLogIn
                      ? finalAddress.streetNumber ?? ''
                      : checkoutController.streetNumberController.text.trim(),
                  house: isGuestLogIn
                      ? finalAddress.house ?? ''
                      : checkoutController.houseController.text.trim(),
                  floor: isGuestLogIn
                      ? finalAddress.floor ?? ''
                      : checkoutController.floorController.text.trim(),
                  discountAmount: discount ?? 0,
                  taxAmount: tax,
                  receiverDetails: null,
                  parcelCategoryId: null,
                  chargePayer: null,
                  dmTips: (checkoutController.orderType == 'take_away' ||
                          checkoutController.tipController.text == 'not_now')
                      ? ''
                      : checkoutController.tipController.text.trim(),
                  cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                  unavailableItemNote:
                      Get.find<CartController>().notAvailableIndex != -1
                          ? Get.find<CartController>().notAvailableList[
                              Get.find<CartController>().notAvailableIndex]
                          : '',
                  deliveryInstruction:
                      checkoutController.selectedInstruction != -1
                          ? AppConstants.deliveryInstructionList[
                              checkoutController.selectedInstruction]
                          : '',
                  partialPayment: checkoutController.isPartialPay ? 1 : 0,
                  guestId:
                      isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
                  isBuyNow: widget.fromCart ? 0 : 1,
                  guestEmail: isGuestLogIn ? finalAddress.email : null,
                  extraPackagingAmount:
                      Get.find<CartController>().needExtraPackage
                          ? checkoutController.store!.extraPackagingAmount
                          : 0,
                  createNewUser: checkoutController.isCreateAccount ? 1 : 0,
                  password: guestPasswordController.text,
                );

                if (kDebugMode) {
                  print(
                      '[COMMISSION_API_CHECK] 🚀 Commission in Body: $commissionAmount');
                  print(
                      '[COMMISSION_API_CHECK] 📦 Full JSON: ${placeOrderBody.toJson()['commission_amount']}');
                }

                if (checkoutController.paymentMethodIndex == 3) {
                  Get.toNamed(RouteHelper.getOfflinePaymentScreen(
                    placeOrderBody: placeOrderBody,
                    zoneId: checkoutController.store!.zoneId!,
                    total: checkoutController.viewTotalPrice!,
                    maxCodOrderAmount: maxCodOrderAmount,
                    fromCart: widget.fromCart,
                    isCodActive: _isCashOnDeliveryActive,
                    forParcel: false,
                  ));
                } else {
                  checkoutController.placeOrder(
                      placeOrderBody,
                      checkoutController.store!.zoneId,
                      orderAmountForAPI,
                      maxCodOrderAmount,
                      widget.fromCart,
                      _isCashOnDeliveryActive!,
                      checkoutController.pickedPrescriptions);
                }
              } else {
                checkoutController.placePrescriptionOrder(
                  widget.storeId,
                  checkoutController.store!.zoneId,
                  checkoutController.distance,
                  finalAddress!.address!,
                  finalAddress.longitude!,
                  finalAddress.latitude!,
                  checkoutController.noteController.text,
                  checkoutController.pickedPrescriptions,
                  (checkoutController.orderType == 'take_away' ||
                          checkoutController.tipController.text == 'not_now')
                      ? ''
                      : checkoutController.tipController.text.trim(),
                  checkoutController.selectedInstruction != -1
                      ? AppConstants.deliveryInstructionList[
                          checkoutController.selectedInstruction]
                      : '',
                  0,
                  0,
                  widget.fromCart,
                  _isCashOnDeliveryActive!,
                );
              }
            }
          }
        : null;

    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      margin: isSticky
          ? const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0,
              Dimensions.paddingSizeDefault, 0)
          : null,
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeLarge,
          horizontal: Dimensions.paddingSizeLarge),
      decoration: isSticky
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusExtraLarge)),
              boxShadow: [
                BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, -2))
              ],
            )
          : null,
      child: SafeArea(
        child: isSticky
            ? Row(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          (checkoutController.isPartialPay
                                  ? 'due_payment'
                                  : 'total_amount')
                              .tr
                              .toUpperCase(),
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor)),
                      Row(children: [
                        Text(
                          _formatExactPrice(
                              checkoutController.viewTotalPrice ?? 0),
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).primaryColor),
                          textDirection: TextDirection.ltr,
                        ),
                        ((discount! > 0 ||
                                    couponDiscount > 0 ||
                                    referralDiscount > 0 ||
                                    (widget.isGiftVoucher && bonusValue > 0)) &&
                                (!isCashBack || widget.isGiftVoucher))
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: Dimensions.paddingSizeExtraSmall),
                                child: Text(
                                  PriceConverter.convertPrice(total +
                                      discount +
                                      couponDiscount +
                                      referralDiscount),
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              )
                            : const SizedBox(),
                      ]),
                    ]),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    isLoading: checkoutController.isLoading,
                    buttonText: 'pay_now'.tr,
                    icon: Icons.arrow_forward,
                    iconRight: true,
                    onPressed: onPressed,
                  ),
                ),
              ])
            : CustomButton(
                isLoading: checkoutController.isLoading,
                buttonText: 'place_order'.tr,
                onPressed: onPressed,
              ),
      ),
    );
  }

  String _formatExactPrice(double value) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String symbol = Get.find<SplashController>().configModel!.currencySymbol!;
    String priceStr = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    return isRightSide ? '$priceStr $symbol' : '$symbol$priceStr';
  }

  List<DropdownItem<int>> _getDropdownAddressList(
      {required BuildContext context,
      required List<AddressModel>? addressList,
      required Store? store}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    dropDownAddressList.add(DropdownItem<int>(
        value: 0,
        child: SizedBox(
          width: context.width > Dimensions.webMaxWidth
              ? Dimensions.webMaxWidth - 50
              : context.width - 50,
          child: AddressWidget(
            address: AddressHelper.getUserAddressFromSharedPref(),
            fromAddress: false,
            fromCheckout: true,
          ),
        )));

    if (addressList != null && store != null) {
      for (int index = 0; index < addressList.length; index++) {
        if (addressList[index].zoneIds!.contains(store.zoneId)) {
          dropDownAddressList.add(DropdownItem<int>(
              value: index + 1,
              child: SizedBox(
                width: context.width > Dimensions.webMaxWidth
                    ? Dimensions.webMaxWidth - 50
                    : context.width - 50,
                child: AddressWidget(
                  address: addressList[index],
                  fromAddress: false,
                  fromCheckout: true,
                ),
              )));
        }
      }
    }
    return dropDownAddressList;
  }

  List<AddressModel> _getAddressList(
      {required List<AddressModel>? addressList, required Store? store}) {
    List<AddressModel> address = [];

    address.add(AddressHelper.getUserAddressFromSharedPref()!);

    if (addressList != null && store != null) {
      for (int index = 0; index < addressList.length; index++) {
        if (addressList[index].zoneIds!.contains(store.zoneId)) {
          address.add(addressList[index]);
        }
      }
    }
    return address;
  }

  Pivot? _getModuleData({required Store? store}) {
    Pivot? moduleData;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (store != null && address != null && address.zoneData != null) {
      for (ZoneData zData in address.zoneData!) {
        if (zData.modules != null) {
          for (Modules m in zData.modules!) {
            if (m.id == Get.find<SplashController>().module?.id &&
                m.pivot?.zoneId == store.zoneId) {
              moduleData = m.pivot;
              break;
            }
          }
        }
      }
    }
    return moduleData;
  }

  bool _checkCODActive({required Store? store}) {
    bool isCashOnDeliveryActive = false;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (store != null && address != null && address.zoneData != null) {
      for (ZoneData zData in address.zoneData!) {
        if (zData.id == store.zoneId) {
          isCashOnDeliveryActive = (zData.cashOnDelivery ?? false) &&
              (Get.find<SplashController>().configModel?.cashOnDelivery ??
                  false);
        }
      }
    }
    return isCashOnDeliveryActive;
  }

  bool _checkDigitalPaymentActive({required Store? store}) {
    bool isDigitalPaymentActive = false;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (store != null && address != null && address.zoneData != null) {
      for (ZoneData zData in address.zoneData!) {
        if (zData.id == store.zoneId) {
          isDigitalPaymentActive = (zData.digitalPayment ?? false) &&
              (Get.find<SplashController>().configModel?.digitalPayment ??
                  false);
        }
      }
    }
    return isDigitalPaymentActive;
  }

  double _calculatePrice(
      {required Store? store, required List<CartModel?>? cartList}) {
    double price = 0;
    if (cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel != null && cartModel.item != null) {
          double? discount = cartModel.item!.discount;
          String? discountType = cartModel.item!.discountType;

          bool isBogoGroup = false;
          bool isMixMatchGroup = false;
          bool isVoucherGroup = false;
          if (cartModel.cartGroupId != null) {
            for (var c in cartList) {
              if (c != null &&
                  c.cartGroupId == cartModel.cartGroupId &&
                  c.item?.type == 'voucher') {
                isVoucherGroup = true;
                if (c.item?.bundleType == 'bogo_free') isBogoGroup = true;
                if (c.item?.bundleType == 'mix_match') isMixMatchGroup = true;
              }
            }
          }

          bool isBogoVoucher = cartModel.item!.type == 'voucher' &&
              cartModel.item!.bundleType == 'bogo_free';

          // Adjust for Customer Commission
          if (store != null &&
              store.commissionPaidBy == 'customer' &&
              store.comission != null &&
              store.comission! > 0 &&
              discount != null &&
              discount > 0 &&
              !isBogoGroup &&
              !isBogoVoucher) {
            if (discountType == 'percent') {
              // Price-independent formula for percentage discounts:
              discount = discount - (1 - discount / 100) * store.comission!;
              discountType = 'percent';
            } else {
              // For amount discounts, we still need a reference price
              double priceForFormula = (cartModel.item!.bundleType ==
                      'simple x')
                  ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
                  : (cartModel.price != null && cartModel.price != 0)
                      ? cartModel.price!
                      : (cartModel.item!.price ??
                          (cartModel.item!.actualPrice ?? 100));

              if (priceForFormula > 0) {
                double dAmount = discount;
                double afterD = priceForFormula - dAmount;
                double comm = afterD * (store.comission! / 100);
                discount = ((dAmount - comm) / priceForFormula) * 100;
                discountType = 'percent';
              }
            }
          }

          if (Get.find<SplashController>()
              .getModuleConfig(cartModel.item!.moduleType)
              .newVariation!) {
            bool isVoucher = cartModel.item!.type == 'voucher';
            bool isFlatVoucher = isVoucher &&
                (cartModel.type == 'Flat discount' ||
                    cartModel.item!.voucherIds == 'Flat discount');
            // Comprehensive gift detection
            bool isGift = cartModel.type == 'Gift' ||
                cartModel.item!.voucherIds == 'Gift' ||
                cartModel.item!.bundleType == 'gift';
            bool isVoucherNestedProduct =
                cartModel.item!.type != 'voucher' && isVoucherGroup;

            bool isSimpleX =
                isVoucher && cartModel.item!.bundleType == 'simple x';
            bool isSimpleBundleVoucher = isVoucher &&
                (cartModel.item!.product?.isNotEmpty ?? false) &&
                cartModel.item!.bundleType != 'bogo_free' &&
                cartModel.item!.bundleType != 'mix_match';
            bool isMixMatchVoucher =
                isVoucher && cartModel.item!.bundleType == 'mix_match';

            if ((isVoucher &&
                    !isFlatVoucher &&
                    !isGift &&
                    !isSimpleX &&
                    !isMixMatchVoucher &&
                    !isSimpleBundleVoucher) ||
                (isVoucherNestedProduct && (isBogoGroup || isMixMatchGroup))) {
              continue;
            }

            double p = (isFlatVoucher || isGift)
                ? (cartModel.price ?? 0)
                : (isSimpleX
                    ? (cartModel.item!.actualPrice ??
                        cartModel.item!.price ??
                        0)
                    : (cartModel.price ?? cartModel.item!.price ?? 0));

            // Hide base price for bundle voucher parent (sum comes from products)
            if (isVoucher &&
                (isSimpleBundleVoucher ||
                    isMixMatchVoucher ||
                    isBogoGroup ||
                    isBogoVoucher)) {
              p = 0;
            }

            // Price logic for nested items
            if (isVoucherNestedProduct) {
              if (cartModel.item!.foodVariations != null) {
                // If variations exist, they provide the price in _calculateVariationPrice
                p = 0;
              } else if ((cartModel.price == null || cartModel.price == 0)) {
                // For nested items with no variations, use catalog base price for discount calculation
                // This applies to Simple Bundle, Mix & Match (but not BOGO which uses combo logic)
                if (!isBogoGroup) {
                  p = cartModel.item!.price ?? 0;
                }
              }
            }

            if (isVoucherGroup || isVoucher) {
              print('[BOGO_TRACE] Processing item: ${cartModel.item!.name}');
              print(
                  '  - isVoucher: $isVoucher, isVoucherNestedProduct: $isVoucherNestedProduct');
              print(
                  '  - Base price p: $p (cartModel.price: ${cartModel.price}, item.price: ${cartModel.item!.price})');
              print(
                  '  - isBogoGroup: $isBogoGroup, isMixMatchGroup: $isMixMatchGroup');
            }

            price = price + (p * (cartModel.quantity ?? 1));
          } else {
            price = _calculateVariationPrice(store: store, cartList: cartList);
          }
        }
      }
    }
    return price;
  }

  double _calculateAddonsPrice(
      {required Store? store, required List<CartModel?>? cartList}) {
    double addOns = 0;
    if (store != null && cartList != null) {
      // 1. Build a Global Addon Map (Pre-scan everything for metadata)
      Map<int, AddOns> globalAddonMetadataPool = {};

      void addToGlobalPool(AddOns addon) {
        if (addon.id == null) return;
        if (!globalAddonMetadataPool.containsKey(addon.id)) {
          globalAddonMetadataPool[addon.id!] = addon;
        } else {
          // Upgrade logic for global pool: Null price/name -> Valid price/name
          AddOns existing = globalAddonMetadataPool[addon.id!]!;
          bool shouldUpgrade = false;
          if (existing.price == null && addon.price != null) {
            shouldUpgrade = true;
          } else if (existing.name == null && addon.name != null) {
            shouldUpgrade = true;
          }
          if (shouldUpgrade) {
            globalAddonMetadataPool[addon.id!] = addon;
          }
        }
      }

      for (var cartModel in cartList) {
        if (cartModel?.item != null) {
          // Scan cartModel.addOns (Service Layer)
          if (cartModel!.addOns != null) {
            for (var a in cartModel.addOns!) {
              addToGlobalPool(a);
            }
          }
          // Scan Item Definition
          if (cartModel.item!.addOns != null) {
            for (var a in cartModel.item!.addOns!) {
              addToGlobalPool(a);
            }
          }
          // Scan Nested Products
          if (cartModel.item!.product != null) {
            for (var p in cartModel.item!.product!) {
              if (p.addOns != null) {
                for (var a in p.addOns!) {
                  addToGlobalPool(a);
                }
              }
            }
          }
          if (cartModel.item!.productB != null) {
            for (var p in cartModel.item!.productB!) {
              if (p.addOns != null) {
                for (var a in p.addOns!) {
                  addToGlobalPool(a);
                }
              }
            }
          }
        }
      }
      print(
          '[CHECKOUT_DEBUG] 🌍 Global metadata pool initialized with ${globalAddonMetadataPool.length} unique addons');
      globalAddonMetadataPool.forEach((key, value) {
        print(
            '[CHECKOUT_DEBUG] 🎱 Pool Item: ID=$key, Name=${value.name}, Price=${value.price}');
      });

      // 2. Main calculation loop
      for (var cartModel in cartList) {
        if (cartModel != null &&
            cartModel.addOnIds != null &&
            cartModel.item != null) {
          for (var addOn in cartModel.addOnIds!) {
            if (addOn.id != null) {
              AddOns? addonMetadata = globalAddonMetadataPool[addOn.id!];

              if (addonMetadata != null && addonMetadata.price != null) {
                int quantity = addOn.quantity ?? 0;

                // Multiply by quantity and parent item quantity
                addOns = addOns +
                    (addonMetadata.price! *
                        quantity *
                        (cartModel.quantity ?? 1));
                print(
                    '[CHECKOUT_DEBUG] ✅ Found addon: ID=${addOn.id}, Name=${addonMetadata.name}, Price=${addonMetadata.price} x $quantity');
              } else {
                print(
                    '[CHECKOUT_DEBUG] ! Addon ID ${addOn.id} not found in global pool or has null price - skipping');
              }
            }
          }
        }
      }
    }
    return addOns;
  }

  double _calculateVariationPrice(
      {required Store? store,
      required List<CartModel?>? cartList,
      bool calculateDiscount = false,
      bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel == null || cartModel.item == null) continue;

        // Check if this is a BOGO group member
        bool isBogoGroup = false;
        String? bogoGroupId;
        if (cartModel.cartGroupId != null) {
          for (var c in cartList) {
            if (c != null &&
                c.cartGroupId == cartModel.cartGroupId &&
                c.item?.type == 'voucher' &&
                c.item?.bundleType == 'bogo_free') {
              isBogoGroup = true;
              bogoGroupId = cartModel.cartGroupId;
              break;
            }
          }
        }

        // Skip variations for BOGO nested items here (processed via parent Voucher).
        if (isBogoGroup && cartModel.item!.type != 'voucher') {
          continue;
        }

        double? discount = cartModel.item!.discount;
        String? discountType = cartModel.item!.discountType;

        bool isBogoVoucher = cartModel.item!.type == 'voucher' &&
            cartModel.item!.bundleType == 'bogo_free';

        // Adjust for Customer Commission
        if (store.commissionPaidBy == 'customer' &&
            store.comission != null &&
            store.comission! > 0 &&
            discount != null &&
            discount > 0 &&
            !isBogoGroup &&
            !isBogoVoucher) {
          if (discountType == 'percent') {
            // Price-independent formula for percentage discounts:
            discount = discount - (1 - discount / 100) * store.comission!;
            discountType = 'percent';
          } else {
            // For amount discounts, we still need a reference price
            double priceForFormula = (cartModel.item!.bundleType == 'simple x')
                ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
                : (cartModel.price != null && cartModel.price != 0)
                    ? cartModel.price!
                    : (cartModel.item!.price ??
                        (cartModel.item!.actualPrice ?? 100));

            if (priceForFormula > 0) {
              double dAmount = discount;
              double afterD = priceForFormula - dAmount;
              double comm = afterD * (store.comission! / 100);
              discount = ((dAmount - comm) / priceForFormula) * 100;
              discountType = 'percent';
            }
          }
        }

        // For BOGO, we want to calculate the FULL price of the expensive item
        // because the "discount" part is handled separately by bogoFreeDiscount.
        double? bogoInternalDiscount =
            (isBogoGroup || isBogoVoucher) ? 0 : discount;
        String? bogoInternalDiscountType =
            (isBogoGroup || isBogoVoucher) ? 'percent' : discountType;

        bool isSimpleX = cartModel.item!.type == 'voucher' &&
            cartModel.item!.bundleType == 'simple x';

        bool isVoucherGroup = false;
        if (cartModel.cartGroupId != null &&
            cartModel.item!.type != 'voucher') {
          for (var c in cartList) {
            if (c != null &&
                c.cartGroupId == cartModel.cartGroupId &&
                c.item?.type == 'voucher') {
              isVoucherGroup = true;
              break;
            }
          }
        }
        bool isVoucherNestedProduct =
            cartModel.item!.type != 'voucher' && isVoucherGroup;

        if (Get.find<SplashController>()
            .getModuleConfig(cartModel.item!.moduleType)
            .newVariation!) {
          isPassedVariationPrice = true;

          if (isBogoGroup && cartModel.item!.type == 'voucher') {
            // Process all items in this BOGO group and take the max
            double maxComboPrice = 0;
            double maxComboDiscountPrice = 0;

            print('[BOGO_TRACE] Voucher processing: ${cartModel.item!.name}');
            for (var groupMember in cartList!) {
              if (groupMember != null &&
                  groupMember.cartGroupId == cartModel.cartGroupId &&
                  groupMember.item?.type != 'voucher') {
                print(
                    '  - BOGO Member Found: ${groupMember.item!.name} (price: ${groupMember.price})');
                double memberVarPrice = 0;
                double memberVarDiscount = 0;
                bool memberVariationSelected = false;

                if (groupMember.item!.foodVariations != null &&
                    groupMember.foodVariations != null) {
                  for (int index = 0;
                      index < groupMember.item!.foodVariations!.length;
                      index++) {
                    if (groupMember
                                .item!.foodVariations![index].variationValues !=
                            null &&
                        groupMember.foodVariations!.length > index) {
                      for (int i = 0;
                          i <
                              groupMember.item!.foodVariations![index]
                                  .variationValues!.length;
                          i++) {
                        if (groupMember.foodVariations![index].length > i &&
                            (groupMember.foodVariations![index][i] ?? false)) {
                          memberVariationSelected = true;
                          if (groupMember.item!.foodVariations![index]
                                  .variationValues![i].optionPrice !=
                              null) {
                            memberVarPrice +=
                                (PriceConverter.convertWithDiscount(
                                        groupMember.item!.foodVariations![index]
                                            .variationValues![i].optionPrice!,
                                        bogoInternalDiscount,
                                        bogoInternalDiscountType,
                                        isFoodVariation: true)! *
                                    (groupMember.quantity ?? 1));
                            memberVarDiscount += (groupMember
                                    .item!
                                    .foodVariations![index]
                                    .variationValues![i]
                                    .optionPrice! *
                                (groupMember.quantity ?? 1));
                          }
                        }
                      }
                    }
                  }
                }

                // Add base price to the combo for max comparison (IF no variations selected)
                // Use catalog price (item.price) as fallback when cart price is 0 (BOGO items
                // are sent with price:0 because the API marks them as free/paid-by-voucher).
                double baseCartPrice =
                    (groupMember.price != null && groupMember.price != 0)
                        ? groupMember.price!
                        : (groupMember.item?.price ?? 0);
                double memberBasePrice = 0;
                if (!memberVariationSelected && baseCartPrice > 0) {
                  memberBasePrice = (PriceConverter.convertWithDiscount(
                          baseCartPrice,
                          bogoInternalDiscount,
                          bogoInternalDiscountType)! *
                      (groupMember.quantity ?? 1));
                }
                double memberBaseDiscount =
                    (!memberVariationSelected && baseCartPrice > 0)
                        ? baseCartPrice * (groupMember.quantity ?? 1)
                        : 0;

                print('    - memberVarPrice: $memberVarPrice');
                print(
                    '    - memberBasePrice: $memberBasePrice (catalogFallback: $baseCartPrice)');

                if ((memberVarPrice + memberBasePrice) > maxComboPrice) {
                  maxComboPrice = memberVarPrice + memberBasePrice;
                  maxComboDiscountPrice =
                      memberVarDiscount + memberBaseDiscount;
                }
              }
            }
            print('  - Final maxComboPrice: $maxComboPrice');

            variationPrice += maxComboPrice;
            variationDiscount += maxComboDiscountPrice;
          } else if (cartModel.item!.foodVariations != null &&
              cartModel.foodVariations != null) {
            bool variationSelected = false;

            for (int index = 0;
                index < cartModel.item!.foodVariations!.length;
                index++) {
              if (cartModel.item!.foodVariations![index].variationValues !=
                      null &&
                  cartModel.foodVariations!.length > index) {
                for (int i = 0;
                    i <
                        cartModel.item!.foodVariations![index].variationValues!
                            .length;
                    i++) {
                  if (cartModel.foodVariations![index].length > i &&
                      (cartModel.foodVariations![index][i] ?? false)) {
                    variationSelected = true;
                    if (cartModel.item!.foodVariations![index]
                            .variationValues![i].optionPrice !=
                        null) {
                      double op = cartModel.item!.foodVariations![index]
                          .variationValues![i].optionPrice!;
                      variationPrice += (isSimpleX
                              ? op
                              : PriceConverter.convertWithDiscount(
                                  op, discount, discountType,
                                  isFoodVariation: true)!) *
                          (cartModel.quantity ?? 1);
                      variationDiscount += (op * (cartModel.quantity ?? 1));
                    }
                  }
                }
              }
            }

            // Fallback for base price if NO variations selected but they exist
            if (!variationSelected &&
                isVoucherNestedProduct &&
                (cartModel.item!.price != null && cartModel.item!.price != 0)) {
              // For nested products, inherit discount from parent voucher
              double? nestedDiscount = discount;
              String? nestedDiscountType = discountType;

              if (cartModel.cartGroupId != null) {
                for (var c in cartList) {
                  if (c != null &&
                      c.cartGroupId == cartModel.cartGroupId &&
                      c.item?.type == 'voucher') {
                    nestedDiscount = c.item?.discount;
                    nestedDiscountType = c.item?.discountType;
                    break;
                  }
                }
              }

              double bp = (PriceConverter.convertWithDiscount(
                      cartModel.item!.price ?? 0,
                      nestedDiscount,
                      nestedDiscountType,
                      isFoodVariation: false)! *
                  (cartModel.quantity ?? 1));
              variationPrice += bp;
              variationDiscount +=
                  (cartModel.item!.price ?? 0) * (cartModel.quantity ?? 1);
            }
          }
        } else {
          String variationType = '';
          if (cartModel.variation != null) {
            for (int i = 0; i < cartModel.variation!.length; i++) {
              variationType = cartModel.variation![i].type ?? '';
            }
          }

          if (cartModel.item!.variations != null &&
              cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice +=
                    ((variation.price ?? 0) * (cartModel.quantity ?? 1));
                break;
              }
            }
          } else {
            variationDiscount += (PriceConverter.convertWithDiscount(
                    cartModel.item!.price ?? 0, discount, discountType)! *
                (cartModel.quantity ?? 1));
            variationPrice +=
                ((cartModel.item!.price ?? 0) * (cartModel.quantity ?? 1));
          }
        }
      }
    }
    if (calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if (calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  double _calculateDiscountPrice(
      {required Store? store,
      required List<CartModel?>? cartList,
      required double price,
      required double addOns,
      required bool calStoreDiscount}) {
    double discount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel == null || cartModel.item == null) continue;

        // --- Saim Fix: Prioritize cart-level discountAmount for Vouchers/Bundles ---
        if (cartModel.item!.type == 'voucher' ||
            cartModel.cartGroupId != null) {
          discount = discount + (cartModel.discountAmount ?? 0);
          continue;
        }
        // --------------------------------------------------------------------------
        double? itemDiscount = cartModel.item!.discount;
        String? itemDiscountType = cartModel.item!.discountType;

        if (cartModel.item!.type != 'voucher' &&
            cartModel.cartGroupId != null) {
          for (var c in cartList) {
            if (c != null &&
                c.cartGroupId == cartModel.cartGroupId &&
                c.item?.type == 'voucher') {
              itemDiscount = c.item?.discount;
              itemDiscountType = c.item?.discountType;
              break;
            }
          }
        }

        // Adjust for Customer Commission
        if (store.commissionPaidBy == 'customer' &&
            store.comission != null &&
            store.comission! > 0 &&
            itemDiscount != null &&
            itemDiscount > 0) {
          if (itemDiscountType == 'percent') {
            // Price-independent formula for percentage discounts:
            // NewDiscount% = OldDiscount% - (1 - OldDiscount%/100) * Commission%
            itemDiscount =
                itemDiscount - (1 - itemDiscount / 100) * store.comission!;
            itemDiscountType = 'percent';
          } else {
            // For amount discounts, we still need a reference price
            double priceForFormula = (cartModel.item!.bundleType == 'simple x')
                ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
                : (cartModel.price != null && cartModel.price != 0)
                    ? cartModel.price!
                    : (cartModel.item!.price ??
                        (cartModel.item!.actualPrice ?? 100));

            if (priceForFormula > 0) {
              double dAmount = itemDiscount;
              double afterD = priceForFormula - dAmount;
              double comm = afterD * (store.comission! / 100);
              itemDiscount = ((dAmount - comm) / priceForFormula) * 100;
              itemDiscountType = 'percent';
            }
          }
        }

        double? dis = (store.discount != null &&
                    DateConverter.isAvailable(
                        store.discount!.startTime, store.discount!.endTime)) &&
                calStoreDiscount
            ? store.discount!.discount
            : itemDiscount;

        String? disType = (store.discount != null &&
                    DateConverter.isAvailable(
                        store.discount!.startTime, store.discount!.endTime)) &&
                calStoreDiscount
            ? 'percent'
            : itemDiscountType;

        if (Get.find<SplashController>()
            .getModuleConfig(cartModel.item!.moduleType)
            .newVariation!) {
          bool isBogoGroup = false;
          bool isMixMatchGroup = false;
          bool isVoucherGroup = false;
          if (cartModel.cartGroupId != null &&
              cartModel.item!.type != 'voucher') {
            for (var c in cartList) {
              if (c != null &&
                  c.cartGroupId == cartModel.cartGroupId &&
                  c.item?.type == 'voucher') {
                isVoucherGroup = true;
                if (c.item?.bundleType == 'bogo_free') isBogoGroup = true;
                if (c.item?.bundleType == 'mix_match') isMixMatchGroup = true;
              }
            }
          }

          // Comprehensive gift detection
          bool isGift = cartModel.type == 'Gift' ||
              cartModel.item!.voucherIds == 'Gift' ||
              cartModel.item!.bundleType == 'gift';

          double basePriceInput = (cartModel.item!.bundleType == 'simple x')
              ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
              : (cartModel.price ?? cartModel.item!.price ?? 0);

          bool isVoucher = cartModel.item!.type == 'voucher';
          bool isSimpleBundleVoucher = isVoucher &&
              (cartModel.item!.product?.isNotEmpty ?? false) &&
              cartModel.item!.bundleType != 'bogo_free' &&
              cartModel.item!.bundleType != 'mix_match';
          bool isMixMatchVoucher =
              isVoucher && cartModel.item!.bundleType == 'mix_match';

          // Hide discount for bundle voucher parent (discount applies to products)
          if (isVoucher &&
              (isSimpleBundleVoucher || isMixMatchVoucher || isBogoGroup)) {
            basePriceInput = 0;
          }

          bool isBundleNested = isVoucherGroup &&
              !isBogoGroup; // Includes Simple Bundle and Mix & Match

          bool variationSelected = false;
          if (cartModel.item!.foodVariations != null &&
              cartModel.foodVariations != null) {
            for (int i = 0; i < cartModel.foodVariations!.length; i++) {
              if (cartModel.foodVariations![i].contains(true)) {
                variationSelected = true;
                break;
              }
            }
          }

          // For simple bundle nested items, use catalog price if cart price is 0
          // BUT only if NO variations are selected (variations replace base price)
          // For bundle nested items (Simple Bundle, Mix & Match), use catalog price if cart price is 0
          // BUT only if NO variations are selected (variations replace base price)
          if (isBundleNested &&
              (cartModel.price == null || cartModel.price == 0) &&
              !variationSelected) {
            basePriceInput = cartModel.item!.price ?? 0;
          }

          if (kDebugMode) {
            print('[DISCOUNT_DEBUG] Item: ${cartModel.item?.name}');
            print(
                '  - isVoucherGroup: $isVoucherGroup, isBogoGroup: $isBogoGroup, isMixMatchGroup: $isMixMatchGroup');
            print(
                '  - basePriceInput: $basePriceInput, dis: $dis, disType: $disType');
            print('  - variationSelected: $variationSelected');
          }

          // Determine if we should skip base price discount calculation
          // Skip if:
          // 1. It's a voucher parent (Simple Bundle, Mix & Match, BOGO) - they don't have base prices
          // 2. It's a BOGO/Mix & Match nested product with variations (variations replace base price)
          // BUT: Don't skip for Simple Bundle nested products - they need base price discount
          bool skipBaseDiscount = false;

          // Check if this is a flat voucher (discount from bonus configuration)
          bool isFlatVoucher = cartModel.item!.type == 'voucher' &&
              cartModel.item!.bundleType != 'bogo_free' &&
              cartModel.item!.bundleType != 'simple x' &&
              cartModel.item!.bundleType != 'mix_match' &&
              !(cartModel.item!.product?.isNotEmpty ?? false);

          if (isFlatVoucher) {
            // Flat voucher: discount comes from bonus configuration (stored in discountAmount)
            // Do NOT set skipBaseDiscount — instead add discountAmount directly below
          } else if (isVoucherGroup && variationSelected) {
            // Check if it's BOGO or Mix & Match (skip base price)
            // For Simple Bundle, we DON'T skip because base price needs discount
            if (isBogoGroup || isMixMatchGroup) {
              skipBaseDiscount = true;
            }
            // For Simple Bundle nested products: skipBaseDiscount remains false
          } else if (isGift) {
            skipBaseDiscount = true;
          } else if (isVoucher &&
              (isSimpleBundleVoucher || isMixMatchVoucher)) {
            skipBaseDiscount = true; // Voucher parent
          }

          double d;
          if (isFlatVoucher) {
            // Flat voucher: use the bonus-based discountAmount stored in cart
            d = cartModel.discountAmount ?? 0;
            if (kDebugMode) {
              print(
                  '[DISCOUNT_DEBUG - FLAT VOUCHER] Using discountAmount: $d for ${cartModel.item?.name}');
            }
          } else {
            d = skipBaseDiscount
                ? 0
                : (((basePriceInput) -
                        (PriceConverter.convertWithDiscount(
                                basePriceInput, dis, disType) ??
                            0)) *
                    (cartModel.quantity ?? 1));
          }

          if (kDebugMode) {
            print(
                '  - isFlatVoucher: $isFlatVoucher, skipBaseDiscount: $skipBaseDiscount');
            print('  - Base price discount (d): $d');
            if (!skipBaseDiscount && !isFlatVoucher && basePriceInput > 0) {
              double discountedPrice = PriceConverter.convertWithDiscount(
                      basePriceInput, dis, disType) ??
                  0;
              print(
                  '  - Original base: $basePriceInput → Discounted: $discountedPrice');
            }
          }

          discount = discount + d;
          if (!isFlatVoucher && disType == 'percent') {
            discount = discount +
                _calculateFoodVariationDiscount(cartModel: cartModel);
          }
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          if (cartModel.variation != null) {
            for (int i = 0; i < cartModel.variation!.length; i++) {
              variationType = cartModel.variation![i].type ?? '';
            }
          }
          if (cartModel.item!.variations != null &&
              cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (PriceConverter.convertWithDiscount(
                        variation.price ?? 0, dis, disType)! *
                    (cartModel.quantity ?? 1));
                variationWithoutDiscountPrice +=
                    ((variation.price ?? 0) * (cartModel.quantity ?? 1));
                break;
              }
            }
            discount =
                discount + (variationWithoutDiscountPrice - variationPrice);
          } else {
            double d = (((cartModel.item!.price ?? 0) -
                    (PriceConverter.convertWithDiscount(
                            cartModel.item!.price ?? 0, dis, disType) ??
                        0)) *
                (cartModel.quantity ?? 1));
            discount = discount + d;
          }
        }
      }
    }

    if (calStoreDiscount) {
      if (store != null && store.discount != null) {
        if (store.discount!.maxDiscount != 0 &&
            store.discount!.maxDiscount! < discount) {
          discount = store.discount!.maxDiscount!;
        }
        if (store.discount!.minPurchase != 0 &&
            store.discount!.minPurchase! > (price + addOns)) {
          discount = 0;
        }
      }
    }
    return discount;
  }

  double _getDiscountPrice(
      double storeDiscountPrice, double itemDiscountPrice) {
    double discountPrice = 0;
    if (storeDiscountPrice > itemDiscountPrice) {
      discountPrice = storeDiscountPrice;
    } else if (itemDiscountPrice > storeDiscountPrice) {
      discountPrice = itemDiscountPrice;
    } else {
      discountPrice = itemDiscountPrice;
    }
    return discountPrice;
  }

  double _getExtraDiscountPrice(
      double storeDiscountPrice, double itemDiscountPrice) {
    double extraDiscount = 0;
    if (storeDiscountPrice > itemDiscountPrice) {
      extraDiscount = storeDiscountPrice - itemDiscountPrice;
    } else if (itemDiscountPrice > storeDiscountPrice) {
      extraDiscount = 0;
    } else {
      extraDiscount = 0;
    }
    return extraDiscount;
  }

  double _calculateFoodVariationDiscount({required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if (cartModel != null &&
        cartModel.item != null &&
        cartModel.item!.foodVariations != null &&
        cartModel.foodVariations != null) {
      // Check if this is a BOGO group member
      bool isBogoGroup = false;
      String? bogoGroupId;
      if (cartModel.cartGroupId != null && _cartList != null) {
        for (var c in _cartList!) {
          if (c != null &&
              c.cartGroupId == cartModel.cartGroupId &&
              c.item?.type == 'voucher' &&
              c.item?.bundleType == 'bogo_free') {
            isBogoGroup = true;
            bogoGroupId = cartModel.cartGroupId;
            break;
          }
        }
      }

      bool isSimpleX = cartModel.item!.type == 'voucher' &&
          cartModel.item!.bundleType == 'simple x';

      // Skip variations for BOGO nested items because the combo is in the voucher
      if (isBogoGroup && cartModel.item!.type != 'voucher') {
        return 0;
      }

      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      // ✅ Check for parent voucher discount in group
      if (cartModel.item!.type != 'voucher' &&
          cartModel.cartGroupId != null &&
          _cartList != null) {
        for (var c in _cartList!) {
          if (c != null &&
              c.cartGroupId == cartModel.cartGroupId &&
              c.item?.type == 'voucher') {
            discount = c.item?.discount;
            discountType = c.item?.discountType;
            break;
          }
        }
      }

      // Adjust for Customer Commission in Food Variation Discount
      Store? effectiveStore = cartModel.item!.store ??
          Get.find<CheckoutController>().store; // Fallback to current store
      if (effectiveStore?.commissionPaidBy == 'customer' &&
          effectiveStore?.comission != null &&
          effectiveStore!.comission! > 0 &&
          discount != null &&
          discount > 0) {
        if (discountType == 'percent') {
          // Price-independent formula for percentage discounts:
          discount =
              discount - (1 - discount / 100) * effectiveStore.comission!;
          discountType = 'percent';
        } else {
          // For amount discounts, we still need a reference price
          double priceForFormula = (cartModel.item!.bundleType == 'simple x')
              ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
              : (cartModel.price != null && cartModel.price != 0)
                  ? cartModel.price!
                  : (cartModel.item!.price ??
                      (cartModel.item!.actualPrice ?? 100));

          if (priceForFormula > 0) {
            double dAmount = discount;
            double afterD = priceForFormula - dAmount;
            double comm = afterD * (effectiveStore.comission! / 100);
            discount = ((dAmount - comm) / priceForFormula) * 100;
            discountType = 'percent';
          }
        }
      }

      if (isBogoGroup &&
          cartModel.item!.type == 'voucher' &&
          _cartList != null) {
        // Process all items in this BOGO group and take the max
        double maxComboPrice = 0;
        double maxComboDiscountPrice = 0;

        for (var groupMember in _cartList!) {
          if (groupMember != null &&
              groupMember.cartGroupId == bogoGroupId &&
              groupMember.item?.type != 'voucher') {
            double memberVarPrice = 0;
            double memberVarDiscount = 0;

            if (groupMember.item!.foodVariations != null &&
                groupMember.foodVariations != null) {
              for (int index = 0;
                  index < groupMember.item!.foodVariations!.length;
                  index++) {
                if (groupMember.item!.foodVariations![index].variationValues !=
                        null &&
                    groupMember.foodVariations!.length > index) {
                  for (int i = 0;
                      i <
                          groupMember.item!.foodVariations![index]
                              .variationValues!.length;
                      i++) {
                    if (groupMember.foodVariations![index].length > i &&
                        (groupMember.foodVariations![index][i] ?? false)) {
                      if (groupMember.item!.foodVariations![index]
                              .variationValues![i].optionPrice !=
                          null) {
                        memberVarPrice += (PriceConverter.convertWithDiscount(
                                groupMember.item!.foodVariations![index]
                                    .variationValues![i].optionPrice!,
                                discount,
                                discountType,
                                isFoodVariation: true)! *
                            (groupMember.quantity ?? 1));
                        memberVarDiscount += (groupMember
                                .item!
                                .foodVariations![index]
                                .variationValues![i]
                                .optionPrice! *
                            (groupMember.quantity ?? 1));
                      }
                    }
                  }
                }
              }
            }

            // Add base price for max comparison
            double memberBasePrice = (PriceConverter.convertWithDiscount(
                    groupMember.price ?? 0, discount, discountType)! *
                (groupMember.quantity ?? 1));
            double memberBaseDiscount =
                (groupMember.price ?? 0) * (groupMember.quantity ?? 1);

            if ((memberVarPrice + memberBasePrice) > maxComboPrice) {
              maxComboPrice = memberVarPrice + memberBasePrice;
              maxComboDiscountPrice = memberVarDiscount + memberBaseDiscount;
            }
          }
        }
        variationPrice += maxComboPrice;
        variationDiscount += maxComboDiscountPrice;
      } else {
        for (int index = 0;
            index < cartModel.item!.foodVariations!.length;
            index++) {
          if (cartModel.item!.foodVariations![index].variationValues != null &&
              cartModel.foodVariations!.length > index) {
            for (int i = 0;
                i <
                    cartModel
                        .item!.foodVariations![index].variationValues!.length;
                i++) {
              if (cartModel.foodVariations![index].length > i &&
                  (cartModel.foodVariations![index][i] ?? false)) {
                if (cartModel.item!.foodVariations![index].variationValues![i]
                        .optionPrice !=
                    null) {
                  double op = cartModel.item!.foodVariations![index]
                      .variationValues![i].optionPrice!;
                  variationPrice += ((isSimpleX)
                          ? op
                          : PriceConverter.convertWithDiscount(
                              op, discount, discountType,
                              isFoodVariation: true)!) *
                      (cartModel.quantity ?? 1);
                  variationDiscount += (op * (cartModel.quantity ?? 1));
                }
              }
            }
          }
        }
      }
    }
    return (variationDiscount - variationPrice);
  }

  double _calculateOrderAmount(
      {required double price,
      required double variations,
      required double discount,
      required double addOns,
      required double couponDiscount,
      required List<CartModel?>? cartList,
      required double referralDiscount}) {
    double orderAmount = 0;
    double variationPrice = 0;
    if (cartList != null &&
        cartList.isNotEmpty &&
        cartList[0]?.item != null &&
        Get.find<SplashController>()
                .getModuleConfig(cartList[0]!.item!.moduleType)
                .newVariation ==
            true) {
      variationPrice = variations;
    }
    orderAmount = (price + variationPrice - discount) +
        addOns -
        couponDiscount -
        referralDiscount;
    return double.parse(orderAmount.toStringAsFixed(2));
  }

  double _calculateSubTotal(
      {required double price,
      required double addOns,
      required double variations,
      required List<CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if (cartList != null && cartList.isNotEmpty && cartList[0]?.item != null) {
      isFoodVariation = Get.find<SplashController>()
              .getModuleConfig(cartList[0]!.item!.moduleType)
              .newVariation ==
          true;
    }
    if (isFoodVariation) {
      subTotal = price + addOns + variations;
    } else {
      subTotal = price;
    }

    print(
        '[CHECKOUT_DEBUG_FINAL] 💰 SubTotal Calc: BasePrice=$price, Addons=$addOns, Variations=$variations, isFoodVar=$isFoodVariation -> SubTotal=$subTotal');
    return subTotal;
  }

  double _calculateOriginalDeliveryCharge(
      {required Store? store,
      required AddressModel address,
      required double? distance,
      required double? extraCharge,
      double? surgePrice,
      String? surgePriceType}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    if (store != null) {
      for (ZoneData zData in address.zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get.find<SplashController>().module!.id &&
              m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }
    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;
    if (store != null &&
        distance != null &&
        distance != -1 &&
        store.selfDeliverySystem == 1) {
      perKmCharge = store.perKmShippingCharge ?? 0;
      minimumCharge = store.minimumShippingCharge ?? 0;
      maximumCharge = store.maximumShippingCharge;
    } else if (store != null &&
        distance != null &&
        distance != -1 &&
        moduleData != null &&
        moduleData.deliveryChargeType == 'distance') {
      perKmCharge = moduleData.perKmShippingCharge ?? 0;
      minimumCharge = moduleData.minimumShippingCharge ?? 0;
      maximumCharge = moduleData.maximumShippingCharge;
    } else if (store != null &&
        moduleData != null &&
        moduleData.deliveryChargeType == 'fixed') {
      perKmCharge = moduleData.fixedShippingCharge ?? 0;
      minimumCharge = moduleData.fixedShippingCharge ?? 0;
      maximumCharge = moduleData.fixedShippingCharge ?? 0;
    }
    if (store != null && distance != null) {
      deliveryCharge = distance * perKmCharge;

      if (deliveryCharge < minimumCharge) {
        deliveryCharge = minimumCharge;
      } else if (maximumCharge != null && deliveryCharge > maximumCharge) {
        deliveryCharge = maximumCharge;
      }
    }

    if (store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      extraChargeForToolTip = extraCharge;
      deliveryCharge = deliveryCharge + extraCharge;
    }

    if (store != null &&
        store.selfDeliverySystem == 0 &&
        surgePrice != null &&
        surgePrice > 0) {
      if (surgePriceType == 'percent') {
        badWeatherChargeForToolTip = (deliveryCharge * (surgePrice / 100));
        deliveryCharge = deliveryCharge + (deliveryCharge * (surgePrice / 100));
      } else {
        badWeatherChargeForToolTip = surgePrice;
        deliveryCharge = deliveryCharge + surgePrice;
      }
    }

    return deliveryCharge;
  }

  double _calculateDeliveryCharge(
      {required Store? store,
      required AddressModel address,
      required double? distance,
      required double? extraCharge,
      required double orderAmount,
      required String orderType,
      double? surgePrice,
      String? surgePriceType}) {
    double deliveryCharge = _calculateOriginalDeliveryCharge(
        store: store,
        address: address,
        distance: distance,
        extraCharge: extraCharge,
        surgePrice: surgePrice,
        surgePriceType: surgePriceType);

    ConfigModel? configModel = Get.find<SplashController>().configModel;

    if (orderType == 'take_away' ||
        (store != null && (store.freeDelivery ?? false)) ||
        (configModel?.adminFreeDelivery?.status == true &&
            (configModel?.adminFreeDelivery?.type != null &&
                configModel?.adminFreeDelivery?.type ==
                    'free_delivery_to_all_store')) ||
        (configModel?.adminFreeDelivery?.status == true &&
            (configModel?.adminFreeDelivery?.type != null &&
                configModel?.adminFreeDelivery?.type ==
                    'free_delivery_by_order_amount') &&
            (configModel?.adminFreeDelivery?.freeDeliveryOver != null &&
                orderAmount >=
                    configModel!.adminFreeDelivery!.freeDeliveryOver!)) ||
        Get.find<CouponController>().freeDelivery ||
        (AuthHelper.isGuestLoggedIn() &&
            (Get.find<CheckoutController>().guestAddress == null &&
                Get.find<CheckoutController>().orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return deliveryCharge;
  }

  double _calculateTotal({
    required double subTotal,
    required double deliveryCharge,
    required double discount,
    required double couponDiscount,
    required bool taxIncluded,
    required double tax,
    required String orderType,
    required double tips,
    required double additionalCharge,
    required double extraPackagingCharge,
    bool isCashBack = false,
  }) {
    double total = subTotal +
        deliveryCharge -
        (isCashBack ? 0 : discount) -
        couponDiscount +
        (taxIncluded ? 0 : tax) +
        ((orderType != 'take_away' &&
                (Get.find<SplashController>().configModel?.dmTipsStatus == 1))
            ? tips
            : 0) +
        additionalCharge +
        extraPackagingCharge;
    return double.parse(total.toStringAsFixed(2));
  }

  bool _checkZoneOfflinePaymentOnOff(
      {required AddressModel? addressModel,
      required CheckoutController checkoutController}) {
    bool? status = false;
    ZoneData? zoneData;
    if (addressModel != null && addressModel.zoneData != null) {
      for (var data in addressModel.zoneData!) {
        if (data.id == checkoutController.store?.zoneId) {
          zoneData = data;
          break;
        }
      }
    }
    status = zoneData?.offlinePayment ?? false;
    return status;
  }

  bool _checkPrescriptionRequired() {
    if (widget.storeId == null &&
        _cartList != null &&
        Get.find<SplashController>()
                .configModel
                ?.moduleConfig
                ?.module
                ?.orderAttachment ==
            true) {
      for (var cart in _cartList!) {
        if (cart?.item?.isPrescriptionRequired == true) {
          return true;
        }
      }
    }
    return false;
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    if ((checkoutController.store?.extraPackagingStatus ?? true) &&
        (Get.find<CartController>().needExtraPackage)) {
      return checkoutController.store?.extraPackagingAmount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(
      double subTotal, double discount, double couponDiscount) {
    double referralDiscount = 0;
    UserInfoModel? userInfoModel = Get.find<ProfileController>().userInfoModel;
    if (userInfoModel != null && (userInfoModel.isValidForDiscount ?? false)) {
      if (userInfoModel.discountAmountType == "percentage") {
        referralDiscount = ((userInfoModel.discountAmount ?? 0) / 100) *
            (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = userInfoModel.discountAmount ?? 0;
      }
    }
    return referralDiscount;
  }

  Future<void> showCashBackSnackBar() async {
    if (_payableAmount != null) {
      await Get.find<HomeController>().getCashBackData(_payableAmount!);
      double? cashBackAmount =
          Get.find<HomeController>().cashBackData?.cashbackAmount ?? 0;
      String? cashBackType =
          Get.find<HomeController>().cashBackData?.cashbackType ?? '';
      String text =
          '${'you_will_get'.tr} ${cashBackType == 'amount' ? PriceConverter.convertPrice(cashBackAmount) : '${cashBackAmount.toStringAsFixed(0)}%'} ${'cash_back_after_completing_order'.tr}';
      if (cashBackAmount > 0) {
        showCustomSnackBar(text, isError: false);
      }
    }
  }
}
