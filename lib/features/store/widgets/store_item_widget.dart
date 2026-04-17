import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class StoreItemWidget extends StatelessWidget {
  final Item item;
  final int index;
  final VoidCallback? onTap;
  final bool showPrice;
  final bool showDiscount;
  final Color? backgroundColor;
  const StoreItemWidget(
      {super.key,
      required this.item,
      required this.index,
      this.onTap,
      this.showPrice = true,
      this.showDiscount = true,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;

    if (item.type == 'voucher' &&
        (item.voucherIds?.toLowerCase().trim() == 'flat discount' ||
            item.bundleType == 'gift')) {
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
    List<Color> colors = _getVoucherColors(item.voucherIds);
    Color mixedColor = Color.lerp(colors[0], colors[1], 0.3) ?? colors[0];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: ClipPath(
            clipper: TopBottomScallopedClipper(cutoutX: 118),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? Theme.of(context).cardColor,
              ),
              child: CustomInkWell(
                onTap: onTap ??
                    () {
                      Get.find<ItemController>()
                          .navigateToItemPage(item, context, inStore: true);
                    },
                radius: Dimensions.radiusLarge,
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Section: Image and Vertical Badge
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomImage(
                                image: item.imageFullUrl ?? '',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Vertical Badge
                          if (item.voucherIds != null &&
                              item.voucherIds!.isNotEmpty)
                            Positioned(
                              top: 10,
                              bottom: 15,
                              left: 0,
                              child: Container(
                                width: 25,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: colors,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight:
                                        Radius.circular(Dimensions.radiusLarge),
                                    bottomRight:
                                        Radius.circular(Dimensions.radiusLarge),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    item.voucherIds ?? '',
                                    style: robotoBold.copyWith(
                                        color: Colors.white, fontSize: 10),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 2),

                      // Divider with Curves (Design mimicry)
                      CustomPaint(
                        size: const Size(1, double.infinity),
                        painter: CurvedDividerPainter(
                            color: mixedColor.withValues(alpha: 0.8)),
                      ),

                      // Middle Section: Item Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name ?? '',
                                style: robotoBlack.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (showPrice)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (((discount ?? 0) > 0 &&
                                            item.type != 'voucher') ||
                                        (item.type == 'voucher' &&
                                            item.bundleType == 'simple x'))
                                      Text(
                                        PriceConverter.convertPrice((item
                                                        .type ==
                                                    'voucher' &&
                                                item.bundleType == 'simple x')
                                            ? (item.actualPrice ?? item.price)
                                            : item.price),
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
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
                                              ? Dimensions.fontSizeSmall
                                              : Dimensions.fontSizeLarge),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Right Section: SAVE badge and Favorite
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Save Badge
                            if (showDiscount && (discount ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: colors, stops: const [0.7, 1.0]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text('SAVE'.tr,
                                        style: robotoBold.copyWith(
                                            color: Colors.white, fontSize: 10)),
                                    Text(
                                      discountType == 'amount'
                                          ? PriceConverter.convertPrice(
                                              discount)
                                          : '${discount?.toInt()}%',
                                      style: robotoBold.copyWith(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),

                            // Favorite Icon
                            GetBuilder<FavouriteController>(
                                builder: (favController) {
                              bool isWished = favController.wishItemIdList
                                  .contains(item.id);
                              return InkWell(
                                onTap: () {
                                  if (isWished) {
                                    favController.removeFromFavouriteList(
                                        item.id, false);
                                  } else {
                                    favController.addToFavouriteList(
                                        item, null, false);
                                  }
                                },
                                child: Icon(
                                  isWished
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isWished
                                      ? Colors.red
                                      : Theme.of(context).disabledColor,
                                  size: 20,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: IgnorePointer(
              child: CustomPaint(
                painter: TopBottomCurvedBorderPainter(
                  colors: colors,
                  stops: const [0.7, 1.0],
                  cutoutX: 118,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getVoucherColors(String? voucherIds) {
    if (voucherIds == null)
      return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
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
}

class CurvedDividerPainter extends CustomPainter {
  final Color color;
  CurvedDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    double dashWidth = 4;
    double dashSpace = 3;
    double startY = 10;
    while (startY < size.height - 10) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    // Drawing top and bottom semi-circles for the cutout look
    // Top cutout (placeholder if needed)
    // Bottom cutout (placeholder if needed)
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TopBottomScallopedClipper extends CustomClipper<Path> {
  final double cutoutX;
  final double radius;

  TopBottomScallopedClipper({required this.cutoutX, this.radius = 10});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(Dimensions.radiusLarge, 0);

    // Top line with cutout
    path.lineTo(cutoutX - radius, 0);
    path.arcToPoint(Offset(cutoutX + radius, 0),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(size.width - Dimensions.radiusLarge, 0);

    // Top-right corner
    path.arcToPoint(Offset(size.width, Dimensions.radiusLarge),
        radius: const Radius.circular(Dimensions.radiusLarge));

    // Right line
    path.lineTo(size.width, size.height - Dimensions.radiusLarge);

    // Bottom-right corner
    path.arcToPoint(Offset(size.width - Dimensions.radiusLarge, size.height),
        radius: const Radius.circular(Dimensions.radiusLarge));

    // Bottom line with cutout
    path.lineTo(cutoutX + radius, size.height);
    path.arcToPoint(Offset(cutoutX - radius, size.height),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(Dimensions.radiusLarge, size.height);

    // Bottom-left corner
    path.arcToPoint(Offset(0, size.height - Dimensions.radiusLarge),
        radius: const Radius.circular(Dimensions.radiusLarge));

    // Left line
    path.lineTo(0, Dimensions.radiusLarge);

    // Top-left corner
    path.arcToPoint(Offset(Dimensions.radiusLarge, 0),
        radius: const Radius.circular(Dimensions.radiusLarge));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TopBottomCurvedBorderPainter extends CustomPainter {
  final List<Color> colors;
  final List<double>? stops;
  final double cutoutX;
  final double radius;
  final double strokeWidth;

  TopBottomCurvedBorderPainter({
    required this.colors,
    this.stops,
    required this.cutoutX,
    this.radius = 10,
    this.strokeWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double halfStroke = strokeWidth / 2;
    Paint paint = Paint()
      ..shader = LinearGradient(
              colors: colors,
              stops: stops,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(Dimensions.radiusLarge, halfStroke);

    path.lineTo(cutoutX - radius, halfStroke);
    path.arcToPoint(Offset(cutoutX + radius, halfStroke),
        radius: const Radius.circular(10.0), clockwise: false);
    path.lineTo(size.width - Dimensions.radiusLarge, halfStroke);

    path.arcToPoint(Offset(size.width - halfStroke, Dimensions.radiusLarge),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));
    path.lineTo(size.width - halfStroke, size.height - Dimensions.radiusLarge);
    path.arcToPoint(
        Offset(size.width - Dimensions.radiusLarge, size.height - halfStroke),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));

    path.lineTo(cutoutX + radius, size.height - halfStroke);
    path.arcToPoint(Offset(cutoutX - radius, size.height - halfStroke),
        radius: const Radius.circular(10.0), clockwise: false);
    path.lineTo(Dimensions.radiusLarge, size.height - halfStroke);

    path.arcToPoint(Offset(halfStroke, size.height - Dimensions.radiusLarge),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));
    path.lineTo(halfStroke, Dimensions.radiusLarge);
    path.arcToPoint(Offset(Dimensions.radiusLarge, halfStroke),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
