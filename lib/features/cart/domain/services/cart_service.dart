import 'package:get/get_utils/get_utils.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart';
import 'package:sixam_mart/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:sixam_mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart'
    as item_variation;

class CartService implements CartServiceInterface {
  final CartRepositoryInterface cartRepositoryInterface;
  CartService({required this.cartRepositoryInterface});

  @override
  Future<List<OnlineCartModel>?> addToCartOnline(OnlineCart cart) async {
    return await cartRepositoryInterface.add(cart);
  }

  @override
  Future<List<OnlineCartModel>?> updateCartOnline(OnlineCart cart) async {
    return await cartRepositoryInterface.update(cart.toJson(), null);
  }

  @override
  Future<bool> updateCartQuantityOnline(
      int cartId, double price, int quantity) async {
    return await cartRepositoryInterface.update({}, cartId,
        price: price, quantity: quantity, isUpdateQty: true);
  }

  @override
  Future<List<OnlineCartModel>?> getCartDataOnline() async {
    return await cartRepositoryInterface.getList();
  }

  @override
  Future<bool> removeCartItemOnline(int cartId) async {
    return await cartRepositoryInterface.delete(cartId);
  }

  @override
  Future<bool> clearCartOnline() async {
    return await cartRepositoryInterface.delete(null, isRemoveAll: true);
  }

  @override
  int availableSelectedIndex(int selectedIndex, int index) {
    int notAvailableIndex = selectedIndex;
    if (notAvailableIndex == index) {
      notAvailableIndex = -1;
    } else {
      notAvailableIndex = index;
    }
    return notAvailableIndex;
  }

  @override
  ModuleModel? forcefullySetModule(ModuleModel? selectedModule,
      List<ModuleModel>? moduleList, int moduleId) {
    ModuleModel? module;
    if (selectedModule == null && moduleList != null) {
      for (ModuleModel m in moduleList) {
        if (m.id == moduleId) {
          module = m;
          break;
        }
      }
    }
    return module;
  }

  @override
  List<AddOns> prepareAddonList(CartModel cartModel) {
    List<AddOns> addOnList = [];
    if (cartModel.addOns != null && cartModel.addOns!.isNotEmpty) {
      addOnList.addAll(cartModel.addOns!);
    } else if (cartModel.addOnIds != null) {
      List<AddOns> allPossibleAddons = [];
      if (cartModel.item?.addOns != null) {
        allPossibleAddons.addAll(cartModel.item!.addOns!);
      }
      if (cartModel.item?.product != null) {
        for (var p in cartModel.item!.product!) {
          if (p.addOns != null) {
            allPossibleAddons.addAll(p.addOns!);
          }
        }
      }
      if (cartModel.item?.productB != null) {
        for (var p in cartModel.item!.productB!) {
          if (p.addOns != null) {
            allPossibleAddons.addAll(p.addOns!);
          }
        }
      }

      for (var addOnId in cartModel.addOnIds!) {
        for (AddOns addOns in allPossibleAddons) {
          if (addOns.id == addOnId.id) {
            // Check if already added to avoid duplicates if same addon exists in multiple sub-products
            if (!addOnList.any((element) => element.id == addOns.id)) {
              addOnList.add(addOns);
            }
            break;
          }
        }
      }
    }
    return addOnList;
  }

  @override
  double calculateAddonPrice(
      double addOns, List<AddOns> addOnList, CartModel cartModel) {
    double addonPrice = addOns;
    if (cartModel.addOnIds != null) {
      for (int index = 0; index < addOnList.length; index++) {
        if (cartModel.addOnIds!.length > index &&
            cartModel.addOnIds![index].quantity != null &&
            addOnList[index].price != null) {
          addonPrice = addonPrice +
              ((addOnList[index].price ?? 0) *
                  (cartModel.addOnIds![index].quantity ?? 1) *
                  (cartModel.quantity ?? 1));
        }
      }
    }
    return addonPrice;
  }

