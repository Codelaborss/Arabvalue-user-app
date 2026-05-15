import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart';
import 'package:sixam_mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/api/api_client.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOns = 0;
  double get addOns => _addOns;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  List<String> notAvailableList = [
    'Remove it from my cart',
    'I’ll wait until it’s restocked',
    'Please cancel the order',
    'Call me ASAP',
    'Notify me when it’s back'
  ];
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Response? _lastResponse;
  Response? get lastResponse => _lastResponse;

  bool _isPolling = false;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  int? _directAddCartItemIndex = -1;
  int? get directAddCartItemIndex => _directAddCartItemIndex;

  void setDirectlyAddToCartIndex(int? index) {
    _directAddCartItemIndex = index;
  }

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if (willUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex =
        cartServiceInterface.availableSelectedIndex(_notAvailableIndex, index);
    if (willUpdate) {
      update();
    }
  }

  void updateCutlery({bool willUpdate = true}) {
    _addCutlery = !_addCutlery;
    if (willUpdate) {
      update();
    }
  }

  Future<void> forcefullySetModule(int moduleId) async {
    ModuleModel? module = cartServiceInterface.forcefullySetModule(
        Get.find<SplashController>().module,
        Get.find<SplashController>().moduleList,
        moduleId);
    if (module != null) {
      await Get.find<SplashController>().setModule(module);
      HomeScreen.loadData(true);
    }
  }

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;

    Map<String, List<CartModel>> bogoGroups = {};

    for (var cartModel in cartList) {
      if (cartModel.cartGroupId != null) {
        String? bundleType;
        for (CartModel cm in cartList) {
          if (cm.cartGroupId == cartModel.cartGroupId &&
              cm.item!.type == 'voucher') {
            bundleType = cm.item!.bundleType;
            break;
          }
        }

        if (bundleType == 'bogo_free') {
          bogoGroups
              .putIfAbsent(cartModel.cartGroupId!, () => [])
              .add(cartModel);
          continue;
        }
      }

      variationWithoutDiscountPrice =
          _processSingleItem(cartModel, false, variationWithoutDiscountPrice);
    }

    // Process BOGO groups
    bogoGroups.forEach((groupId, items) {
      double maxComboBaseAndVar = 0;
      double totalAddons = 0;

      for (var cartModel in items) {
        double? discount = cartModel.item!.discount;
        String? discountType = cartModel.item!.discountType;

        // Apply voucher discount if applicable
        for (CartModel cm in _cartList) {
          if (cm.item!.type == 'voucher' && cm.cartGroupId == groupId) {
            discount = cm.item!.discount;
            discountType = cm.item!.discountType;
            break;
          }
        }

        bool isFoodVariation =
            ModuleHelper.getModuleConfig(cartModel.item!.moduleType)
                .newVariation!;
        List<AddOns> addOnList =
            cartServiceInterface.prepareAddonList(cartModel);

        // All addons are always paid in BOGO
        totalAddons +=
            cartServiceInterface.calculateAddonPrice(0, addOnList, cartModel);

        if (cartModel.item!.type != 'voucher') {
          double itemBasePrice = (PriceConverter.convertWithDiscount(
                  cartModel.item!.price!, discount, discountType)! *
              cartModel.quantity!);
          double itemVariationPrice =
              cartServiceInterface.calculateVariationPrice(
                  isFoodVariation, cartModel, discount, discountType, 0);
          double comboPrice = itemBasePrice + itemVariationPrice;

          if (comboPrice > maxComboBaseAndVar) {
            maxComboBaseAndVar = comboPrice;
          }
        }
      }

      // Add all items as "free" (base price 0) initially to populate lists,
      // but manually add the calculated max combo and total addons.
      for (var cartModel in items) {
        _processSingleItem(
            cartModel, true, 0); // isFree=true to avoid double counting
      }

      // Manually add the calculated voucher group totals
      _subTotal += maxComboBaseAndVar + totalAddons;
      _itemPrice += maxComboBaseAndVar;
      _addOns += totalAddons;
    });

    _itemDiscountPrice =
        _itemDiscountPrice + (variationWithoutDiscountPrice - _variationPrice);
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    return _subTotal;
  }

  double _processSingleItem(
      CartModel cartModel, bool isFree, double variationWithoutDiscountPrice) {
    double currentVariationWithoutDiscountPrice = variationWithoutDiscountPrice;
    bool isFoodVariation =
        ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
    double? discount = cartModel.item!.discount;
    String? discountType = cartModel.item!.discountType;

    if (cartModel.item!.type != 'voucher' && cartModel.cartGroupId != null) {
      for (CartModel cm in _cartList) {
        if (cm.item!.type == 'voucher' &&
            cm.cartGroupId == cartModel.cartGroupId) {
          discount = cm.item!.discount;
          discountType = cm.item!.discountType;
          break;
        }
      }
    }

    List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

    _addOnsList.add(addOnList);
    _availableList.add(DateConverter.isAvailable(
        cartModel.item!.availableTimeStarts,
        cartModel.item!.availableTimeEnds));

    if (!isFree) {
      _addOns = cartServiceInterface.calculateAddonPrice(
          _addOns, addOnList, cartModel);

      double currentItemVariationPrice =
          cartServiceInterface.calculateVariationPrice(
              isFoodVariation, cartModel, discount, discountType, 0);
      double currentItemVariationWithoutDiscountPrice =
          cartServiceInterface.calculateVariationWithoutDiscountPrice(
              isFoodVariation, cartModel, 0);
      bool haveVariation =
          cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      if (isFoodVariation) {
        bool isFlatDiscount = cartModel.type == 'Flat discount' ||
            cartModel.item!.voucherIds == 'Flat discount';
        // Comprehensive gift detection
        bool isGift = cartModel.type == 'Gift' ||
            cartModel.item!.voucherIds == 'Gift' ||
            cartModel.item!.bundleType == 'gift';

        bool isVoucherNestedProduct = false;
        if (cartModel.item!.type != 'voucher' &&
            cartModel.cartGroupId != null) {
          for (CartModel cm in _cartList) {
            if (cm.item!.type == 'voucher' &&
                cm.cartGroupId == cartModel.cartGroupId) {
              isVoucherNestedProduct = true;
              break;
            }
          }
        }

        double baseItemPrice = ((isFlatDiscount ||
                isGift ||
                isVoucherNestedProduct)
            ? (cartModel.price ?? 0)
            : (cartModel.item!.bundleType == 'simple x'
                ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
                : cartModel.item!.price!));

        double price = (cartModel.item!.type == 'voucher' &&
                !isFlatDiscount &&
                cartModel.item!.bundleType != 'simple x')
            ? 0
            : baseItemPrice * cartModel.quantity!;

        _itemPrice += price;
        _itemDiscountPrice += ((cartModel.item!.type == 'voucher' &&
                    cartModel.item!.bundleType != 'simple x') ||
                isFlatDiscount ||
                isGift)
            ? (cartModel.discountAmount ?? 0)
            : (price -
                (PriceConverter.convertWithDiscount(
                        baseItemPrice, discount, discountType)! *
                    cartModel.quantity!));

        _variationPrice += currentItemVariationPrice;
        currentVariationWithoutDiscountPrice +=
            currentItemVariationWithoutDiscountPrice;
      } else {
        bool isFlatDiscount = cartModel.type == 'Flat discount' ||
            cartModel.item!.voucherIds == 'Flat discount';
        // Comprehensive gift detection
        bool isGift = cartModel.type == 'Gift' ||
            cartModel.item!.voucherIds == 'Gift' ||
            cartModel.item!.bundleType == 'gift';

        bool isVoucherNestedProduct = false;
        if (cartModel.item!.type != 'voucher' &&
            cartModel.cartGroupId != null) {
          for (CartModel cm in _cartList) {
            if (cm.item!.type == 'voucher' &&
                cm.cartGroupId == cartModel.cartGroupId) {
              isVoucherNestedProduct = true;
              break;
            }
          }
        }

        double baseItemPrice = ((isFlatDiscount ||
                isGift ||
                isVoucherNestedProduct)
            ? (cartModel.price ?? 0)
            : (cartModel.item!.bundleType == 'simple x'
                ? (cartModel.item!.actualPrice ?? cartModel.item!.price ?? 0)
                : cartModel.item!.price!));

        double price = haveVariation
            ? currentItemVariationWithoutDiscountPrice
            : (cartModel.item!.type == 'voucher' &&
                    !isFlatDiscount &&
                    cartModel.item!.bundleType != 'simple x')
                ? 0
                : baseItemPrice * cartModel.quantity!;
        _itemPrice += price;
        _itemDiscountPrice += haveVariation
            ? (currentItemVariationWithoutDiscountPrice -
                currentItemVariationPrice)
            : ((cartModel.item!.type == 'voucher' &&
                        cartModel.item!.bundleType != 'simple x') ||
                    isFlatDiscount ||
                    isGift)
                ? (cartModel.discountAmount ?? 0)
                : (price -
                    (PriceConverter.convertWithDiscount(
                            baseItemPrice, discount, discountType)! *
                        cartModel.quantity!));

        if (haveVariation) {
          currentVariationWithoutDiscountPrice +=
              currentItemVariationWithoutDiscountPrice;
        }
      }
    }
    return currentVariationWithoutDiscountPrice;
  }

  Future<void> addToCart(CartModel cartModel, int? index) async {
    if (index != null && index != -1) {
      _cartList.replaceRange(index, index + 1, [cartModel]);
    } else {
      _cartList.add(cartModel);
    }
    Get.find<ItemController>()
        .setExistInCart(cartModel.item, null, notify: true);
    await cartServiceInterface.addSharedPrefCartList(_cartList);

    calculationCart();
    update();
  }

  int? getCartId(int cartIndex) {
    return cartServiceInterface.getCartId(cartIndex, _cartList);
  }

  Future<void> setQuantity(
      bool isIncrement, int cartIndex, int? stock, int? quantityLimit) async {
    _isLoading = true;
    update();

    _cartList[cartIndex].quantity =
        await cartServiceInterface.decideItemQuantity(
            isIncrement,
            _cartList,
            cartIndex,
            stock,
            quantityLimit,
            Get.find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .stock!);

    double discountedPrice =
        await cartServiceInterface.calculateDiscountedPrice(
            _cartList[cartIndex],
            _cartList[cartIndex].quantity!,
            ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType)
                .newVariation!);
    if (ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType)
        .newVariation!) {
      await Get.find<ItemController>()
          .setExistInCart(_cartList[cartIndex].item, null, notify: true);
    }

    await updateCartQuantityOnline(_cartList[cartIndex].id!, discountedPrice,
        _cartList[cartIndex].quantity!);
  }

  Future<void> removeFromCart(int index, {Item? item}) async {
    int cartId = _cartList[index].id!;
    _cartList.removeAt(index);
    update();
    Get.find<ItemController>().cartIndexSet();
    await removeCartItemOnline(cartId, item: item);
    if (Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }
  }

  Future<void> clearCartList({bool canRemoveOnline = true}) async {
    _cartList = [];
    if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
        (ModuleHelper.getModule() != null ||
            ModuleHelper.getCacheModule() != null) &&
        canRemoveOnline) {
      clearCartOnline();
    }
  }

  int isExistInCart(
      int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    return cartServiceInterface.isExistInCart(
        _cartList, itemID, variationType, isUpdate, cartIndex);
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    return cartServiceInterface.existAnotherStoreItem(
        storeID, moduleId, _cartList);
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    _lastResponse = null;
    Response response = await Get.find<ApiClient>().postData(
        '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
        cart.toJson(),
        timeout: cart.timeout,
        handleError: false);
    _lastResponse = response;

    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      if (response.body is List) {
        response.body.forEach(
            (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      } else {
        onlineCartList = await cartServiceInterface.getCartDataOnline() ?? [];
      }
      List<CartModel> previousCartList = List.from(_cartList);
      _cartList = [];
      if (cart.addOns != null && cart.addOns!.isNotEmpty) {
        for (OnlineCartModel onlineCartModel in onlineCartList) {
          if (onlineCartModel.itemId == cart.itemId &&
              (onlineCartModel.addOns == null ||
                  onlineCartModel.addOns!.isEmpty) &&
              (onlineCartModel.addOnIds != null &&
                  onlineCartModel.addOnIds!.isNotEmpty)) {
            onlineCartModel.addOns ??= [];
            for (int id in onlineCartModel.addOnIds!) {
              for (AddOns addOn in cart.addOns!) {
                if (addOn.id == id) {
                  onlineCartModel.addOns!.add(addOn);
                  break;
                }
              }
            }
          }
        }
      }

      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList, existingCart: previousCartList));
      calculationCart();
      success = true;
    }
    _isLoading = false;
    update();

    return success;
  }

  Future<bool> updateCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    List<OnlineCartModel>? onlineCartList =
        await cartServiceInterface.updateCartOnline(cart);
    if (onlineCartList != null) {
      List<CartModel> previousCartList = List.from(_cartList);
      _cartList = [];
      if (cart.addOns != null && cart.addOns!.isNotEmpty) {
        for (OnlineCartModel onlineCartModel in onlineCartList) {
          if (onlineCartModel.itemId == cart.itemId &&
              (onlineCartModel.addOns == null ||
                  onlineCartModel.addOns!.isEmpty) &&
              (onlineCartModel.addOnIds != null &&
                  onlineCartModel.addOnIds!.isNotEmpty)) {
            onlineCartModel.addOns ??= [];
            for (int id in onlineCartModel.addOnIds!) {
              for (AddOns addOn in cart.addOns!) {
                if (addOn.id == id) {
                  onlineCartModel.addOns!.add(addOn);
                  break;
                }
              }
            }
          }
        }
      }

      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList, existingCart: previousCartList));
      calculationCart();
      success = true;
    }
    _isLoading = false;
    update();

    return success;
  }

  Future<void> updateCartQuantityOnline(
      int cartId, double price, int quantity) async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.updateCartQuantityOnline(
        cartId, price, quantity);
    if (success) {
      await getCartDataOnline();
      calculationCart();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _isLoading = false;
    update();
  }

  Future<void> getCartDataOnline() async {
    if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
        (ModuleHelper.getModule() != null ||
            ModuleHelper.getCacheModule() != null)) {
      _isLoading = true;
      List<OnlineCartModel>? onlineCartList =
          await cartServiceInterface.getCartDataOnline();
      List<CartModel> previousCartList = List.from(_cartList);
      _cartList = [];
      if (onlineCartList != null) {
        _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
            onlineCartModel: onlineCartList, existingCart: previousCartList));
      }
      calculationCart();
      _isLoading = false;
      update();

      _checkAndSchedulePolling();
    }
  }

  void _checkAndSchedulePolling() {
    bool hasPendingFlatDiscount = _cartList.any((cart) =>
        (cart.type == 'Flat discount' ||
            cart.item!.voucherIds == 'Flat discount') &&
        cart.status == 'pending');

    if (hasPendingFlatDiscount && !_isPolling) {
      _isPolling = true;
      print(
          '====> Found pending Flat Discount item. Scheduling polling in 2 seconds...');
      Future.delayed(const Duration(seconds: 2), () {
        _isPolling = false;
        getCartDataOnline();
      });
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item}) async {
    _isLoading = true;
    update();
    print('====> [CART_SERVICE] Attempting to remove cart item ID: $cartId');
    bool success = await cartServiceInterface.removeCartItemOnline(cartId);
    if (success) {
      print('====> [CART_SERVICE] Successfully removed cart item ID: $cartId');
      await getCartDataOnline();
      if (item != null) {
        Get.find<ItemController>().setExistInCart(item, null, notify: true);
      }
    } else {
      print('====> [CART_SERVICE] Failed to remove cart item ID: $cartId');
    }
    _isLoading = false;
    update();
    return success;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline();
    if (success) {
      getCartDataOnline();
    }
    _isLoading = false;
    update();
    return success;
  }

  int cartQuantity(int itemId) {
    return cartServiceInterface.cartQuantity(itemId, _cartList);
  }

  String cartVariant(int itemId) {
    return cartServiceInterface.cartVariant(itemId, _cartList);
  }

  /// Force-reset loading state (used when flat voucher cancel is pressed)
  void resetLoading() {
    _isLoading = false;
    update();
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }
}
