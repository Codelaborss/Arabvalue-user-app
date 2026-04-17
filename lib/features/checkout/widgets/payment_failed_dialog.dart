import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String? orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool? isCashOnDelivery;
  final String guestId;

  /// Optional: full order model — used to detect voucher type and
  /// show the custom payment-failed UI for voucher orders.
  final OrderModel? orderModel;

  const PaymentFailedDialog({
    super.key,
    required this.orderID,
    required this.maxCodOrderAmount,
    required this.orderAmount,
    required this.orderType,
    required this.isCashOnDelivery,
    required this.guestId,
    this.orderModel,
  });

  bool get _isFlat {
    String? vType = orderModel?.voucherType?.toLowerCase() ?? '';
    bool isFlat = vType.contains('flat');
    debugPrint(
        'PaymentFailedDialog: _isFlat check = $isFlat (voucherType: ${orderModel?.voucherType})');
    return isFlat;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'PaymentFailedDialog: Building Dialog (orderID: $orderID, isVoucher: true [Force Custom UI])');
    // User requested to show this custom dialog for EVERYTHING (vouchers and regular products)
    return _buildVoucherFailedDialog(context);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Custom UI — Voucher payment failure
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildVoucherFailedDialog(BuildContext context) {
    final String paymentMethod =
        (orderModel?.paymentMethod ?? '').replaceAll('_', ' ').toUpperCase();

    // Flat-only amounts
    final double couponDisc = orderModel?.couponDiscountAmount ?? 0;
    final double storeDisc = orderModel?.storeDiscountAmount ?? 0;
    final double directDisc = orderModel?.discountAmount ?? 0;
    final double totalDiscount = couponDisc + storeDisc + directDisc;

    debugPrint(
        'PaymentFailedDialog: RAW DATA FROM MODEL -> voucherType: ${orderModel?.voucherType}, offerType: ${orderModel?.offerType}, discountAmount: ${orderModel?.discountAmount}, totalOrderAmount: ${orderModel?.totalOrderAmount}');
    debugPrint(
        'PaymentFailedDialog: UI CALCULATION -> totalDiscount: $totalDiscount, isFlat: $_isFlat');

    final double payable = orderModel?.orderAmount ?? orderAmount ?? 0;
    final double totalBeforeDiscount = (orderModel?.totalOrderAmount ?? 0) > 0
        ? orderModel!.totalOrderAmount!
        : (payable + totalDiscount);

    String offerLabel = '';
    if (orderModel?.offerType != null && orderModel!.offerType!.isNotEmpty) {
      offerLabel =
          ' (${orderModel!.offerType!.replaceAll('_', ' ').capitalizeFirst})';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Unsuccessful',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.red,
                    ),
                  ),
                ),
              ]),
              const Divider(height: Dimensions.paddingSizeLarge),

              // ── Order ID ──────────────────────────────────────────────────
              Text(
                'Order #$orderID',
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: 4),

              // ── Reason ────────────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  'Reason: Payment not completed',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // ── Flat-only: Order Details section ─────────────────────────
              if (_isFlat) ...[
                _sectionLabel('ORDER DETAILS (APPROVED BY VENDOR)'),
                const SizedBox(height: 6),
                _detailRow(
                  context,
                  'Total Amount',
                  PriceConverter.convertPrice(totalBeforeDiscount),
                ),
                if (totalDiscount > 0)
                  _detailRow(
                    context,
                    'Discount$offerLabel',
                    '-${PriceConverter.convertPrice(totalDiscount)}',
                    valueColor: Colors.green,
                  ),
                _detailRow(
                  context,
                  'Payable Now',
                  PriceConverter.convertPrice(payable),
                  bold: true,
                ),
                const Divider(height: Dimensions.paddingSizeLarge),
              ],

              // ── Payment method ────────────────────────────────────────────
              _sectionLabel('PAYMENT METHOD'),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.credit_card, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text(
                  paymentMethod.isNotEmpty ? paymentMethod : 'Card',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // ── Action buttons ────────────────────────────────────────────
              GetBuilder<OrderController>(builder: (orderController) {
                return !orderController.isLoading
                    ? Column(children: [
                        if (isCashOnDelivery! &&
                            (Get.find<SplashController>()
                                .configModel!
                                .cashOnDelivery!)) ...[
                          CustomButton(
                            buttonText: 'switch_to_cash_on_delivery'.tr,
                            onPressed: () {
                              if ((((maxCodOrderAmount != null &&
                                              orderAmount! <
                                                  maxCodOrderAmount!) ||
                                          maxCodOrderAmount == null ||
                                          maxCodOrderAmount == 0) &&
                                      orderType != 'parcel') ||
                                  orderType == 'parcel') {
                                orderController
                                    .switchToCOD(orderID,
                                        guestId:
                                            guestId.isNotEmpty ? guestId : null)
                                    .then((success) {
                                  if (success) {
                                    double total = ((orderAmount! / 100) *
                                        Get.find<SplashController>()
                                            .configModel!
                                            .loyaltyPointItemPurchasePoint!);
                                    if (AuthHelper.isLoggedIn()) {
                                      Get.find<AuthController>()
                                          .saveEarningPoint(
                                              total.toStringAsFixed(0));
                                    }
                                  }
                                });
                              } else {
                                if (Get.isDialogOpen!) {
                                  Get.back();
                                }
                                showCustomSnackBar(
                                    '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                              }
                            },
                            radius: Dimensions.radiusSmall,
                            height: 45,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                        CustomButton(
                          buttonText: 'cancel_order'.tr,
                          onPressed: () {
                            orderController
                                .cancelOrder(int.parse(orderID!),
                                    'Digital payment issue',
                                    guestId:
                                        guestId.isNotEmpty ? guestId : null)
                                .then((success) {
                              if (success) {
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }
                            });
                          },
                          radius: Dimensions.radiusSmall,
                          height: 45,
                          color: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.2),
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ])
                    : const Center(child: CircularProgressIndicator());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // ── Footnote ──────────────────────────────────────────────────
              Text(
                'This order is saved in your history. You can retry or change your payment method.',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: robotoMedium.copyWith(
        fontSize: Dimensions.fontSizeExtraSmall,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ),
        Text(
          value,
          style: (bold ? robotoBold : robotoMedium).copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ]),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Original generic UI — non-voucher orders (unchanged)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildGenericFailedDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Image.asset(Images.warning, width: 70, height: 70),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                'are_you_agree_with_this_order_fail'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Text(
                'if_you_do_not_pay'.tr,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            GetBuilder<OrderController>(builder: (orderController) {
              return !orderController.isLoading
                  ? Column(children: [
                      isCashOnDelivery!
                          ? CustomButton(
                              buttonText: 'switch_to_cash_on_delivery'.tr,
                              onPressed: () {
                                if ((((maxCodOrderAmount != null &&
                                                orderAmount! <
                                                    maxCodOrderAmount!) ||
                                            maxCodOrderAmount == null ||
                                            maxCodOrderAmount == 0) &&
                                        orderType != 'parcel') ||
                                    orderType == 'parcel') {
                                  orderController
                                      .switchToCOD(orderID,
                                          guestId: guestId.isNotEmpty
                                              ? guestId
                                              : null)
                                      .then((success) {
                                    if (success) {
                                      double total = ((orderAmount! / 100) *
                                          Get.find<SplashController>()
                                              .configModel!
                                              .loyaltyPointItemPurchasePoint!);
                                      if (AuthHelper.isLoggedIn()) {
                                        Get.find<AuthController>()
                                            .saveEarningPoint(
                                                total.toStringAsFixed(0));
                                      }
                                    }
                                  });
                                } else {
                                  if (Get.isDialogOpen!) {
                                    Get.back();
                                  }
                                  showCustomSnackBar(
                                      '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                                }
                              },
                              radius: Dimensions.radiusSmall,
                              height: 40,
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: Get.find<SplashController>()
                                  .configModel!
                                  .cashOnDelivery!
                              ? Dimensions.paddingSizeLarge
                              : 0),
                      TextButton(
                        onPressed: () {
                          Get.find<OrderController>()
                              .cancelOrder(
                                  int.parse(orderID!), 'Digital payment issue',
                                  guestId: guestId.isNotEmpty ? guestId : null)
                              .then((success) {
                            if (success) {
                              Get.offAllNamed(RouteHelper.getInitialRoute());
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.3),
                          minimumSize: const Size(Dimensions.webMaxWidth, 40),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall)),
                        ),
                        child: Text('cancel_order'.tr,
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color)),
                      ),
                    ])
                  : const Center(child: CircularProgressIndicator());
            }),
          ]),
        ),
      ),
    );
  }
}