  @override
  double calculateVariationPrice(bool isFoodVariation, CartModel cartModel,
      double? discount, String? discountType, double variationPrice) {
    double price = variationPrice;
    if (isFoodVariation) {
      if (cartModel.item?.foodVariations != null &&
          cartModel.foodVariations != null) {
        // 🎯 BOGO Free: Use only the highest-priced variation
        bool isBogoFree = cartModel.item?.bundleType == 'bogo_free';
        List<double> variationPrices = [];

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
                double? optionPrice = cartModel.item!.foodVariations![index]
                    .variationValues![i].optionPrice;
                if (optionPrice != null) {
                  double priceWithDiscount =
                      ((PriceConverter.convertWithDiscount(
                                  optionPrice, discount, discountType,
                                  isFoodVariation: true) ??
                              0) *
                          (cartModel.quantity ?? 1));

                  if (isBogoFree) {
                    variationPrices.add(priceWithDiscount);
                  } else {
                    price += priceWithDiscount;
                  }
                }
              }
            }
          }
        }

        // For BOGO Free, add only the maximum variation price
        if (isBogoFree && variationPrices.isNotEmpty) {
          price += variationPrices.reduce((a, b) => a > b ? a : b);
        }
      }
    } else {
      String variationType = '';
      if (cartModel.variation != null) {
        for (int i = 0; i < cartModel.variation!.length; i++) {
          variationType = cartModel.variation![i].type ?? '';
        }
      }

      if (cartModel.item?.variations != null) {
        for (item_variation.Variation variation
            in cartModel.item!.variations!) {
          if (variation.type == variationType) {
            price = ((PriceConverter.convertWithDiscount(
                        variation.price ?? 0, discount, discountType) ??
                    0) *
                (cartModel.quantity ?? 1));
            break;
          }
        }
      }
    }
    return price;
  }

  @override
  double calculateVariationWithoutDiscountPrice(bool isFoodVariation,
      CartModel cartModel, double variationWithoutDiscount) {
    double variationWithoutDiscountPrice = variationWithoutDiscount;
    if (!isFoodVariation) {
      String variationType = '';
      for (int i = 0; i < cartModel.variation!.length; i++) {
        variationType = cartModel.variation![i].type!;
      }
      for (item_variation.Variation variation in cartModel.item!.variations!) {
        if (variation.type == variationType) {
          variationWithoutDiscountPrice =
              ((variation.price ?? 0) * (cartModel.quantity ?? 1));
          break;
        }
      }
    } else {
      for (int index = 0;
          index < cartModel.item!.foodVariations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.item!.foodVariations![index].variationValues!.length;
            i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationWithoutDiscountPrice += ((cartModel
                        .item!
                        .foodVariations![index]
                        .variationValues![i]
                        .optionPrice ??
                    0) *
                (cartModel.quantity ?? 1));
          }
        }
      }
    }
    return variationWithoutDiscountPrice;
  }

  @override
  bool checkVariation(bool isFoodVariation, CartModel cartModel) {
    bool haveVariation = false;
    if (!isFoodVariation) {
      String variationType = '';
      for (int i = 0; i < cartModel.variation!.length; i++) {
        variationType = cartModel.variation![i].type!;
      }
      for (item_variation.Variation variation in cartModel.item!.variations!) {
        if (variation.type == variationType) {
          haveVariation = true;
          break;
        }
      }
    }
    return haveVariation;
  }

  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {
    await cartRepositoryInterface.addSharedPrefCartList(cartProductList);
  }

  @override
  int? getCartId(int cartIndex, List<CartModel> cartList) {
    if (cartIndex != -1) {
      return cartList.isNotEmpty ? cartList[cartIndex].id : null;
    } else {
      return null;
    }
  }

  @override
  Future<int> decideItemQuantity(bool isIncrement, List<CartModel> cartList,
      int cartIndex, int? stock, int? quantityLimit, bool moduleStock) async {
    int quantity = cartList[cartIndex].quantity!;
    if (isIncrement) {
      if (moduleStock && cartList[cartIndex].quantity! >= stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      } else if (quantityLimit != null) {
        if (quantity >= quantityLimit && quantityLimit != 0) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit');
        } else {
          quantity = quantity + 1;
        }
      } else {
        quantity = quantity + 1;
      }
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  @override
  Future<double> calculateDiscountedPrice(
      CartModel cartModel, int quantity, bool isFoodVariation) async {
    double? discount = cartModel.item!.discount;
    String? discountType = cartModel.item!.discountType;
    double variationPrice = 0;
    double addonPrice = 0;

    if (isFoodVariation) {
      for (int index = 0;
          index < cartModel.item!.foodVariations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.item!.foodVariations![index].variationValues!.length;
            i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                    cartModel.item!.foodVariations![index].variationValues![i]
                        .optionPrice!,
                    discount,
                    discountType,
                    isFoodVariation: true)! *
                cartModel.quantity!);
          }
        }
      }

      List<AddOns> addOnList = cartModel.addOns ?? [];

      for (int index = 0; index < addOnList.length; index++) {
        addonPrice = addonPrice +
            (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }
    }
    bool isFlatDiscount = cartModel.type == 'Flat discount' ||
        cartModel.item!.voucherIds == 'Flat discount';
    bool isGift = cartModel.type == 'Gift';
    double basePrice = (isFlatDiscount || isGift)
        ? (cartModel.price ?? 0)
        : cartModel.item!.price!;

    double discountedPrice = addonPrice +
        variationPrice +
        (basePrice * quantity) -
        (isFlatDiscount || isGift
            ? 0
            : PriceConverter.calculation(
                basePrice, discount, discountType!, quantity));
    return discountedPrice;
  }

  @override
  List<CartModel> formatOnlineCartToLocalCart(
      {required List<OnlineCartModel> onlineCartModel,
      List<CartModel>? existingCart}) {
    List<CartModel> cartList = [];
    Map<String, item_variation.Item> voucherDefinitions = {};

    // 🔍 Global Addon Recovery Map: Pre-scan for metadata (prices/names)
    Map<int, AddOns> globalAddonMetadataPool = {};
    void addToGlobalPool(AddOns addon) {
      if (addon.id == null) return;
      if (!globalAddonMetadataPool.containsKey(addon.id)) {
        globalAddonMetadataPool[addon.id!] = addon;
        print(
            '[CART_SERVICE_DEBUG] ➕ Added Addon to Pool: ID=${addon.id}, Name=${addon.name}, Price=${addon.price}');
      } else {
        AddOns existing = globalAddonMetadataPool[addon.id!]!;
        bool shouldUpgrade = false;
        if (existing.price == null && addon.price != null) {
          shouldUpgrade = true;
        } else if (existing.name == null && addon.name != null) {
          shouldUpgrade = true;
        }
        if (shouldUpgrade) {
          globalAddonMetadataPool[addon.id!] = addon;
          print(
              '[CART_SERVICE_DEBUG] ⬆️ Upgraded Addon in Pool: ID=${addon.id}, Name=${addon.name}, Price=${addon.price}');
        }
      }
    }

    // 1. GLOBAL PRE-SCAN PHASE (Metadata Discovery)
    // Scan PREVIOUS local cart state first to recover metadata stripped by API
    if (existingCart != null) {
      print(
          '[CART_SERVICE_DEBUG] 📜 Scanning ${existingCart.length} items from previous cart state');
      for (var cm in existingCart) {
        if (cm.addOns != null) {
          for (var a in cm.addOns!) {
            addToGlobalPool(a);
          }
        }
        if (cm.item?.addOns != null) {
          for (var a in cm.item!.addOns!) {
            addToGlobalPool(a);
          }
        }
      }
    }

    // Scan for Parent Vouchers AND all nested products for addon definitions
    for (var c in onlineCartModel) {
      if (c.item != null) {
        // 1. Scan main item definition
        if (c.item!.addOns != null) {
          for (var a in c.item!.addOns!) {
            addToGlobalPool(a);
          }
        }
        // 2. Scan nested products (Recursively if needed, but 1 level for BOGO/Bundle)
        if (c.item!.product != null) {
          for (var p in c.item!.product!) {
            if (p.addOns != null) {
              for (var a in p.addOns!) {
                addToGlobalPool(a);
              }
            }
          }
        }
        if (c.item!.productB != null) {
          for (var p in c.item!.productB!) {
            if (p.addOns != null) {
              for (var a in p.addOns!) {
                addToGlobalPool(a);
              }
            }
          }
        }
      }

      // 3. Scan cart-level metadata (metadata returned directly by backend in 'add_ons' field)
      if (c.addOns != null) {
        for (var a in c.addOns!) {
          addToGlobalPool(a);
        }
      }

      // Track voucher definitions for discount inheritance
      if (c.item?.type == 'voucher' && c.cartGroupId != null) {
        voucherDefinitions[c.cartGroupId.toString()] = c.item!;
      }
    }

    // DEBUG: Dump pool content
    print(
        '[CART_SERVICE_DEBUG] 🌍 Global addon pool initialized with ${globalAddonMetadataPool.length} entries');
    globalAddonMetadataPool.forEach((key, value) {
      print(
          '[CART_SERVICE_DEBUG] 🎱 Pool Item: ID=$key, Name=${value.name}, Price=${value.price}');
    });

    for (OnlineCartModel cart in onlineCartModel) {
      bool isFlatDiscount = cart.type == 'Flat discount' ||
          cart.item!.voucherIds == 'Flat discount';
      // Comprehensive gift detection
      bool isGift = cart.type == 'Gift' ||
          cart.item!.voucherIds == 'Gift' ||
          cart.item!.bundleType == 'gift';

      bool isVoucherNestedProduct = false;
      if (cart.item!.type != 'voucher' && cart.cartGroupId != null) {
        if (voucherDefinitions.containsKey(cart.cartGroupId.toString())) {
          isVoucherNestedProduct = true;
        }
      }

      // For Gift and Flat Discount items, prioritize cart.price over item.price (which is 0)
      // For Flat Discount, use cart.totalPrice (full amount before discount) to show original price in subtotal
      double price = (isFlatDiscount || isGift || isVoucherNestedProduct)
          ? ((isFlatDiscount && cart.totalPrice != null)
              ? cart.totalPrice!
              : (cart.price ?? 0))
          : (cart.item?.price ?? 0);

      if (isGift) {
        print('[CART_SERVICE_DEBUG] 🎁 Gift Item Detected!');
        print('[CART_SERVICE_DEBUG]   - cart.price: ${cart.price}');
        print('[CART_SERVICE_DEBUG]   - cart.item.price: ${cart.item?.price}');
        print(
            '[CART_SERVICE_DEBUG]   - cart.voucherIds: ${cart.item?.voucherIds}');
        print(
            '[CART_SERVICE_DEBUG]   - cart.bundleType: ${cart.item?.bundleType}');
        print('[CART_SERVICE_DEBUG]   - Final price: $price');
      }

      // discountedPrice is the price after item-level or voucher-level discount
      // For Flat Discount and Gift, the API's "price" field is already the discounted amount
      double discountedPrice = (isFlatDiscount || isGift)
          ? (cart.price ?? 0)
          : (cart.item?.price ?? 0);
      // Preserve discount_amount from API for flat vouchers (bonus-based discount)
      double discountAmount = cart.discountAmount ?? 0;
      print(
          '[CART_SERVICE] 💰 discountAmount for item ${cart.item?.name}: $discountAmount (from API: ${cart.discountAmount})');
      double? discount = cart.item!.discount;
      String? discountType = cart.item!.discountType;
      int? quantity = cart.quantity;
      int? stock = cart.item!.stock;

      // Map 'status' from OnlineCartModel to CartModel
      // User Logic: If item is Flat discount and status is 'not_responded', treat as 'pending'
      String? status = cart.status;
      if (isFlatDiscount && status == 'not_responded') {
        print(
            '[CART_SERVICE] 🔄 Mapping status "not_responded" to "pending" for Flat Discount item: ${cart.id}');
        status = 'pending';
      }

      if (cart.item!.type != 'voucher' && cart.cartGroupId != null) {
        if (voucherDefinitions.containsKey(cart.cartGroupId.toString())) {
          item_variation.Item voucherItem =
              voucherDefinitions[cart.cartGroupId.toString()]!;
          discount = voucherItem.discount;
          discountType = voucherItem.discountType;
        }
      }

      List<List<bool?>> selectedFoodVariations = [];
      if (ModuleHelper.getModuleConfig(cart.item!.moduleType).newVariation!) {
        if (cart.item!.type == 'voucher' &&
            (cart.item!.foodVariations == null ||
                cart.item!.foodVariations!.isEmpty) &&
            cart.foodVariation != null) {
          cart.item!.foodVariations = [];
          for (var fv in cart.foodVariation!) {
            List<item_variation.VariationValue> values = [];
            for (var v in fv.values!) {
              values.add(item_variation.VariationValue(
                level: v.label,
                optionPrice: double.tryParse(v.optionPrice ?? '0') ?? 0,
              ));
            }
            cart.item!.foodVariations!.add(item_variation.FoodVariation(
              name: fv.name,
              multiSelect: fv.type == 'multi',
              min: fv.min,
              max: fv.max,
              required: fv.required == 'on',
              variationValues: values,
            ));
          }
        }
        for (int index = 0;
            index < cart.item!.foodVariations!.length;
            index++) {
          selectedFoodVariations.add([]);
          for (int i = 0;
              i < cart.item!.foodVariations![index].variationValues!.length;
              i++) {
            bool isSelected = false;
            if (cart.foodVariation != null) {
              for (var fv in cart.foodVariation!) {
                if (fv.name == cart.item!.foodVariations![index].name) {
                  for (var v in fv.values!) {
                    if (v.label ==
                        cart.item!.foodVariations![index].variationValues![i]
                            .level) {
                      isSelected = true;
                      break;
                    }
                  }
                }
              }
            }
            if (isSelected ||
                (cart.item!.foodVariations![index].variationValues![i]
                        .isSelected ??
                    false)) {
              selectedFoodVariations[index].add(true);
            } else {
              selectedFoodVariations[index].add(false);
            }
          }
        }
      } else {
        String variationType =
            cart.productVariation != null && cart.productVariation!.isNotEmpty
                ? cart.productVariation![0].type!
                : '';
        for (item_variation.Variation variation in cart.item!.variations!) {
          if (variation.type == variationType) {
            discountedPrice = ((PriceConverter.convertWithDiscount(
                        variation.price ?? 0, discount, discountType) ??
                    0) *
                (cart.quantity ?? 1));
            break;
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];

      // Use Global Addon Pool for current item
      for (int index = 0; index < (cart.addOnIds?.length ?? 0); index++) {
        int addOnId = cart.addOnIds![index];
        int addOnQty = cart.addOnQtys![index];

        addOnIdList.add(AddOn(id: addOnId, quantity: addOnQty));

        AddOns? addonMetadata = globalAddonMetadataPool[addOnId];
        if (addonMetadata != null && addonMetadata.price != null) {
          print(
              '[CART_SERVICE_DEBUG] ✅ Found Addon ID: $addOnId, Name: ${addonMetadata.name}, Price: ${addonMetadata.price}');
          addOnsList.add(AddOns(
              id: addOnId,
              name: addonMetadata.name,
              price: addonMetadata.price));
        } else {
          print(
              '[CART_SERVICE_DEBUG] ⚠️ Addon ID $addOnId not found in global pool or has null price!');
          addOnsList.add(AddOns(id: addOnId, name: null, price: null));
        }
      }

      int? quantityLimit = cart.item!.quantityLimit;

      cartList.add(
        CartModel(
          cart.id,
          price,
          discountedPrice,
          cart.productVariation ?? [],
          selectedFoodVariations,
          discountAmount,
          quantity,
          addOnIdList,
          addOnsList,
          false,
          stock,
          cart.item,
          quantityLimit,
          cartGroupId: cart.cartGroupId,
          type: cart.type,
          status: status,
          giftDetails: cart.giftDetails,
        ),
      );
    }

    return cartList;
  }

  @override
  int isExistInCart(List<CartModel> cartList, int? itemID, String variationType,
      bool isUpdate, int? cartIndex) {
    for (int index = 0; index < cartList.length; index++) {
      if (cartList[index].item!.id == itemID &&
          (cartList[index].variation!.isNotEmpty
              ? cartList[index].variation![0].type == variationType
              : true)) {
        if ((isUpdate && index == cartIndex)) {
          return -1;
        } else {
          return index;
        }
      }
    }
    return -1;
  }

  @override
  bool existAnotherStoreItem(
      int? storeID, int? moduleId, List<CartModel> cartList) {
    for (CartModel cartModel in cartList) {
      if (cartModel.item!.storeId != storeID &&
          cartModel.item!.moduleId == moduleId) {
        return true;
      }
    }
    return false;
  }

  @override
  int cartQuantity(int itemId, List<CartModel> cartList) {
    int quantity = 0;
    for (CartModel cart in cartList) {
      if (cart.item!.id == itemId) {
        quantity += cart.quantity!;
      }
    }
    return quantity;
  }

  @override
  String cartVariant(int itemId, List<CartModel> cartList) {
    String variant = '';
    for (CartModel cart in cartList) {
      if (cart.item!.id == itemId) {
        if (!ModuleHelper.getModuleConfig(cart.item!.moduleType)
            .newVariation!) {
          variant = (cart.variation != null && cart.variation!.isNotEmpty)
              ? cart.variation![0].type!
              : '';
        }
      }
    }
    return variant;
  }
}
