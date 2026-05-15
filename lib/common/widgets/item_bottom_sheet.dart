import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet_shimmer.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/quantity_button.dart';
import 'package:sixam_mart/common/widgets/order_status_dialog.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'dart:math';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:get/get.dart';

class ItemBottomSheet extends StatefulWidget {
  final int itemId;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final bool inStorePage;
  const ItemBottomSheet(
      {super.key,
      required this.itemId,
      this.isCampaign = false,
      this.cart,
      this.cartIndex,
      this.inStorePage = false});

  @override
  State<ItemBottomSheet> createState() => _ItemBottomSheetState();
}

class _ItemBottomSheetState extends State<ItemBottomSheet> {
  bool _newVariation = false;
  List<bool> _isExpanded = [];
  bool _bogoAExpanded = false;
  bool _bogoBExpanded = false;
  int? _editingBogoAIndex;
  int? _editingBogoBIndex;

  // Flat Voucher State
  final TextEditingController _amountController = TextEditingController();
  int? _selectedBranchId;
  Store? _selectedBranch;
  double _flatVoucherPrice = 0;
  double _flatVoucherDiscount = 0;
  double _flatVoucherBonus = 0;

  bool _isBuyNowLoading = false;
  bool _isGiftLoading = false;

  // Simple Bundle State - tracks confirmed selections

  // Gift Voucher State
  double _selectedGiftAmount = 0;
  double _giftBonusPercentage = 0;
  double _giftBonusAmount = 0;
  GiftOccasionModel? _selectedOccasion;
  int? _selectedDesignIndex;

  bool _buyForSelf = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _selectedTimingIndex = 0;
  DateTime? _selectedDate;
  int _messageLength = 0;
  final int _maxMessageLength = 200;

