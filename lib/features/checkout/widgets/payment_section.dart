import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';

class PaymentSection extends StatelessWidget {
  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final CheckoutController checkoutController;
  final bool isOfflinePaymentActive;
  const PaymentSection({
    super.key,
    this.storeId,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
            storeId != null ? 'payment_method'.tr : 'choose_payment_method'.tr,
            style: robotoBold.copyWith(color: Colors.black)),
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      SizedBox(
          height: !ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeSmall
              : 0),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Colors.white,
          border: Border.all(color: Colors.grey.withAlpha(200), width: 1),
        ),
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault),
        child: storeId != null
            ? checkoutController.paymentMethodIndex == 0
                ? Row(children: [
                    Image.asset(
                      Images.cash,
                      width: 20,
                      height: 20,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                        child: Text(
                      'cash_on_delivery'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor),
                    )),
                    Text(
                      PriceConverter.convertPrice(total),
                      textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).primaryColor),
                    )
                  ])
                : const SizedBox()
            : InkWell(
                onTap: () {
                  if (ResponsiveHelper.isDesktop(context)) {
                    Get.dialog(Dialog(
                        backgroundColor: Colors.transparent,
                        child: PaymentMethodBottomSheet(
                          isCashOnDeliveryActive: isCashOnDeliveryActive,
                          isDigitalPaymentActive: isDigitalPaymentActive,
                          isWalletActive: isWalletActive,
                          storeId: storeId,
                          totalPrice: total,
                          isOfflinePaymentActive: isOfflinePaymentActive,
                        )));
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => PaymentMethodBottomSheet(
                        isCashOnDeliveryActive: isCashOnDeliveryActive,
                        isDigitalPaymentActive: isDigitalPaymentActive,
                        isWalletActive: isWalletActive,
                        storeId: storeId,
                        totalPrice: total,
                        isOfflinePaymentActive: isOfflinePaymentActive,
                      ),
                    );
                  }
                },
                child: Row(children: [
                  checkoutController.paymentMethodIndex != -1
                      ? Image.asset(
                          checkoutController.paymentMethodIndex == 0
                              ? Images.cash
                              : checkoutController.paymentMethodIndex == 1
                                  ? Images.wallet
                                  : checkoutController.paymentMethodIndex == 2
                                      ? Images.digitalPayment
                                      : Images.cash,
                          width: 20,
                          height: 20,
                          color: Theme.of(context).disabledColor,
                        )
                      : Icon(
                          Icons.credit_card,
                          size: 20,
                          color: Theme.of(context).disabledColor,
                        ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                      child: Row(children: [
                    Builder(builder: (context) {
                      return Text(
                        checkoutController.paymentMethodIndex == 0
                            ? '${'cash_on_delivery'.tr} ${checkoutController.isPartialPay ? '(${'partial'.tr})' : ''}'
                            : checkoutController.paymentMethodIndex == 1 &&
                                    !checkoutController.isPartialPay
                                ? 'wallet_payment'.tr
                                : checkoutController.paymentMethodIndex == 2
                                    ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''} - ${checkoutController.isPartialPay ? 'partial'.tr : ''})'
                                    : checkoutController.paymentMethodIndex == 3
                                        ? '${'offline_payment'.tr}(${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName} - ${checkoutController.isPartialPay ? 'partial'.tr : ''})'
                                        : !ResponsiveHelper.isDesktop(context)
                                            ? 'select_payment_method'.tr
                                            : 'add_payment_method'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: !ResponsiveHelper.isDesktop(context)
                              ? Theme.of(context).disabledColor
                              : checkoutController.paymentMethodIndex == -1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    checkoutController.paymentMethodIndex == -1 &&
                            !ResponsiveHelper.isDesktop(context)
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.warning_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.error),
                          )
                        : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ])),
                  Icon(Icons.credit_card,
                      size: 24, color: Colors.black.withAlpha(200)),
                ]),
              ),
      ),
    ]);
  }
}
