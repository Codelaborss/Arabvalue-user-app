import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  const OrderItemWidget(
      {super.key, required this.order, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    bool isLtr = Get.find<LocalizationController>().isLtr;
    /*for (var addOn in orderDetails.addOns!) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }*/

    String? variationText = '';
    if (orderDetails.variation!.isNotEmpty) {
      if (orderDetails.variation!.isNotEmpty) {
        List<String> variationTypes =
            orderDetails.variation![0].type!.split('-');
        if (variationTypes.length ==
            orderDetails.itemDetails!.choiceOptions!.length) {
          int index = 0;
          for (var choice in orderDetails.itemDetails!.choiceOptions!) {
            variationText =
                '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
            index = index + 1;
          }
        } else {
          variationText = orderDetails.itemDetails!.variations![0].type;
        }
      }
    } else if (orderDetails.foodVariation!.isNotEmpty) {
      for (FoodVariation variation in orderDetails.foodVariation!) {
        variationText =
            '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if (variation.variationValues != null) {
          for (VariationValue value in variation.variationValues!) {
            variationText =
                '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        variationText = '${variationText!})';
      }
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: ClipPath(
            clipper: TopBottomScallopedClipper(cutoutX: 60, isLtr: isLtr),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImage(
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          image: '${orderDetails.imageFullUrl}',
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(
                                  orderDetails.itemDetails!.name!,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                Text('${'quantity'.tr}:',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall)),
                                Text(
                                  orderDetails.quantity.toString(),
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Row(children: [
                                Expanded(
                                    child: Text(
                                  PriceConverter.convertPrice(
                                      orderDetails.price),
                                  style: robotoMedium,
                                  textDirection: TextDirection.ltr,
                                )),
                                ((Get.find<SplashController>()
                                                .configModel!
                                                .moduleConfig!
                                                .module!
                                                .unit! &&
                                            orderDetails
                                                    .itemDetails!.unitType !=
                                                null) ||
                                        (Get.find<SplashController>()
                                                .configModel!
                                                .moduleConfig!
                                                .module!
                                                .vegNonVeg! &&
                                            Get.find<SplashController>()
                                                .configModel!
                                                .toggleVegNonVeg!))
                                    ? Get.find<SplashController>()
                                            .getModuleConfig(order.moduleType)
                                            .newVariation!
                                        ? CustomAssetImageWidget(
                                            orderDetails.itemDetails!.veg == 0
                                                ? Images.nonVegImage
                                                : Images.vegImage,
                                            height: 11,
                                            width: 11,
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall,
                                                horizontal: Dimensions
                                                    .paddingSizeSmall),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                            child: Text(
                                              orderDetails
                                                      .itemDetails!.unitType ??
                                                  '',
                                              style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )
                                    : const SizedBox(),
                                SizedBox(
                                    width: orderDetails.itemDetails!
                                                .isStoreHalalActive! &&
                                            orderDetails
                                                .itemDetails!.isHalalItem!
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0),
                                orderDetails.itemDetails!.isStoreHalalActive! &&
                                        orderDetails.itemDetails!.isHalalItem!
                                    ? const CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 13,
                                        width: 13)
                                    : const SizedBox(),
                              ]),
                            ]),
                      ),
                    ]),
                    variationText!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall),
                            child: Row(children: [
                              const SizedBox(width: 60),
                              Text('${'variations'.tr}: ',
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall)),
                              Flexible(
                                  child: Text(variationText,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ))),
                            ]),
                          )
                        : const SizedBox(),
                  ]),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: IgnorePointer(
              child: CustomPaint(
                painter: TopBottomCurvedBorderPainter(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.6),
                  ],
                  stops: const [0.7, 1.0],
                  cutoutX: 60,
                  isLtr: isLtr,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopBottomScallopedClipper extends CustomClipper<Path> {
  final double cutoutX;
  final double radius;
  final bool isLtr;

  TopBottomScallopedClipper(
      {required this.cutoutX, this.radius = 10, this.isLtr = true});

  @override
  Path getClip(Size size) {
    double actualCutoutX = isLtr ? cutoutX : size.width - cutoutX;
    Path path = Path();
    path.moveTo(Dimensions.radiusLarge, 0);

    // Top line with cutout
    path.lineTo(actualCutoutX - radius, 0);
    path.arcToPoint(Offset(actualCutoutX + radius, 0),
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
    path.lineTo(actualCutoutX + radius, size.height);
    path.arcToPoint(Offset(actualCutoutX - radius, size.height),
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
  final bool isLtr;

  TopBottomCurvedBorderPainter({
    required this.colors,
    this.stops,
    required this.cutoutX,
    this.radius = 10,
    this.strokeWidth = 5.0,
    this.isLtr = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double actualCutoutX = isLtr ? cutoutX : size.width - cutoutX;
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

    path.lineTo(actualCutoutX - radius, halfStroke);
    path.arcToPoint(Offset(actualCutoutX + radius, halfStroke),
        radius: const Radius.circular(10.0), clockwise: false);
    path.lineTo(size.width - Dimensions.radiusLarge, halfStroke);

    path.arcToPoint(Offset(size.width - halfStroke, Dimensions.radiusLarge),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));
    path.lineTo(size.width - halfStroke, size.height - Dimensions.radiusLarge);
    path.arcToPoint(
        Offset(size.width - Dimensions.radiusLarge, size.height - halfStroke),
        radius: const Radius.circular(Dimensions.radiusLarge - 0));

    path.lineTo(actualCutoutX + radius, size.height - halfStroke);
    path.arcToPoint(Offset(actualCutoutX - radius, size.height - halfStroke),
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