  @override
  void initState() {
    super.initState();

    ItemController itemController = Get.find<ItemController>();
    SplashController splashController = Get.find<SplashController>();

    if (splashController.module == null) {
      if (splashController.cacheModule != null) {
        splashController.setCacheConfigModule(splashController.cacheModule);
      }
    }

    itemController
        .getItemDetails(itemId: widget.itemId, cart: widget.cart)
        .then((_) {
      if (mounted) {
        setState(() {
          _newVariation = splashController
                  .getModuleConfig(itemController.item?.moduleType)
                  .newVariation ??
              false;

          // Auto-select defaults for gift vouchers
          if (itemController.item != null &&
              itemController.item!.bundleType == 'gift') {
            // 1. Pre-select first gift amount if fixed options exist
            if (itemController.item!.fixedAmountOptions != null &&
                itemController.item!.fixedAmountOptions!.isNotEmpty) {
              double? firstAmount = double.tryParse(
                  itemController.item!.fixedAmountOptions![0].toString());
              if (firstAmount != null) {
                _selectedGiftAmount = firstAmount;
                _amountController.text = firstAmount.toStringAsFixed(0);
                _calculateGiftVoucherValues(
                    firstAmount.toString(), itemController.item);
              }
            }

            // 2. Pre-select first occasion and designttttt
            if (itemController.item!.giftOccasions != null &&
                itemController.item!.giftOccasions!.isNotEmpty) {
              _selectedOccasion = itemController.item!.giftOccasions![0];
              _selectedDesignIndex = 0;
            }
          }

          print(
              '====> _newVariation set to: $_newVariation for item ${itemController.item?.name}');
          print(
              '====> foodVariations count: ${itemController.item?.foodVariations?.length ?? 0}');
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateFlatVoucherValues(String value, Item? item) {
    if (value.isEmpty) {
      setState(() {
        _flatVoucherDiscount = 0;
        _flatVoucherPrice = 0;
        _flatVoucherBonus = 0;
      });
      return;
    }

    double amount = double.tryParse(value) ?? 0;
    double bonusPerc = 0;

    if (item?.bonusConfiguration != null) {
      for (var config in item!.bonusConfiguration!) {
        double min = double.tryParse(config.minAmount.toString()) ?? 0;
        double max =
            double.tryParse(config.maxAmount.toString()) ?? double.infinity;
        if (amount >= min && amount <= max) {
          bonusPerc = double.tryParse(config.bonusPercentage.toString()) ?? 0;
          break;
        }
      }
    }

    double discountAmount = amount * (bonusPerc / 100);

    // Apply Customer Commission Logic for Flat Vouchers
    if (item?.store?.commissionPaidBy == 'customer' &&
        item?.store?.comission != null) {
      double afterDiscountAmount = amount - discountAmount;
      double commissionAmount =
          afterDiscountAmount * (item!.store!.comission! / 100);
      bonusPerc = ((discountAmount - commissionAmount) / amount) * 100;
      discountAmount = amount * (bonusPerc / 100);
    }

    setState(() {
      _flatVoucherBonus = bonusPerc;
      _flatVoucherDiscount = discountAmount;
      _flatVoucherPrice = amount - discountAmount;
    });
  }

  bool _isFlatVoucherValid(Item? item) {
    if (item == null) return false;
    double amount = double.tryParse(_amountController.text) ?? 0;

    bool inRange = false;
    if (item.bonusConfiguration != null &&
        item.bonusConfiguration!.isNotEmpty) {
      for (var config in item.bonusConfiguration!) {
        double min = double.tryParse(config.minAmount.toString()) ?? 0;
        double max =
            double.tryParse(config.maxAmount.toString()) ?? double.infinity;
        if (amount >= min && amount <= max) {
          inRange = true;
          break;
        }
      }
    } else {
      if (item.bonusConfiguration == null || item.bonusConfiguration!.isEmpty)
        inRange = true;
    }

    bool branchSelected =
        _selectedBranchId != null || _isDeliveryOrPickup(item);

    return amount > 0 && inRange && branchSelected;
  }

  bool _isDeliveryOrPickup(Item? item) {
    if (item == null || item.voucherIds == null) return false;
    String vId = item.voucherIds!.toLowerCase();
    return vId.contains('delivery') || vId.contains('pickup');
  }

  String _formatPrice(double value) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String symbol = Get.find<SplashController>().configModel!.currencySymbol!;
    String priceStr = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    return isRightSide ? '$priceStr $symbol' : '$symbol$priceStr';
  }

  void _calculateGiftVoucherValues(String value, Item? item) {
    if (value.isEmpty) {
      setState(() {
        _selectedGiftAmount = 0;
        _giftBonusPercentage = 0;
        _giftBonusAmount = 0;
      });
      return;
    }

    double amount = double.tryParse(value) ?? 0;
    double bonusPerc = 0;

    if (item?.bonusConfiguration != null) {
      for (var config in item!.bonusConfiguration!) {
        double min = double.tryParse(config.minAmount.toString()) ?? 0;
        double max =
            double.tryParse(config.maxAmount.toString()) ?? double.infinity;
        if (amount >= min && amount <= max) {
          bonusPerc = double.tryParse(config.bonusPercentage.toString()) ?? 0;
          break;
        }
      }
    }

    double discountAmount = amount * (bonusPerc / 100);

    setState(() {
      _selectedGiftAmount = amount;
      _giftBonusPercentage = bonusPerc;
      _giftBonusAmount = discountAmount;
    });
  }

  void _selectGiftAmount(double value, Item item) {
    setState(() {
      _selectedGiftAmount = value;
      _amountController.text = value.toStringAsFixed(0);
      _calculateGiftVoucherValues(value.toString(), item);
    });
  }

  Widget _buildTopUpValueSection(Item item) {
    bool hasFixedOptions =
        item.fixedAmountOptions != null && item.fixedAmountOptions!.isNotEmpty;
    bool isCustomEnabled = item.enableCustomAmount == '1';

    List<String?> minMax = item.minMaxAmount ?? [null, null];
    double? minAmount =
        double.tryParse(minMax.isNotEmpty ? minMax[0] ?? '' : '');
    double? maxAmount =
        double.tryParse(minMax.length > 1 ? minMax[1] ?? '' : '');

    bool hasValidRange = (minAmount != null && minAmount > 0) ||
        (maxAmount != null && maxAmount > 0);

    bool isRangeValid = true;
    if (hasValidRange) {
      if (minAmount != null &&
          _selectedGiftAmount < minAmount &&
          _selectedGiftAmount > 0) {
        isRangeValid = false;
      }
      if (maxAmount != null && _selectedGiftAmount > maxAmount) {
        isRangeValid = false;
      }
    }

    double amountToPay = _selectedGiftAmount + _giftBonusAmount;
    List<Color> primaryColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor
    ];
    List<Color> voucherColors = _getVoucherColors(item.voucherIds);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('top_up_value'.tr,
              style:
                  robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          const Divider(height: 1),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (hasFixedOptions) ...[
            Text('select_amount'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Wrap(
              spacing: Dimensions.paddingSizeSmall,
              runSpacing: Dimensions.paddingSizeSmall,
              children: item.fixedAmountOptions!.map((amountStr) {
                double amount = double.tryParse(amountStr) ?? 0;
                bool isSelected = _selectedGiftAmount == amount;
                return InkWell(
                  onTap: () => _selectGiftAmount(amount, item),
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                enabled: isCustomEnabled,
                decoration: InputDecoration(
                  hintText: isCustomEnabled
                      ? 'enter_amount'.tr
                      : 'custom_amount_disabled'.tr,
                  prefixIcon: Icon(Icons.attach_money,
                      color: Theme.of(context).primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault, vertical: 12),
                ),
                onChanged: (val) => _calculateGiftVoucherValues(val, item),
              ),
            ),
          ],
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

          // Available Bonus Tiers
          if (item.bonusConfiguration != null &&
              item.bonusConfiguration!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Available Bonus Tiers:',
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: Colors.black),
            ),
            const SizedBox(height: 4),
            ...item.bonusConfiguration!.map((config) {
              double minAmt = double.tryParse(config.minAmount ?? '0') ?? 0;
              double maxAmt = double.tryParse(config.maxAmount ?? '0') ?? 0;
              double bonus =
                  double.tryParse(config.bonusPercentage ?? '0') ?? 0;

              // Check if entered amount is in this tier
              bool isActiveTier = _selectedGiftAmount >= minAmt &&
                  _selectedGiftAmount <= maxAmt;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      isActiveTier ? Icons.check_circle : Icons.circle_outlined,
                      size: 14,
                      color: isActiveTier
                          ? Colors.green
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatPrice(minAmt)} - ${_formatPrice(maxAmt)}: ${bonus.toStringAsFixed(0)}% Bonus',
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isActiveTier
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor,
                          fontWeight: isActiveTier
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Value Breakdown Row (3 Columns matching GiftScreen1)
          Row(
            children: [
              Expanded(
                child: _buildBreakdownPill(
                  label: 'amount_to_pay'.tr,
                  value: _formatPrice(_selectedGiftAmount),
                  isSolid: false,
                  colors: primaryColors,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: _buildBreakdownPill(
                  label: 'bonus_value'.tr,
                  value: _formatPrice(_giftBonusAmount),
                  isSolid: false,
                  colors: primaryColors,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: _buildBreakdownPill(
                  label: 'total_card_value'.tr,
                  value: _formatPrice(amountToPay),
                  isSolid: true,
                  colors: voucherColors,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _buildOccasionSection(item),
          if (_selectedOccasion != null) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            _buildDesignSection(_selectedOccasion!),
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 0.5),
            ),
            _buildCardInfoSection(item),
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 0.5),
            ),
            _buildShareSection(),
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 0.5),
            ),
            _buildReviewSection(item),
          ],
        ],
      ),
    );
  }

  Widget _buildCardInfoSection(Item item) {
    List<String> messageTemplates = _selectedOccasion?.message ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('card_info'.tr,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
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
          Text('recipient_name'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'enter_name'.tr,
            controller: _firstNameController,
            inputType: TextInputType.name,
            showLabelText: false,
            borderRadius: Dimensions.radiusLarge,
            borderColor: Theme.of(context).primaryColor.withOpacity(0.3),
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
            borderColor: Theme.of(context).primaryColor.withOpacity(0.3),
            fillColor: Colors.white,
            onChanged: (val) => setState(() => _messageLength = val.length),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_messageLength/$_maxMessageLength',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeExtraSmall),
            ),
          ),
          if (messageTemplates.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
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
                    padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () {
                        if ((_messageController.text.length +
                                template.length) <=
                            _maxMessageLength) {
                          setState(() {
                            _messageController.text =
                                _messageController.text.isEmpty
                                    ? template
                                    : '${_messageController.text} $template';
                            _messageLength = _messageController.text.length;
                          });
                        }
                      },
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: 6),
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
      ],
    );
  }

  Widget _buildShareSection() {
    if (_buyForSelf) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('delivery_via_email'.tr,
            style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text('share_via_email'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomTextField(
          hintText: 'enter_recipient_email'.tr,
          controller: _emailController,
          inputType: TextInputType.emailAddress,
          showLabelText: false,
          borderRadius: Dimensions.radiusLarge,
          borderColor: Theme.of(context).primaryColor.withOpacity(0.3),
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
                onPressed: () => setState(() => _selectedTimingIndex = 1),
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
                onPressed: () => setState(() {
                  _selectedTimingIndex = 0;
                  _selectedDate = null;
                }),
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
              if (pickedDate != null && mounted) {
                setState(() => _selectedDate = pickedDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3)),
                color: Colors.white,
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
                  Icon(Icons.calendar_today_outlined,
                      color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewSection(Item item) {
    String senderName =
        '${Get.find<ProfileController>().userInfoModel?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.lName ?? ''}'
            .trim();
    if (senderName.isEmpty) senderName = 'sender'.tr;

    String recipientName =
        _buyForSelf ? senderName : _firstNameController.text.trim();
    if (recipientName.isEmpty) recipientName = 'recipient'.tr;

    String sharingMethod =
        _buyForSelf ? 'self_purchase'.tr : 'email_delivery'.tr;
    String timing = _buyForSelf
        ? 'instant'.tr
        : (_selectedTimingIndex == 1
            ? (_selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                : 'scheduled'.tr)
            : 'instantly'.tr);

    String? designImage;
    if (_selectedOccasion != null &&
        _selectedDesignIndex != null &&
        _selectedOccasion!.icon != null &&
        _selectedOccasion!.icon!.isNotEmpty) {
      String icon = _selectedOccasion!.icon![_selectedDesignIndex!];
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
        const SizedBox(height: Dimensions.paddingSizeDefault),
        if (designImage != null) ...[
          Text('gift_card_design'.tr, style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            height: 160,
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
        ],
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('order_info'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildInfoRow('merchant'.tr, item.storeName ?? ''),
              _buildInfoRow('recipient_name'.tr, recipientName),
              if (!_buyForSelf && _messageController.text.isNotEmpty)
                _buildInfoRow('recipient_message'.tr, _messageController.text),
              _buildInfoRow('send_by'.tr, senderName),
              _buildInfoRow('delivery_method'.tr, sharingMethod),
              _buildInfoRow('delivery_time'.tr, timing),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('payment_breakdown'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildInfoRow('card_value'.tr,
                  _formatPrice(_selectedGiftAmount + _giftBonusAmount),
                  isBoldValue: true),
              if (_giftBonusAmount > 0)
                _buildInfoRow('bonus_value'.tr, _formatPrice(_giftBonusAmount),
                    isBoldValue: true, valueColor: Colors.purple),
              _buildInfoRow(
                  'amount_to_pay'.tr, _formatPrice(_selectedGiftAmount),
                  isBoldValue: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBoldValue = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: robotoRegular.copyWith(color: Colors.black54)),
          Text(value,
              style: isBoldValue
                  ? robotoBold.copyWith(color: valueColor ?? Colors.black)
                  : robotoMedium.copyWith(color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildDesignSection(GiftOccasionModel occasion) {
    if (occasion.icon == null || occasion.icon!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_design'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
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
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDesignIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                  ],
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).primaryColor, width: 2)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: Stack(children: [
                    CustomImage(
                      image: occasion.icon![index],
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
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
        ),
      ],
    );
  }

  Widget _buildOccasionSection(Item item) {
    if (item.giftOccasions == null || item.giftOccasions!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_occasion'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: item.giftOccasions!.map((occasion) {
              bool isSelected = _selectedOccasion?.id == occasion.id;
              return Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedOccasion = occasion;
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
        Text(label,
            style: robotoBold.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    } else if (ids.contains('in-store') ||
        ids.contains('instore') ||
        ids.contains('store')) {
      return [const Color(0xFF1ABC9C), const Color(0xFFA8E063)];
    } else if (ids.contains('flat')) {
      return [const Color(0xFFFF8A2B), const Color(0xFFFFD54F)];
    } else if (ids.contains('gift')) {
      return [const Color(0xFF6A4DF4), const Color(0xFFC084FC)];
    }
    return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: GetPlatform.isWeb
            ? const BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
            : const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<ItemController>(builder: (itemController) {
        Item? item = itemController.item;

        if (item != null &&
            item.product != null &&
            _isExpanded.length != item.product!.length) {
          _isExpanded = List.filled(item.product!.length, false);
          if (item.product!.length == 1) {
            _isExpanded[0] = true;
          }
        }

        if (item == null) {
          return const ItemBottomSheetShimmer();
        }

        double? startingPrice;
        double? initialDiscount = item.discount;
        double? discount = item.discount;
        double? endingPrice;
        if ((item.choiceOptions?.isNotEmpty ?? false) &&
            (item.foodVariations?.isEmpty ?? true) &&
            !_newVariation) {
          List<double> priceList = [];
          if (item.variations != null) {
            for (var variation in item.variations ?? []) {
              if (variation.price != null) {
                priceList.add(variation.price ?? 0);
              }
            }
          }
          if (priceList.isNotEmpty) {
            priceList.sort((a, b) => a.compareTo(b));
            startingPrice = priceList[0];
            if (priceList[0] < priceList[priceList.length - 1]) {
              endingPrice = priceList[priceList.length - 1];
            }
          }
        } else {
          startingPrice = item.price;
        }

        double? price = item.price;
        double variationPrice = 0;
        Variation? variation;
        String? discountType = item.discountType;

        if (item.type == 'voucher' &&
            (item.voucherIds?.toLowerCase().trim() == 'flat discount' ||
                item.bundleType == 'gift')) {
          double dynamicBonus = item.bundleType == 'gift'
              ? _giftBonusPercentage
              : _flatVoucherBonus;
          initialDiscount = dynamicBonus;
          discount = dynamicBonus;
          discountType = 'percent';
        } else if (item.type == 'voucher' &&
            (item.bundleType == 'bogo_free' ||
                (item.voucherIds?.toLowerCase().trim().contains('bogo') ??
                    false))) {
          initialDiscount = 50;
          discount = 50;
          discountType = 'percent';
        }

        int? stock = item.stock ?? 0;

        if (discountType == 'amount') {
          discount = (discount ?? 0) * (itemController.quantity ?? 1);
        }

        if (_newVariation) {
          for (int index = 0; index < item.foodVariations!.length; index++) {
            for (int i = 0;
                i < item.foodVariations![index].variationValues!.length;
                i++) {
              if (itemController.selectedVariations.length > index &&
                  itemController.selectedVariations[index].length > i &&
                  (itemController.selectedVariations[index][i] ?? false)) {
                variationPrice += item?.foodVariations?[index]
                        .variationValues?[i].optionPrice ??
                    0;
              }
            }
          }
        } else {
          List<String> variationList = [];
          if (item.choiceOptions != null &&
              item.choiceOptions!.isNotEmpty &&
              itemController.variationIndex != null) {
            for (int index = 0;
                index < (item?.choiceOptions?.length ?? 0);
                index++) {
              variationList.add(item
                      ?.choiceOptions?[index]
                      .options?[
                          (itemController.variationIndex?.length ?? 0) > index
                              ? itemController.variationIndex![index]
                              : 0]
                      ?.replaceAll(' ', '') ??
                  '');
            }
          }
          String variationType = '';
          bool isFirst = true;
          for (var variation in variationList) {
            if (isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            } else {
              variationType = '$variationType-$variation';
            }
          }

          if (item?.variations != null) {
            for (Variation variations in item.variations!) {
              if (variations.type == variationType) {
                price = variations.price;
                variation = variations;
                stock = variations.stock;
                break;
              }
            }
          }
        }

        // For bundle vouchers, the voucher's own price is often a dummy or placeholder
        // We should reset it to 0 and build it from variations/products instead
        if (item.type == 'voucher' &&
            item.bundleType != 'simple x' &&
            item.bundleType != 'gift') {
          price = 0;
        }

        price = (price ?? 0) + variationPrice;

        double priceWithDiscount =
            (item.type == 'voucher' && item.bundleType == 'simple x')
                ? price
                : (PriceConverter.convertWithDiscount(
                        price, discount, discountType) ??
                    0);
        double addonsCost = 0;
        List<AddOn> addOnIdList = [];
        List<AddOns> addOnsList = [];
        // Add null check here
        if (item.addOns != null) {
          for (int index = 0; index < item.addOns!.length; index++) {
            if (itemController.addOnActiveList[index]) {
              addonsCost = addonsCost +
                  ((item.addOns![index].price ?? 0) *
                      (itemController.addOnQtyList[index] ?? 0));
              addOnIdList.add(AddOn(
                  id: item.addOns![index].id,
                  quantity: itemController.addOnQtyList[index]));
              addOnsList.add(item.addOns![index]);
            }
          }
        }

        List<AddOns> flattenedAddOns = [];
        List<FoodVariation> flattenedFoodVariations = [];
        if (item.product != null) {
          for (var p in item.product!) {
            if (p.addOns != null) {
              for (var addon in p.addOns!) {
                flattenedAddOns.add(AddOns(
                  id: addon.id,
                  name: addon.name,
                  price: addon.price,
                  productId: p.id,
                ));
              }
            }
            if (p.foodVariations != null) {
              for (var fv in p.foodVariations!) {
                flattenedFoodVariations.add(FoodVariation(
                  name: fv.name,
                  multiSelect: fv.multiSelect,
                  min: fv.min,
                  max: fv.max,
                  required: fv.required,
                  variationValues: fv.variationValues,
                  productId: p.id,
                ));
              }
            }
          }
        }

        for (int index in itemController.productSelect) {
          if (index < flattenedAddOns.length) {
            addonsCost += flattenedAddOns[index].price ?? 0;
            addOnIdList.add(AddOn(id: flattenedAddOns[index].id, quantity: 1));
            addOnsList.add(flattenedAddOns[index]);
          }
        }

        double variationCost = 0;
        for (int i = 0; i < flattenedFoodVariations.length; i++) {
          if (itemController.voucherVariationIndex.length > i &&
              itemController.voucherVariationIndex[i] != -1) {
            variationCost += flattenedFoodVariations[i]
                    .variationValues?[itemController.voucherVariationIndex[i]]
                    .optionPrice ??
                0;
          }
        }

        priceWithDiscount = priceWithDiscount;

        // Zero out base price for bundle vouchers as per backend requirements
        // EXCEPT for "simple x" which should show its base price
        if (item.type == 'voucher' &&
            item.product != null &&
            item.product!.isNotEmpty &&
            item.bundleType != 'simple x') {
          price = 0;
          priceWithDiscount = 0;
        }

        double bundleSumPrice = 0;
        double bundleSumPriceWithDiscount = 0;
        if (item.type == 'voucher' &&
            item.product != null &&
            item.product!.isNotEmpty &&
            item.bundleType != 'bogo_free' &&
            item.bundleType != 'mix_match' &&
            item.bundleType != 'gift' &&
            item.bundleType != 'simple x') {
          for (var p in item.product!) {
            if (p.foodVariations == null || p.foodVariations!.isEmpty) {
              bundleSumPrice += (p.price ?? 0);
              bundleSumPriceWithDiscount += PriceConverter.convertWithDiscount(
                  p.price ?? 0, discount, discountType)!;
            }
          }
        }

        double priceWithDiscountAndAddons = 0;

        // Apply Customer Commission Logic after all price components are ready
        if (item.store?.commissionPaidBy == 'customer' &&
            item.store?.comission != null &&
            item.store!.comission! > 0) {
          if (discountType == 'percent') {
            double newDiscountPercentage =
                discount! - (1 - discount! / 100) * item.store!.comission!;
            discount = newDiscountPercentage;
            initialDiscount = newDiscountPercentage;

            // For Simple X, update price using the new percentage
            if (item.bundleType == 'simple x') {
              double refPrice = (item.actualPrice ?? item.price ?? 100);
              price = refPrice * (1 - discount! / 100);
            }
          } else if (discountType == 'fixed' || discountType == 'amount') {
            // RefPrice = All components before discount
            double refPrice = (price ?? 0) + variationCost + bundleSumPrice;

            // Special handling for different voucher types
            if (item.bundleType == 'simple x') {
              refPrice = (item.actualPrice ?? item.price ?? 100);
            } else if (item.bundleType == 'mix_match') {
              refPrice = itemController.getMixMatchRawTotalAmount(0);
            } else if (item.bundleType == 'bogo_free') {
              double bogoRaw = 0;
              if (itemController.selectedBogoProductAIndex != null) {
                bogoRaw += (item
                        .product![itemController.selectedBogoProductAIndex!]
                        .price ??
                    0);
              }
              if (itemController.selectedBogoProductBIndex != null) {
                bogoRaw += (item
                        .productB![itemController.selectedBogoProductBIndex!]
                        .price ??
                    0);
              }
              if (bogoRaw > 0) refPrice = bogoRaw;
            }

            if (refPrice <= 0)
              refPrice = (item.actualPrice ?? item.price ?? 100);

            double initialDiscountAmount = discount!;
            double priceAfterDiscount = refPrice - initialDiscountAmount;
            double commissionAmount =
                priceAfterDiscount * (item.store!.comission! / 100);

            discount = initialDiscountAmount - commissionAmount;
            initialDiscount = discount;

            debugPrint('--- Saim Formula applied (Shifted) ---');
            debugPrint(
                'RefPrice: $refPrice, InitialDisc: $initialDiscountAmount, Commission: $commissionAmount, NewDisc: $discount');

            // For Simple X, we must update the price variable as it represents the final deal price
            if (item.bundleType == 'simple x') {
              price = refPrice - discount!;
            }
          }
        }

        // Refresh priceWithDiscount after discount update
        priceWithDiscount =
            (item.type == 'voucher' && item.bundleType == 'simple x')
                ? (price ?? 0)
                : (PriceConverter.convertWithDiscount(
                        price, discount, discountType) ??
                    0);

        // Refresh bundleSumPriceWithDiscount after discount update
        if (item.type == 'voucher' && bundleSumPrice > 0) {
          bundleSumPriceWithDiscount = 0;
          for (var p in item.product!) {
            if (p.foodVariations == null || p.foodVariations!.isEmpty) {
              bundleSumPriceWithDiscount += PriceConverter.convertWithDiscount(
                  p.price ?? 0, discount, discountType)!;
            }
          }
        }
        double bogoLowerPrice = 0;
        double bogoSumWithoutAddons = 0;
        if (item.bundleType == 'mix_match') {
          price = itemController.getMixMatchRawTotalAmount(0);
          priceWithDiscountAndAddons = itemController.getMixMatchTotalAmount(
              priceWithDiscount, discount, discountType);
        } else if (item.bundleType == 'bogo_free') {
          // BOGO Logic Refined: Max(priceA + variationsA, priceB + variationsB) + All Addons
          // We separate options into variations and addons for correct BOGO math
          double priceA = 0;
          double priceB = 0;
          double varA = 0;
          double adsA = 0;
          double varB = 0;
          double adsB = 0;

          if (itemController.selectedBogoProductAIndex != null) {
            Item productA =
                item.product![itemController.selectedBogoProductAIndex!];

            // Set base price to 0 if product has food_variations
            if (productA.foodVariations != null &&
                productA.foodVariations!.isNotEmpty) {
              priceA = 0;
            } else {
              priceA = productA.price ?? 0;
            }

            for (int i = 0; i < productA.foodVariations!.length; i++) {
              for (int j = 0;
                  j < productA.foodVariations![i].variationValues!.length;
                  j++) {
                if (i < itemController.selectedBogoVariationsA.length &&
                    j < itemController.selectedBogoVariationsA[i].length &&
                    (itemController.selectedBogoVariationsA[i][j] ?? false)) {
                  varA += productA
                          .foodVariations![i].variationValues![j].optionPrice ??
                      0;
                }
              }
            }
            for (int i = 0; i < productA.addOns!.length; i++) {
              if (i < itemController.selectedBogoAddonsA.length &&
                  itemController.selectedBogoAddonsA[i]) {
                adsA += (productA.addOns![i].price ?? 0) *
                    (i < itemController.selectedBogoAddonQtyA.length
                        ? (itemController.selectedBogoAddonQtyA[i] ?? 1)
                        : 1);
              }
            }
          }

          if (itemController.selectedBogoProductBIndex != null) {
            Item productB =
                item.productB![itemController.selectedBogoProductBIndex!];

            if (productB.foodVariations != null &&
                productB.foodVariations!.isNotEmpty) {
              priceB = 0;
            } else {
              priceB = productB.price ?? 0;
            }

            for (int i = 0; i < productB.foodVariations!.length; i++) {
              for (int j = 0;
                  j < productB.foodVariations![i].variationValues!.length;
                  j++) {
                if (i < itemController.selectedBogoVariationsB.length &&
                    j < itemController.selectedBogoVariationsB[i].length &&
                    (itemController.selectedBogoVariationsB[i][j] ?? false)) {
                  varB += productB
                          .foodVariations![i].variationValues![j].optionPrice ??
                      0;
                }
              }
            }
            for (int i = 0; i < productB.addOns!.length; i++) {
              if (i < itemController.selectedBogoAddonsB.length &&
                  itemController.selectedBogoAddonsB[i]) {
                adsB += (productB.addOns![i].price ?? 0) *
                    (i < itemController.selectedBogoAddonQtyB.length
                        ? (itemController.selectedBogoAddonQtyB[i] ?? 1)
                        : 1);
              }
            }
          }

          double totalA = priceA + varA;
          double totalB = priceB + varB;
          double basePrice = totalA > totalB ? totalA : totalB;

          // Apply commission to BOGO base price only when BOTH products are selected
          if (item.store?.commissionPaidBy == 'customer' &&
              item.store?.comission != null &&
              item.store!.comission! > 0 &&
              itemController.selectedBogoProductAIndex != null &&
              itemController.selectedBogoProductBIndex != null) {
            basePrice = basePrice * (1 + item.store!.comission! / 100);
          }
          bogoLowerPrice =
              (totalA + totalB + adsA + adsB) * (itemController.quantity ?? 1);
          bogoSumWithoutAddons =
              (totalA + totalB) * (itemController.quantity ?? 1);
          price = (basePrice + adsA + adsB) * (itemController.quantity ?? 1);
          priceWithDiscountAndAddons = price;
        } else {
          if (item.type == 'voucher') {
            if (item.bundleType == 'gift') {
              priceWithDiscountAndAddons =
                  (_selectedGiftAmount * (itemController.quantity ?? 1));
            } else {
              priceWithDiscountAndAddons =
                  ((priceWithDiscount + bundleSumPriceWithDiscount) *
                          (itemController.quantity ?? 1)) +
                      (item.bundleType == 'simple x'
                          ? (variationCost * (itemController.quantity ?? 1))
                          : PriceConverter.convertWithDiscount(
                              (variationCost * (itemController.quantity ?? 1)),
                              discount,
                              discountType,
                            )!) +
                      (addonsCost * (itemController.quantity ?? 1));
            }
          } else {
            priceWithDiscountAndAddons = PriceConverter.convertWithDiscount(
                  (price * (itemController.quantity ?? 0)),
                  discount,
                  discountType,
                )! +
                (addonsCost * (itemController.quantity ?? 1)) +
                (variationCost * (itemController.quantity ?? 1));
          }
        }

        double totalPriceWithoutDiscount = 0;
        if (item.bundleType == 'mix_match' || item.bundleType == 'bogo_free') {
          totalPriceWithoutDiscount = price!;
        } else if (item.bundleType == 'gift') {
          totalPriceWithoutDiscount = (_selectedGiftAmount + _giftBonusAmount) *
              (itemController.quantity ?? 1);
        } else {
          if (item.type == 'voucher') {
            double basePrice = (item.bundleType == 'simple x'
                ? (item.actualPrice ?? item.price ?? 0)
                : (price ?? 0));
            totalPriceWithoutDiscount = ((basePrice + bundleSumPrice) *
                    (itemController.quantity ?? 1)) +
                (variationCost * (itemController.quantity ?? 1)) +
                (addonsCost * (itemController.quantity ?? 1));
          } else {
            totalPriceWithoutDiscount =
                ((price ?? 0) * (itemController.quantity ?? 0)) +
                    (addonsCost * (itemController.quantity ?? 1)) +
                    (variationCost * (itemController.quantity ?? 1));
          }
        }

        // Recalculate Save Tag dynamically for UI based on final adjusted price
        if (item.store?.commissionPaidBy == 'customer' &&
            item.store?.comission != null &&
            item.store!.comission! > 0) {
          double totalAds = (addonsCost * (itemController.quantity ?? 1));
          double basePriceForDiscount = (item.bundleType == 'bogo_free')
              ? bogoLowerPrice
              : totalPriceWithoutDiscount;

          // Exclude addons from Save Tag calculation to prevent dilution
          double baseWithoutAds = basePriceForDiscount - totalAds;
          double payableWithoutAds = priceWithDiscountAndAddons - totalAds;
          double netDiscountAmount = baseWithoutAds - payableWithoutAds;

          if (netDiscountAmount > 0 && baseWithoutAds > 0) {
            initialDiscount = (netDiscountAmount / baseWithoutAds) * 100;
            if (initialDiscount! < 0) initialDiscount = 0;
            discountType = 'percent';
          } else if (netDiscountAmount <= 0) {
            initialDiscount = 0;
          }
        }

        bool isAvailable = DateConverter.isAvailable(
            item.availableTimeStarts, item.availableTimeEnds);

        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88),
          child: item.voucherIds == 'Flat discount'
              ? _buildFlatVoucherUI(context, itemController)
              : Stack(
                  children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Voucher Header or Product Image
                                item.type == 'voucher'
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildVoucherHeader(
                                              context,
                                              item,
                                              initialDiscount,
                                              discountType,
                                              price,
                                              priceWithDiscount),
                                          if (item.bundleType == 'gift')
                                            _buildTopUpValueSection(item),
                                        ],
                                      )
                                    : Center(
                                        child: Stack(children: [
                                          InkWell(
                                            onTap: widget.isCampaign
                                                ? null
                                                : () {
                                                    if (!widget.isCampaign) {
                                                      Get.toNamed(RouteHelper
                                                          .getItemImagesRoute(
                                                              item));
                                                    }
                                                  },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusMedium),
                                              child: CustomImage(
                                                image: item.imageFullUrl ?? '',
                                                width: 350,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          DiscountTag(
                                              discount: initialDiscount,
                                              discountType: discountType,
                                              fromTop: 20),
                                          Positioned(
                                            bottom: 10,
                                            left: 10,
                                            child: !widget.isCampaign
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeExtraSmall,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .cardColor
                                                          .withValues(
                                                              alpha: 0.8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.star,
                                                            color: Colors.amber,
                                                            size: 15),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Text(
                                                          (item.avgRating ?? 0)
                                                              .toString(),
                                                          style: robotoMedium.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1)),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: widget.isCampaign
                                                ? const SizedBox()
                                                : GetBuilder<
                                                        FavouriteController>(
                                                    builder: (wishList) {
                                                    return InkWell(
                                                      onTap: () {
                                                        if (AuthHelper
                                                            .isLoggedIn()) {
                                                          wishList.wishItemIdList
                                                                  .contains(
                                                                      item.id)
                                                              ? wishList
                                                                  .removeFromFavouriteList(
                                                                      item.id,
                                                                      false,
                                                                      getXSnackBar:
                                                                          true)
                                                              : wishList
                                                                  .addToFavouriteList(
                                                                      item,
                                                                      null,
                                                                      false,
                                                                      getXSnackBar:
                                                                          true);
                                                        } else {
                                                          showCustomSnackBar(
                                                              'you_are_not_logged_in'
                                                                  .tr,
                                                              getXSnackBar:
                                                                  true);
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8),
                                                        ),
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeSmall),
                                                        child: Icon(
                                                          wishList.wishItemIdList
                                                                  .contains(
                                                                      item.id)
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: wishList
                                                                  .wishItemIdList
                                                                  .contains(
                                                                      item.id)
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Theme.of(
                                                                      context)
                                                                  .disabledColor,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                          ),
                                        ]),
                                      ),

                                Padding(
                                  padding: item.type == 'voucher'
                                      ? const EdgeInsets.only(
                                          left: Dimensions.paddingSizeDefault,
                                          right: Dimensions.paddingSizeDefault,
                                          top: Dimensions.paddingSizeExtraSmall,
                                          bottom: Dimensions.paddingSizeDefault)
                                      : const EdgeInsets.all(
                                          Dimensions.paddingSizeDefault),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            item.type == 'voucher'
                                                ? const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeLarge)
                                                : Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                        Expanded(
                                                            child: Text(
                                                          item.name ??
                                                              '', // Use ?? instead of !
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeExtraLarge),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                        const SizedBox(
                                                            width: 60),
                                                        item.isStoreHalalActive! &&
                                                                item.isHalalItem!
                                                            ? CustomToolTip(
                                                                message:
                                                                    'this_is_a_halal_food'
                                                                        .tr,
                                                                preferredDirection:
                                                                    AxisDirection
                                                                        .up,
                                                                child: const CustomAssetImageWidget(
                                                                    Images
                                                                        .halalTag,
                                                                    height: 30,
                                                                    width: 30),
                                                              )
                                                            : const SizedBox(),
                                                      ]),

                                            (item.type == 'voucher')
                                                ? const SizedBox()
                                                : InkWell(
                                                    onTap: () {
                                                      if (widget.inStorePage) {
                                                        Navigator.pop(context);
                                                      } else {
                                                        Navigator.pop(context);
                                                        Get.find<
                                                                CartController>()
                                                            .forcefullySetModule(
                                                                item.moduleId ??
                                                                    0);
                                                        Get.toNamed(RouteHelper
                                                            .getStoreRoute(
                                                                id: item
                                                                    .storeId,
                                                                page: 'item'));
                                                      }
                                                    },
                                                    child: Text(
                                                      item.storeName ??
                                                          '', // Use ?? instead of !
                                                      style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                            if (item.type != 'voucher')
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),

                                            const SizedBox(),

                                            (item.type == 'voucher')
                                                ? const SizedBox()
                                                : Row(children: [
                                                    price > priceWithDiscount
                                                        ? Text(
                                                            '${PriceConverter.convertPrice(startingPrice)}'
                                                            '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                            style: robotoBold.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                                color: Colors
                                                                    .black,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough),
                                                          )
                                                        : const SizedBox(),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    Text(
                                                      '${PriceConverter.convertPrice(startingPrice, discount: initialDiscount, discountType: discountType)}'
                                                      '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: initialDiscount, discountType: discountType)}' : ''}',
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeExtraLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ]),
                                            item.type == 'voucher'
                                                ? const SizedBox()
                                                : const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                            item.type == 'voucher'
                                                ? const SizedBox()
                                                : Divider(
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withValues(
                                                            alpha: 0.9)),
                                            item.type == 'voucher'
                                                ? const SizedBox()
                                                : const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),

                                            (item.type == 'voucher')
                                                ? const SizedBox()
                                                : (item.description
                                                            ?.isNotEmpty ??
                                                        false)
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    'description'
                                                                        .tr,
                                                                    style: robotoBold.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeLarge)),
                                                                ((Get.find<SplashController>().configModel?.moduleConfig?.module?.unit ??
                                                                                false) &&
                                                                            item.unitType !=
                                                                                null) ||
                                                                        ((Get.find<SplashController>().configModel?.moduleConfig?.module?.vegNonVeg ??
                                                                                false) &&
                                                                            (Get.find<SplashController>().configModel?.toggleVegNonVeg ??
                                                                                false))
                                                                    ? Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                Dimensions.paddingSizeExtraSmall,
                                                                            horizontal: Dimensions.paddingSizeSmall),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(Dimensions.radiusExtraLarge),
                                                                            color: Theme.of(context).cardColor,
                                                                            boxShadow: [
                                                                              BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 5)
                                                                            ]),
                                                                        child: Get.find<SplashController>().configModel?.moduleConfig?.module?.unit ??
                                                                                false
                                                                            ? Text(
                                                                                item.unitType ?? '',
                                                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                                                              )
                                                                            : Row(children: [
                                                                                Image.asset(item.veg == 1 ? Images.vegLogo : Images.nonVegLogo, height: 20, width: 20),
                                                                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                Text(item.veg == 1 ? 'veg'.tr : 'non_veg'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                                                              ]),
                                                                      )
                                                                    : const SizedBox(),
                                                              ]),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                              item.description ??
                                                                  '',
                                                              style: robotoRegular.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color
                                                                      ?.withValues(
                                                                          alpha:
                                                                              0.5))),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeLarge),
                                                        ],
                                                      )
                                                    : const SizedBox(),

                                            item.type == 'voucher'
                                                ? const SizedBox()
                                                : Divider(
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withValues(
                                                            alpha: 0.9)),
                                            item.type == 'voucher'
                                                ? const SizedBox()
                                                : const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                            (item.bundleType == 'mix_match')
                                                ? _buildMixMatchSelection(
                                                    context,
                                                    itemController,
                                                    item,
                                                    discount,
                                                    discountType)
                                                : (item.bundleType ==
                                                        'bogo_free')
                                                    ? _buildBogoSelection(
                                                        context,
                                                        itemController,
                                                        item)
                                                    : (item.product
                                                                ?.isNotEmpty ??
                                                            false)
                                                        ? Container(
                                                            width:
                                                                double.infinity,
                                                            margin: const EdgeInsets
                                                                .only(
                                                                bottom: Dimensions
                                                                    .paddingSizeDefault),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              border: Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.2),
                                                                  width: 1),
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  if (item.product!
                                                                          .length >
                                                                      1)
                                                                    if (item.type == 'voucher' &&
                                                                        item.bundleType !=
                                                                            'simple x' &&
                                                                        item.bundleType !=
                                                                            'gift' &&
                                                                        totalPriceWithoutDiscount >
                                                                            priceWithDiscountAndAddons)
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                Dimensions.paddingSizeExtraSmall),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Text(
                                                                              PriceConverter.convertPrice(totalPriceWithoutDiscount),
                                                                              style: robotoMedium.copyWith(
                                                                                fontSize: Dimensions.fontSizeSmall,
                                                                                color: Theme.of(context).disabledColor,
                                                                                decoration: TextDecoration.lineThrough,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            Dimensions.paddingSizeExtraSmall),
                                                                    child: Text(
                                                                        'bundle_includes'
                                                                            .tr,
                                                                        style: robotoBold.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Colors.black)),
                                                                  ),
                                                                  Divider(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .disabledColor
                                                                          .withValues(
                                                                              alpha: 0.3)),
                                                                  const SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeExtraSmall),
                                                                  ListView
                                                                      .builder(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    itemCount: item
                                                                        .product
                                                                        ?.length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      int currentAddOnIndex =
                                                                          0;
                                                                      int currentVariationIndex =
                                                                          0;

                                                                      for (int i =
                                                                              0;
                                                                          i < index;
                                                                          i++) {
                                                                        currentAddOnIndex +=
                                                                            item.product![i].addOns?.length ??
                                                                                0;
                                                                        currentVariationIndex +=
                                                                            item.product![i].foodVariations?.length ??
                                                                                0;
                                                                      }

                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                Dimensions.paddingSizeExtraSmall),
                                                                        child:
                                                                            Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              Dimensions.paddingSizeSmall),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            border:
                                                                                Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                                                                            borderRadius:
                                                                                BorderRadius.circular(Dimensions.radiusLarge),
                                                                            boxShadow: [
                                                                              BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    _isExpanded[index] = !_isExpanded[index];
                                                                                  });
                                                                                },
                                                                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                  ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                                                                    child: CustomImage(
                                                                                      image: item.product?[index].imageFullUrl ?? '',
                                                                                      height: 85,
                                                                                      width: 85,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                  Expanded(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          item.product?[index].name ?? '',
                                                                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.black),
                                                                                        ),
                                                                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                                                        if (_isExpanded[index])
                                                                                          Text(
                                                                                            'customize'.tr,
                                                                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
                                                                                          ),
                                                                                        if (!_isExpanded[index])
                                                                                          Text(
                                                                                            // Show base price without discount, OR variation price with discount
                                                                                            (() {
                                                                                              bool hasVariations = item.product![index].foodVariations?.isNotEmpty ?? false;
                                                                                              double basePrice = hasVariations ? 0 : (item.product![index].price ?? 0);
                                                                                              double selectedVariationPrice = 0;
                                                                                              bool variationSelected = false;
                                                                                              int currentVariationIndex = 0;

                                                                                              // Calculate starting variation index for this product
                                                                                              for (int i = 0; i < index; i++) {
                                                                                                currentVariationIndex += item.product![i].foodVariations?.length ?? 0;
                                                                                              }

                                                                                              // Calculate selected variation price (with discount)
                                                                                              if (hasVariations) {
                                                                                                for (int vIndex = 0; vIndex < item.product![index].foodVariations!.length; vIndex++) {
                                                                                                  int globalVIndex = currentVariationIndex + vIndex;
                                                                                                  if (globalVIndex < itemController.voucherVariationIndex.length && itemController.voucherVariationIndex[globalVIndex] != -1) {
                                                                                                    int selectedValIndex = itemController.voucherVariationIndex[globalVIndex];
                                                                                                    double optionPrice = item.product![index].foodVariations![vIndex].variationValues![selectedValIndex].optionPrice ?? 0;
                                                                                                    // Apply discount to variation price
                                                                                                    double discountedVariationPrice = PriceConverter.convertWithDiscount(optionPrice, discount, discountType) ?? optionPrice;
                                                                                                    selectedVariationPrice += discountedVariationPrice;
                                                                                                    variationSelected = true;
                                                                                                  }
                                                                                                }
                                                                                              }

                                                                                              // If variation selected, show variation price with discount
                                                                                              // If no variation, show base price WITHOUT discount
                                                                                              // Addons are NEVER included in card price
                                                                                              if (variationSelected) {
                                                                                                return PriceConverter.convertPrice(selectedVariationPrice);
                                                                                              } else if (!hasVariations) {
                                                                                                return PriceConverter.convertPrice(basePrice);
                                                                                              } else {
                                                                                                return 'enter_voucher_price'.tr;
                                                                                              }
                                                                                            }()),
                                                                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.black),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Icon(
                                                                                        _isExpanded[index] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                                                        color: Theme.of(context).hintColor,
                                                                                        size: 25,
                                                                                      ),
                                                                                      if (!_isExpanded[index])
                                                                                        ...(() {
                                                                                          double addonAmt = 0;
                                                                                          int currentAddOnIdx = 0;
                                                                                          for (int i = 0; i < index; i++) {
                                                                                            currentAddOnIdx += item.product![i].addOns?.length ?? 0;
                                                                                          }
                                                                                          if (item.product![index].addOns?.isNotEmpty ?? false) {
                                                                                            for (int i = 0; i < item.product![index].addOns!.length; i++) {
                                                                                              int globalIdx = currentAddOnIdx + i;
                                                                                              if (itemController.productSelect.contains(globalIdx)) {
                                                                                                addonAmt += item.product![index].addOns![i].price ?? 0;
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                          return addonAmt > 0
                                                                                              ? <Widget>[
                                                                                                  const SizedBox(height: 16),
                                                                                                  Text(
                                                                                                    '+ ${PriceConverter.convertPrice(addonAmt)} Add-Ons',
                                                                                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
                                                                                                    textAlign: TextAlign.end,
                                                                                                  ),
                                                                                                ]
                                                                                              : <Widget>[];
                                                                                        }()),
                                                                                    ],
                                                                                  ),
                                                                                ]),
                                                                              ),
                                                                              // Show expanded form with variations and addons
                                                                              if (_isExpanded[index]) ...[
                                                                                // EXPANDED VIEW - Show variations and addons
                                                                                // EXPANDED VIEW - Show editable form
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                                                                Text('description'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black)),
                                                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                                                Text(item.product![index].description ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black)),
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                                                                // Product Variations
                                                                                if (item.product![index].foodVariations?.isNotEmpty ?? false) ...[
                                                                                  Row(children: [
                                                                                    Text('variations'.tr, style: robotoBold.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeLarge)),
                                                                                    const Spacer(),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                                                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                                                      child: Text(
                                                                                        item.product![index].foodVariations!.any((v) => v.required ?? false) ? 'required'.tr : 'optional'.tr,
                                                                                        style: robotoBold.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeSmall),
                                                                                      ),
                                                                                    ),
                                                                                  ]),
                                                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                                                  ListView.builder(
                                                                                    shrinkWrap: true,
                                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                                    padding: EdgeInsets.zero,
                                                                                    itemCount: item.product![index].foodVariations!.length,
                                                                                    itemBuilder: (context, vIndex) {
                                                                                      int globalVIndex = currentVariationIndex + vIndex;
                                                                                      return Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            item.product![index].foodVariations![vIndex].name ?? '',
                                                                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                                                                                          ),
                                                                                          const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                          ListView.builder(
                                                                                            shrinkWrap: true,
                                                                                            physics: const NeverScrollableScrollPhysics(),
                                                                                            padding: EdgeInsets.zero,
                                                                                            itemCount: item.product![index].foodVariations![vIndex].variationValues?.length ?? 0,
                                                                                            itemBuilder: (context, valIndex) {
                                                                                              bool isSelected = itemController.voucherVariationIndex[globalVIndex] == valIndex;
                                                                                              return InkWell(
                                                                                                onTap: () => itemController.setVoucherVariation(globalVIndex, valIndex),
                                                                                                child: Container(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                                                                                  child: Row(children: [
                                                                                                    Icon(
                                                                                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                                                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                                                                                      size: 18,
                                                                                                    ),
                                                                                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        item.product![index].foodVariations![vIndex].variationValues![valIndex].level ?? '',
                                                                                                        maxLines: 1,
                                                                                                        overflow: TextOverflow.ellipsis,
                                                                                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '+${PriceConverter.convertPrice(item.product![index].foodVariations![vIndex].variationValues![valIndex].optionPrice)}',
                                                                                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                                                                                                    ),
                                                                                                  ]),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                          const SizedBox(height: Dimensions.paddingSizeDefault),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                                                                ],

                                                                                // Product Add-ons
                                                                                if (item.product![index].addOns?.isNotEmpty ?? false) ...[
                                                                                  Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                                                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                                  Row(children: [
                                                                                    Text('addons'.tr, style: robotoBold.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeLarge)),
                                                                                    const Spacer(),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                                                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                                                      child: Text(
                                                                                        'optional'.tr,
                                                                                        style: robotoBold.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeSmall),
                                                                                      ),
                                                                                    ),
                                                                                  ]),
                                                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                                                  ListView.builder(
                                                                                    shrinkWrap: true,
                                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                                    padding: EdgeInsets.zero,
                                                                                    itemCount: item.product![index].addOns!.length,
                                                                                    itemBuilder: (context, i) {
                                                                                      int globalIndex = currentAddOnIndex + i;
                                                                                      return InkWell(
                                                                                        onTap: () => itemController.setSelect(globalIndex, true, isToggle: true),
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                                                                                          child: Row(children: [
                                                                                            Container(
                                                                                              height: 20,
                                                                                              width: 20,
                                                                                              decoration: BoxDecoration(
                                                                                                color: itemController.productSelect.contains(globalIndex) ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                                                                                border: Border.all(
                                                                                                  color: itemController.productSelect.contains(globalIndex) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                                                                                  width: 1.5,
                                                                                                ),
                                                                                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                              ),
                                                                                              child: itemController.productSelect.contains(globalIndex) ? Icon(Icons.check, color: Theme.of(context).cardColor, size: 14) : const SizedBox(),
                                                                                            ),
                                                                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                item.product![index].addOns![i].name ?? '',
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                style: itemController.productSelect.contains(globalIndex) ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black) : robotoBold.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeSmall),
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              '+${PriceConverter.convertPrice(item.product![index].addOns![i].price)}',
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              textDirection: TextDirection.ltr,
                                                                                              style: itemController.productSelect.contains(globalIndex) ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black) : robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
                                                                                            ),
                                                                                          ]),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                                                                ],

                                                                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                              ],
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ]),
                                                          )
                                                        : const SizedBox(),

                                            (item.branches != null &&
                                                    item.branches!.isNotEmpty)
                                                ? Container(
                                                    margin: const EdgeInsets
                                                        .only(
                                                        bottom: Dimensions
                                                            .paddingSizeLarge),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusLarge),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey[
                                                              Get.isDarkMode
                                                                  ? 800
                                                                  : 200]!,
                                                          blurRadius: 5,
                                                          spreadRadius: 1,
                                                        )
                                                      ],
                                                    ),
                                                    child: _isDeliveryOrPickup(
                                                            item)
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeDefault),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'redeemable_at_x_outlets'
                                                                            .trParams({
                                                                          'count': item
                                                                              .branches!
                                                                              .length
                                                                              .toString()
                                                                        }),
                                                                        style: robotoMedium.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                if (_selectedBranch ==
                                                                        null &&
                                                                    !_isDeliveryOrPickup(
                                                                        item))
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                    ),
                                                                    child: Text(
                                                                      'Required',
                                                                      style: robotoMedium.copyWith(
                                                                          color: Colors
                                                                              .red,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                  ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Get.dialog(
                                                                        Dialog(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(Dimensions.radiusDefault)),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            400,
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            Dimensions.paddingSizeDefault),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Text('select_outlet'.tr,
                                                                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                                                            ConstrainedBox(
                                                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                                                                              child: ListView.builder(
                                                                                shrinkWrap: true,
                                                                                itemCount: item.branches!.length,
                                                                                itemBuilder: (context, index) {
                                                                                  Store branch = item.branches![index];
                                                                                  bool available = _isBranchAvailable(branch);
                                                                                  String? activeAt;
                                                                                  if (!available && branch.availability != null) {
                                                                                    for (var a in branch.availability!) {
                                                                                      if (a.status == 'not_available') {
                                                                                        activeAt = a.activeAt;
                                                                                        break;
                                                                                      }
                                                                                    }
                                                                                  }

                                                                                  return ListTile(
                                                                                    enabled: available,
                                                                                    leading: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                                                                                      ),
                                                                                      child: Opacity(
                                                                                        opacity: available ? 1 : 0.5,
                                                                                        child: ClipOval(
                                                                                          child: CustomImage(
                                                                                            image: branch.logoFullUrl ?? '',
                                                                                            height: 35,
                                                                                            width: 35,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    title: Text(
                                                                                      available ? (branch.name ?? '') : '${branch.name ?? ''} (Not Available)',
                                                                                      style: robotoMedium.copyWith(color: available ? null : Theme.of(context).disabledColor),
                                                                                    ),
                                                                                    subtitle: Text(
                                                                                      available ? (branch.address ?? '') : (activeAt != null ? 'Available at: $activeAt' : 'Currently unavailable'),
                                                                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: available ? null : Theme.of(context).disabledColor),
                                                                                    ),
                                                                                    trailing: _selectedBranchId == branch.id ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                                                                                    onTap: available
                                                                                        ? () {
                                                                                            setState(() {
                                                                                              _selectedBranchId = branch.id;
                                                                                              _selectedBranch = branch;
                                                                                            });
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        : null,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ));
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        _selectedBranch !=
                                                                                null
                                                                            ? _selectedBranch!.name!
                                                                            : 'see_all'.tr,
                                                                        style: robotoMedium.copyWith(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            fontSize: Dimensions.fontSizeSmall),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              Dimensions.paddingSizeExtraSmall),
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          size:
                                                                              20),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                                    dividerColor:
                                                                        Colors
                                                                            .transparent),
                                                            child:
                                                                ExpansionTile(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault)),
                                                              collapsedShape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault)),
                                                              title: Row(
                                                                children: [
                                                                  Text(
                                                                      'redeemable_at_x_outlets'
                                                                          .trParams({
                                                                        'count': item
                                                                            .branches!
                                                                            .length
                                                                            .toString()
                                                                      }),
                                                                      style: robotoMedium.copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeLarge)),
                                                                  const Spacer(),
                                                                  Text(
                                                                      'see_all'
                                                                          .tr,
                                                                      style: robotoRegular.copyWith(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall)),
                                                                ],
                                                              ),
                                                              childrenPadding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      Dimensions
                                                                          .paddingSizeSmall),
                                                              children: [
                                                                Text(
                                                                    'voucher_can_be_used'
                                                                        .tr,
                                                                    style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .fontSizeSmall,
                                                                        color: Theme.of(context)
                                                                            .disabledColor)),
                                                                const SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeSmall),
                                                                Wrap(
                                                                  spacing: 8.0,
                                                                  runSpacing:
                                                                      4.0,
                                                                  children: item
                                                                      .branches!
                                                                      .map(
                                                                          (branch) {
                                                                    return Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .primaryColor
                                                                            .withValues(alpha: 0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions.radiusDefault),
                                                                      ),
                                                                      child: Builder(
                                                                          builder:
                                                                              (context) {
                                                                        // ONLY check availability for Delivery/Pickup and Flat Discount vouchers
                                                                        // Everything else (Gift, In-Store, etc.) should always be available
                                                                        bool shouldCheckAvailability = _isDeliveryOrPickup(item) ||
                                                                            item.voucherIds?.toLowerCase().contains('flat') ==
                                                                                true ||
                                                                            item.voucherIds ==
                                                                                'Flat discount';

                                                                        bool available = shouldCheckAvailability
                                                                            ? _isBranchAvailable(branch)
                                                                            : true;

                                                                        String?
                                                                            activeAt;
                                                                        if (!available &&
                                                                            branch.availability !=
                                                                                null) {
                                                                          for (var a
                                                                              in branch.availability!) {
                                                                            if (a.status ==
                                                                                'not_available') {
                                                                              activeAt = a.activeAt;
                                                                              break;
                                                                            }
                                                                          }
                                                                        }

                                                                        return Text(
                                                                            available
                                                                                ? (branch.name ?? '')
                                                                                : '${branch.name ?? ''} (Not Available)${activeAt != null ? ' - $activeAt' : ''}',
                                                                            style: robotoRegular.copyWith(
                                                                              fontSize: Dimensions.fontSizeSmall,
                                                                              color: available ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                                                            ));
                                                                      }),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ],
                                                            )),
                                                  )
                                                : const SizedBox(),

                                            _buildVoucherSettings(
                                                item, context),
                                            _buildVoucherTerms(item, context),

                                            _buildHowItWorks(item, context),

                                            _buildCustomerReviewSection(
                                                item, context),

                                            (item.nutritionsName != null &&
                                                    (item.nutritionsName!
                                                        .isNotEmpty))
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'nutrition_details'
                                                              .tr,
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge)),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Wrap(
                                                          children: List.generate(
                                                              item.nutritionsName
                                                                      ?.length ??
                                                                  0, (index) {
                                                        return Text(
                                                          '${item.nutritionsName?[index]}${((item.nutritionsName?.length ?? 0) - 1) == index ? '.' : ', '}',
                                                          style: robotoRegular.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color
                                                                  ?.withValues(
                                                                      alpha:
                                                                          0.5)),
                                                        );
                                                      })),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeLarge),
                                                    ],
                                                  )
                                                : const SizedBox(),

                                            (item.allergiesName != null &&
                                                    (item.allergiesName!
                                                        .isNotEmpty))
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'allergic_ingredients'
                                                              .tr,
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge)),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Wrap(
                                                          children: List.generate(
                                                              item.allergiesName
                                                                      ?.length ??
                                                                  0, (index) {
                                                        return Text(
                                                          '${item.allergiesName?[index]}${((item.allergiesName?.length ?? 0) - 1) == index ? '.' : ', '}',
                                                          style: robotoRegular.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color
                                                                  ?.withValues(
                                                                      alpha:
                                                                          0.5)),
                                                        );
                                                      })),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeLarge),
                                                    ],
                                                  )
                                                : const SizedBox(),

                                            (item.genericName != null &&
                                                    (item.genericName
                                                            ?.isNotEmpty ??
                                                        false))
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('generic_name'.tr,
                                                          style: robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge)),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Wrap(
                                                          children: List.generate(
                                                              item.genericName
                                                                      ?.length ??
                                                                  0, (index) {
                                                        return Text(
                                                          '${item.genericName?[index]}${((item.genericName?.length ?? 0) - 1) == index ? '.' : ', '}',
                                                          style: robotoRegular.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color
                                                                  ?.withValues(
                                                                      alpha:
                                                                          0.5)),
                                                        );
                                                      })),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeLarge),
                                                    ],
                                                  )
                                                : const SizedBox(),

                                            // Variation
                                            // Variation
                                            (item.foodVariations?.isNotEmpty ??
                                                    false)
                                                ? NewVariationView(
                                                    item: item,
                                                    itemController:
                                                        itemController,
                                                    discount: initialDiscount,
                                                    discountType: discountType,
                                                    showOriginalPrice: (price >
                                                            priceWithDiscount) &&
                                                        (discountType ==
                                                            'percent'),
                                                  )
                                                : (item.choiceOptions != null &&
                                                        (item.choiceOptions
                                                                ?.isNotEmpty ??
                                                            false))
                                                    ? VariationView(
                                                        item: item,
                                                        itemController:
                                                            itemController,
                                                      )
                                                    : const SizedBox(),
                                            SizedBox(
                                                height: (Get.find<SplashController>()
                                                                .configModel
                                                                ?.moduleConfig
                                                                ?.module
                                                                ?.addOn ??
                                                            false) &&
                                                        (item.addOns
                                                                ?.isNotEmpty ??
                                                            false)
                                                    ? Dimensions
                                                        .paddingSizeLarge
                                                    : 0),

                                            // Addons
                                            (Get.find<SplashController>()
                                                            .configModel
                                                            ?.moduleConfig
                                                            ?.module
                                                            ?.addOn ??
                                                        false) &&
                                                    (item.addOns?.isNotEmpty ??
                                                        false)
                                                ? AddonView(
                                                    itemController:
                                                        itemController,
                                                    item: item)
                                                : const SizedBox(),

                                            isAvailable
                                                ? const SizedBox()
                                                : Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeSmall),
                                                    margin: const EdgeInsets
                                                        .only(
                                                        bottom: Dimensions
                                                            .paddingSizeSmall),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall),
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: Column(children: [
                                                      Text(
                                                          'not_available_now'
                                                              .tr,
                                                          style: robotoMedium
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                          )),
                                                      Text(
                                                        '${'available_will_be'.tr} ${DateConverter.convertTimeToTime(item.availableTimeStarts ?? '')} - '
                                                        '${DateConverter.convertTimeToTime(item.availableTimeEnds ?? '')}',
                                                        style: robotoRegular,
                                                      ),
                                                    ]),
                                                  ),
                                          ]),
                                      (initialDiscount != null &&
                                              initialDiscount > 0 &&
                                              item.type != 'voucher')
                                          ? Positioned(
                                              top: -5,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 18),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 5,
                                                        spreadRadius: 1)
                                                  ],
                                                ),
                                                child: Column(children: [
                                                  Text('save'.tr,
                                                      style: robotoRegular
                                                          .copyWith(
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .white)),
                                                  Text(
                                                    discountType == 'percent'
                                                        ? '${initialDiscount != null && initialDiscount! % 1 == 0 ? initialDiscount?.toStringAsFixed(0) : initialDiscount?.toStringAsFixed(1)}%'
                                                        : PriceConverter
                                                            .convertPrice(
                                                                initialDiscount),
                                                    style: robotoBold.copyWith(
                                                        fontSize: 26,
                                                        color: Colors.white),
                                                  ),
                                                ]),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ),

                      ///Bottom side..
                      (!(item.scheduleOrder ?? false) && !isAvailable)
                          ? const SizedBox()
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: GetPlatform.isWeb
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(40))
                                    : const BorderRadius.all(
                                        Radius.circular(0)),
                                boxShadow: ResponsiveHelper.isDesktop(context)
                                    ? null
                                    : const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5,
                                            spreadRadius: 1)
                                      ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeDefault),
                              child: Column(children: [
                                if (item.type != 'voucher' ||
                                    item.voucherIds == 'In-Store')
                                  Builder(builder: (context) {
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${'total_amount'.tr}:',
                                              style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .disabledColor)),
                                          Row(children: [
                                            if (item.bundleType ==
                                                'bogo_free') ...[
                                              // Low price strikethrough on LEFT
                                              Text(
                                                _formatPrice(bogoLowerPrice),
                                                style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraLarge,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              // High price prominently on RIGHT
                                              Text(
                                                _formatPrice(
                                                    priceWithDiscountAndAddons),
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeOverLarge,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                            ] else ...[
                                              if (totalPriceWithoutDiscount >
                                                  priceWithDiscountAndAddons)
                                                Text(
                                                  _formatPrice(
                                                      totalPriceWithoutDiscount),
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              if (totalPriceWithoutDiscount >
                                                  priceWithDiscountAndAddons)
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall),
                                              Text(
                                                _formatPrice((item.type ==
                                                        'voucher')
                                                    ? (item.bundleType ==
                                                            'simple x'
                                                        ? priceWithDiscountAndAddons
                                                        : (priceWithDiscountAndAddons -
                                                            (priceWithDiscount *
                                                                (itemController
                                                                        .quantity ??
                                                                    1))))
                                                    : priceWithDiscountAndAddons),
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeOverLarge,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                            ],
                                          ]),
                                          if (item.availabilityForCurrentUser
                                                  ?.status ==
                                              'not_available')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Text(
                                                'out_of_stock'.tr,
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error),
                                              ),
                                            ),
                                          if (item.availabilityForCurrentUser
                                                  ?.userUsage !=
                                              null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Text(
                                                '${'remaining'.tr}: ${item.availabilityForCurrentUser!.userUsage!.remaining ?? 0}',
                                                style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Colors.black),
                                              ),
                                            ),
                                        ]);
                                  }),
                                if (item.type != 'voucher' ||
                                    item.voucherIds == 'In-Store')
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                SafeArea(
                                  child: Row(
                                      mainAxisAlignment: item.type == 'voucher'
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                      children: [
                                        if (item.type == 'voucher' &&
                                            item.voucherIds != 'In-Store')
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('${'total_amount'.tr}:',
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .disabledColor)),
                                                Row(
                                                  children: [
                                                    if (item.bundleType ==
                                                        'bogo_free') ...[
                                                      // Low price strikethrough on LEFT
                                                      Text(
                                                        _formatPrice(
                                                            bogoLowerPrice),
                                                        style: robotoMedium
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeExtraLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      // High price prominently on RIGHT
                                                      Text(
                                                        _formatPrice(
                                                            priceWithDiscountAndAddons),
                                                        style:
                                                            robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeOverLarge,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Original logic for non-BOGO vouchers
                                                      if (totalPriceWithoutDiscount >
                                                              priceWithDiscountAndAddons ||
                                                          item.bundleType ==
                                                              'gift')
                                                        Text(
                                                          _formatPrice(
                                                              totalPriceWithoutDiscount),
                                                          style: robotoMedium
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                        ),
                                                      if (totalPriceWithoutDiscount >
                                                              priceWithDiscountAndAddons ||
                                                          item.bundleType ==
                                                              'gift')
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall),
                                                      Text(
                                                        _formatPrice((item
                                                                    .type ==
                                                                'voucher')
                                                            ? (item.bundleType ==
                                                                        'gift' ||
                                                                    item.bundleType ==
                                                                        'simple x'
                                                                ? priceWithDiscountAndAddons
                                                                : (priceWithDiscountAndAddons -
                                                                    (priceWithDiscount *
                                                                        (itemController.quantity ??
                                                                            1))))
                                                            : priceWithDiscountAndAddons),
                                                        style:
                                                            robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeOverLarge,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (item.availabilityForCurrentUser
                                                        ?.status ==
                                                    'not_available')
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    child: Text(
                                                      'out_of_stock'.tr,
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error),
                                                    ),
                                                  ),
                                                if (item.availabilityForCurrentUser
                                                        ?.userUsage !=
                                                    null)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    child: Text(
                                                      '${'remaining'.tr}: ${item.availabilityForCurrentUser!.userUsage!.remaining ?? 0}',
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                        // Quantity
                                        if (item.type != 'voucher')
                                          Row(children: [
                                            QuantityButton(
                                              onTap: () {
                                                if ((itemController.quantity ??
                                                        0) >
                                                    1) {
                                                  itemController.setQuantity(
                                                      false,
                                                      stock,
                                                      item.quantityLimit,
                                                      getxSnackBar: true);
                                                }
                                              },
                                              isIncrement: false,
                                              fromSheet: true,
                                            ),
                                            Text(
                                                itemController.quantity
                                                    .toString(),
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge)),
                                            QuantityButton(
                                              onTap: () =>
                                                  itemController.setQuantity(
                                                      true,
                                                      stock,
                                                      item.quantityLimit,
                                                      getxSnackBar: true),
                                              isIncrement: true,
                                              fromSheet: true,
                                            ),
                                          ]),
                                        if (item.type != 'voucher')
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),

                                        GetBuilder<CartController>(
                                            builder: (cartController) {
                                          bool isInStore =
                                              item.voucherIds == 'In-Store';

                                          void Function()? handleOnPressed(
                                              bool forGift) {
                                            bool shouldBeNull = (((Get.find<SplashController>()
                                                                .configModel
                                                                ?.moduleConfig
                                                                ?.module
                                                                ?.stock ??
                                                            false) &&
                                                        (stock ?? 0) <= 0) ||
                                                    (item.bundleType == 'bogo_free' &&
                                                        _isBogoVariationMissing(
                                                            item, itemController)) ||
                                                    (item.bundleType == 'mix_match' &&
                                                        _isMixMatchSelectionMissing(
                                                            item, itemController)) ||
                                                    (item.type == 'voucher' &&
                                                        item.bundleType !=
                                                            'bogo_free' &&
                                                        item.bundleType !=
                                                            'mix_match' &&
                                                        _isVoucherVariationMissing(
                                                            item, itemController)) ||
                                                    (priceWithDiscountAndAddons <=
                                                        0)) ||
                                                ((_isDeliveryOrPickup(item) ||
                                                        item.voucherIds
                                                                ?.toLowerCase()
                                                                .contains('flat') ==
                                                            true ||
                                                        item.voucherIds == 'Flat discount') &&
                                                    item.branches != null &&
                                                    item.branches!.isNotEmpty &&
                                                    !_anyBranchAvailable(item));
                                            if (forGift) {
                                              // New logic: Direct navigation, no local validation needed
                                            }

                                            if (shouldBeNull) return null;
                                            return () async {
                                              String getNestedProductPrice(
                                                  Item product) {
                                                if (product.foodVariations !=
                                                        null &&
                                                    product.foodVariations!
                                                        .isNotEmpty) {
                                                  return '0';
                                                }
                                                return (product.price ?? 0)
                                                    .toString();
                                              }

                                              // Removed local _isGiftMode toggle logic

                                              if (forGift) {
                                                setState(() {
                                                  _isGiftLoading = true;
                                                });
                                              } else {
                                                setState(() {
                                                  _isBuyNowLoading = true;
                                                });
                                              }
                                              try {
                                                String? invalid;

                                                if (!_checkAvailability(item)) {
                                                  invalid = item
                                                          .availabilityForCurrentUser
                                                          ?.msg ??
                                                      'Item is not available';
                                                }

                                                if (invalid == null &&
                                                    item.bundleType ==
                                                        'bogo_free') {
                                                  if (itemController
                                                          .selectedBogoProductAIndex ==
                                                      null) {
                                                    invalid =
                                                        'Please select first product';
                                                  } else if (itemController
                                                          .selectedBogoProductBIndex ==
                                                      null) {
                                                    invalid =
                                                        'Please select second product';
                                                  }
                                                }

                                                if (invalid == null &&
                                                    _newVariation &&
                                                    item.bundleType !=
                                                        'bogo_free' &&
                                                    item.bundleType !=
                                                        'mix_match') {
                                                  for (int index = 0;
                                                      index <
                                                          (item.foodVariations
                                                                  ?.length ??
                                                              0);
                                                      index++) {
                                                    if (!(item
                                                                .foodVariations?[
                                                                    index]
                                                                ?.multiSelect ??
                                                            false) &&
                                                        (item.foodVariations?[index]?.required ??
                                                            false) &&
                                                        !itemController
                                                            .selectedVariations[
                                                                index]
                                                            .contains(true)) {
                                                      invalid =
                                                          '${'choose_a_variation_from'.tr} ${item.foodVariations?[index]?.name}';
                                                      break;
                                                    } else if ((item
                                                                .foodVariations?[
                                                                    index]
                                                                ?.multiSelect ??
                                                            false) &&
                                                        ((item.foodVariations?[index]?.required ?? false) ||
                                                            itemController.selectedVariations[index]
                                                                .contains(
                                                                    true)) &&
                                                        (item.foodVariations?[index]?.min ?? 0) >
                                                            itemController.selectedVariationLength(
                                                                itemController
                                                                    .selectedVariations,
                                                                index)) {
                                                      invalid =
                                                          '${'select_minimum'.tr} ${item.foodVariations?[index]?.min} '
                                                          '${'and_up_to'.tr} ${item.foodVariations?[index]?.max} ${'options_from'.tr}'
                                                          ' ${item.foodVariations?[index]?.name} ${'variation'.tr}';
                                                      break;
                                                    }
                                                  }
                                                }

                                                if (invalid == null &&
                                                    item.type == 'voucher' &&
                                                    item.bundleType !=
                                                        'bogo_free' &&
                                                    item.bundleType !=
                                                        'mix_match') {
                                                  for (int i = 0;
                                                      i <
                                                          flattenedFoodVariations
                                                              .length;
                                                      i++) {
                                                    if ((flattenedFoodVariations[
                                                                    i]
                                                                .required ??
                                                            false) &&
                                                        itemController
                                                                    .voucherVariationIndex[
                                                                i] ==
                                                            -1) {
                                                      invalid =
                                                          '${'choose_a_variation_from'.tr} ${flattenedFoodVariations[i].name}';
                                                      break;
                                                    }
                                                  }
                                                }

                                                if (Get.find<SplashController>()
                                                        .moduleList !=
                                                    null) {
                                                  for (ModuleModel module
                                                      in Get.find<SplashController>()
                                                              .moduleList ??
                                                          []) {
                                                    if (module.id ==
                                                        item.moduleId) {
                                                      Get.find<
                                                              SplashController>()
                                                          .setModule(module);
                                                      break;
                                                    }
                                                  }
                                                }

                                                if (invalid != null) {
                                                  setState(() {
                                                    _isBuyNowLoading = false;
                                                    _isGiftLoading = false;
                                                  });
                                                  _showAvailabilityDialog(
                                                      invalid);
                                                } else {
                                                  String cartGroup = (Random()
                                                              .nextInt(
                                                                  90000000) +
                                                          10000000)
                                                      .toString();
                                                  CartModel cartModel =
                                                      CartModel(
                                                    null,
                                                    price,
                                                    priceWithDiscountAndAddons,
                                                    variation != null
                                                        ? [variation]
                                                        : [],
                                                    itemController
                                                        .selectedVariations,
                                                    ((price ?? 0) -
                                                        (PriceConverter
                                                                .convertWithDiscount(
                                                                    price,
                                                                    discount,
                                                                    discountType) ??
                                                            0)),
                                                    itemController.quantity,
                                                    addOnIdList,
                                                    addOnsList,
                                                    widget.isCampaign,
                                                    item.stock,
                                                    item,
                                                    item.quantityLimit,
                                                    cartGroupId: cartGroup,
                                                  );
                                                  List<OrderVariation>
                                                      variations =
                                                      _getSelectedVariations(
                                                    isFoodVariation: Get.find<
                                                                SplashController>()
                                                            .getModuleConfig(
                                                                item.moduleType)
                                                            .newVariation ??
                                                        false,
                                                    foodVariations:
                                                        item.foodVariations,
                                                    selectedVariations:
                                                        itemController
                                                            .selectedVariations,
                                                  );

                                                  // Separate lists for BOGO products
                                                  List<OrderVariation>
                                                      bogoVariationsA = [];
                                                  List<OrderVariation>
                                                      bogoVariationsB = [];
                                                  List<int?> bogoAddOnIdA = [];
                                                  List<int?> bogoAddOnQtyA = [];
                                                  List<AddOns> bogoAddOnsA = [];
                                                  List<int?> bogoAddOnIdB = [];
                                                  List<int?> bogoAddOnQtyB = [];
                                                  List<AddOns> bogoAddOnsB = [];
                                                  double totalBogoPriceA = 0;
                                                  double totalBogoPriceB = 0;
                                                  if (flattenedFoodVariations
                                                      .isNotEmpty) {
                                                    for (int i = 0;
                                                        i <
                                                            flattenedFoodVariations
                                                                .length;
                                                        i++) {
                                                      int selectedIndex =
                                                          itemController
                                                              .voucherVariationIndex[i];
                                                      if (selectedIndex != -1) {
                                                        variations
                                                            .add(OrderVariation(
                                                          name:
                                                              flattenedFoodVariations[
                                                                          i]
                                                                      ?.name ??
                                                                  '',
                                                          type: flattenedFoodVariations[
                                                                          i]
                                                                      ?.multiSelect ??
                                                                  false
                                                              ? 'multi'
                                                              : 'single',
                                                          min:
                                                              flattenedFoodVariations[
                                                                          i]
                                                                      ?.min ??
                                                                  0,
                                                          max:
                                                              flattenedFoodVariations[
                                                                          i]
                                                                      ?.max ??
                                                                  0,
                                                          required:
                                                              (flattenedFoodVariations[
                                                                              i]
                                                                          ?.required ??
                                                                      false)
                                                                  ? 'on'
                                                                  : 'off',
                                                          values: [
                                                            OrderVariationValue(
                                                              label: flattenedFoodVariations[
                                                                          i]
                                                                      .variationValues![
                                                                          selectedIndex]
                                                                      .level ??
                                                                  '',
                                                              optionPrice: (item
                                                                                  .type ==
                                                                              'voucher' &&
                                                                          item.discount !=
                                                                              null &&
                                                                          item.discount! >
                                                                              0
                                                                      ? PriceConverter
                                                                          .convertWithDiscount(
                                                                          flattenedFoodVariations[i]?.variationValues?[selectedIndex].optionPrice ??
                                                                              0,
                                                                          item.discount,
                                                                          item.discountType,
                                                                          isFoodVariation:
                                                                              true,
                                                                        )
                                                                      : flattenedFoodVariations[
                                                                              i]
                                                                          ?.variationValues?[
                                                                              selectedIndex]
                                                                          .optionPrice)
                                                                  .toString(),
                                                            ),
                                                          ],
                                                          productId:
                                                              flattenedFoodVariations[
                                                                      i]
                                                                  ?.productId
                                                                  ?.toString(),
                                                        ));
                                                      }
                                                    }
                                                  }
                                                  List<int?> listOfAddOnId = [];
                                                  List<int?> listOfAddOnQty =
                                                      [];

                                                  if (item.bundleType ==
                                                      'bogo_free') {
                                                    // BOGO Variations and Addons collection
                                                    Item productA = item
                                                            .product![
                                                        itemController
                                                            .selectedBogoProductAIndex!];
                                                    Item productB = item
                                                            .productB![
                                                        itemController
                                                            .selectedBogoProductBIndex!];

                                                    // Product A Options
                                                    bogoVariationsA.addAll(
                                                        _getSelectedVariations(
                                                      isFoodVariation: true,
                                                      foodVariations: productA
                                                          .foodVariations,
                                                      selectedVariations:
                                                          itemController
                                                              .selectedBogoVariationsA,
                                                    ));
                                                    for (int i = 0;
                                                        i <
                                                            productA
                                                                .addOns!.length;
                                                        i++) {
                                                      if (i <
                                                              itemController
                                                                  .selectedBogoAddonsA
                                                                  .length &&
                                                          itemController
                                                                  .selectedBogoAddonsA[
                                                              i]) {
                                                        bogoAddOnIdA.add(
                                                            productA
                                                                .addOns![i].id);
                                                        bogoAddOnQtyA.add(i <
                                                                itemController
                                                                    .selectedBogoAddonQtyA
                                                                    .length
                                                            ? itemController
                                                                .selectedBogoAddonQtyA[i]
                                                            : 1);
                                                        bogoAddOnsA.add(productA
                                                            .addOns![i]);
                                                      }
                                                    }

                                                    // Product B Options
                                                    bogoVariationsB.addAll(
                                                        _getSelectedVariations(
                                                      isFoodVariation: true,
                                                      foodVariations: productB
                                                          .foodVariations,
                                                      selectedVariations:
                                                          itemController
                                                              .selectedBogoVariationsB,
                                                    ));
                                                    for (int i = 0;
                                                        i <
                                                            productB
                                                                .addOns!.length;
                                                        i++) {
                                                      if (i <
                                                              itemController
                                                                  .selectedBogoAddonsB
                                                                  .length &&
                                                          itemController
                                                                  .selectedBogoAddonsB[
                                                              i]) {
                                                        bogoAddOnIdB.add(
                                                            productB
                                                                .addOns![i].id);
                                                        bogoAddOnQtyB.add(i <
                                                                itemController
                                                                    .selectedBogoAddonQtyB
                                                                    .length
                                                            ? itemController
                                                                .selectedBogoAddonQtyB[i]
                                                            : 1);
                                                        bogoAddOnsB.add(productB
                                                            .addOns![i]);
                                                      }
                                                    }

                                                    // Calculate total price A
                                                    totalBogoPriceA =
                                                        double.tryParse(
                                                                getNestedProductPrice(
                                                                    productA)) ??
                                                            0;
                                                    for (var v
                                                        in bogoVariationsA) {
                                                      for (var val
                                                          in v.values!) {
                                                        totalBogoPriceA +=
                                                            double.tryParse(
                                                                    val.optionPrice ??
                                                                        '0') ??
                                                                0;
                                                      }
                                                    }

                                                    // Calculate total price B
                                                    totalBogoPriceB =
                                                        double.tryParse(
                                                                getNestedProductPrice(
                                                                    productB)) ??
                                                            0;
                                                    for (var v
                                                        in bogoVariationsB) {
                                                      for (var val
                                                          in v.values!) {
                                                        totalBogoPriceB +=
                                                            double.tryParse(
                                                                    val.optionPrice ??
                                                                        '0') ??
                                                                0;
                                                      }
                                                    }
                                                  } else {
                                                    listOfAddOnId =
                                                        _getSelectedAddonIds(
                                                            addOnIdList:
                                                                addOnIdList);
                                                    listOfAddOnQty =
                                                        _getSelectedAddonQtnList(
                                                            addOnIdList:
                                                                addOnIdList);
                                                  }

                                                  // For BOGO free: price of the free (cheaper) item
                                                  double bogoFreeItemPrice =
                                                      (item.bundleType ==
                                                              'bogo_free')
                                                          ? (totalBogoPriceA <=
                                                                  totalBogoPriceB
                                                              ? totalBogoPriceA
                                                              : totalBogoPriceB)
                                                          : 0;

                                                  List<OnlineCart> cartsToAdd =
                                                      [];
                                                  // Usage of cartGroup hoisted from below

                                                  GiftDetails? giftDetails;
                                                  if (item.bundleType ==
                                                      'gift') {
                                                    String recipientName = _buyForSelf
                                                        ? '${Get.find<ProfileController>().userInfoModel?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.lName ?? ''}'
                                                            .trim()
                                                        : '${_firstNameController.text} ${_lastNameController.text}'
                                                            .trim();

                                                    String deliveryTime = _buyForSelf
                                                        ? 'Instant'
                                                        : (_selectedTimingIndex ==
                                                                0
                                                            ? 'Instant'
                                                            : (_selectedDate !=
                                                                    null
                                                                ? DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .format(
                                                                        _selectedDate!)
                                                                : 'Scheduled'));

                                                    giftDetails = GiftDetails(
                                                      occasion:
                                                          _selectedOccasion
                                                              ?.title,
                                                      image: (_selectedOccasion != null &&
                                                              _selectedDesignIndex !=
                                                                  null &&
                                                              _selectedOccasion!
                                                                      .icon !=
                                                                  null &&
                                                              _selectedOccasion!
                                                                  .icon!
                                                                  .isNotEmpty)
                                                          ? _selectedOccasion!
                                                                  .icon![
                                                              _selectedDesignIndex!]
                                                          : null,
                                                      senderName:
                                                          '${Get.find<ProfileController>().userInfoModel?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.lName ?? ''}'
                                                              .trim(),
                                                      recipientName:
                                                          recipientName,
                                                      recipientEmail: _buyForSelf
                                                          ? (Get.find<ProfileController>()
                                                                  .userInfoModel
                                                                  ?.email ??
                                                              '')
                                                          : _emailController
                                                              .text,
                                                      message:
                                                          _messageController
                                                              .text,
                                                      deliveryTime:
                                                          deliveryTime,
                                                      amount:
                                                          _selectedGiftAmount,
                                                      bonus: _giftBonusAmount,
                                                    );
                                                  }

                                                  // Pre-compute total mix_match discount for main voucher
                                                  double mixMatchTotalDiscount =
                                                      0;
                                                  double mixMatchRawTotal = 0;
                                                  if (item.bundleType ==
                                                      'mix_match') {
                                                    for (var sel in itemController
                                                        .selectedMixMatchProducts) {
                                                      double rawPrice =
                                                          sel.totalPrice +
                                                              sel.addonsPrice;
                                                      double discountedVariation = (item
                                                                      .discount !=
                                                                  null &&
                                                              item.discount! >
                                                                  0)
                                                          ? (PriceConverter
                                                                  .convertWithDiscount(
                                                                      sel.totalPrice,
                                                                      discount,
                                                                      discountType) ??
                                                              sel.totalPrice)
                                                          : sel.totalPrice;
                                                      mixMatchTotalDiscount +=
                                                          rawPrice -
                                                              (discountedVariation +
                                                                  sel.addonsPrice);
                                                      mixMatchRawTotal +=
                                                          rawPrice;
                                                    }
                                                  }

                                                  // 1. Main Voucher/Item Cart Object
                                                  cartsToAdd.add(OnlineCart(
                                                    null,
                                                    widget.isCampaign
                                                        ? null
                                                        : item.id,
                                                    widget.isCampaign
                                                        ? item.id
                                                        : null,
                                                    (item.bundleType == 'gift'
                                                            ? _selectedGiftAmount
                                                            : priceWithDiscountAndAddons)
                                                        .toString(),
                                                    '',
                                                    variation != null
                                                        ? [variation]
                                                        : null,
                                                    (Get.find<SplashController>()
                                                                .getModuleConfig(item
                                                                    .moduleType)
                                                                .newVariation! ||
                                                            (item.type ==
                                                                    'voucher' &&
                                                                variations
                                                                    .isNotEmpty))
                                                        ? variations
                                                            .where((v) =>
                                                                v.productId ==
                                                                null)
                                                            .toList()
                                                        : null,
                                                    itemController.quantity,
                                                    listOfAddOnId
                                                        .where((id) =>
                                                            addOnsList
                                                                .firstWhere(
                                                                    (a) =>
                                                                        a.id ==
                                                                        id)
                                                                .productId ==
                                                            null)
                                                        .toList(),
                                                    addOnsList
                                                        .where((a) =>
                                                            a.productId == null)
                                                        .toList(),
                                                    listOfAddOnQty
                                                        .where((qty) =>
                                                            addOnsList
                                                                .firstWhere((a) =>
                                                                    a.id ==
                                                                    listOfAddOnId[
                                                                        listOfAddOnQty
                                                                            .indexOf(qty)])
                                                                .productId ==
                                                            null)
                                                        .toList(),
                                                    'Item',
                                                    cartGroup: (item.type ==
                                                                'voucher' ||
                                                            item.bundleType ==
                                                                'bogo_free')
                                                        ? cartGroup
                                                        : null,
                                                    storeId: _isDeliveryOrPickup(
                                                            item)
                                                        ? _selectedBranchId
                                                        : (_selectedBranchId ??
                                                            item.storeId),
                                                    giftDetails: giftDetails,
                                                    totalPrice: item
                                                                .bundleType ==
                                                            'bogo_free'
                                                        ? bogoLowerPrice
                                                        : item.bundleType ==
                                                                'mix_match'
                                                            ? mixMatchRawTotal
                                                            : (item.type ==
                                                                        'voucher' &&
                                                                    item.bundleType !=
                                                                        'gift')
                                                                ? totalPriceWithoutDiscount
                                                                : (item.bundleType ==
                                                                        'gift'
                                                                    ? (_selectedGiftAmount +
                                                                        _giftBonusAmount)
                                                                    : priceWithDiscountAndAddons),
                                                    isPaid: item.bundleType ==
                                                            'bogo_free'
                                                        ? 0
                                                        : null,
                                                    discountAmount: (item.type ==
                                                                'voucher' &&
                                                            item.bundleType !=
                                                                'gift')
                                                        ? (totalPriceWithoutDiscount -
                                                                (priceWithDiscountAndAddons /
                                                                    (itemController
                                                                            .quantity ??
                                                                        1)))
                                                            .abs()
                                                        : (item.bundleType ==
                                                                'bogo_free'
                                                            ? bogoFreeItemPrice
                                                            : (item.bundleType ==
                                                                    'gift'
                                                                ? _giftBonusAmount
                                                                : null)),
                                                  ));

                                                  // 2. Nested Products Cart Objects (for all bundle simple products or those with variations)
                                                  bool isSimpleBundle = item
                                                              .type ==
                                                          'voucher' &&
                                                      item.bundleType !=
                                                          'bogo_free' &&
                                                      item.bundleType !=
                                                          'mix_match' &&
                                                      item.bundleType !=
                                                          'gift' &&
                                                      item.bundleType !=
                                                          'simple x' &&
                                                      item.product != null &&
                                                      item.product!.isNotEmpty;

                                                  if (isSimpleBundle ||
                                                      (item.type == 'voucher' &&
                                                          variations.any((v) =>
                                                              v.productId !=
                                                              null))) {
                                                    Map<
                                                            String,
                                                            List<
                                                                OrderVariation>>
                                                        nestedVariations = {};
                                                    for (var v in variations) {
                                                      if (v.productId != null) {
                                                        if (!nestedVariations
                                                            .containsKey(
                                                                v.productId)) {
                                                          nestedVariations[v
                                                              .productId!] = [];
                                                        }
                                                        nestedVariations[
                                                                v.productId!]!
                                                            .add(v);
                                                      }
                                                    }

                                                    // If it's a simple bundle, ensure all products are processed even without variations
                                                    if (isSimpleBundle) {
                                                      for (var p
                                                          in item.product!) {
                                                        if (!nestedVariations
                                                            .containsKey(p.id
                                                                .toString())) {
                                                          nestedVariations[p.id
                                                              .toString()] = [];
                                                        }
                                                      }
                                                    }

                                                    nestedVariations.forEach(
                                                        (productId, vars) {
                                                      // Filter Addons for this product
                                                      List<AddOns>
                                                          productAddOns =
                                                          addOnsList
                                                              .where((a) =>
                                                                  a.productId
                                                                      .toString() ==
                                                                  productId)
                                                              .toList();
                                                      List<int?>
                                                          productAddOnIds =
                                                          productAddOns
                                                              .map((a) => a.id)
                                                              .toList();
                                                      List<int?>
                                                          productAddOnQtys = [];
                                                      for (var addon
                                                          in productAddOns) {
                                                        int index = addOnsList
                                                            .indexOf(addon);
                                                        if (index != -1 &&
                                                            index <
                                                                listOfAddOnQty
                                                                    .length) {
                                                          productAddOnQtys.add(
                                                              listOfAddOnQty[
                                                                  index]);
                                                        } else {
                                                          // Fallback, though logical indices should match if addOnsList is source
                                                          // But listOfAddOnQty matches position in addOnsList?
                                                          // Check logic again: listOfAddOnQty is built from itemController.addOnQtyList via _getSelectedAddonQtnList
                                                          // addOnsList is built via _getSelectedAddonIds ?? No
                                                          // Wait, addOnsList is constructed in the lines above via itemController.productSelect loop
                                                          // Let's rely on finding qry by id or parallel index if reliable
                                                          // Actually, `listOfAddOnQty` corresponds to `listOfAddOnId`.
                                                          // We can find the quantity by finding the index of the addon's ID in `listOfAddOnId`.
                                                          int idIndex =
                                                              listOfAddOnId
                                                                  .indexOf(
                                                                      addon.id);
                                                          if (idIndex != -1) {
                                                            productAddOnQtys.add(
                                                                listOfAddOnQty[
                                                                    idIndex]);
                                                          } else {
                                                            productAddOnQtys
                                                                .add(1);
                                                          }
                                                        }
                                                      }

                                                      // Find the actual product to check food_variations
                                                      Item nestedProduct = item
                                                          .product!
                                                          .firstWhere((p) =>
                                                              p.id.toString() ==
                                                              productId);

                                                      cartsToAdd.add(OnlineCart(
                                                        null, // Always new item for nested products
                                                        int.parse(productId),
                                                        null,
                                                        '0', // Price assumed 0 as it is part of voucher
                                                        '',
                                                        null,
                                                        vars,
                                                        itemController.quantity,
                                                        productAddOnIds,
                                                        productAddOns,
                                                        productAddOnQtys,
                                                        'Item',
                                                        cartGroup: cartGroup,
                                                        discountAmount: 0,
                                                        totalPrice: 0,
                                                        storeId: _isDeliveryOrPickup(
                                                                item)
                                                            ? _selectedBranchId
                                                            : (_selectedBranchId ??
                                                                item.storeId),
                                                      ));
                                                    });
                                                  }

                                                  // 3. Mix & Match Product Cart Objects
                                                  if (item.bundleType ==
                                                      'mix_match') {
                                                    for (var selection
                                                        in itemController
                                                            .selectedMixMatchProducts) {
                                                      Item product = item
                                                              .product![
                                                          selection
                                                              .productIndex];

                                                      List<OrderVariation>
                                                          mixMatchVariations =
                                                          _getSelectedVariations(
                                                        isFoodVariation: true,
                                                        foodVariations: product
                                                            .foodVariations,
                                                        selectedVariations:
                                                            selection
                                                                .selectedVariations,
                                                        discount: discount,
                                                        discountType:
                                                            discountType,
                                                      );

                                                      List<int?>
                                                          mixMatchAddOnIds =
                                                          selection
                                                              .selectedAddonIds
                                                              .map((id) =>
                                                                  id as int?)
                                                              .toList();
                                                      List<int?>
                                                          mixMatchAddOnQtys =
                                                          selection
                                                              .selectedAddonQuantities
                                                              .map((qty) =>
                                                                  qty as int?)
                                                              .toList();
                                                      List<AddOns>
                                                          mixMatchAddons = [];
                                                      if (product.addOns !=
                                                          null) {
                                                        for (int id in selection
                                                            .selectedAddonIds) {
                                                          mixMatchAddons.add(
                                                              product
                                                                  .addOns!
                                                                  .firstWhere(
                                                                      (a) =>
                                                                          a.id ==
                                                                          id));
                                                        }
                                                      }

                                                      cartsToAdd.add(OnlineCart(
                                                        null,
                                                        product.id,
                                                        null,
                                                        '0', // Price assumed 0 for mix & match
                                                        '',
                                                        null,
                                                        mixMatchVariations,
                                                        itemController.quantity,
                                                        mixMatchAddOnIds,
                                                        mixMatchAddons,
                                                        mixMatchAddOnQtys,
                                                        'Item',
                                                        cartGroup: cartGroup,
                                                        discountAmount: 0,
                                                        totalPrice: 0,
                                                        storeId: _isDeliveryOrPickup(
                                                                item)
                                                            ? _selectedBranchId
                                                            : (_selectedBranchId ??
                                                                item.storeId),
                                                      ));
                                                    }
                                                  }

                                                  // 4. BOGO Product A & B Cart Objects
                                                  if (item.bundleType ==
                                                      'bogo_free') {
                                                    int isPaidA =
                                                        totalBogoPriceA >=
                                                                totalBogoPriceB
                                                            ? 1
                                                            : 0;
                                                    int isPaidB =
                                                        totalBogoPriceA >=
                                                                totalBogoPriceB
                                                            ? 0
                                                            : 1;

                                                    // The free item's price = min of both effective prices
                                                    // (already computed above as bogoFreeItemPrice)

                                                    // Product A
                                                    Item productA = item
                                                            .product![
                                                        itemController
                                                            .selectedBogoProductAIndex!];

                                                    cartsToAdd.add(OnlineCart(
                                                      null,
                                                      productA.id,
                                                      null,
                                                      '0',
                                                      '',
                                                      null,
                                                      bogoVariationsA,
                                                      itemController.quantity,
                                                      bogoAddOnIdA,
                                                      bogoAddOnsA,
                                                      bogoAddOnQtyA,
                                                      'Item',
                                                      cartGroup: cartGroup,
                                                      discountAmount: 0,
                                                      storeId: _isDeliveryOrPickup(
                                                              item)
                                                          ? _selectedBranchId
                                                          : (_selectedBranchId ??
                                                              item.storeId),
                                                      totalPrice:
                                                          totalBogoPriceA,
                                                      isPaid: isPaidA,
                                                    ));

                                                    // Product B
                                                    Item productB = item
                                                            .productB![
                                                        itemController
                                                            .selectedBogoProductBIndex!];

                                                    cartsToAdd.add(OnlineCart(
                                                      null,
                                                      productB.id,
                                                      null,
                                                      '0',
                                                      '',
                                                      null,
                                                      bogoVariationsB,
                                                      itemController.quantity,
                                                      bogoAddOnIdB,
                                                      bogoAddOnsB,
                                                      bogoAddOnQtyB,
                                                      'Item',
                                                      cartGroup: cartGroup,
                                                      discountAmount: 0,
                                                      storeId: _isDeliveryOrPickup(
                                                              item)
                                                          ? _selectedBranchId
                                                          : (_selectedBranchId ??
                                                              item.storeId),
                                                      totalPrice:
                                                          totalBogoPriceB,
                                                      isPaid: isPaidB,
                                                    ));
                                                  }

                                                  if (widget.isCampaign) {
                                                    Get.toNamed(
                                                        RouteHelper
                                                            .getCheckoutRoute(
                                                                'campaign'),
                                                        arguments:
                                                            CheckoutScreen(
                                                          storeId: null,
                                                          fromCart: false,
                                                          cartList: [cartModel],
                                                        ));
                                                  } else {
                                                    if (widget.cart != null ||
                                                        itemController
                                                                .cartIndex !=
                                                            -1) {
                                                      int index = widget.cart !=
                                                              null
                                                          ? cartController
                                                              .cartList
                                                              .indexOf(
                                                                  widget.cart!)
                                                          : itemController
                                                              .cartIndex;
                                                      if (index != -1) {
                                                        await cartController
                                                            .removeFromCart(
                                                                index);
                                                      }
                                                    }

                                                    if (widget.cart == null &&
                                                        itemController
                                                                .cartIndex ==
                                                            -1 &&
                                                        cartController.cartList
                                                            .isNotEmpty) {
                                                      debugPrint(
                                                          '[BUY_NOW_DEBUG] 🧹 Auto-clearing cart (Buy Now)...');
                                                      await cartController
                                                          .clearCartOnline();
                                                    }

                                                    bool allSuccess = true;

                                                    bool isFlatDiscount = item
                                                                .type ==
                                                            'Flat discount' ||
                                                        item.voucherIds ==
                                                            'Flat discount';
                                                    if (isFlatDiscount &&
                                                        widget.cart == null &&
                                                        itemController
                                                                .cartIndex ==
                                                            -1) {
                                                      Get.dialog(
                                                          OrderStatusDialog(
                                                              cartGroupId:
                                                                  cartGroup),
                                                          barrierDismissible:
                                                              false);
                                                    }

                                                    for (var cartItem
                                                        in cartsToAdd) {
                                                      bool success = false;
                                                      if (cartItem.cartId !=
                                                          null) {
                                                        success = await Get.find<
                                                                CartController>()
                                                            .updateCartOnline(
                                                                cartItem);
                                                      } else {
                                                        success = await Get.find<
                                                                CartController>()
                                                            .addToCartOnline(
                                                                cartItem);
                                                      }
                                                      debugPrint(
                                                          '[BUY_NOW_DEBUG] 🛒 Add result: $success for Item: ${cartItem.itemId}');
                                                      if (!success) {
                                                        allSuccess = false;
                                                      }
                                                    }

                                                    if (allSuccess) {
                                                      if (widget.cart != null) {
                                                        Navigator.pop(context);
                                                      } else {
                                                        if (!isFlatDiscount) {
                                                          debugPrint(
                                                              '[BUY_NOW_DEBUG] 🚀 NAVIGATING TO CHECKOUT (allSuccess: $allSuccess)');
                                                          // Get.back(); // Removed to keep sheet open as per user request
                                                          Get.toNamed(
                                                              RouteHelper
                                                                  .getCheckoutRoute(
                                                                      'buy_now'),
                                                              preventDuplicates:
                                                                  false,
                                                              arguments:
                                                                  CheckoutScreen(
                                                                storeId: null,
                                                                fromCart: true,
                                                                cartList: null,
                                                                isBuyNow: true,
                                                                isGift:
                                                                    forGift, // Pass gift flag
                                                                isGiftVoucher:
                                                                    item.bundleType ==
                                                                        'gift',
                                                              ));
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              } finally {
                                                if (mounted) {
                                                  setState(() {
                                                    _isBuyNowLoading = false;
                                                    _isGiftLoading = false;
                                                  });
                                                }
                                              }
                                            };
                                          }

                                          Widget buyNowButton = CustomButton(
                                            width: item.type == 'voucher' &&
                                                    !isInStore
                                                ? 160
                                                : (ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2.0
                                                    : null),
                                            height: item.type == 'voucher'
                                                ? 55
                                                : 50,
                                            isLoading: _isBuyNowLoading,
                                            buttonText: (Get.find<
                                                                SplashController>()
                                                            .configModel
                                                            ?.moduleConfig
                                                            ?.module
                                                            ?.stock ??
                                                        false) &&
                                                    (stock ?? 0) <= 0
                                                ? 'out_of_stock'.tr
                                                : widget.isCampaign
                                                    ? 'order_now'.tr
                                                    : (item.type ==
                                                                'Flat discount' ||
                                                            item.voucherIds ==
                                                                'Flat discount')
                                                        ? 'Pay Now'
                                                        : 'buy_now'.tr,
                                            onPressed: handleOnPressed(false),
                                            color: _checkAvailability(item)
                                                ? null
                                                : Theme.of(context)
                                                    .disabledColor,
                                            textColor: _checkAvailability(item)
                                                ? null
                                                : Theme.of(context).cardColor,
                                          );

                                          return isInStore
                                              ? Expanded(
                                                  child: Row(children: [
                                                  Expanded(
                                                      child: CustomButton(
                                                    height: 55,
                                                    isLoading: _isGiftLoading,
                                                    buttonText:
                                                        'buy_as_gift'.tr,
                                                    onPressed: handleOnPressed(
                                                        true), // Same as buy now
                                                    color:
                                                        _checkAvailability(item)
                                                            ? null
                                                            : Theme.of(context)
                                                                .disabledColor,
                                                    textColor:
                                                        _checkAvailability(item)
                                                            ? null
                                                            : Theme.of(context)
                                                                .cardColor,
                                                  )),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  Expanded(child: buyNowButton),
                                                ]))
                                              : (item.type == 'voucher'
                                                  ? buyNowButton
                                                  : Expanded(
                                                      child: buyNowButton));
                                        }),
                                      ]),
                                ),
                              ]),
                            ),
                    ]),
                  ],
                ),
        );
      }),
    );
  }

  void _showAvailabilityDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: PointerInterceptor(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(Images.warning,
                      width: 50,
                      height: 50,
                      color: Theme.of(context).primaryColor),
                ),
                Text(
                  'alert'.tr,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(message,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomButton(
                  buttonText: 'ok'.tr,
                  onPressed: () => Navigator.pop(context),
                  radius: Dimensions.radiusSmall,
                  height: 50,
                ),
              ]),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  List<OrderVariation> _getSelectedVariations({
    required bool isFoodVariation,
    required List<FoodVariation>? foodVariations,
    required List<List<bool?>> selectedVariations,
    double? discount,
    String? discountType,
  }) {
    List<OrderVariation> variations = [];
    if (isFoodVariation) {
      for (int i = 0; i < foodVariations!.length; i++) {
        if (selectedVariations[i].contains(true)) {
          List<OrderVariationValue> values = [];
          for (int j = 0; j < foodVariations[i].variationValues!.length; j++) {
            if (selectedVariations[i][j]!) {
              double originalPrice =
                  foodVariations[i].variationValues![j].optionPrice ?? 0;

              // ✅ Apply discount if provided (for nested products in vouchers)
              double finalPrice = originalPrice;
              if (discount != null && discount > 0) {
                finalPrice = PriceConverter.convertWithDiscount(
                      originalPrice,
                      discount,
                      discountType,
                      isFoodVariation: true,
                    ) ??
                    originalPrice;
              }

              values.add(OrderVariationValue(
                label: foodVariations[i].variationValues![j].level,
                optionPrice: finalPrice.toString(),
              ));
            }
          }
          variations.add(OrderVariation(
            name: foodVariations[i].name,
            type: foodVariations[i].multiSelect ?? false ? 'multi' : 'single',
            min: foodVariations[i].min ?? 0,
            max: foodVariations[i].max ?? 0,
            required: (foodVariations[i].required ?? false) ? 'on' : 'off',
            values: values,
          ));
        }
      }
    }
    return variations;
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  bool _checkAvailability(Item item) {
    if (item.availabilityForCurrentUser?.status == 'not_available') {
      return false;
    }
    return true;
  }

  bool _isVoucherVariationMissing(Item item, ItemController itemController) {
    List<FoodVariation> flattenedFoodVariations = [];
    if (item.product != null) {
      for (var p in item.product!) {
        if (p.foodVariations != null) {
          flattenedFoodVariations.addAll(p.foodVariations!);
        }
      }
    }
    for (int i = 0; i < flattenedFoodVariations.length; i++) {
      if ((flattenedFoodVariations[i].required ?? false) &&
          (itemController.voucherVariationIndex.length <= i ||
              itemController.voucherVariationIndex[i] == -1)) {
        return true;
      }
    }
    return false;
  }

  bool _isBogoVariationMissing(Item item, ItemController itemController) {
    if (itemController.selectedBogoProductAIndex == null ||
        itemController.selectedBogoProductBIndex == null) {
      return true;
    }

    // Check Product A variations
    Item productA = item.product![itemController.selectedBogoProductAIndex!];
    if (productA.foodVariations != null &&
        productA.foodVariations!.isNotEmpty) {
      bool anyVariationSelectedA = false;
      bool requiredMissingA = false;

      for (int i = 0; i < productA.foodVariations!.length; i++) {
        bool selected = itemController.selectedBogoVariationsA.isNotEmpty &&
            i < itemController.selectedBogoVariationsA.length &&
            itemController.selectedBogoVariationsA[i].contains(true);

        if (selected) {
          anyVariationSelectedA = true;
        }

        if ((productA.foodVariations![i].required ?? false) && !selected) {
          requiredMissingA = true;
          break;
        }
      }

      // If variations exist, at least one must be selected AND all required must be met
      if (requiredMissingA || !anyVariationSelectedA) {
        return true;
      }
    }

    // Check Product B variations
    Item productB = item.productB![itemController.selectedBogoProductBIndex!];
    if (productB.foodVariations != null &&
        productB.foodVariations!.isNotEmpty) {
      bool anyVariationSelectedB = false;
      bool requiredMissingB = false;

      for (int i = 0; i < productB.foodVariations!.length; i++) {
        bool selected = itemController.selectedBogoVariationsB.isNotEmpty &&
            i < itemController.selectedBogoVariationsB.length &&
            itemController.selectedBogoVariationsB[i].contains(true);

        if (selected) {
          anyVariationSelectedB = true;
        }

        if ((productB.foodVariations![i].required ?? false) && !selected) {
          requiredMissingB = true;
          break;
        }
      }

      // If variations exist, at least one must be selected AND all required must be met
      if (requiredMissingB || !anyVariationSelectedB) {
        return true;
      }
    }

    return false;
  }

  bool _isMixMatchSelectionMissing(Item item, ItemController itemController) {
    if (itemController.selectedMixMatchProducts.length <
        (item.requiredQuantity ?? 0)) {
      return true;
    }

    // Check if each selected product has all required variations selected
    for (var selection in itemController.selectedMixMatchProducts) {
      Item selectedProduct = item.product![selection.productIndex];
      if (selectedProduct.foodVariations != null) {
        for (int i = 0; i < selectedProduct.foodVariations!.length; i++) {
          if ((selectedProduct.foodVariations![i].required ?? false) &&
              !selection.selectedVariations[i].contains(true)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  Widget _buildMixMatchSelection(
      BuildContext context,
      ItemController itemController,
      Item item,
      double? discount,
      String? discountType) {
    int requiredQty = item.requiredQuantity ?? 0;
    int currentQty = itemController.selectedMixMatchProducts.length;

    return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$currentQty/$requiredQty',
                style: robotoBold.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeSmall),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
                currentQty == requiredQty
                    ? 'selection_complete'.tr
                    : 'select_x_items'.trParams(
                        {'count': (requiredQty - currentQty).toString()}),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Divider(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              height: 1),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.product!.length,
            itemBuilder: (context, index) {
              bool isSelected = itemController.isMixMatchProductSelected(index);
              bool isExpanded =
                  itemController.currentMixMatchProductIndex == index;

              return Container(
                margin:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: isSelected ? 2 : 1),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isExpanded) {
                          itemController.collapseMixMatchProduct();
                        } else if (isSelected) {
                          int existingIndex = itemController
                              .selectedMixMatchProducts
                              .indexWhere((s) => s.productIndex == index);
                          if (existingIndex != -1) {
                            itemController.removeMixMatchProduct(existingIndex);
                          }
                        } else {
                          itemController.selectMixMatchProduct(index);
                        }
                      },
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(Dimensions.radiusDefault),
                          bottom: Radius.circular(
                              isExpanded ? 0 : Dimensions.radiusDefault)),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: item.product![index].imageFullUrl ?? '',
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product![index].name ?? '',
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    isSelected
                                        ? (() {
                                            var selection = itemController
                                                .selectedMixMatchProducts
                                                .firstWhere((s) =>
                                                    s.productIndex == index);
                                            double variations =
                                                selection.totalPrice;
                                            Item selectedProduct =
                                                item.product![index];
                                            bool hasNoVariations =
                                                selectedProduct
                                                            .foodVariations ==
                                                        null ||
                                                    selectedProduct
                                                        .foodVariations!
                                                        .isEmpty;

                                            double variationsPrice =
                                                (hasNoVariations)
                                                    ? variations
                                                    : (PriceConverter
                                                            .convertWithDiscount(
                                                                variations,
                                                                discount,
                                                                discountType) ??
                                                        variations);

                                            double totalPrice =
                                                variationsPrice +
                                                    selection.addonsPrice;
                                            return variationsPrice > 0
                                                ? PriceConverter.convertPrice(
                                                    variationsPrice)
                                                : (selectedProduct
                                                                .foodVariations !=
                                                            null &&
                                                        selectedProduct
                                                            .foodVariations!
                                                            .isNotEmpty)
                                                    ? 'enter_voucher_price'.tr
                                                    : PriceConverter
                                                        .convertPrice(0);
                                          }())
                                        : (() {
                                            // For unselected products, show base price WITHOUT discount
                                            Item product = item.product![index];
                                            if (product.foodVariations ==
                                                    null ||
                                                product
                                                    .foodVariations!.isEmpty) {
                                              // No variations, show original base price (no discount)
                                              return PriceConverter
                                                  .convertPrice(
                                                      product.price ?? 0);
                                            }
                                            // Has variations but not selected, show placeholder
                                            return 'enter_voucher_price'.tr;
                                          }()),
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black),
                                  ),
                                ]),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          // Selection Indicator + optional Add-Ons label
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).disabledColor,
                                        width: 2)),
                              ),
                              if (isSelected && !isExpanded)
                                ...(() {
                                  var sel = itemController
                                      .selectedMixMatchProducts
                                      .where((s) => s.productIndex == index)
                                      .toList();
                                  double addonAmt = sel.isNotEmpty
                                      ? sel.first.addonsPrice
                                      : 0;
                                  return addonAmt > 0
                                      ? <Widget>[
                                          const SizedBox(height: 16),
                                          Text(
                                            '+ ${PriceConverter.convertPrice(addonAmt)} Add-Ons',
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Colors.black),
                                            textAlign: TextAlign.end,
                                          ),
                                        ]
                                      : <Widget>[];
                                }()),
                            ],
                          )
                        ]),
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.product![index].description != null &&
                                item.product![index].description!
                                    .isNotEmpty) ...[
                              Text('description'.tr,
                                  style: robotoBold.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.fontSizeDefault)),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Text(item.product![index].description!,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Colors.black)),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              const Divider(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                            ],
                            _buildMixMatchOptions(
                                context, itemController, item.product![index])
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ]));
  }

  Widget _buildMixMatchOptions(
      BuildContext context, ItemController itemController, Item product) {
    void calculateAndSave() {
      double price = 0;

      // Add variations
      if (product.foodVariations != null) {
        for (int i = 0; i < product.foodVariations!.length; i++) {
          for (int j = 0;
              j < product.foodVariations![i].variationValues!.length;
              j++) {
            if (itemController.currentMixMatchVariations[i][j] ?? false) {
              price +=
                  product.foodVariations![i].variationValues![j].optionPrice ??
                      0;
            }
          }
        }
      }

      // Add addons
      double addonsCost = 0;
      if (product.addOns != null) {
        for (int i = 0; i < product.addOns!.length; i++) {
          if (itemController.currentMixMatchAddons[i]) {
            addonsCost += (product.addOns![i].price ?? 0) *
                (itemController.currentMixMatchAddonQty[i] ?? 1);
          }
        }
      }

      // Add base price if no variations exist
      // (variations replace base price, so only one or the other)
      if (product.foodVariations == null || product.foodVariations!.isEmpty) {
        price = product.price ?? 0;
      }

      itemController.updateMixMatchProduct(product, price, addonsCost);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variations
        if (product.foodVariations != null &&
            product.foodVariations!.isNotEmpty) ...[
          Text('variations'.tr,
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: Colors.black)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.foodVariations!.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, vIndex) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(product.foodVariations![vIndex].name ?? '',
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Colors.black)),
                        if (product.foodVariations![vIndex].required == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('(${'required'.tr})',
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: Dimensions.fontSizeSmall)),
                          ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ...List.generate(
                        product.foodVariations![vIndex].variationValues
                                ?.length ??
                            0, (valIndex) {
                      bool isSelected = itemController
                              .currentMixMatchVariations[vIndex][valIndex] ??
                          false;
                      return InkWell(
                        onTap: () {
                          itemController.setMixMatchVariationIndex(
                              vIndex, valIndex, product);
                          calculateAndSave();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 20,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                                child: Text(
                                    product.foodVariations![vIndex]
                                            .variationValues![valIndex].level ??
                                        '',
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black),
                                    maxLines: 1)),
                            Text(
                                '+${PriceConverter.convertPrice(product.foodVariations![vIndex].variationValues![valIndex].optionPrice)}',
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.black)),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ]);
            },
          ),
        ],

        // Addons
        if (product.addOns != null && product.addOns!.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('addons'.tr,
                  style: robotoBold.copyWith(color: Colors.black)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSmall)),
                child: Text('optional'.tr,
                    style: robotoRegular.copyWith(
                        fontSize: 10, color: Theme.of(context).disabledColor)),
              )
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.addOns!.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              bool isSelected = itemController.currentMixMatchAddons[index];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  InkWell(
                    onTap: () {
                      itemController.addMixMatchAddOn(!isSelected, index);
                      calculateAndSave();
                    },
                    child: Row(children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons
                                .radio_button_off, // Using radio button style as requested but multi-select logic
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(product.addOns![index].name ?? '',
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black)),
                    ]),
                  ),
                  const Spacer(),
                  Text(
                      '+${PriceConverter.convertPrice(product.addOns![index].price)}',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black)),
                  if (isSelected) ...[
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withOpacity(0.2))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(children: [
                        InkWell(
                            onTap: () {
                              itemController.setMixMatchAddOnQuantity(
                                  false, index);
                              calculateAndSave();
                            },
                            child: Icon(Icons.remove,
                                size: 16,
                                color: Theme.of(context).disabledColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                              itemController.currentMixMatchAddonQty[index]
                                  .toString(),
                              style: robotoMedium.copyWith(fontSize: 12)),
                        ),
                        InkWell(
                            onTap: () {
                              itemController.setMixMatchAddOnQuantity(
                                  true, index);
                              calculateAndSave();
                            },
                            child: Icon(Icons.add,
                                size: 16,
                                color: Theme.of(context).primaryColor)),
                      ]),
                    ),
                  ]
                ]),
              );
            },
          ),
        ],

        // Confirm Selection Button
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Builder(builder: (context) {
          bool canConfirm = true;
          if (product.foodVariations != null &&
              product.foodVariations!.isNotEmpty) {
            bool anyVariationSelected = false;
            bool requiredMissing = false;

            for (int i = 0; i < product.foodVariations!.length; i++) {
              bool isRequired = product.foodVariations![i].required ?? false;
              bool variationSelected = false;

              if (itemController.currentMixMatchVariations.isNotEmpty &&
                  i < itemController.currentMixMatchVariations.length) {
                for (var val in itemController.currentMixMatchVariations[i]) {
                  if (val == true) {
                    variationSelected = true;
                    break;
                  }
                }
              }

              if (variationSelected) {
                anyVariationSelected = true;
              }

              if (isRequired && !variationSelected) {
                requiredMissing = true;
                break;
              }
            }

            // Button enabled ONLY if all required variations are selected AND at least one is chosen
            canConfirm = !requiredMissing && anyVariationSelected;
          }

          return CustomButton(
            buttonText: 'confirm_selection'.tr,
            onPressed: canConfirm
                ? () {
                    calculateAndSave();
                    itemController.collapseMixMatchProduct();
                  }
                : null,
          );
        }),
      ],
    );
  }

  double _calculateSelectedProductPrice(Item product,
      List<List<bool?>> variations, List<bool> addons, List<int?> addonQtys) {
    double price =
        (product.foodVariations != null && product.foodVariations!.isNotEmpty)
            ? 0
            : (product.price ?? 0);
    if (product.foodVariations != null && variations.isNotEmpty) {
      for (int i = 0; i < product.foodVariations!.length; i++) {
        if (i < variations.length) {
          for (int j = 0;
              j < product.foodVariations![i].variationValues!.length;
              j++) {
            if (j < variations[i].length && (variations[i][j] ?? false)) {
              price +=
                  product.foodVariations![i].variationValues![j].optionPrice ??
                      0;
            }
          }
        }
      }
    }
    if (product.addOns != null && addons.isNotEmpty) {
      for (int i = 0; i < product.addOns!.length; i++) {
        if (i < addons.length && addons[i]) {
          price += (product.addOns![i].price ?? 0) *
              (i < addonQtys.length ? (addonQtys[i] ?? 1) : 1);
        }
      }
    }
    return price;
  }

  Widget _buildBogoSelection(
      BuildContext context, ItemController itemController, Item item) {
    double? priceA;
    double? priceB;

    if (item.product != null &&
        itemController.selectedBogoProductAIndex != null) {
      Item productA = item.product![itemController.selectedBogoProductAIndex!];
      priceA = _calculateSelectedProductPrice(
          productA,
          itemController.selectedBogoVariationsA,
          itemController.selectedBogoAddonsA,
          itemController.selectedBogoAddonQtyA);
    }

    if (item.productB != null &&
        itemController.selectedBogoProductBIndex != null) {
      Item productB = item.productB![itemController.selectedBogoProductBIndex!];
      priceB = _calculateSelectedProductPrice(
          productB,
          itemController.selectedBogoVariationsB,
          itemController.selectedBogoAddonsB,
          itemController.selectedBogoAddonQtyB);
    }

    bool aIsFree = false;
    bool bIsFree = false;

    if (priceA != null && priceB != null) {
      if (priceA < priceB) {
        aIsFree = true;
      } else {
        bIsFree = true;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildBogoSection(
          context,
          itemController,
          item.product ?? [],
          itemController.selectedBogoProductAIndex,
          'first_selected_item'.tr,
          true,
          isFree: aIsFree),
      const SizedBox(height: Dimensions.paddingSizeDefault),
      _buildBogoSection(
          context,
          itemController,
          item.productB ?? [],
          itemController.selectedBogoProductBIndex,
          'second_selected_item'.tr,
          false,
          isFree: bIsFree),
      const SizedBox(height: Dimensions.paddingSizeDefault),
    ]);
  }

  Widget _buildBogoSection(BuildContext context, ItemController itemController,
      List<Item> products, int? selectedIndex, String title, bool isProductA,
      {bool isFree = false}) {
    bool isExpanded =
        (isProductA && _bogoAExpanded) || (!isProductA && _bogoBExpanded);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1)
        ],
      ),
      child: Column(children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isProductA) {
                _bogoAExpanded = !_bogoAExpanded;
                if (!_bogoAExpanded) {
                  _editingBogoAIndex = null;
                }
              } else {
                _bogoBExpanded = !_bogoBExpanded;
                if (!_bogoBExpanded) {
                  _editingBogoBIndex = null;
                }
              }
            });
          },
          child: Row(children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isProductA ? '1' : '2',
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                title,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: Colors.black),
              ),
            ),
            Text(
              isExpanded ? 'view'.tr : 'see_all'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons
                      .keyboard_arrow_down, // Changed icons to match 'See all' style usually assumes expansion
              size: 20,
              color: Theme.of(context).disabledColor,
            ),
          ]),
        ),
        if (selectedIndex != null && !isExpanded) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildBogoCard(context, products[selectedIndex], true, isProductA,
              itemController, isFree,
              showDetails: false, isConfirmed: true),
        ],
        if (isExpanded) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Divider(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              height: 1),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              bool isEditing =
                  (isProductA ? _editingBogoAIndex : _editingBogoBIndex) ==
                      index;
              bool isConfirmed = selectedIndex == index;
              return _buildBogoCard(context, products[index], isEditing,
                  isProductA, itemController, isConfirmed && isFree,
                  isConfirmed: isConfirmed);
            },
          ),
        ],
      ]),
    );
  }

  Widget _buildBogoCard(BuildContext context, Item product, bool isSelected,
      bool isProductA, ItemController itemController, bool isFree,
      {bool showDetails = true, bool isConfirmed = false}) {
    double addonsPrice = 0;
    bool hasVariations =
        product.foodVariations != null && product.foodVariations!.isNotEmpty;
    bool showSelectionUI = isConfirmed || (isSelected && !hasVariations);

    if (isSelected) {
      if (isProductA) {
        for (int i = 0; i < product.addOns!.length; i++) {
          if (i < itemController.selectedBogoAddonsA.length &&
              itemController.selectedBogoAddonsA[i]) {
            addonsPrice += (product.addOns![i].price ?? 0) *
                (i < itemController.selectedBogoAddonQtyA.length
                    ? (itemController.selectedBogoAddonQtyA[i] ?? 1)
                    : 1);
          }
        }
      } else {
        for (int i = 0; i < product.addOns!.length; i++) {
          if (i < itemController.selectedBogoAddonsB.length &&
              itemController.selectedBogoAddonsB[i]) {
            addonsPrice += (product.addOns![i].price ?? 0) *
                (i < itemController.selectedBogoAddonQtyB.length
                    ? (itemController.selectedBogoAddonQtyB[i] ?? 1)
                    : 1);
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
            color: showSelectionUI
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            width: showSelectionUI ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              int index = -1;
              if (isProductA) {
                index = itemController.item!.product!.indexOf(product);
                if (isConfirmed && !showDetails) {
                  itemController.selectBogoProductA(index);
                  setState(() {
                    _editingBogoAIndex = null;
                    _bogoAExpanded = true;
                  });
                } else {
                  setState(() {
                    if (_editingBogoAIndex == index) {
                      _editingBogoAIndex = null;
                    } else {
                      _editingBogoAIndex = index;
                      // Only initialize if product is NOT already confirmed
                      if (itemController.selectedBogoProductAIndex != index) {
                        itemController.initBogoProductA(index);
                      }
                    }
                  });
                }
              } else {
                index = itemController.item!.productB!.indexOf(product);
                if (isConfirmed && !showDetails) {
                  itemController.selectBogoProductB(index);
                  setState(() {
                    _editingBogoBIndex = null;
                    _bogoBExpanded = true;
                  });
                } else {
                  setState(() {
                    if (_editingBogoBIndex == index) {
                      _editingBogoBIndex = null;
                    } else {
                      _editingBogoBIndex = index;
                      // Only initialize if product is NOT already confirmed
                      if (itemController.selectedBogoProductBIndex != index) {
                        itemController.initBogoProductB(index);
                      }
                    }
                  });
                }
              }
            },
            borderRadius: BorderRadius.vertical(
                top: const Radius.circular(Dimensions.radiusLarge),
                bottom:
                    Radius.circular(isSelected ? 0 : Dimensions.radiusLarge)),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: CustomImage(
                    image: product.imageFullUrl ?? '',
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? '',
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              (() {
                                // Only show base + variation price (no addons)
                                double basePrice =
                                    _calculateSelectedProductPrice(
                                        product,
                                        isProductA
                                            ? itemController
                                                .selectedBogoVariationsA
                                            : itemController
                                                .selectedBogoVariationsB,
                                        [], // no addons
                                        []);

                                return basePrice > 0
                                    ? PriceConverter.convertPrice(basePrice)
                                    : (product.foodVariations != null &&
                                            product.foodVariations!.isNotEmpty)
                                        ? 'enter_voucher_price'.tr
                                        : PriceConverter.convertPrice(0);
                              }()),
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.black),
                            ),
                            if (isFree) ...[
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF00B894),
                                    Color(0xFF55EFC4)
                                  ]),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                child: Text(
                                  'FREE',
                                  style: robotoBold.copyWith(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ]),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                // Selection Indicator + optional Add-Ons label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showSelectionUI
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(
                              color: showSelectionUI
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              width: 2)),
                    ),
                    if (!showDetails && isConfirmed && addonsPrice > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        '+ ${PriceConverter.convertPrice(addonsPrice)} Add-Ons',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                )
              ]),
            ),
          ),
          // For Product A or selected Product B, show details if isSelected
          // Product B must be tapped first to initialize variation arrays
          if (isSelected && showDetails) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text('description'.tr,
                        style: robotoBold.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(product.description!,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const Divider(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                  _buildBogoOptions(
                      context, itemController, product, isProductA),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Builder(builder: (context) {
                    bool canConfirm = true;
                    if (product.foodVariations != null &&
                        product.foodVariations!.isNotEmpty) {
                      List<List<bool?>> variations = isProductA
                          ? itemController.selectedBogoVariationsA
                          : itemController.selectedBogoVariationsB;

                      bool anyVariationSelected = false;
                      bool requiredMissing = false;

                      for (int i = 0; i < product.foodVariations!.length; i++) {
                        bool isRequired =
                            product.foodVariations![i].required ?? false;
                        bool variationSelected = variations.isNotEmpty &&
                            i < variations.length &&
                            variations[i].contains(true);

                        if (variationSelected) {
                          anyVariationSelected = true;
                        }

                        if (isRequired && !variationSelected) {
                          requiredMissing = true;
                          break;
                        }
                      }

                      // Button is enabled ONLY if (all required are met) AND (at least one variation is actually selected)
                      canConfirm = !requiredMissing && anyVariationSelected;
                    }

                    return CustomButton(
                      buttonText: 'confirm_selection'.tr,
                      onPressed: canConfirm
                          ? () {
                              setState(() {
                                int index = -1;
                                if (isProductA) {
                                  index = itemController.item!.product!
                                      .indexOf(product);
                                  itemController.confirmBogoProductA(index);
                                  _editingBogoAIndex = null;
                                  _bogoAExpanded = false;
                                } else {
                                  index = itemController.item!.productB!
                                      .indexOf(product);
                                  itemController.confirmBogoProductB(index);
                                  _editingBogoBIndex = null;
                                  _bogoBExpanded = false;
                                }
                              });
                            }
                          : null,
                    );
                  })
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBogoOptions(BuildContext context, ItemController itemController,
      Item product, bool isProductA) {
    List<List<bool?>> selectedVariations = isProductA
        ? itemController.selectedBogoVariationsA
        : itemController.selectedBogoVariationsB;
    List<bool> selectedAddons = isProductA
        ? itemController.selectedBogoAddonsA
        : itemController.selectedBogoAddonsB;
    List<int?> selectedAddonQty = isProductA
        ? itemController.selectedBogoAddonQtyA
        : itemController.selectedBogoAddonQtyB;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Variations
      if (product.foodVariations != null &&
          product.foodVariations!.isNotEmpty) ...[
        Text('variations'.tr,
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Colors.black)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.foodVariations!.length,
          itemBuilder: (context, vIndex) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.foodVariations![vIndex].name ?? '',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.black)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: product
                            .foodVariations![vIndex].variationValues?.length ??
                        0,
                    itemBuilder: (context, valIndex) {
                      bool isSelected = vIndex < selectedVariations.length &&
                          valIndex < selectedVariations[vIndex].length &&
                          (selectedVariations[vIndex][valIndex] ?? false);
                      return InkWell(
                        onTap: () => itemController.setBogoVariationIndex(
                            vIndex, valIndex, product, isProductA),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 18,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                                child: Text(
                                    product.foodVariations![vIndex]
                                            .variationValues![valIndex].level ??
                                        '',
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black),
                                    maxLines: 1)),
                            Text(
                                PriceConverter.convertPrice(product
                                    .foodVariations![vIndex]
                                    .variationValues![valIndex]
                                    .optionPrice),
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.black)),
                          ]),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ]);
          },
        ),
      ],

      // Addons
      if (product.addOns != null && product.addOns!.isNotEmpty) ...[
        Text('addons'.tr,
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Colors.black)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.addOns!.length,
          itemBuilder: (context, aIndex) {
            bool isSelected =
                aIndex < selectedAddons.length && selectedAddons[aIndex];
            return Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                InkWell(
                  onTap: () => itemController.addBogoAddOn(
                      !isSelected, aIndex, isProductA),
                  child: Row(children: [
                    Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(product.addOns![aIndex].name ?? '',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.black)),
                  ]),
                ),
                const Spacer(),
                Text(PriceConverter.convertPrice(product.addOns![aIndex].price),
                    style: robotoBold.copyWith(color: Colors.black)),
                if (isSelected) ...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Row(children: [
                    InkWell(
                      onTap: () => itemController.setBogoAddOnQuantity(
                          false, aIndex, isProductA),
                      child: Icon(Icons.remove_circle_outline,
                          color: Theme.of(context).primaryColor, size: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                          (aIndex < selectedAddonQty.length
                                  ? selectedAddonQty[aIndex]
                                  : 1)
                              .toString(),
                          style: robotoMedium),
                    ),
                    InkWell(
                      onTap: () => itemController.setBogoAddOnQuantity(
                          true, aIndex, isProductA),
                      child: Icon(Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ]),
                ],
              ]),
            );
          },
        ),
      ],
    ]);
  }

  Widget _buildVoucherSettings(Item item, BuildContext context) {
    if (item.settings == null) return const SizedBox();

    List<Widget> content = [];

    // 1. Validity Period
    if (item.settings!.validityPeriod != null &&
        (item.settings!.validityPeriod!.start != null ||
            item.settings!.validityPeriod!.end != null)) {
      content.add(_buildSettingItem(context, 'validity_period'.tr,
          '${item.settings!.validityPeriod!.start ?? ""} - ${item.settings!.validityPeriod!.end ?? ""}'));
    }

    // 2. Specific Days of Week
    if (item.settings!.specificDaysOfWeek != null) {
      List<String> validDays = [];
      SpecificDaysOfWeek days = item.settings!.specificDaysOfWeek!;

      void addDay(String name, DaySchedule? day) {
        if (day != null && day.start != null) {
          validDays.add(
              '$name${day.start != null ? " (${day.start} - ${day.end ?? ""})" : ""}');
        }
      }

      addDay('Monday', days.monday);
      addDay('Tuesday', days.tuesday);
      addDay('Wednesday', days.wednesday);
      addDay('Thursday', days.thursday);
      addDay('Friday', days.friday);
      addDay('Saturday', days.saturday);
      addDay('Sunday', days.sunday);

      if (validDays.isNotEmpty) {
        content.add(
            _buildSettingItem(context, 'valid_on'.tr, validDays.join(', ')));
      }
    }

    // 3. Holiday Occasions
    if (item.settings!.holidaysOccasions != null &&
        item.settings!.holidaysOccasions!.isNotEmpty) {
      for (var holiday in item.settings!.holidaysOccasions!) {
        if (holiday.nameEn != null || holiday.startDate != null) {
          content.add(_buildSettingItem(context, 'holiday_restrictions'.tr,
              '${holiday.nameEn ?? ""}${holiday.startDate != null ? " (${holiday.startDate}${holiday.endDate != null && holiday.endDate != holiday.startDate ? " - ${holiday.endDate}" : ""})" : ""}'));
        }
      }
    }

    // 4. Custom Blackout Dates
    if (item.settings!.customBlackoutDates != null &&
        item.settings!.customBlackoutDates!.isNotEmpty) {
      for (var date in item.settings!.customBlackoutDates!) {
        if (date.date != null || date.description != null) {
          content.add(_buildSettingItem(context, 'blackout_dates'.tr,
              '${date.description ?? ""}${date.date != null ? " (${date.date})" : ""}'));
        }
      }
    }

    // 5. Age Restriction
    if (item.settings!.ageRestriction != null &&
        item.settings!.ageRestriction!.isNotEmpty) {
      for (var restriction in item.settings!.ageRestriction!) {
        if (restriction.text != null) {
          content.add(_buildSettingItem(
              context, 'age_restriction'.tr, restriction.text!));
        }
      }
    }

    // 6. Group Size
    if (item.settings!.groupSizeText != null ||
        item.settings!.groupSizeRequirement != null) {
      content.add(_buildSettingItem(
          context,
          'group_size_required'.tr,
          item.settings!.groupSizeText ??
              'Minimum ${item.settings!.groupSizeRequirement} People'));
    }

    // 7. Offer Validity
    if (item.settings!.offerValidityText != null ||
        item.settings!.offerValidityAfterPurchase != null) {
      content.add(_buildSettingItem(
          context,
          'offer_validity'.tr,
          item.settings!.offerValidityText != null
              ? '${item.settings!.offerValidityText} Days'
              : '${item.settings!.offerValidityAfterPurchase} Days'));
    }

    // 8. Usage Limits
    if (item.settings!.usageLimitPerUser != null &&
        item.settings!.usageLimitPerUser!.value != null) {
      content.add(_buildSettingItem(context, 'usage_limit_per_user'.tr,
          '${item.settings!.usageLimitPerUser!.value} ${item.settings!.usageLimitPerUser!.period ?? ""}'));
    }
    if (item.settings!.usageLimitPerStore != null &&
        item.settings!.usageLimitPerStore!.value != null) {
      content.add(_buildSettingItem(context, 'usage_limit_per_store'.tr,
          '${item.settings!.usageLimitPerStore!.value} ${item.settings!.usageLimitPerStore!.period ?? ""}'));
    }

    // 9. General Restrictions
    if (item.settings!.generalRestrictions != null &&
        item.settings!.generalRestrictions!.isNotEmpty) {
      for (var restriction in item.settings!.generalRestrictions!) {
        if (restriction.nameEn != null) {
          content.add(_buildSettingItem(
              context, 'general_restrictions'.tr, restriction.nameEn!));
        }
      }
    }

    if (content.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Text('usage_terms'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              Text('view'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ],
          ),
          childrenPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          children: content,
        ),
      ),
    );
  }

  Widget _buildVoucherTerms(Item item, BuildContext context) {
    if (item.termAndConditionIds == null || item.termAndConditionIds!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Text('Terms & Condition'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              Text('view'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ],
          ),
          childrenPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          children: item.termAndConditionIds!.map((term) {
            return Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (term.title != null && term.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(term.title!,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault)),
                    ),
                  if (term.description != null && term.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(term.description!,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.7))),
                    ),

                  // Time & Day
                  if (term.days != null && term.days!.isNotEmpty)
                    _buildSettingItem(
                        context, 'valid_on'.tr, term.days!.join(', ')),
                  if (term.timeFrom != null && term.timeTo != null)
                    _buildSettingItem(context, 'time'.tr,
                        '${term.timeFrom} - ${term.timeTo}'),
                  if (term.validFromDate != null || term.validUntilDate != null)
                    _buildSettingItem(context, 'validity'.tr,
                        '${term.validFromDate ?? ""} - ${term.validUntilDate ?? ""}'),

                  // Holidays
                  if (term.holidayRestrictions != null &&
                      term.holidayRestrictions!.isNotEmpty)
                    _buildSettingItem(context, 'holiday_restrictions'.tr,
                        term.holidayRestrictions!.join(', ')),
                  if (term.blackoutDates != null &&
                      term.blackoutDates!.isNotEmpty)
                    _buildSettingItem(
                        context, 'blackout_dates'.tr, term.blackoutDates!),
                  if (term.specialOccasions != null &&
                      term.specialOccasions!.isNotEmpty)
                    _buildSettingItem(context, 'special_occasions'.tr,
                        term.specialOccasions!.join(', ')),

                  // Usage Limits
                  if (term.limitPerUser != null)
                    _buildSettingItem(
                        context, 'limit_per_user'.tr, term.limitPerUser!),
                  if (term.limitPeriod != null)
                    _buildSettingItem(context, 'period'.tr, term.limitPeriod!),
                  if (term.minPurchAccount != null)
                    _buildSettingItem(
                        context, 'min_purchase'.tr, term.minPurchAccount!),
                  if (term.maxDiscountAmount != null)
                    _buildSettingItem(
                        context, 'max_discount'.tr, term.maxDiscountAmount!),
                  if (term.advanceBookingRequired != null)
                    _buildSettingItem(context, 'advance_booking'.tr,
                        '${term.advanceBookingRequired} days'),
                  if (term.groupSizeRequired != null)
                    _buildSettingItem(
                        context, 'group_size'.tr, term.groupSizeRequired!),

                  // Location
                  if (term.venueTypes != null && term.venueTypes!.isNotEmpty)
                    _buildSettingItem(
                        context, 'venue_types'.tr, term.venueTypes!.join(', ')),
                  if (term.specificBranch != null &&
                      term.specificBranch!.isNotEmpty)
                    _buildSettingItem(
                        context, 'branch'.tr, term.specificBranch!),
                  if (term.city != null && term.city!.isNotEmpty)
                    _buildSettingItem(context, 'city'.tr, term.city!),
                  if (term.deliveryRadius != null)
                    _buildSettingItem(context, 'delivery_radius'.tr,
                        '${term.deliveryRadius} km'),

                  // Membership
                  if (term.customerType != null)
                    _buildSettingItem(
                        context, 'customer_type'.tr, term.customerType!),
                  if (term.ageRestriction != null)
                    _buildSettingItem(
                        context, 'age_restriction'.tr, term.ageRestriction!),
                  if (term.minMembershipRadius != null)
                    _buildSettingItem(context, 'membership_duration'.tr,
                        term.minMembershipRadius!),

                  // Policies
                  if (term.restrictionTypes != null &&
                      term.restrictionTypes!.isNotEmpty)
                    _buildSettingItem(context, 'restrictions'.tr,
                        term.restrictionTypes!.join(', ')),
                  if (term.cancellationPolicy != null)
                    _buildSettingItem(context, 'cancellation_policy'.tr,
                        term.cancellationPolicy!),
                  if (term.excludedProduct != null &&
                      term.excludedProduct!.isNotEmpty)
                    _buildSettingItem(
                        context, 'excluded_products'.tr, term.excludedProduct!),
                  if (term.surchargeAccount != null)
                    _buildSettingItem(
                        context, 'surcharge_amount'.tr, term.surchargeAccount!),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  TextSpan(
                    text: value,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(Item item, BuildContext context) {
    if (item.howItWorks == null || item.howItWorks!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          title: Row(
            children: [
              Text('how_to_use_card'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              Text('view'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ],
          ),
          childrenPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          children: item.howItWorks!.map((howItWorks) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (howItWorks.guideTitle != null)
                  Text(howItWorks.guideTitle!,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                if (howItWorks.sections != null)
                  ...howItWorks.sections!.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.title != null)
                          Text(section.title!,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall)),
                        if (section.steps != null)
                          ...section.steps!
                              .map((step) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("• "),
                                        Expanded(
                                            child: Text(step,
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .disabledColor))),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                    );
                  }).toList(),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomerReviewSection(Item item, BuildContext context) {
    if (item.reviews == null || item.reviews!.isEmpty) {
      return const SizedBox();
    }

    List<Reviews> filteredReviews = item.reviews!
        .where((review) => review.comment != null && review.comment!.isNotEmpty)
        .toList();

    if (filteredReviews.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          title: Row(
            children: [
              Text('Review'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              Text('view'.tr,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ],
          ),
          childrenPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          children: filteredReviews.map((review) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: CustomImage(
                      image: review.customer?.imageFullUrl ?? '',
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      placeholder: Images.placeholder,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${review.customer?.fName ?? ''} ${review.customer?.lName ?? ''}'
                              .trim(),
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          review.comment!,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVoucherHeader(
      BuildContext context,
      Item item,
      double? initialDiscount,
      String? discountType,
      double? price,
      double priceWithDiscount) {
    const double cutoutY = 220;
    const double radius = 10;
    bool isGift = item.bundleType == 'gift';

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        if (!isGift)
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: CustomImage(
                    image: item.imageFullUrl ?? '',
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dynamic In-Store Tag with Gradient
              Positioned(
                top: 0,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1ABC9C), Color(0xFFA8E063)],
                      stops: [0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    item.voucherIds ?? (item.type?.toUpperCase() ?? 'VOUCHER'),
                    style:
                        robotoBold.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              // Rating and Favorite icons
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraSmall,
                      vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 15),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        (item.avgRating ?? 0).toString(),
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GetBuilder<FavouriteController>(
                  builder: (wishList) {
                    return InkWell(
                      onTap: () {
                        if (AuthHelper.isLoggedIn()) {
                          wishList.wishItemIdList.contains(item.id)
                              ? wishList.removeFromFavouriteList(item.id, false,
                                  getXSnackBar: true)
                              : wishList.addToFavouriteList(item, null, false,
                                  getXSnackBar: true);
                        } else {
                          showCustomSnackBar('you_are_not_logged_in'.tr,
                              getXSnackBar: true);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .cardColor
                              .withValues(alpha: 0.8),
                        ),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Icon(
                          wishList.wishItemIdList.contains(item.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: wishList.wishItemIdList.contains(item.id)
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        if (!isGift)
          // Dashed line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: HorizontalDashedLinePainter(
                color: const Color(0xFF1ABC9C).withValues(
                    alpha: (item.voucherIds != null &&
                            item.voucherIds!.startsWith('0'))
                        ? 0.7
                        : (item.voucherIds != null &&
                                item.voucherIds!.startsWith('1')
                            ? 0.3
                            : 0.5)),
                dashWidth: 10,
                dashSpace: 6,
                strokeWidth: 5.0,
              ),
            ),
          ),

        // Content Section
        Padding(
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            top: isGift ? Dimensions.paddingSizeDefault : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name ?? '',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (initialDiscount != null && initialDiscount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1ABC9C), Color(0xFFA8E063)],
                          stops: [0.7, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (item.offerType?.toLowerCase() == 'cash back')
                                ? 'cashback_uppercase'.tr
                                : (item.bundleType == 'gift'
                                    ? 'bonus_uppercase'.tr
                                    : 'save_uppercase'.tr),
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                                color: Colors.white, fontSize: 10),
                          ),
                          Text(
                            discountType == 'percent'
                                ? '${initialDiscount % 1 == 0 ? initialDiscount.toStringAsFixed(0) : initialDiscount.toStringAsFixed(1)}%'
                                : PriceConverter.convertPrice(initialDiscount),
                            textAlign: TextAlign.center,
                            style: robotoBlack.copyWith(
                                color: Colors.white, fontSize: 16, height: 1.0),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                (item.type == 'voucher' && item.bundleType == 'simple x')
                    ? PriceConverter.convertPrice(
                        item.actualPrice ?? item.price)
                    : 'enter_voucher_price'.tr,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: Colors.black),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Description Label
              Text(
                'description'.tr,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault, color: Colors.black),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                item.description ?? '',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault, color: Colors.black),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Divider(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  thickness: 1),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Store Info at Bottom
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.2),
                          width: 1.5),
                    ),
                    child: ClipOval(
                      child: CustomImage(
                        image: item.store?.logoFullUrl ?? '',
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Text(
                      item.store?.name ?? '',
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          top: Dimensions.paddingSizeSmall,
          bottom: 0),
      child: isGift
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    width: 1),
              ),
              child: content,
            )
          : ClipPath(
              clipper: ScallopedEdgeClipper(cutoutY: cutoutY, radius: radius),
              child: CustomPaint(
                foregroundPainter: ScallopedBorderPainter(
                  cutoutY: cutoutY,
                  radius: radius,
                  strokeWidth: 5.0,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1ABC9C), Color(0xFFA8E063)],
                    stops: [0.7, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: content,
                ),
              ),
            ),
    );
  }

  Widget _buildFlatVoucherUI(
      BuildContext context, ItemController itemController) {
    Item? item = itemController.item;
    if (item == null) return const SizedBox();

    const double cutoutY = 220;
    const double radius = 10;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Standardized Voucher Card (Gradient Border Wrapping Image, Title, Description, and Store)
                    Container(
                      margin: EdgeInsets.zero,
                      child: ClipPath(
                        clipper: ScallopedEdgeClipper(
                            cutoutY: cutoutY, radius: radius),
                        child: CustomPaint(
                          foregroundPainter: ScallopedBorderPainter(
                            cutoutY: cutoutY,
                            radius: radius,
                            strokeWidth: 5.0,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A2B), Color(0xFFFFD54F)],
                              stops: [0.7, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Section
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusLarge),
                                        child: CustomImage(
                                          image: item.imageFullUrl ?? '',
                                          width: double.infinity,
                                          height: 190,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Flat Discount Badge
                                    Positioned(
                                      top: 0,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF8A2B),
                                              Color(0xFFFFD54F)
                                            ],
                                            stops: [0.7, 1.0],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          'Flat Discount'.toUpperCase(),
                                          style: robotoBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    // Rating
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions
                                                .paddingSizeExtraSmall,
                                            vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .cardColor
                                              .withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 15),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall),
                                            Text(
                                              (item.avgRating ?? 0).toString(),
                                              style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Favorite
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: GetBuilder<FavouriteController>(
                                        builder: (wishList) {
                                          return InkWell(
                                            onTap: () {
                                              if (AuthHelper.isLoggedIn()) {
                                                wishList.wishItemIdList
                                                        .contains(item.id)
                                                    ? wishList
                                                        .removeFromFavouriteList(
                                                            item.id, false,
                                                            getXSnackBar: true)
                                                    : wishList
                                                        .addToFavouriteList(
                                                            item, null, false,
                                                            getXSnackBar: true);
                                              } else {
                                                showCustomSnackBar(
                                                    'you_are_not_logged_in'.tr,
                                                    getXSnackBar: true);
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withValues(alpha: 0.8),
                                              ),
                                              padding: const EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              child: Icon(
                                                wishList.wishItemIdList
                                                        .contains(item.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: wishList.wishItemIdList
                                                        .contains(item.id)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .disabledColor,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Dashed line
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 5),
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 1),
                                    painter: HorizontalDashedLinePainter(
                                      color: const Color(0xFFFF8A2B)
                                          .withValues(alpha: 0.5),
                                      dashWidth: 10,
                                      dashSpace: 6,
                                      strokeWidth: 5.0,
                                    ),
                                  ),
                                ),

                                // Content Part
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeDefault),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name ?? '',
                                              style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (_flatVoucherBonus > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF8A2B),
                                                    Color(0xFFFFD54F)
                                                  ],
                                                  stops: [0.7, 1.0],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusLarge),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2))
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    (item.offerType
                                                                ?.toLowerCase() ==
                                                            'cash back')
                                                        ? 'cashback_uppercase'
                                                            .tr
                                                        : 'save_uppercase'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: robotoBold.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                  Text(
                                                    '${_flatVoucherBonus % 1 == 0 ? _flatVoucherBonus.toStringAsFixed(0) : _flatVoucherBonus.toStringAsFixed(1)}%',
                                                    textAlign: TextAlign.center,
                                                    style: robotoBlack.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        height: 1.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall),
                                      Row(
                                        children: [
                                          if (item.price != null &&
                                              item.price! > 0)
                                            Text(
                                              PriceConverter.convertPrice(
                                                  item.price),
                                              style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: Dimensions.paddingSizeSmall),

                                      // Description Label
                                      Text(
                                        'description'.tr,
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        item.description ?? '',
                                        style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                      Divider(
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withValues(alpha: 0.3),
                                          thickness: 1),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),

                                      // Store Info
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.2),
                                                  width: 1.5),
                                            ),
                                            child: ClipOval(
                                              child: CustomImage(
                                                image:
                                                    item.store?.logoFullUrl ??
                                                        '',
                                                height: 45,
                                                width: 45,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeDefault),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item.storeName ?? '',
                                                    style: robotoBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              Dimensions.paddingSizeDefault),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Input Container
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(
                        children: [
                          Text('enter_the_final_amount_shown_on_your_bill'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.black)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                                fontSize: 24,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '\$00.00',
                            ),
                            onChanged: (val) =>
                                _calculateFlatVoucherValues(val, item),
                          ),
                          const Divider(),

                          // Your Deal
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('your_deal'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black)),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  _flatVoucherBonus > 0
                                      ? '${_flatVoucherBonus.toStringAsFixed(0)}% off total bill'
                                      : 'no_discount_applied'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Colors.black),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                // Display discount configuration tiers
                                if (item.bonusConfiguration != null &&
                                    item.bonusConfiguration!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'available_discount_tiers'.tr,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      ...item.bonusConfiguration!.map((config) {
                                        double enteredAmount = double.tryParse(
                                                _amountController.text) ??
                                            0;
                                        double minAmt = double.tryParse(
                                                config.minAmount ?? '0') ??
                                            0;
                                        double maxAmt = double.tryParse(
                                                config.maxAmount ?? '0') ??
                                            0;
                                        double bonus = double.tryParse(
                                                config.bonusPercentage ??
                                                    '0') ??
                                            0;

                                        // Check if entered amount is in this tier
                                        bool isActiveTier =
                                            enteredAmount >= minAmt &&
                                                enteredAmount <= maxAmt;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isActiveTier
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                size: 14,
                                                color: isActiveTier
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .disabledColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${PriceConverter.convertPrice(minAmt)} - ${PriceConverter.convertPrice(maxAmt)}: ${bonus.toStringAsFixed(0)}% off',
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeExtraSmall,
                                                    color: isActiveTier
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .disabledColor,
                                                    fontWeight: isActiveTier
                                                        ? FontWeight.bold
                                                        : FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  )
                                else
                                  Text(
                                    'no_minimum_spend'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor),
                                  ),
                                // Validation feedback
                                if (_amountController.text.isNotEmpty &&
                                    !_isFlatVoucherValid(item))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _selectedBranchId == null
                                          ? 'Please select an outlet below'
                                          : 'Amount is outside valid ranges',
                                      style: robotoRegular.copyWith(
                                          color: Colors.red,
                                          fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Redeemable at X outlets
                    if (item.branches != null && item.branches!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'redeemable_at_x_outlets'.trParams({
                                      'count': item.branches!.length.toString()
                                    }),
                                    style: robotoMedium.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.fontSizeLarge))),
                            if (_selectedBranch == null &&
                                !_isDeliveryOrPickup(item))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text('required'.tr,
                                    style: robotoRegular.copyWith(
                                        color: Colors.red, fontSize: 10)),
                              ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                // Show branches dialog
                                Get.dialog(Dialog(
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    height: 400,
                                    child: Column(
                                      children: [
                                        Text('select_outlet'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge)),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeDefault),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: item.branches!.length,
                                            itemBuilder: (context, index) {
                                              Store branch =
                                                  item.branches![index];
                                              bool available =
                                                  _isBranchAvailable(branch);
                                              String? activeAt;
                                              if (!available &&
                                                  branch.availability != null) {
                                                for (var a
                                                    in branch.availability!) {
                                                  if (a.status ==
                                                      'not_available') {
                                                    activeAt = a.activeAt;
                                                    break;
                                                  }
                                                }
                                              }

                                              return InkWell(
                                                onTap: available
                                                    ? () {
                                                        setState(() {
                                                          _selectedBranch =
                                                              branch;
                                                          _selectedBranchId =
                                                              branch.id;
                                                        });
                                                        Navigator.pop(context);
                                                      }
                                                    : null,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Opacity(
                                                        opacity:
                                                            available ? 1 : 0.5,
                                                        child: ClipOval(
                                                          child: CustomImage(
                                                            image: branch
                                                                    .logoFullUrl ??
                                                                '',
                                                            height: 40,
                                                            width: 40,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              available
                                                                  ? (branch
                                                                          .name ??
                                                                      '')
                                                                  : '${branch.name ?? ''} (Not Available)',
                                                              style: robotoMedium.copyWith(
                                                                  color: available
                                                                      ? null
                                                                      : Theme.of(
                                                                              context)
                                                                          .disabledColor),
                                                            ),
                                                            Text(
                                                              available
                                                                  ? (branch
                                                                          .address ??
                                                                      '')
                                                                  : (activeAt !=
                                                                          null
                                                                      ? 'Available at: $activeAt'
                                                                      : 'currently_unavailable'
                                                                          .tr),
                                                              style: robotoRegular.copyWith(
                                                                  fontSize: 12,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (available &&
                                                          _selectedBranchId ==
                                                              branch.id)
                                                        const Icon(
                                                            Icons.check_circle,
                                                            color:
                                                                Colors.green),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                              },
                              child: Row(
                                children: [
                                  Text(_selectedBranch?.name ?? 'See all',
                                      style: robotoRegular.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildVoucherSettings(item, context),
                    _buildVoucherTerms(item, context),
                    _buildHowItWorks(item, context),
                    _buildCustomerReviewSection(item, context),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ],
              ),
              child: GetBuilder<CartController>(builder: (cartController) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('total_amount'.tr.toUpperCase(),
                              style: robotoRegular.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).disabledColor)),
                          Row(
                            children: [
                              if (_amountController.text.isNotEmpty)
                                Text(
                                  _formatPrice(
                                      double.tryParse(_amountController.text) ??
                                          0),
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              if (_amountController.text.isNotEmpty)
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                              Text(_formatPrice(_flatVoucherPrice),
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeOverLarge,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                          if (item.availabilityForCurrentUser?.status ==
                              'not_available')
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                'out_of_stock'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          if (item.availabilityForCurrentUser?.userUsage !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                '${'remaining'.tr}: ${item.availabilityForCurrentUser!.userUsage!.remaining ?? 0}',
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                    ),
                    CustomButton(
                      width: 150,
                      buttonText: 'pay_now'.tr,
                      isLoading: cartController.isLoading,
                      onPressed: () async {
                        if (!_checkAvailability(item)) {
                          _showAvailabilityDialog(
                              item.availabilityForCurrentUser?.msg ??
                                  'Item is not available');
                          return;
                        }

                        if (!(_isFlatVoucherValid(item) &&
                            _flatVoucherPrice > 0 &&
                            (item.branches == null ||
                                item.branches!.isEmpty ||
                                _anyBranchAvailable(item)))) {
                          return;
                        }

                        final CartController cc = Get.find<CartController>();

                        // Step 1: Force a single refresh before checking for existing items
                        await cc.getCartDataOnline();

                        // Step 2: Remove any existing item with same item.id (one attempt is enough)
                        try {
                          final existingItem = cc.cartList.firstWhere(
                            (c) => c.item?.id == item.id,
                          );
                          if (existingItem.id != null) {
                            await cc.removeCartItemOnline(existingItem.id!);
                          }
                        } catch (_) {}

                        String cartGroup =
                            (Random().nextInt(90000000) + 10000000).toString();

                        bool isCancelled = false;
                        Get.dialog(
                          OrderStatusDialog(cartGroupId: cartGroup),
                          barrierDismissible: false,
                        ).then((result) {
                          if (result == 'cancelled') {
                            isCancelled = true;
                          }
                        });

                        bool added = await _addFlatVoucherToCartWithGroup(
                            item, itemController, cartGroup);

                        if (!added) {
                          if (Get.isDialogOpen ?? false) {
                            Navigator.pop(context);
                          }
                          return;
                        }

                        // Step 3: Minimal cleanup if cancelled
                        if (isCancelled || !(Get.isDialogOpen ?? true)) {
                          cc.resetLoading();

                          // Just do one background cleanup check after a short delay
                          // Controller polling will handle the list update
                          Future.delayed(const Duration(seconds: 2), () async {
                            print(
                                '====> [ITEM_BOTTOM_SHEET] Background cleanup check for cartGroup: $cartGroup');
                            await cc.getCartDataOnline();
                            try {
                              final addedItem = cc.cartList.firstWhere(
                                (c) => c.cartGroupId == cartGroup,
                              );
                              if (addedItem.id != null) {
                                print(
                                    '====> [ITEM_BOTTOM_SHEET] Found trailing item ID: ${addedItem.id}. Removing...');
                                await cc.removeCartItemOnline(addedItem.id!);
                              }
                            } catch (_) {
                              print(
                                  '====> [ITEM_BOTTOM_SHEET] No trailing item found for $cartGroup');
                              // If not found yet, it's okay, next poll will show it and user can try again
                              // or we could retry once more here if we really wanted to.
                            }
                          });
                        }
                      },
                    ),
                  ],
                );
              }),
            )
          ],
        ),
      ],
    );
  }

  Future<bool> _addFlatVoucherToCartWithGroup(
      Item item, ItemController itemController, String cartGroup) async {
    double amount = double.tryParse(_amountController.text) ?? 0;

    Item itemToSend = item;
    if (_selectedBranch != null) {
      Map<String, dynamic> json = item.toJson();
      json['store_id'] = _selectedBranch!.id;
      json['store_name'] = _selectedBranch!.name;
      itemToSend = Item.fromJson(json);
    }

    print('=====> Adding Flat Voucher to Cart (Online Sync)');
    print(
        '=====> Amount: $amount, Discount: $_flatVoucherDiscount, Final Price: $_flatVoucherPrice');
    print(
        '=====> Selected Store: ${_selectedBranch?.name} (ID: ${_selectedBranchId})');
    print('=====> Cart Group: $cartGroup');

    // Determine if this is a cash_back or direct_discount voucher
    bool isCashBack = item.discountType == 'cash_back';

    // For cash_back: user pays full amount (cashback given later)
    // For direct_discount: user pays discounted price immediately
    String priceToSend =
        isCashBack ? amount.toString() : _flatVoucherPrice.toString();

    OnlineCart onlineCart = OnlineCart(
      null, // cartId
      item.id, // itemId
      null, // itemCampaignId
      priceToSend, // price
      '', // variant
      null, // variation (List<Variation>)
      [], // variations (List<OrderVariation>)
      1, // quantity
      [], // addOnIds
      [], // addOns
      [], // addOnQtys
      'Item', // model
      itemType: 'Item',
      cartGroup: cartGroup,
      storeId: _selectedBranchId,
      giftDetails: null,
      timeout: 300, // 5 minutes
      discountAmount: _flatVoucherDiscount > 0 ? _flatVoucherDiscount : null,
      totalPrice: amount, // always full entered amount
      offerType: item.offerType, // Use the correct offer type from response
    );

    bool success = await Get.find<CartController>().addToCartOnline(onlineCart);

    if (success) {
      showCustomSnackBar('Flat voucher added to cart!', isError: false);
    }

    return success;
  }

  bool _isBranchAvailable(Store branch) {
    if (branch.status == 0) return false;
    if (branch.availability != null && branch.availability!.isNotEmpty) {
      for (var a in branch.availability!) {
        if (a.status == 'not_available') return false;
      }
    }
    return true;
  }

  bool _anyBranchAvailable(Item item) {
    if (item.branches == null || item.branches!.isEmpty)
      return true; // Items without branches are assumed available
    for (var b in item.branches!) {
      if (_isBranchAvailable(b)) return true;
    }
    return false;
  }
}

