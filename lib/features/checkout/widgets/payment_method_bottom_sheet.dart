import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/payment/widgets/offline_payment_button.dart';
import 'package:sixam_mart/util/images.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;
  const PaymentMethodBottomSheet(
      {super.key,
      required this.isCashOnDeliveryActive,
      required this.isDigitalPaymentActive,
      required this.isWalletActive,
      required this.storeId,
      required this.totalPrice,
      required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();
  final TextEditingController _amountController = TextEditingController();
  bool showChangeAmount = false;

  @override
  void initState() {
    super.initState();

    configurePartialPayment();
  }

  void configurePartialPayment() {
    if (!AuthHelper.isGuestLoggedIn()) {
      double walletBalance =
          Get.find<ProfileController>().userInfoModel!.walletBalance!;
      if (walletBalance < widget.totalPrice) {
        canSelectWallet = false;
      }
      if (Get.find<CheckoutController>().isPartialPay) {
        notHideWallet = false;
        if (Get.find<SplashController>().configModel!.partialPaymentMethod! ==
            'cod') {
          notHideCod = true;
          notHideDigital = false;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'digital_payment') {
          notHideCod = false;
          notHideDigital = true;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'both') {
          notHideCod = true;
          notHideDigital = true;
        }
      }
      // Removed else block that was hiding wallet
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool isLoggedIn = AuthHelper.isLoggedIn();
    //bool isDesktop = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: 550,
      child: GetBuilder<CheckoutController>(builder: (checkoutController) {
        // Removed disablePayments logic to allow wallet deselection
        bool disablePayments = false;

        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(Dimensions.radiusLarge),
              bottom: Radius.circular(ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusLarge
                  : 0),
            ),
          ),
          // padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveHelper.isDesktop(context)
                    ? Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.clear),
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 4,
                          width: 35,
                          margin: const EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Align(
                  alignment: Alignment.center,
                  child: Text('payment_method'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.black)),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('choose_payment_method'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Colors.black)),
                      Text('click_one_of_the_option_below'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor)),
                    ],
                  ),
                ),
                // const SizedBox(height: Dimensions.paddingSizeSmall),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeSmall),
                    child: Column(
                      children: [
                        widget.isWalletActive && notHideWallet
                            ? paymentButtonView(
                                title: 'pay_via_wallet'.tr,
                                subtitle:
                                    '${'current_balance'.tr}: ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}',
                                isSelected:
                                    checkoutController.paymentMethodIndex == 1,
                                disablePayments: false,
                                onTap: () {
                                  if (checkoutController.paymentMethodIndex ==
                                      1) {
                                    checkoutController.setPaymentMethod(-1);
                                  } else {
                                    checkoutController.setPaymentMethod(1);
                                  }
                                },
                              )
                            : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        widget.isCashOnDeliveryActive && notHideCod
                            ? paymentButtonView(
                                title: 'cash_on_delivery'.tr,
                                isSelected:
                                    checkoutController.paymentMethodIndex == 0,
                                image: Images.codIcon,
                                disablePayments: false,
                                onTap: () {
                                  checkoutController.setPaymentMethod(0);
                                },
                              )
                            : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        // changeAmountView(checkoutController),

                        widget.isDigitalPaymentActive && notHideDigital
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: 'pay_via_online'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: Colors.black)),
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                            text:
                                                '(${'faster_and_secure_way_to_pay_bill'.tr})',
                                            style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ]),
                                    ),
                                  ),
                                  ListView.builder(
                                      itemCount: Get.find<SplashController>()
                                          .configModel!
                                          .activePaymentMethodList!
                                          .length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        bool isSelected = checkoutController
                                                    .paymentMethodIndex ==
                                                2 &&
                                            Get.find<SplashController>()
                                                    .configModel!
                                                    .activePaymentMethodList![
                                                        index]
                                                    .getWay! ==
                                                checkoutController
                                                    .digitalPaymentName;

                                        return paymentButtonView(
                                          disablePayments: disablePayments,
                                          onTap: disablePayments
                                              ? null
                                              : () {
                                                  checkoutController
                                                      .setPaymentMethod(2);
                                                  checkoutController
                                                      .changeDigitalPaymentName(Get
                                                              .find<
                                                                  SplashController>()
                                                          .configModel!
                                                          .activePaymentMethodList![
                                                              index]
                                                          .getWay!);
                                                },
                                          title: Get.find<SplashController>()
                                              .configModel!
                                              .activePaymentMethodList![index]
                                              .getWayTitle!,
                                          isSelected: isSelected,
                                          image: Get.find<SplashController>()
                                              .configModel!
                                              .activePaymentMethodList![index]
                                              .getWayImageFullUrl,
                                        );
                                      }),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        widget.isOfflinePaymentActive
                            ? OfflinePaymentButton(
                                isSelected:
                                    checkoutController.paymentMethodIndex == 3,
                                offlineMethodList:
                                    checkoutController.offlineMethodList,
                                isOfflinePaymentActive:
                                    widget.isOfflinePaymentActive,
                                onTap: disablePayments
                                    ? null
                                    : () =>
                                        checkoutController.setPaymentMethod(3),
                                checkoutController: checkoutController,
                                tooltipController: tooltipController,
                                disablePayment: disablePayments,
                              )
                            : const SizedBox(),

                        // Row(children: [
                        //   widget.isCashOnDeliveryActive && notHideCod ? Expanded(
                        //     child: Padding(
                        //       padding: EdgeInsets.only(right: widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Dimensions.paddingSizeSmall : 0),
                        //       child: PaymentButtonNew(
                        //         icon: Images.codIcon,
                        //         title: 'cash_on_delivery'.tr,
                        //         isSelected: checkoutController.paymentMethodIndex == 0,
                        //         onTap: () {
                        //           checkoutController.setPaymentMethod(0);
                        //         },
                        //       ),
                        //     ),
                        //   ) : const SizedBox(),
                        //   // SizedBox(width: widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? 0 : Dimensions.paddingSizeLarge),
                        //
                        //   widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Expanded(
                        //     child: Padding(
                        //       padding: EdgeInsets.only(left: widget.isCashOnDeliveryActive && notHideCod ? Dimensions.paddingSizeSmall : 0),
                        //       child: PaymentButtonNew(
                        //         icon: Images.partialWallet,
                        //         title: 'pay_via_wallet'.tr,
                        //         isSelected: checkoutController.paymentMethodIndex == 1,
                        //         onTap: () {
                        //           if(canSelectWallet) {
                        //             checkoutController.setPaymentMethod(1);
                        //           } else if(checkoutController.isPartialPay){
                        //             showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                        //             Get.back();
                        //           } else{
                        //             showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                        //             Get.back();
                        //           }
                        //         },
                        //       ),
                        //     ),
                        //   ) : const SizedBox(),
                        //
                        // ]),
                        // const SizedBox(height: Dimensions.paddingSizeLarge),
                        //
                        // widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Row(children: [
                        //   Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        //   Text(
                        //     'faster_and_secure_way_to_pay_bill'.tr,
                        //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                        //   ),
                        // ]) : const SizedBox(),
                        // SizedBox(height: widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Dimensions.paddingSizeLarge : 0),
                        //
                        // widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? ListView.builder(
                        //     physics: const NeverScrollableScrollPhysics(),
                        //     shrinkWrap: true,
                        //     padding: EdgeInsets.zero,
                        //     itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                        //     itemBuilder: (context, index) {
                        //       bool isSelected = checkoutController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == checkoutController.digitalPaymentName;
                        //       return InkWell(
                        //         onTap: (){
                        //           checkoutController.setPaymentMethod(2);
                        //           checkoutController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                        //         },
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //               color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        //               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        //               border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5)
                        //           ),
                        //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                        //           margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        //           child: Row(children: [
                        //             Container(
                        //               height: 20, width: 20,
                        //               decoration: BoxDecoration(
                        //                   shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        //                   border: Border.all(color: Theme.of(context).disabledColor)
                        //               ),
                        //               child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                        //             ),
                        //             const SizedBox(width: Dimensions.paddingSizeDefault),
                        //
                        //             Expanded(
                        //               child: Text(
                        //                 Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                        //                 style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                        //                 overflow: TextOverflow.ellipsis, maxLines: 1,
                        //               ),
                        //             ),
                        //
                        //             CustomImage(
                        //               height: 20, fit: BoxFit.contain,
                        //               image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl!,
                        //             ),
                        //             const SizedBox(width: Dimensions.paddingSizeSmall),
                        //           ]),
                        //         ),
                        //       );
                        //     }) : const SizedBox(),

                        // OfflinePaymentButton(
                        //   isSelected: checkoutController.paymentMethodIndex == 3,
                        //   offlineMethodList: checkoutController.offlineMethodList,
                        //   isOfflinePaymentActive: widget.isOfflinePaymentActive,
                        //   onTap: () {
                        //     checkoutController.setPaymentMethod(3);
                        //   },
                        //   checkoutController: checkoutController, tooltipController: tooltipController,
                        // ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault,
                      horizontal: Dimensions.paddingSizeLarge),
                  child: CustomButton(
                    buttonText: 'select'.tr,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ]),
        );
      }),
    );
  }

  Widget changeAmountView(CheckoutController checkoutController) {
    return checkoutController.paymentMethodIndex == 0
        ? Column(
            children: [
              showChangeAmount
                  ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                            color: Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.2)),
                      ),
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      margin: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Dimensions.paddingSizeExtraSmall,
                          children: [
                            Text(
                                '${'change_amount'.tr}(${Get.find<SplashController>().configModel?.currencySymbol})',
                                style: robotoBold),
                            Text(
                                'specify_the_amount_of_change_the_deliveryman_needs_to_bring_when_delivering_the_order'
                                    .tr,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor)),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            CustomTextField(
                              // hintText: 'amount'.tr,
                              titleText: 'amount'.tr,
                              showLabelText: false,
                              inputType: TextInputType.number,
                              isAmount: true,
                              inputAction: TextInputAction.done,
                              controller: _amountController,
                              onChanged: (String value) {
                                checkoutController.setExchangeAmount(
                                    double.tryParse(value) ?? 0);
                              },
                            ),
                          ]),
                    )
                  : const SizedBox(),
              CustomInkWell(
                onTap: () {
                  setState(() {
                    showChangeAmount = !showChangeAmount;
                  });
                },
                radius: Dimensions.radiusSmall,
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Text(showChangeAmount ? 'see_less'.tr : 'see_more'.tr,
                    style: robotoBold.copyWith(color: Colors.blue)),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          )
        : const SizedBox();
  }

  Widget paymentButtonView(
      {required String title,
      String? subtitle,
      String? image,
      required bool isSelected,
      required Function? onTap,
      bool disablePayments = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: CustomInkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                width: isSelected ? 1 : 0.5),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault),
          child: Row(children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 24,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: disablePayments
                            ? Theme.of(context).disabledColor
                            : Colors.black),
                  ),
                  subtitle != null
                      ? Text(
                          subtitle,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            image != null
                ? CustomImage(
                    height: 40,
                    width: 70,
                    fit: BoxFit.contain,
                    image: image,
                    color: disablePayments
                        ? Theme.of(context).disabledColor
                        : null,
                  )
                : const SizedBox(),
          ]),
        ),
      ),
    );
  }
}
