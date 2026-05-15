import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'dart:math';
import 'package:get/get.dart';

class GiftScreen1 extends StatefulWidget {
  const GiftScreen1({super.key});

  @override
  State<GiftScreen1> createState() => _GiftScreen1State();
}

class _GiftScreen1State extends State<GiftScreen1> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _occasionSearchController =
      TextEditingController();

  String? _selectedSector;
  String _searchText = '';
  double _amount = 0;
  double _bonusAmount = 0;
  double _bonusPercentage = 0;
  int _messageLength = 0;
  final int _maxMessageLength = 200;
  int _selectedTimingIndex = 0;
  DateTime? _selectedDate;
  int? _selectedDesignIndex;
  bool _buyForSelf = false;
  int? _lastSelectedItemId;

  bool get isReviewReady =>
      _selectedDesignIndex != null &&
      (_buyForSelf || _firstNameController.text.isNotEmpty);

  // Message templates are now loaded from selected occasion's messages

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<GiftController>().resetGiftFlow();
      Get.find<CategoryController>().getCategoryList(false);
      Get.find<CategoryController>()
          .getCategoryStoreList(null, 1, 'all', true, isGift: true);
      if (mounted) {
        setState(() {
          _selectedSector = 'all';
        });
      }
    });

    _amountController.addListener(() {
      setState(() {
        if (_amountController.text.isNotEmpty) {
          _amount = double.tryParse(_amountController.text) ?? 0;
        } else {
          _amount = 0;
        }
        _calculateBonus();
        // Auto save to controller and proceed if valid
        _autoSaveAmount();
      });
    });

    _messageController.addListener(() {
      if (_messageController.text.length > _maxMessageLength) {
        _messageController.text =
            _messageController.text.substring(0, _maxMessageLength);
        _messageController.selection =
            TextSelection.fromPosition(TextPosition(offset: _maxMessageLength));
      }
      setState(() {
        _messageLength = _messageController.text.length;
      });
    });

    _firstNameController.addListener(() {
      setState(() {});
    });
    _lastNameController.addListener(() {
      setState(() {});
    });
    _emailController.addListener(() {
      setState(() {});
    });
    _occasionSearchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _occasionSearchController.dispose();
    super.dispose();
  }

  void _calculateBonus() {
    Item? item = Get.find<GiftController>().selectedItem;
    _bonusAmount = 0;
    _bonusPercentage = 0;
    if (item != null && item.bonusConfiguration != null) {
      for (var config in item.bonusConfiguration!) {
        double min = double.tryParse(config.minAmount ?? '0') ?? 0;
        double maxString = double.tryParse(config.maxAmount ?? '0') ?? 0;
        double max = (maxString == 0 &&
                (config.maxAmount == null || config.maxAmount == '0'))
            ? double.infinity
            : maxString;

        if (_amount >= min && _amount <= max) {
          _bonusPercentage =
              double.tryParse(config.bonusPercentage ?? '0') ?? 0;
          _bonusAmount = (_amount * _bonusPercentage) / 100;
          break;
        }
      }
    }
  }

  void _autoSaveAmount() {
    Item? item = Get.find<GiftController>().selectedItem;
    List<String?> minMax = item?.minMaxAmount ?? [null, null];
    double? minAmount =
        double.tryParse(minMax.isNotEmpty ? minMax[0] ?? '' : '');
    double? maxAmount =
        double.tryParse(minMax.length > 1 ? minMax[1] ?? '' : '');

    bool isRangeValid = true;
    if (minAmount != null && _amount < minAmount && _amount > 0) {
      isRangeValid = false;
    }
    if (maxAmount != null && _amount > maxAmount) {
      isRangeValid = false;
    }

    if (_amount > 0 && isRangeValid) {
      Get.find<GiftController>().saveSelectedAmount(_amount, _bonusAmount);
    }
  }

  void _selectAmount(double value) {
    setState(() {
      _amount = value;
      _amountController.text = value.toStringAsFixed(0);
      _calculateBonus();
    });
  }

  String _formatPrice(double value) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String symbol = Get.find<SplashController>().configModel!.currencySymbol!;
    String priceStr = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    return isRightSide ? '$priceStr $symbol' : '$symbol$priceStr';
  }

  void _addTemplateMessage(String template) {
    String currentText = _messageController.text;
    if ((currentText.length + template.length) <= _maxMessageLength) {
      _messageController.text =
          currentText.isEmpty ? template : '$currentText $template';
      _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'gift_card'.tr),
      body: GetBuilder<GiftController>(builder: (giftController) {
        // Reset local state if the selected voucher has changed (e.g., when switching partners)
        if (giftController.selectedItem?.id != _lastSelectedItemId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _lastSelectedItemId = giftController.selectedItem?.id;
                _amount = 0;
                _amountController.clear();
                _bonusAmount = 0;
                _bonusPercentage = 0;
                _selectedDesignIndex = null;
                _messageController.clear();
                _messageLength = 0;
                _selectedTimingIndex = 0;
                _selectedDate = null;
              });
            }
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto-select first design if occasion is selected but no design index set
              if (giftController.selectedOccasion != null &&
                  _selectedDesignIndex == null)
                Builder(builder: (context) {
                  _selectedDesignIndex = 0;
                  return const SizedBox();
                }),

              // SECTION 1: Category Selection
              _buildSectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('select_a_category'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: 2),
                    Divider(
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1),
                        thickness: 1,
                        height: 1),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    GetBuilder<CategoryController>(
                        builder: (categoryController) {
                      return categoryController.categoryList != null
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedSector = 'all';
                                          categoryController
                                              .getCategoryStoreList(
                                            null,
                                            1,
                                            'all',
                                            true,
                                            isGift: true,
                                          );
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeDefault,
                                            vertical:
                                                Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          color: _selectedSector == 'all'
                                              ? Theme.of(context).primaryColor
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault),
                                          border: _selectedSector == 'all'
                                              ? null
                                              : Border.all(
                                                  color: Theme.of(context)
                                                      .disabledColor
                                                      .withValues(alpha: 0.2)),
                                        ),
                                        child: Text('all'.tr,
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: _selectedSector == 'all'
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color)),
                                      ),
                                    ),
                                  ),
                                  ...categoryController.categoryList!
                                      .map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall),
                                      child: _buildSectorChip(context, category,
                                          categoryController, giftController),
                                    );
                                  }).toList(),
                                ],
                              ),
                            )
                          : const Center(child: CircularProgressIndicator());
                    }),
                  ],
                ),
              ),

              // SECTION 2: Store Selection
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildSectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('select_a_partner'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      titleText: 'search_for_partner'.tr,
                      hintText: 'search_for_partner'.tr,
                      prefixIcon: Icons.search,
                      inputType: TextInputType.text,
                      controller: _searchController,
                      showLabelText: false,
                      borderRadius: Dimensions.radiusLarge,
                      borderColor: Theme.of(context).primaryColor,
                      fillColor: Colors.white,
                      onChanged: (String value) {
                        setState(() {
                          _searchText = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    GetBuilder<CategoryController>(
                        builder: (categoryController) {
                      if (categoryController.categoryStoreList == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      List<Store> filteredStores = categoryController
                          .categoryStoreList!
                          .where((store) =>
                              store.name!.toLowerCase().contains(_searchText))
                          .toList();

                      // Auto-select first store if none selected
                      if (giftController.selectedStore == null &&
                          filteredStores.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          giftController.saveSelectedStore(filteredStores[0]);
                          giftController.getStoreItems(filteredStores[0].id!);
                        });
                      }

                      if (filteredStores.isEmpty) {
                        return Center(
                            child: Text('no_partners_found'.tr,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor)));
                      }

                      // Create rows of 6 stores each for horizontal scrolling
                      List<List<Store>> chunkedStores = [];
                      for (var i = 0; i < filteredStores.length; i += 6) {
                        chunkedStores.add(filteredStores.sublist(
                            i,
                            i + 6 > filteredStores.length
                                ? filteredStores.length
                                : i + 6));
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chunkedStores.map((rowStores) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeSmall),
                              child: Row(
                                children: rowStores.map((store) {
                                  return Container(
                                    width:
                                        160, // Decreased width for better fit
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    child: _buildStoreCard(
                                        context, store, giftController),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // SECTION 3: Top-Up Value & Customize gift card (Occasions)
              if (giftController.isVoucherSelected) ...[
                const SizedBox(height: Dimensions.paddingSizeLarge),
                _buildSectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopUpValueSection(giftController),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _buildOccasionSection(giftController),
                    ],
                  ),
                ),
              ],

              // SECTION 6 (Designs), 7 (Card Info), 8 (Share/Email) & 9 (Review)
              if (giftController.isOccasionSelected) ...[
                const SizedBox(height: Dimensions.paddingSizeLarge),
                _buildSectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDesignSection(giftController),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _buildCardInfoSection(giftController),
                      if (!_buyForSelf) ...[
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        _buildShareSection(giftController),
                      ],
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _buildReviewSection(giftController),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
            ],
          ),
        );
      }),
      bottomNavigationBar:
          GetBuilder<GiftController>(builder: (giftController) {
        if (!isReviewReady) return const SizedBox();

        double cardTotalValue = giftController.selectedAmount ?? 0;
        double bonus = giftController.bonusAmount ?? 0;
        double totalToPay = cardTotalValue + bonus;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('total'.tr,
                            style: robotoRegular.copyWith(
                                color: Colors.grey, fontSize: 10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              PriceConverter.convertPrice(cardTotalValue),
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).primaryColor),
                            ),
                            if (bonus > 0) ...[
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                PriceConverter.convertPrice(totalToPay),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 150,
                    child: CustomButton(
                      buttonText: 'buy_now'.tr,
                      isLoading: Get.find<CartController>().isLoading,
                      onPressed: () async {
                        String cartGroup =
                            (Random().nextInt(90000000) + 10000000).toString();

                        GiftDetails giftDetails = GiftDetails(
                          occasion: _occasionSearchController.text.isNotEmpty
                              ? _occasionSearchController.text
                              : giftController.selectedOccasion?.title,
                          image: giftController
                              .selectedOccasion?.icon?[_selectedDesignIndex!],
                          senderName: Get.find<ProfileController>()
                                  .userInfoModel
                                  ?.fName ??
                              'User',
                          recipientName: _buyForSelf
                              ? (Get.find<ProfileController>()
                                      .userInfoModel
                                      ?.fName ??
                                  'Self')
                              : '${_firstNameController.text} ${_lastNameController.text}',
                          recipientEmail: _buyForSelf
                              ? (Get.find<ProfileController>()
                                      .userInfoModel
                                      ?.email ??
                                  '')
                              : _emailController.text,
                          message: _messageController.text,
                          deliveryTime: _selectedTimingIndex == 0
                              ? 'instant'.tr
                              : (_selectedDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate!)
                                  : 'scheduled'.tr),
                          amount: cardTotalValue,
                          bonus: bonus,
                        );

                        OnlineCart onlineCart = OnlineCart(
                          null,
                          giftController.selectedItem!.id,
                          null,
                          cardTotalValue.toString(),
                          '',
                          null,
                          [],
                          1,
                          [],
                          [],
                          [],
                          'Item',
                          itemType: 'Item',
                          cartGroup: cartGroup,
                          storeId: giftController.selectedStore?.id,
                          timeout: 130,
                          giftDetails: giftDetails,
                          discountAmount: bonus,
                          totalPrice: cardTotalValue + bonus,
                        );

                        bool success = await Get.find<CartController>()
                            .addToCartOnline(onlineCart);

                        if (success) {
                          Get.toNamed(RouteHelper.getCheckoutRoute('buy_now'),
                              arguments: CheckoutScreen(
                                storeId: null,
                                fromCart: true,
                                cartList: null,
                                isBuyNow: true,
                                isGiftVoucher: true,
                              ));
                        } else {
                          showCustomSnackBar(
                              'failed_to_add_gift_card_to_cart'.tr);
                        }
                      },
                      radius: Dimensions.radiusDefault,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectorChip(BuildContext context, CategoryModel category,
      CategoryController categoryController, GiftController giftController) {
    final isSelected = _selectedSector == category.name;
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedSector == category.name) {
            _selectedSector = null;
          } else {
            _selectedSector = category.name;
            categoryController.getCategoryStoreList(
              category.id.toString(),
              1,
              'all',
              true,
              isGift: true,
            );

            // Fetch first store after a short delay since getCategoryStoreList returns void
            Future.delayed(const Duration(milliseconds: 500), () {
              if (categoryController.categoryStoreList != null &&
                  categoryController.categoryStoreList!.isNotEmpty) {
                giftController.saveSelectedStore(
                    categoryController.categoryStoreList![0]);
                giftController.getStoreItems(
                    categoryController.categoryStoreList![0].id!);
              }
            });
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: isSelected
              ? null
              : Border.all(
                  color:
                      Theme.of(context).disabledColor.withValues(alpha: 0.2)),
        ),
        child: Text(category.name!,
            style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color)),
      ),
    );
  }

  /// Calculate highest bonus percentage from voucher's bonus configuration
  double? _getHighestBonusPercentage(GiftController giftController) {
    try {
      Item? voucher = giftController.selectedItem;
      if (voucher == null) {
        debugPrint('=====> No voucher selected yet');
        return null;
      }

      debugPrint('=====> Checking bonus for voucher: ${voucher.name}');
      debugPrint(
          '=====> bonus_configuration value: ${voucher.bonusConfiguration}');

      // Parse bonus_configuration from voucher (already a List<BonusConfiguration>)
      if (voucher.bonusConfiguration != null &&
          voucher.bonusConfiguration!.isNotEmpty) {
        double maxBonus = 0;
        for (var config in voucher.bonusConfiguration!) {
          double? percentage = double.tryParse(config.bonusPercentage ?? '0');
          debugPrint(
              '=====> Found bonus tier: min=${config.minAmount}, max=${config.maxAmount}, bonus=${config.bonusPercentage}%');

          if (percentage != null && percentage > maxBonus) {
            maxBonus = percentage;
          }
        }
        debugPrint('=====> Highest bonus from voucher: $maxBonus%');
        return maxBonus > 0 ? maxBonus : null;
      } else {
        debugPrint('=====> No bonus_configuration in voucher');
      }
    } catch (e) {
      debugPrint('=====> Error parsing voucher bonus configuration: $e');
    }
    return null;
  }

  Widget _buildStoreCard(
      BuildContext context, Store store, GiftController giftController) {
    final isSelected = giftController.selectedStore?.id == store.id;
    double? bonusPercentage = _getHighestBonusPercentage(giftController);

    return InkWell(
      onTap: () {
        giftController.saveSelectedStore(store);
        giftController.getStoreItems(store.id!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6A4DF4)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Store logo and rating below
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Store circular image
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImage(
                            image: store.logoFullUrl ??
                                store.coverPhotoFullUrl ??
                                '',
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Rating below logo
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            store.avgRating?.toStringAsFixed(1) ?? '0.0',
                            style: robotoBold.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Store Name
                        Text(
                          store.name ?? '',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Spacing to align Bonus with Rating row
                        const SizedBox(height: 18),

                        // Bonus Percentage (Beside Rating level)
                        if (bonusPercentage != null && bonusPercentage > 0)
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF6A4DF4), // 70%
                                Color(0xFFC084FC), // 30%
                              ],
                              stops: [0.7, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              '+${bonusPercentage.toStringAsFixed(0)}% ${'bonus'.tr}',
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection overlay - stays within card bounds due to ClipRRect
            if (isSelected) ...[
              // Semi-transparent purple overlay - DARKER for visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A4DF4).withValues(
                        alpha: 0.3), // Increased to 0.3 for visibility
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                ),
              ),

              // Centered Checkmark
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFF6A4DF4), width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF6A4DF4),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpValueSection(GiftController giftController) {
    Item? item = giftController.selectedItem;
    bool hasFixedOptions = item?.fixedAmountOptions != null &&
        item!.fixedAmountOptions!.isNotEmpty;
    bool isCustomEnabled = item?.enableCustomAmount == '1';

    List<String?> minMax = item?.minMaxAmount ?? [null, null];
    double? minAmount =
        double.tryParse(minMax.isNotEmpty ? minMax[0] ?? '' : '');
    double? maxAmount =
        double.tryParse(minMax.length > 1 ? minMax[1] ?? '' : '');

    bool hasValidRange = (minAmount != null && minAmount > 0) ||
        (maxAmount != null && maxAmount > 0);
    bool showFixedOptions = hasFixedOptions;

    double bonusValue = _bonusAmount;
    double cardValue = _amount;
    double amountToPay = _amount + bonusValue;

    bool isRangeValid = true;
    if (hasValidRange) {
      if (minAmount != null && _amount < minAmount && _amount > 0) {
        isRangeValid = false;
      }
      if (maxAmount != null && _amount > maxAmount) {
        isRangeValid = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('top_up_value'.tr,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        const Divider(height: 1),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        if (showFixedOptions) ...[
          Text('select_amount'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Wrap(
            spacing: Dimensions.paddingSizeSmall,
            runSpacing: Dimensions.paddingSizeSmall,
            children: item.fixedAmountOptions!.map((amountStr) {
              double amount = double.tryParse(amountStr) ?? 0;
              bool isSelected = _amount == amount;
              return InkWell(
                onTap: () => _selectAmount(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${Get.find<SplashController>().configModel!.currencySymbol}$amountStr',
                    style: robotoMedium.copyWith(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
        if (isCustomEnabled) ...[
          Text('custom_amount'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'enter_amount'.tr,
            controller: _amountController,
            inputType: TextInputType.number,
            showLabelText: false,
            isEnabled: isCustomEnabled,
            prefixIcon: Icons.attach_money,
            borderRadius: Dimensions.radiusExtraLarge,
            borderColor: Theme.of(context).primaryColor,
            fillColor: Colors.white,
          ),
          if (hasValidRange) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              '${minAmount != null ? 'Min: $minAmount' : ''}${minAmount != null && maxAmount != null ? ', ' : ''}${maxAmount != null ? 'Max: $maxAmount' : ''}',
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color:
                      isRangeValid ? Theme.of(context).hintColor : Colors.red),
            ),
          ],
        ],
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Bonus Tiers Section
        if (item?.bonusConfiguration != null &&
            item!.bonusConfiguration!.isNotEmpty) ...[
          Text('available_bonus_tiers'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: item.bonusConfiguration!.map((config) {
                double minAmt = double.tryParse(config.minAmount ?? '0') ?? 0;
                double maxAmt = double.tryParse(config.maxAmount ?? '0') ?? 0;
                double bonus =
                    double.tryParse(config.bonusPercentage ?? '0') ?? 0;

                // Check if currently selected amount is in this tier
                bool isActiveTier = _amount >= minAmt && _amount <= maxAmt;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isActiveTier
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 18,
                        color: isActiveTier
                            ? Colors.green
                            : Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          '${_formatPrice(minAmt)} - ${_formatPrice(maxAmt)}',
                          style: isActiveTier
                              ? robotoBold.copyWith(
                                  color: Theme.of(context).primaryColor)
                              : robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor),
                        ),
                      ),
                      Text(
                        '${bonus.toStringAsFixed(0)}% ${'bonus'.tr}',
                        style: isActiveTier
                            ? robotoBold.copyWith(
                                color: Theme.of(context).primaryColor)
                            : robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        // Value Breakdown Row (Pills)
        Row(
          children: [
            Expanded(
              child: _buildBreakdownPill(
                label: 'amount_to_pay'.tr,
                value: _formatPrice(cardValue),
                isSolid: false,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _buildBreakdownPill(
                label: 'bonus'.tr,
                value: _formatPrice(bonusValue),
                isSolid: false,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _buildBreakdownPill(
                label: 'total_card_value'.tr,
                value: _formatPrice(amountToPay),
                isSolid: true,
                colors: _getVoucherColors(item?.voucherIds),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownPill(
      {required String label,
      required String value,
      required bool isSolid,
      required List<Color> colors}) {
    Color mixedColor = Color.lerp(colors[0], colors[1], 0.3) ?? colors[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: robotoBold.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSolid ? null : Colors.white,
            gradient: isSolid
                ? LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: isSolid ? null : Border.all(color: mixedColor),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: robotoBold.copyWith(
              color: isSolid ? Colors.white : mixedColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getVoucherColors(String? voucherIds) {
    if (voucherIds == null) {
      return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
    }
    String ids = voucherIds.toLowerCase();
    if (ids.contains('delivery') || ids.contains('pickup')) {
      return [const Color(0xFFF43F8C), const Color(0xFFFB8B5E)];
    } else if (ids.contains('in-store') || ids.contains('instore')) {
      return [const Color(0xFF1ABC9C), const Color(0xFFA8E063)];
    } else if (ids.contains('flat') ||
        ids.contains('discount') ||
        ids.contains('voucher')) {
      return [const Color(0xFFFF8A2B), const Color(0xFFFFD54F)];
    } else if (ids.contains('gift')) {
      return [const Color(0xFF6A4DF4), const Color(0xFFC084FC)];
    }
    return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
  }

  Widget _buildOccasionSection(GiftController giftController) {
    // Get occasions from the selected voucher instead of separate API
    List<GiftOccasionModel>? occasions =
        giftController.selectedItem?.giftOccasions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_occasion'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        if (occasions != null && occasions.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: occasions.map((occasion) {
                bool isSelected =
                    giftController.selectedOccasion?.id == occasion.id;
                return Padding(
                  padding:
                      const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () {
                      giftController.selectOccasion(occasion);
                      setState(() {
                        _selectedDesignIndex = 0;
                      });
                    },
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusExtraLarge),
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1),
                      ),
                      child: Text(
                        occasion.title ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          Center(
              child: Text('no_occasions_available'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor))),
      ],
    );
  }

  Widget _buildDesignSection(GiftController giftController) {
    GiftOccasionModel? occasion = giftController.selectedOccasion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_design'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        if (occasion?.icon != null && occasion!.icon!.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: 1.3,
            ),
            itemCount: occasion.icon!.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedDesignIndex == index;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDesignIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1)
                      ],
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor, width: 2)
                          : null,
                    ),
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        child: CustomImage(
                          image: (occasion.icon![index].startsWith('http')
                              ? occasion.icon![index]
                              : '${AppConstants.baseUrl}/${occasion.icon![index]}'),
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      if (isSelected)
                        const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ]),
                  ),
                ),
              );
            },
          )
        else
          Center(
              child: Text('no_designs_available'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor))),
      ],
    );
  }

  Widget _buildCardInfoSection(GiftController giftController) {
    Item? voucher = giftController.selectedVoucher;
    List<String> messageTemplates = [];

    // First try to get messages from selected occasion
    if (giftController.selectedOccasion?.message != null &&
        giftController.selectedOccasion!.message!.isNotEmpty) {
      messageTemplates = giftController.selectedOccasion!.message!;
    }
    // Fallback to voucher message templates if occasion messages not available
    else if (voucher != null &&
        voucher.messageTemplates != null &&
        voucher.messageTemplates!.isNotEmpty) {
      messageTemplates = voucher.messageTemplates!
          .map((e) => e.title ?? '')
          .where((title) => title.isNotEmpty)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('card_info'.tr,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        const Divider(height: 1),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Buy for Self Toggle
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _buyForSelf = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_buyForSelf
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Text(
                      'send_as_a_gift_card'.tr,
                      style: robotoMedium.copyWith(
                        color: !_buyForSelf
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _buyForSelf = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _buyForSelf
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Text(
                      'buy_for_your_self'.tr,
                      style: robotoMedium.copyWith(
                        color: _buyForSelf
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_buyForSelf) ...[
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text('recipient_name_here'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'john_doe'.tr,
            controller: _firstNameController,
            inputType: TextInputType.name,
            showLabelText: false,
            borderRadius: Dimensions.radiusLarge,
            borderColor: Theme.of(context).primaryColor,
            fillColor: Colors.white,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('enter_message_optional'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'write_your_message_here'.tr,
            controller: _messageController,
            inputType: TextInputType.multiline,
            maxLines: 3,
            showLabelText: false,
            borderRadius: Dimensions.radiusLarge,
            borderColor: Theme.of(context).primaryColor,
            fillColor: Colors.white,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(
              '$_messageLength/$_maxMessageLength',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeExtraSmall),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('message_templates'.tr,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeSmall)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: messageTemplates.map((template) {
                return Padding(
                  padding:
                      const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () {
                      String currentText = _messageController.text;
                      if ((currentText.length + template.length) <=
                          _maxMessageLength) {
                        _messageController.text = currentText.isEmpty
                            ? template
                            : '$currentText $template';
                        _messageController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _messageController.text.length));
                      }
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1),
                      ),
                      child: Text(
                        template,
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShareSection(GiftController giftController) {
    if (_buyForSelf) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('delivery_via_email'.tr,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        const Divider(height: 1),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text('share_via_email'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomTextField(
          hintText: 'enter_recipient_email'.tr,
          controller: _emailController,
          inputType: TextInputType.emailAddress,
          showLabelText: false,
          borderRadius: Dimensions.radiusLarge,
          borderColor: Theme.of(context).primaryColor,
          fillColor: Colors.white,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text('email_delivery_time'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                buttonText: 'send_on_future_date'.tr,
                onPressed: () {
                  setState(() {
                    _selectedTimingIndex = 1;
                  });
                },
                color: _selectedTimingIndex == 1
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                textColor: _selectedTimingIndex == 1
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                isBorder: _selectedTimingIndex != 1,
                fontSize: Dimensions.fontSizeExtraSmall,
                radius: Dimensions.radiusExtraLarge,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: CustomButton(
                buttonText: 'send_instantly'.tr,
                onPressed: () {
                  setState(() {
                    _selectedTimingIndex = 0;
                    _selectedDate = null;
                  });
                },
                color: _selectedTimingIndex == 0
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                textColor: _selectedTimingIndex == 0
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                isBorder: _selectedTimingIndex != 0,
                fontSize: Dimensions.fontSizeExtraSmall,
                radius: Dimensions.radiusExtraLarge,
              ),
            ),
          ],
        ),
        if (_selectedTimingIndex == 1) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'select_date'.tr,
                    style: robotoRegular,
                  ),
                  const Icon(Icons.calendar_today_outlined),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewSection(GiftController giftController) {
    String storeName = giftController.selectedStore?.name ?? '';
    double cardTotalValue = giftController.selectedAmount ?? 0;
    double bonus = giftController.bonusAmount ?? 0;
    double totalToPay = cardTotalValue + bonus;

    String userName =
        '${Get.find<ProfileController>().userInfoModel?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.lName ?? ''}'
            .trim();
    if (userName.isEmpty) userName = 'user_name'.tr;

    String recipientName = _buyForSelf
        ? userName
        : '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    if (recipientName.isEmpty) recipientName = 'recipient_name'.tr;

    String recipientEmail = _buyForSelf
        ? (Get.find<ProfileController>().userInfoModel?.email ?? '')
        : _emailController.text.trim();

    String sharingMethod = _buyForSelf ? 'digital_send'.tr : 'email_delivery'.tr;
    String timing = _buyForSelf
        ? 'instant'.tr
        : (_selectedTimingIndex == 1
            ? (_selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                : 'scheduled'.tr)
            : 'now'.tr);

    String? designImage;
    if (giftController.selectedOccasion != null &&
        _selectedDesignIndex != null &&
        giftController.selectedOccasion!.icon != null &&
        giftController.selectedOccasion!.icon!.isNotEmpty) {
      String icon =
          giftController.selectedOccasion!.icon![_selectedDesignIndex!];
      designImage =
          icon.startsWith('http') ? icon : '${AppConstants.baseUrl}/$icon';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('order_review'.tr,
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).primaryColor)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        const Divider(height: 1),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text('gift_card_design'.tr, style: robotoBold),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Gift Card Design Preview
        if (designImage != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, spreadRadius: 2)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              child: CustomImage(
                image: designImage,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Order Info Table
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('order_info'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              const Divider(height: 1),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildInfoRow('merchant'.tr, storeName),
              _buildInfoRow('recipient_name'.tr, recipientName),
              if (!_buyForSelf && _messageController.text.isNotEmpty)
                _buildInfoRow('recipient_message'.tr, _messageController.text),
              _buildInfoRow('send_by'.tr, userName),
              _buildInfoRow('delivery_method'.tr,
                  '$sharingMethod${recipientEmail.isNotEmpty ? ': $recipientEmail' : ''}'),
              _buildInfoRow('delivery_time'.tr, timing),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Payment Breakdown
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('payment_breakdown'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              const Divider(height: 1),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildInfoRow('card_value'.tr, _formatPrice(totalToPay),
                  isBoldValue: true),
              if (bonus > 0)
                _buildInfoRow('bonus_value'.tr, _formatPrice(bonus),
                    isBoldValue: true, valueColor: Colors.purple),
              _buildInfoRow('total_to_pay'.tr, _formatPrice(cardTotalValue),
                  isBoldValue: true),
            ],
          ),
        ),
        const SizedBox(height: 100), // Space for sticky bar
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBoldValue = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: robotoRegular.copyWith(
                  color: Colors.black87, fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