class AddonView extends StatelessWidget {
  final Item item;
  final ItemController itemController;
  const AddonView(
      {super.key, required this.item, required this.itemController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('addons'.tr, style: robotoMedium),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Text(
              'optional'.tr,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: item.addOns!.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (!itemController.addOnActiveList[index]) {
                  itemController.addAddOn(true, index);
                } else if (itemController.addOnQtyList[index] == 1) {
                  itemController.addAddOn(false, index);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Checkbox(
                      value: itemController.addOnActiveList[index],
                      activeColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall)),
                      onChanged: (bool? newValue) {
                        if (!itemController.addOnActiveList[index]) {
                          itemController.addAddOn(true, index);
                        } else if (itemController.addOnQtyList[index] == 1) {
                          itemController.addAddOn(false, index);
                        }
                      },
                      visualDensity:
                          const VisualDensity(horizontal: -3, vertical: -3),
                      side: BorderSide(
                          width: 2, color: Theme.of(context).hintColor),
                    ),
                    Text(
                      item.addOns![index].name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: itemController.addOnActiveList[index]
                          ? robotoMedium
                          : robotoRegular.copyWith(
                              color: Theme.of(context).hintColor),
                    ),
                  ]),
                  const Spacer(),
                  Text(
                    item.addOns![index].price! > 0
                        ? PriceConverter.convertPrice(item.addOns![index].price)
                        : 'free'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: itemController.addOnActiveList[index]
                        ? robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall)
                        : robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor),
                  ),
                  itemController.addOnActiveList[index]
                      ? Container(
                          height: 25,
                          width: 90,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).cardColor),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (itemController.addOnQtyList[index]! >
                                          1) {
                                        itemController.setAddOnQuantity(
                                            false, index);
                                      } else {
                                        itemController.addAddOn(false, index);
                                      }
                                    },
                                    child: Center(
                                        child: Icon(
                                      (itemController.addOnQtyList[index]! > 1)
                                          ? Icons.remove
                                          : Icons.delete_outline_outlined,
                                      size: 18,
                                      color: (itemController
                                                  .addOnQtyList[index]! >
                                              1)
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).colorScheme.error,
                                    )),
                                  ),
                                ),
                                Text(
                                  itemController.addOnQtyList[index].toString(),
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => itemController
                                        .setAddOnQuantity(true, index),
                                    child: Center(
                                        child: Icon(Icons.add,
                                            size: 18,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ]),
                        )
                      : const SizedBox(),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      ],
    );
  }
}

