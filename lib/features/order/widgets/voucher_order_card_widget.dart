import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart'
    as splash;
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/scalloped_edge_clipper.dart';
import 'package:sixam_mart/common/widgets/curved_border_painter.dart';
import 'package:sixam_mart/common/widgets/horizontal_dashed_line_painter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class VoucherOrderCardWidget extends StatelessWidget {
  final OrderDetailsModel orderDetail;
  final OrderModel? order;
  final String? qrCode;
  final String? storeLogo;
  final List<Widget>?
      expandableSections; // For Voucher Info, Redemption, Usage Terms

  const VoucherOrderCardWidget({
    super.key,
    required this.orderDetail,
    this.order,
    this.qrCode,
    this.storeLogo,
    this.expandableSections,
  });

  @override
  Widget build(BuildContext context) {
    Item? item = orderDetail.itemDetails;
    if (item == null) return const SizedBox();

    double price = orderDetail.price ?? 0;
    double discount = orderDetail.discountOnItem ?? 0;
    double originalPrice =
        (item.actualPrice != null && item.actualPrice! > price)
            ? item.actualPrice!
            : price + discount;

    String bundleType = item.bundleType ?? '';
    bool isGift = bundleType == 'gift';
    bool isCashBack =
        (order?.offerType == 'cash back' || item.offerType == 'cash back');

    if ((order?.giftDetails == null && orderDetail.giftDetails == null) &&
        order != null) {
      if (order!.orderAmount != null && order!.orderAmount! > 0) {
        price = order!.orderAmount!;
      }
      if (order!.discountAmount != null && order!.discountAmount! > 0) {
        discount = order!.discountAmount!;
      }
      if (bundleType == 'simple x') {
        if (item.actualPrice != null && item.actualPrice! > 0) {
          originalPrice = item.actualPrice!;
        }
      } else if (order!.totalOrderAmount != null &&
          order!.totalOrderAmount! > 0) {
        originalPrice = order!.totalOrderAmount!;
      }
    }

    double giftValuePrice = price;
    if ((order?.giftDetails != null || orderDetail.giftDetails != null) &&
        bundleType != 'gift') {
      if (bundleType == 'simple x') {
        giftValuePrice = (item.actualPrice != null && item.actualPrice! > 0)
            ? item.actualPrice!
            : (order?.orderAmount ?? price);
      } else {
        giftValuePrice = order?.totalOrderAmount ?? price;
      }
    } else if (isGift &&
        order != null &&
        order!.totalOrderAmount != null &&
        order!.totalOrderAmount! > 0) {
      // For gift vouchers, use totalOrderAmount (Card Value) as the display price
      price = order!.totalOrderAmount!;
    }

    // Use dynamic colors for border and badges
    List<Color> gradientColors = _getVoucherColors(item);

    bool isFlat = (item.voucherType ?? '').toLowerCase().contains('flat') ||
        (item.voucherIds ?? '').toLowerCase().contains('flat');

    String badgeText = (item.voucherIds != null && item.voucherIds!.isNotEmpty)
        ? item.voucherIds!.toUpperCase()
        : (bundleType.isNotEmpty)
            ? bundleType.toUpperCase()
            : (item.voucherType ?? 'Voucher').toUpperCase();

    double cutoutY = (ResponsiveHelper.isDesktop(context) ? 300 : 165) + 21;

    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall,
      ),
      child: Center(
        child: SizedBox(
          width: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
          child: ClipPath(
            clipper: ScallopedEdgeClipper(cutoutY: cutoutY),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: CustomPaint(
                painter: CurvedBorderPainter(
                  colors: gradientColors,
                  stops: const [0.7, 1.0],
                  cutoutY: cutoutY,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Voucher Image with badges
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomImage(
                              image: ((order?.giftDetails?.image != null ||
                                      orderDetail.giftDetails?.image != null))
                                  ? (order?.giftDetails?.image ??
                                      orderDetail.giftDetails!.image!)
                                  : item.imageFullUrl ?? '',
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 300
                                  : 165,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Voucher Type Badge (Top-Start — follows LTR/RTL)
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          top: 0,
                          start: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                stops: const [0.7, 1.0],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: robotoBold.copyWith(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        // Remove discount badge from here - will add next to title
                      ],
                    ),

                    // Dashed Divider after image
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
                            color: gradientColors[0].withValues(alpha: 0.8),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),

                    // Voucher Info Section
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // Title and Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: isGift
                                    ? // Gift voucher: Show Store logo + name
                                    Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: CustomImage(
                                              image: storeLogo ??
                                                  item.storeLogoFullUrl ??
                                                  '',
                                              height: 38,
                                              width: 38,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item.storeName ?? '',
                                              style: robotoBlack.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    : // Other vouchers: Show voucher name
                                    Text(
                                        item.name ?? '',
                                        style: robotoBlack.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).primaryColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                              const SizedBox(width: 10),
                              if (isGift)
                                // Gift voucher: "Voucher Value" badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      stops: const [0.7, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'voucher_value'.tr,
                                        style: robotoMedium.copyWith(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                      Text(
                                        _formatVoucherPrice(price),
                                        style: robotoBlack.copyWith(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                )
                              else if ((order?.giftDetails != null ||
                                  orderDetail.giftDetails != null))
                                // Has giftDetails: "Gift Value" badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      stops: const [0.7, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'gift_value'.tr,
                                        style: robotoMedium.copyWith(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                      Text(
                                        _formatVoucherPrice(giftValuePrice),
                                        style: robotoBlack.copyWith(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                )
                              else if (discount > 0)
                                // Regular discount: SAVE badge
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 13, right: 13, top: 10, bottom: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      stops: const [0.7, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isCashBack
                                            ? 'cashback_uppercase'.tr
                                            : 'save_uppercase'.tr,
                                        style: robotoBold.copyWith(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                      Text(
                                        _formatVoucherPrice(discount),
                                        style: robotoBlack.copyWith(
                                            color: Colors.white,
                                            fontSize: 20,
                                            height: 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Store Info Row (Hide for gift vouchers, show for others)
                          if (!isGift)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CustomImage(
                                        image: storeLogo ??
                                            item.storeLogoFullUrl ??
                                            '',
                                        height: 38,
                                        width: 38,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      item.storeName ?? '',
                                      style: robotoBlack.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                if ((order?.giftDetails != null ||
                                    orderDetail.giftDetails != null))
                                  // Show vector image only if has giftDetails
                                  Image.asset(Images.vector,
                                      height: 24, width: 24)
                                else
                                  // Show price for normal vouchers
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (discount > 0 && !isCashBack)
                                        Text(
                                          _formatVoucherPrice(originalPrice),
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
                                        _formatVoucherPrice(price),
                                        style: robotoBlack.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                          // Description section removed

                          const SizedBox(height: 12),
                          // Expiry Date
                          if (item.validUntil != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeSmall),
                              child: Text(
                                'expires_on_with_date'
                                    .trParams({'date': item.validUntil ?? ''}),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // QR Code Section OR Flat Voucher Summary
                    if (isFlat && order != null)
                      _buildFlatVoucherSummary(context, order!)
                    else if (!isFlat &&
                        qrCode != null &&
                        qrCode!.isNotEmpty) ...[
                      // Divider line before QR section
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        color: Colors.grey[200],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeDefault),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 180,
                              child: Stack(
                                children: [
                                  // Top Info (Top-Start): Expiry Date if present, otherwise Bundle ID
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    top: 0,
                                    start: 0,
                                    child: (item.validUntil != null)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'expires_on_colon'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.validUntil!,
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'voucher_id_colon'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (item.voucherIds != null &&
                                                        item.voucherIds!
                                                            .isNotEmpty)
                                                    ? item.voucherIds!
                                                    : '#${orderDetail.orderId}',
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),

                                  // QR Code (Slightly Up and Left from Center)
                                  Positioned(
                                    top: 20,
                                    left: -6, // Nudged left
                                    right: 0,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeExtraSmall),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                        child: QrImageView(
                                          data: qrCode!,
                                          version: QrVersions.auto,
                                          size: 145,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Action Buttons (Bottom-Start - Moved Up)
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    bottom: 15,
                                    start: 0,
                                    child: InkWell(
                                      onTap: () {
                                        Share.share(
                                            'https://fortestingweb.com/share-voucher/$qrCode');
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.share_outlined,
                                              size: 22, color: Colors.black54),
                                          const SizedBox(height: 4),
                                          Text(
                                            'share_text'.tr,
                                            style: robotoRegular.copyWith(
                                              fontSize: 10,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Voucher Code (Center-End - Shifted Right)
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    top: 0,
                                    bottom: 0,
                                    end: -1,
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'voucher_code_colon'.tr,
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            qrCode!,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8), // Reduced spacing

                            // Row(
                            //   children: [
                            //     _buildActionButton(
                            //       context,
                            //       icon: Icons.share,
                            //       label: 'Share',
                            //       color: Colors.black,
                            //       onTap: () {
                            //         Share.share(
                            //             'https://fortestingweb.com/share-voucher/$qrCode');
                            //       },
                            //     ),
                            //     const SizedBox(
                            //         width: Dimensions.paddingSizeDefault),
                            //     // _buildActionButton(
                            //     //   context,
                            //     //   icon: Icons.download,
                            //     //   label: 'Download',
                            //     //   color: Colors.black,
                            //     //   onTap: () {
                            //     //     // TODO: Implement download functionality
                            //     //   },
                            //     // ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),

                      // Divider line after QR section
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        color: Colors.grey[200],
                      ),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    if ((order?.giftDetails != null ||
                        orderDetail.giftDetails != null))
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: gradientColors[0].withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'to_colon'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).primaryColor),
                                ),
                                Text(
                                  (order?.giftDetails ??
                                              orderDetail.giftDetails)!
                                          .recipientName ??
                                      '',
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (order?.giftDetails ?? orderDetail.giftDetails)!
                                      .message ??
                                  '',
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (order?.giftDetails ?? orderDetail.giftDetails)!
                                      .senderName ??
                                  '',
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Expandable sections (Voucher Info, Redemption, Usage Terms)
                    if (expandableSections != null) ...expandableSections!,

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Branded Footer Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Images.elaklogo,
                                  height: 22, width: 22),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                'powered_by_yellow_pages'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(Images.logo, height: 22, width: 22),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                'arabi_value_text'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatVoucherSummary(BuildContext context, OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('discount_summary'.tr,
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildSummaryRow(
            'total_amount'.tr,
            _formatVoucherPrice(order.orderAmount),
            isBold: true,
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            'discount_type'.tr,
            order.offerType?.tr ?? 'direct_discount'.tr,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'total_discount'.tr,
            '- ${_formatVoucherPrice(order.discountAmount)}',
            textColor: Colors.red,
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            'amount_paid'.tr,
            _formatVoucherPrice(order.totalOrderAmount),
            isBold: true,
            fontSize: Dimensions.fontSizeLarge,
            textColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, double? fontSize, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: robotoRegular.copyWith(
              fontSize: fontSize ?? Dimensions.fontSizeDefault,
              color: Colors.grey[600],
            )),
        Text(value,
            style: isBold
                ? robotoBold.copyWith(
                    fontSize: fontSize ?? Dimensions.fontSizeDefault,
                    color: textColor ?? Colors.black)
                : robotoMedium.copyWith(
                    fontSize: fontSize ?? Dimensions.fontSizeDefault,
                    color: textColor ?? Colors.black)),
      ],
    );
  }

  List<Color> _getVoucherColors(Item item) {
    Color primaryColor = Get.context != null
        ? Theme.of(Get.context!).primaryColor
        : const Color(0xFF2196F3);

    String type = (item.voucherType ?? '').toLowerCase();
    String bundle = (item.bundleType ?? '').toLowerCase();
    String ids = (item.voucherIds ?? '')
        .toLowerCase(); // User identified type string might be here

    if (bundle.contains('gift') ||
        type.contains('gift') ||
        ids.contains('gift')) {
      return [const Color(0xFF6A4DF4), const Color(0xFFC084FC)];
    } else if (type.contains('delivery') ||
        type.contains('pickup') ||
        ids.contains('delivery') ||
        ids.contains('pickup')) {
      return [const Color(0xFFF43F8C), const Color(0xFFFB8B5E)];
    } else if (type.contains('in-store') ||
        type.contains('instore') ||
        type.contains('in store') ||
        ids.contains('in-store') ||
        ids.contains('instore') ||
        ids.contains('in store')) {
      return [const Color(0xFF1ABC9C), const Color(0xFFA8E063)];
    } else if (type.contains('flat') ||
        type.contains('discount') ||
        ids.contains('flat') ||
        ids.contains('discount')) {
      return [const Color(0xFFFF8A2B), const Color(0xFFFFD54F)];
    }

    return [primaryColor, primaryColor.withValues(alpha: 0.7)];
  }

  String _formatVoucherPrice(double? value) {
    if (value == null) return PriceConverter.convertPrice(0);
    return "${Get.find<splash.SplashController>().configModel!.currencySymbol}${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}";
  }
}
