import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/horizontal_dashed_line_painter.dart';
import 'package:sixam_mart/common/widgets/scalloped_edge_clipper.dart';
import 'package:sixam_mart/common/widgets/curved_border_painter.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class WebHotVoucherCardWidget extends StatelessWidget {
  final Item item;
  final bool showLogo;
  final bool showPrice;
  final double? width;
  const WebHotVoucherCardWidget(
      {super.key,
      required this.item,
      this.showLogo = true,
      this.showPrice = true,
      this.width = 280});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = _getVoucherColors(item.voucherIds);
    Color mixedColor = Color.lerp(colors[0], colors[1], 0.3) ?? colors[0];
    double? discount = item.discount;
    String? discountType = item.discountType;

    if (item.type == 'voucher' &&
        item.voucherIds?.toLowerCase().trim() == 'flat discount') {
      if (item.bonusConfiguration != null &&
          item.bonusConfiguration!.isNotEmpty) {
        double maxBonus = 0;
        for (var config in item.bonusConfiguration!) {
          double bonus = double.tryParse(config.bonusPercentage ?? '0') ?? 0;
          if (bonus > maxBonus) {
            maxBonus = bonus;
          }
        }
        if (maxBonus > 0) {
          discount = maxBonus;
          discountType = 'percent';
        }
      }
    } else if (item.type == 'voucher' &&
        (item.bundleType == 'bogo_free' ||
            (item.voucherIds?.toLowerCase().trim().contains('bogo') ??
                false))) {
      discount = 50;
      discountType = 'percent';
    }

    double imageHeight = (showLogo || showPrice) ? 160 : 130;
    double cutoutY = imageHeight + 18;

    return SizedBox(
      width: width,
      child: ClipPath(
        clipper: ScallopedEdgeClipper(cutoutY: cutoutY), // Adjusted for web
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: CustomPaint(
            painter: CurvedBorderPainter(
              colors: colors,
              stops: const [0.7, 1.0],
              cutoutY: cutoutY, // Adjusted for web
            ),
            child: InkWell(
              onTap: () =>
                  Get.find<ItemController>().navigateToItemPage(item, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Section (Image Area)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 8, bottom: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomImage(
                            image: item.imageFullUrl ?? '',
                            height: imageHeight, // Adjusted for web
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Voucher Type Badge (Top-Left)
                      if (item.voucherIds != null &&
                          item.voucherIds!.isNotEmpty)
                        Positioned(
                          top: 0,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: colors, stops: const [0.7, 1.0]),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              item.voucherIds ?? 'Voucher',
                              style: robotoBold.copyWith(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),

                      // Rating (Bottom-Left)
                      if ((item.avgRating ?? 0) > 0)
                        Positioned(
                          bottom: 15,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 1)
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  (item.avgRating ?? 0).toStringAsFixed(1),
                                  style: robotoBold.copyWith(
                                      fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Favorite (Bottom-Right)
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: GetBuilder<FavouriteController>(
                            builder: (favouriteController) {
                          bool isWished = favouriteController.wishItemIdList
                              .contains(item.id);
                          return CircleAvatar(
                            radius: 14,
                            backgroundColor: Theme.of(context)
                                .cardColor
                                .withValues(alpha: 0.8),
                            child: CustomFavouriteWidget(
                              isWished: isWished,
                              isStore: false,
                              item: item,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Middle Divider
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 10,
                        color: Colors.transparent,
                      ),
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: HorizontalDashedLinePainter(
                          color: mixedColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Section (Info Area)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name ?? '',
                                style: robotoBlack.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).primaryColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Save Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: colors, stops: const [0.7, 1.0]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'save'.tr.toUpperCase(),
                                    style: robotoBold.copyWith(
                                        color: Colors.white, fontSize: 8),
                                  ),
                                  Text(
                                    discountType == 'amount'
                                        ? PriceConverter.convertPrice(discount)
                                        : '${discount?.toInt()}%',
                                    style: robotoBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (showLogo)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CustomImage(
                                  image: item.storeLogoFullUrl ?? '',
                                  height: 35,
                                  width: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (showLogo) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.storeName ?? '',
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showPrice) const SizedBox(width: 8),
                            // Price Row
                            if (showPrice)
                              Row(
                                children: [
                                  if (((discount ?? 0) > 0 &&
                                          item.type != 'voucher') ||
                                      (item.type == 'voucher' &&
                                          item.bundleType == 'simple x'))
                                    Text(
                                      PriceConverter.convertPrice(
                                          (item.type == 'voucher' &&
                                                  item.bundleType == 'simple x')
                                              ? (item.actualPrice ?? item.price)
                                              : item.price),
                                      style: robotoRegular.copyWith(
                                        fontSize: 11,
                                        color: Theme.of(context).disabledColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  if (((discount ?? 0) > 0 &&
                                          item.type != 'voucher') ||
                                      (item.type == 'voucher' &&
                                          item.bundleType == 'simple x'))
                                    const SizedBox(width: 4),
                                  Text(
                                    (item.type == 'voucher' &&
                                            item.bundleType != 'simple x')
                                        ? 'enter_voucher_price'.tr
                                        : (item.type == 'voucher' &&
                                                item.bundleType == 'simple x')
                                            ? PriceConverter.convertPrice(
                                                item.price)
                                            : PriceConverter.convertPrice(
                                                item.price,
                                                discount: discount,
                                                discountType: discountType),
                                    style: robotoBold.copyWith(
                                        fontSize: (item.type == 'voucher' &&
                                                item.bundleType != 'simple x')
                                            ? 11
                                            : Dimensions.fontSizeDefault,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
}