class VariationView extends StatelessWidget {
  final Item? item;
  final ItemController itemController;
  const VariationView(
      {super.key, required this.item, required this.itemController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: item!.choiceOptions!.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
          bottom: item!.choiceOptions!.isNotEmpty
              ? Dimensions.paddingSizeLarge
              : 0),
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item!.choiceOptions![index].title!, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: item!.choiceOptions![index].options!.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeExtraSmall),
                  child: InkWell(
                    onTap: () {
                      itemController.setCartVariationIndex(index, i, item);
                    },
                    child: Row(children: [
                      Expanded(
                          child: Text(
                        item!.choiceOptions![index].options![i].trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Radio<int>(
                        value: i,
                        groupValue: itemController.variationIndex![index],
                        onChanged: (int? value) => itemController
                            .setCartVariationIndex(index, i, item),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(
              height: index != item!.choiceOptions!.length - 1
                  ? Dimensions.paddingSizeLarge
                  : 0),
        ]);
      },
    );
  }
}

class NewVariationView extends StatelessWidget {
  final Item? item;
  final ItemController itemController;
  final double? discount;
  final String? discountType;
  final bool showOriginalPrice;
  const NewVariationView(
      {super.key,
      required this.item,
      required this.itemController,
      required this.discount,
      required this.discountType,
      required this.showOriginalPrice});

