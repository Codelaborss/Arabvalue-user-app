import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart'
    as splash;
import 'package:get/get.dart';

class ExpandableVoucherSection extends StatefulWidget {
  final String title;
  final Widget? content;
  final List<Item>? voucherProducts;
  final List<Store>? branches;
  final List<HowItWorks>? howItWorks;
  final VoucherSectionType type;
  final List<OrderDetailsModel>? orderProductDetails;
  final String? bundleType;
  final bool hasGiftDetail;
  final Item? item;
  final OrderModel? order;
  final VoucherSettings? voucherSettings;

  const ExpandableVoucherSection({
    super.key,
    required this.title,
    this.content,
    this.voucherProducts,
    this.branches,
    this.howItWorks,
    required this.type,
    this.orderProductDetails,
    this.bundleType,
    this.hasGiftDetail = false,
    this.item,
    this.order,
    this.voucherSettings,
  });

  @override
  State<ExpandableVoucherSection> createState() =>
      _ExpandableVoucherSectionState();
}

class _ExpandableVoucherSectionState extends State<ExpandableVoucherSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'view'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: _buildContent(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case VoucherSectionType.voucherInfo:
        return _buildVoucherProducts();
      case VoucherSectionType.branches:
        return _buildBranches();
      case VoucherSectionType.usageTerms:
        return _buildUsageTerms();
      case VoucherSectionType.howToUse:
        return _buildHowToUse();
      case VoucherSectionType.giftVoucherInfo:
        return _buildGiftVoucherInfo();
    }
  }

  Widget _buildVoucherProducts() {
    if (widget.bundleType == 'simple x') {
      return _buildSimpleXDetails();
    }

    // Use actual order product items if available (with selected variation/addons)
    if (widget.orderProductDetails != null &&
        widget.orderProductDetails!.isNotEmpty) {
      return _buildOrderProductDetails();
    }

    // Fallback: static voucherProducts list
    if (widget.voucherProducts == null || widget.voucherProducts!.isEmpty) {
      return Text('no_products_available'.tr);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.voucherProducts!.map((product) {
        bool hasVariations =
            (product.variations != null && product.variations!.isNotEmpty) ||
                (product.foodVariations != null &&
                    product.foodVariations!.isNotEmpty);
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  product.name ?? '',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              if (!hasVariations && product.price != null && product.price! > 0)
                Text(
                  _formatVoucherPrice(product.price),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: widget.bundleType == 'gift'
                        ? const Color(0xFF6A4DF4)
                        : const Color(0xFF1ABC9C),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimpleXDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item?.name != null)
              Expanded(
                child: Text(
                  widget.item!.name!,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF00275E)),
                ),
              ),
            if (widget.order?.orderAmount != null) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                _formatVoucherPrice(widget.order!.orderAmount),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: const Color(0xFF1ABC9C),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        if (widget.item?.description != null) ...[
          Text(
            'description'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item!.description!
                .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderProductDetails() {
    // Filter out items with no product name (avoids empty containers)
    final validItems = widget.orderProductDetails!
        .where((d) => (d.itemDetails?.name ?? '').isNotEmpty)
        .toList();

    if (validItems.isEmpty) return const SizedBox();

    // For bogo_free: find the item with lowest effective price → mark as "Free"
    int? freeItemId;
    if (widget.bundleType == 'bogo_free' && validItems.length >= 2) {
      double _effectivePrice(OrderDetailsModel d) {
        final fvs = d.foodVariation ?? [];
        if (fvs.isNotEmpty &&
            fvs.first.variationValues != null &&
            fvs.first.variationValues!.isNotEmpty) {
          return fvs.first.variationValues!.first.optionPrice ??
              d.itemDetails?.price ??
              0;
        }
        return d.itemDetails?.price ?? 0;
      }

      OrderDetailsModel cheapest = validItems.reduce(
        (a, b) => _effectivePrice(a) <= _effectivePrice(b) ? a : b,
      );
      freeItemId = cheapest.itemId;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validItems.map((orderDetail) {
        final String productName = orderDetail.itemDetails?.name ?? '';
        final List<FoodVariation> foodVariations =
            orderDetail.foodVariation ?? [];
        final List<AddOn> addOns = orderDetail.addOns ?? [];
        final double? basePrice = orderDetail.itemDetails?.price;
        final bool isFreeItem =
            freeItemId != null && orderDetail.itemId == freeItemId;

        // Collect selected variation values
        List<Map<String, dynamic>> selectedVariations = [];
        for (var fv in foodVariations) {
          if (fv.variationValues != null) {
            for (var val in fv.variationValues!) {
              double optPrice =
                  double.tryParse(val.optionPrice?.toString() ?? '0') ?? 0;
              selectedVariations.add({
                'name': fv.name ?? '',
                'label': val.level ?? '',
                'price': optPrice,
              });
            }
          }
        }

        bool hasVariation = selectedVariations.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 2),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name row — with optional "Free" badge for bogo_free
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            productName,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isFreeItem) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.bundleType == 'gift'
                                  ? const Color(0xFF6A4DF4)
                                  : const Color(0xFF1ABC9C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'free'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!hasVariation && basePrice != null && basePrice > 0)
                    Text(
                      _formatVoucherPrice(basePrice),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: widget.bundleType == 'gift'
                            ? const Color(0xFF6A4DF4)
                            : const Color(0xFF1ABC9C),
                      ),
                    ),
                ],
              ),

              // Selected Variations with prices
              if (hasVariation) ...[
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 6),
                ...selectedVariations.map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${v['name']} : ${v['label']}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatVoucherPrice(v['price'] as double),
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF1ABC9C),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Add-ons with prices
              if (addOns.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 6),
                Text(
                  'add_ons'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                ...addOns.map((addon) {
                  final String addonName = addon.name ?? '';
                  final double addonPrice = addon.price ?? 0;
                  final int addonQty = addon.quantity ?? 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              addonQty > 1
                                  ? '$addonName x$addonQty'
                                  : addonName,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatVoucherPrice(addonPrice * addonQty),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBranches() {
    if (widget.branches == null || widget.branches!.isEmpty) {
      return Text('no_branches_available'.tr);
    }
    return Column(
      children: widget.branches!.map((branch) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipOval(
                  child: CustomImage(
                    image: branch.logoFullUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(builder: (context) {
                      // ONLY check availability for Delivery/Pickup and Flat Discount vouchers
                      bool shouldCheckAvailability = false;
                      String? vIds = widget.item?.voucherIds?.toLowerCase();
                      if (vIds != null) {
                        shouldCheckAvailability = vIds.contains('delivery') ||
                            vIds.contains('pickup') ||
                            vIds.contains('flat');
                      }

                      bool available = shouldCheckAvailability
                          ? _isBranchAvailable(branch)
                          : true;

                      String? activeAt;
                      if (!available && branch.availability != null) {
                        for (var a in branch.availability!) {
                          if (a.status == 'not_available') {
                            activeAt = a.activeAt;
                            break;
                          }
                        }
                      }

                      return Text(
                        available
                            ? (branch.name ?? '')
                            : '${branch.name ?? ''}${'not_available_parentheses'.tr}${activeAt != null ? ' - $activeAt' : ''}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: available
                              ? Colors.black87
                              : Theme.of(context).disabledColor,
                        ),
                      );
                    }),
                    if (branch.address != null)
                      Text(
                        branch.address!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsageTerms() {
    if (widget.voucherSettings == null) {
      return Text('no_usage_terms_available'.tr);
    }
    VoucherSettings settings = widget.voucherSettings!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (settings.validityPeriod != null &&
            (settings.validityPeriod!.start != null &&
                settings.validityPeriod!.start!.isNotEmpty &&
                settings.validityPeriod!.start != 'null') &&
            (settings.validityPeriod!.end != null &&
                settings.validityPeriod!.end!.isNotEmpty &&
                settings.validityPeriod!.end != 'null'))
          _buildSettingItem('validity_period'.tr,
              '${settings.validityPeriod!.start} to ${settings.validityPeriod!.end}'),

        if (settings.ageRestriction != null &&
            settings.ageRestriction!.isNotEmpty)
          _buildSettingItem(
              'age_restriction'.tr,
              settings.ageRestriction!
                  .where((e) => e.text != null || e.value != null)
                  .map((e) => e.text ?? '${e.value}+ Only')
                  .join(', ')),

        if ((settings.groupSizeText != null &&
                settings.groupSizeText!.isNotEmpty) ||
            (settings.groupSizeRequirement != null &&
                settings.groupSizeRequirement! > 0))
          _buildSettingItem(
              'group_size'.tr,
              (settings.groupSizeText != null &&
                      settings.groupSizeText!.isNotEmpty)
                  ? settings.groupSizeText!
                  : 'Minimum ${settings.groupSizeRequirement} People'),

        if (settings.usageLimitPerUser != null &&
            (settings.usageLimitPerUser!.value != null &&
                settings.usageLimitPerUser!.value!.isNotEmpty &&
                settings.usageLimitPerUser!.value != 'null'))
          _buildSettingItem('usage_limit'.tr,
              '${settings.usageLimitPerUser!.value}${settings.usageLimitPerUser!.period != null && settings.usageLimitPerUser!.period!.isNotEmpty && settings.usageLimitPerUser!.period != 'null' ? ' ${settings.usageLimitPerUser!.period}' : ' times'}'),

        if (settings.usageLimitPerStore != null &&
            (settings.usageLimitPerStore!.value != null &&
                settings.usageLimitPerStore!.value!.isNotEmpty &&
                settings.usageLimitPerStore!.value != 'null'))
          _buildSettingItem('store_usage_limit'.tr,
              '${settings.usageLimitPerStore!.value}${settings.usageLimitPerStore!.period != null && settings.usageLimitPerStore!.period!.isNotEmpty && settings.usageLimitPerStore!.period != 'null' ? ' ${settings.usageLimitPerStore!.period}' : ' times'}'),

        if ((settings.offerValidityText != null &&
                settings.offerValidityText!.isNotEmpty &&
                settings.offerValidityText != 'null') ||
            (settings.offerValidityAfterPurchase != null &&
                settings.offerValidityAfterPurchase! > 0))
          _buildSettingItem(
              'validity_after_purchase'.tr,
              (settings.offerValidityText != null &&
                      settings.offerValidityText!.isNotEmpty &&
                      settings.offerValidityText != 'null')
                  ? '${settings.offerValidityText} Days'
                  : '${settings.offerValidityAfterPurchase} Days'),

        if (settings.generalRestrictions != null &&
            settings.generalRestrictions!.isNotEmpty)
          ...settings.generalRestrictions!
              .where((e) =>
                  (e.nameEn != null && e.nameEn!.isNotEmpty) ||
                  (e.nameAr != null && e.nameAr!.isNotEmpty))
              .map((e) => _buildSettingItem(
                  null, e.nameEn ?? e.nameAr ?? 'general_restriction'.tr)),

        // Holidays and Blackout dates
        if (settings.holidaysOccasions != null &&
            settings.holidaysOccasions!.isNotEmpty)
          _buildSettingItem(
              'holidays'.tr,
              settings.holidaysOccasions!
                  .where((e) => e.nameEn != null || e.nameAr != null)
                  .map((e) => (e.nameEn ?? e.nameAr)!)
                  .join(', ')),

        if (settings.specificDaysOfWeek != null)
          _buildSpecificDaysOfWeek(settings.specificDaysOfWeek!),

        if (settings.customBlackoutDates != null &&
            settings.customBlackoutDates!.isNotEmpty)
          _buildSettingItem(
              'blackout_dates'.tr,
              settings.customBlackoutDates!
                  .where((e) =>
                      (e.date != null && e.date!.isNotEmpty) ||
                      (e.description != null && e.description!.isNotEmpty))
                  .map((e) =>
                      '${e.date ?? ''}${e.description != null ? ' (${e.description})' : ''}')
                  .join(', ')),
      ],
    );
  }

  Widget _buildSpecificDaysOfWeek(SpecificDaysOfWeek days) {
    List<String> activeDays = [];
    if (days.monday != null)
      activeDays.add('Mon (${days.monday!.start}-${days.monday!.end})');
    if (days.tuesday != null)
      activeDays.add('Tue (${days.tuesday!.start}-${days.tuesday!.end})');
    if (days.wednesday != null)
      activeDays.add('Wed (${days.wednesday!.start}-${days.wednesday!.end})');
    if (days.thursday != null)
      activeDays.add('Thu (${days.thursday!.start}-${days.thursday!.end})');
    if (days.friday != null)
      activeDays.add('Fri (${days.friday!.start}-${days.friday!.end})');
    if (days.saturday != null)
      activeDays.add('Sat (${days.saturday!.start}-${days.saturday!.end})');
    if (days.sunday != null)
      activeDays.add('Sun (${days.sunday!.start}-${days.sunday!.end})');

    if (activeDays.isEmpty) return const SizedBox();

    return _buildSettingItem('available_days'.tr, activeDays.join(', '));
  }

  Widget _buildSettingItem(String? title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall)),
                Text(value,
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToUse() {
    if (widget.howItWorks == null || widget.howItWorks!.isEmpty) {
      return Text('no_usage_terms_available'.tr);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.howItWorks!.map((guide) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (guide.guideTitle != null)
                Text(guide.guideTitle!,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF00275E),
                    )),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (guide.sections != null)
                ...guide.sections!.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (section.title != null)
                        Text(section.title!,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.grey[700],
                            )),
                      if (section.steps != null)
                        ...section.steps!.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall, top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.key + 1}. ',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall)),
                                Expanded(
                                  child: Text(entry.value,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall)),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  );
                }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGiftVoucherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.item?.name != null) ...[
          Text(
            widget.item!.name!,
            style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFF00275E)),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
        if (widget.item?.description != null) ...[
          Text(
            'description'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item!.description!
                .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Colors.grey[600]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
        if (widget.order != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('card_value'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall)),
              Text(
                _formatVoucherPrice(widget.order!.totalOrderAmount),
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('bonus'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall)),
              Text(
                _formatVoucherPrice(widget.order!.discountAmount),
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF1ABC9C)),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('paid_amount'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              Text(
                _formatVoucherPrice(widget.order!.orderAmount),
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF6A4DF4)),
              ),
            ],
          ),
        ]
      ],
    );
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

  String _formatVoucherPrice(double? value) {
    if (value == null) return PriceConverter.convertPrice(0);
    return "${Get.find<splash.SplashController>().configModel!.currencySymbol}${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}";
  }
}

enum VoucherSectionType {
  voucherInfo,
  branches,
  usageTerms,
  howToUse,
  giftVoucherInfo,
}