  @override
  Widget build(BuildContext context) {
    return item!.foodVariations != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: item!.foodVariations!.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
                bottom: (item!.foodVariations != null &&
                        item!.foodVariations!.isNotEmpty)
                    ? Dimensions.paddingSizeLarge
                    : 0),
            itemBuilder: (context, index) {
              int selectedCount = 0;
              if (item!.foodVariations![index].required!) {
                for (var value in itemController.selectedVariations[index]) {
                  if (value == true) {
                    selectedCount++;
                  }
                }
              }
              return Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                margin: EdgeInsets.only(
                    bottom: index != item!.foodVariations!.length - 1
                        ? Dimensions.paddingSizeLarge
                        : 0),
                decoration: BoxDecoration(
                    color: itemController.selectedVariations[index]
                            .contains(true)
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.01)
                        : Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.05),
                    border: Border.all(
                        color: itemController.selectedVariations[index]
                                .contains(true)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        width: 0.5),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(item!.foodVariations![index].name!,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                            Container(
                              decoration: BoxDecoration(
                                color: item!.foodVariations![index].required! &&
                                        (item!.foodVariations![index]
                                                    .multiSelect!
                                                ? item!
                                                    .foodVariations![index].min!
                                                : 1) >
                                            selectedCount
                                    ? Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.1)
                                    : Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                item!.foodVariations![index].required!
                                    ? (item!.foodVariations![index].multiSelect!
                                                ? item!
                                                    .foodVariations![index].min!
                                                : 1) <=
                                            selectedCount
                                        ? 'completed'.tr
                                        : 'required'.tr
                                    : 'optional'.tr,
                                style: robotoRegular.copyWith(
                                  color: item!.foodVariations![index].required!
                                      ? (item!.foodVariations![index]
                                                      .multiSelect!
                                                  ? item!.foodVariations![index]
                                                      .min!
                                                  : 1) <=
                                              selectedCount
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).colorScheme.error
                                      : Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      item!.foodVariations![index].multiSelect!
                          ? Text(
                              '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}'
                                  ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).disabledColor),
                            )
                          : Text(
                              'select_one'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).primaryColor),
                            ),
                      SizedBox(
                          height: item!.foodVariations![index].multiSelect!
                              ? Dimensions.paddingSizeExtraSmall
                              : 0),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: itemController.collapseVariation[index]
                            ? item!.foodVariations![index].variationValues!
                                        .length >
                                    4
                                ? 5
                                : item!.foodVariations![index].variationValues!
                                    .length
                            : item!
                                .foodVariations![index].variationValues!.length,
                        itemBuilder: (context, i) {
                          if (i == 4 &&
                              itemController.collapseVariation[index]) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              child: InkWell(
                                onTap: () => itemController
                                    .showMoreSpecificSection(index),
                                child: Row(children: [
                                  Icon(Icons.expand_more,
                                      size: 18,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '${'view'.tr} ${item!.foodVariations![index].variationValues!.length - 4} ${'more_option'.tr}',
                                    style: robotoMedium.copyWith(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeExtraSmall
                                      : 0),
                              child: InkWell(
                                onTap: () {
                                  itemController.setNewCartVariationIndex(
                                      index, i, item!);
                                },
                                child: Row(children: [
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        item!.foodVariations![index]
                                                .multiSelect!
                                            ? Checkbox(
                                                value: itemController
                                                        .selectedVariations[
                                                    index][i],
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall)),
                                                onChanged: (bool? newValue) {
                                                  itemController
                                                      .setNewCartVariationIndex(
                                                          index, i, item!);
                                                },
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: -3,
                                                        vertical: -3),
                                                side: BorderSide(
                                                    width: 2,
                                                    color: Theme.of(context)
                                                        .hintColor),
                                              )
                                            : Radio(
                                                value: i,
                                                groupValue: itemController
                                                    .selectedVariations[index]
                                                    .indexOf(true),
                                                onChanged: (dynamic value) {
                                                  itemController
                                                      .setNewCartVariationIndex(
                                                          index, i, item!);
                                                },
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                toggleable: false,
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: -3,
                                                        vertical: -3),
                                              ),
                                        Text(
                                          item!.foodVariations![index]
                                              .variationValues![i].level!
                                              .trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: itemController
                                                  .selectedVariations[index][i]!
                                              ? robotoMedium
                                              : robotoRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                        ),
                                      ]),
                                  const Spacer(),
                                  showOriginalPrice
                                      ? Text(
                                          '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: TextDirection.ltr,
                                          style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Colors.black,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                      width: showOriginalPrice
                                          ? Dimensions.paddingSizeExtraSmall
                                          : 0),
                                  Text(
                                    '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: item!.type == 'voucher' ? null : discount, discountType: item!.type == 'voucher' ? null : discountType, isFoodVariation: true)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.ltr,
                                    style: itemController
                                            .selectedVariations[index][i]!
                                        ? robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall)
                                        : robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color: Theme.of(context)
                                                .disabledColor),
                                  ),
                                ]),
                              ),
                            );
                          }
                        },
                      ),
                    ]),
              );
            },
          )
        : const SizedBox();
  }
}

class HorizontalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double startXOffset;
  HorizontalDashedLinePainter(
      {required this.color,
      this.strokeWidth = 4.5,
      this.dashWidth = 5,
      this.dashSpace = 3,
      this.startXOffset = 10});

  @override
  void paint(Canvas canvas, Size size) {
    double startX = startXOffset;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    while (startX < size.width - startXOffset) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ScallopedEdgeClipper extends CustomClipper<Path> {
  final double cutoutY;
  final double radius;
  final double borderRadius;

  ScallopedEdgeClipper(
      {required this.cutoutY, this.radius = 10, this.borderRadius = 12});

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Top-left corner
    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

    // Right side with cutout
    path.lineTo(size.width, cutoutY - radius);
    path.arcToPoint(
      Offset(size.width, cutoutY + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - borderRadius, size.height);

    // Bottom side
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    // Left side with cutout
    path.lineTo(0, cutoutY + radius);
    path.arcToPoint(
      Offset(0, cutoutY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(ScallopedEdgeClipper oldClipper) =>
      oldClipper.cutoutY != cutoutY ||
      oldClipper.radius != radius ||
      oldClipper.borderRadius != borderRadius;
}

class ScallopedBorderPainter extends CustomPainter {
  final double cutoutY;
  final double radius;
  final double borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  ScallopedBorderPainter({
    required this.cutoutY,
    this.radius = 10,
    this.borderRadius = 12,
    required this.gradient,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();

    // Top-left corner
    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

    // Right side with cutout
    path.lineTo(size.width, cutoutY - radius);
    path.arcToPoint(
      Offset(size.width, cutoutY + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - borderRadius, size.height);

    // Bottom side
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    // Left side with cutout
    path.lineTo(0, cutoutY + radius);
    path.arcToPoint(
      Offset(0, cutoutY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ScallopedBorderPainter oldDelegate) => true;
}

List<Color> _getVoucherColors(String? voucherIds) {
  if (voucherIds == null) {
    return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
  }
  String ids = voucherIds.toLowerCase();
  if (ids.contains('delivery') || ids.contains('pickup')) {
    return [const Color(0xFFF43F8C), const Color(0xFFFB8B5E)];
  } else if (ids.contains('in-store') ||
      ids.contains('instore') ||
      ids.contains('in store')) {
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
