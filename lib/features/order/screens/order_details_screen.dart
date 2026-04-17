import 'dart:async';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/checkout/widgets/offline_success_dialog.dart';
import 'package:sixam_mart/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_calcuation_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_info_widget.dart';
import 'package:sixam_mart/features/order/widgets/voucher_order_card_widget.dart';
import 'package:sixam_mart/features/order/widgets/expandable_voucher_section.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromNotification;
  final bool fromOfflinePayment;
  final String? contactNumber;
  const OrderDetailsScreen(
      {super.key,
      required this.orderModel,
      required this.orderId,
      this.fromNotification = false,
      this.fromOfflinePayment = false,
      this.contactNumber});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;
  double? _maxCodOrderAmount;
  bool? _isCashOnDeliveryActive = false;
  final ScrollController scrollController = ScrollController();

  void _loadData(BuildContext context, bool reload) async {
    await Get.find<OrderController>()
        .trackOrder(
            widget.orderId.toString(), reload ? null : widget.orderModel, false,
            contactNumber: widget.contactNumber)
        .then((value) {
      if (widget.fromOfflinePayment) {
        Future.delayed(
            const Duration(seconds: 2),
            () => showAnimatedDialog(
                Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      }
    });
    Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(),
        contactNumber: widget.contactNumber);
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
  }

  void _startApiCall() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await Get.find<OrderController>().timerTrackOrder(
          widget.orderId.toString(),
          contactNumber: widget.contactNumber);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData(context, false);

    _startApiCall();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification || widget.fromOfflinePayment) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'order_details'.tr,
            onBackPressed: () {
              if (widget.fromNotification || widget.fromOfflinePayment) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
            child: GetBuilder<OrderController>(builder: (orderController) {
          double deliveryCharge = 0;
          double itemsPrice = 0;
          double discount = 0;
          double couponDiscount = 0;
          double tax = 0;
          double addOns = 0;
          double dmTips = 0;
          double additionalCharge = 0;
          double extraPackagingCharge = 0;
          double referrerBonusAmount = 0;
          OrderModel? order = orderController.trackModel;
          bool parcel = false;
          bool prescriptionOrder = false;
          bool taxIncluded = false;
          bool ongoing = false;
          bool showChatPermission = true;
          if (orderController.orderDetails != null && order != null) {
            parcel = order.orderType == 'parcel';
            prescriptionOrder = order.prescriptionOrder!;
            deliveryCharge = order.deliveryCharge!;
            couponDiscount = order.couponDiscountAmount!;
            discount = order.storeDiscountAmount! +
                order.flashAdminDiscountAmount! +
                order.flashStoreDiscountAmount!;
            tax = order.totalTaxAmount!;
            dmTips = order.dmTips!;
            taxIncluded = order.taxStatus!;
            additionalCharge = order.additionalCharge!;
            extraPackagingCharge = order.extraPackagingAmount!;
            referrerBonusAmount = order.referrerBonusAmount!;
            if (prescriptionOrder) {
              double orderAmount =
                  order.totalOrderAmount ?? order.orderAmount ?? 0;
              itemsPrice = (orderAmount + discount) -
                  ((taxIncluded ? 0 : tax) + deliveryCharge) -
                  dmTips -
                  additionalCharge;
            } else {
              for (OrderDetailsModel orderDetails
                  in orderController.orderDetails!) {
                /*for(AddOn addOn in orderDetails.addOns!) {
                  addOns = addOns + (addOn.price! * addOn.quantity!);
                }*/
                itemsPrice =
                    itemsPrice + (orderDetails.price! * orderDetails.quantity!);
              }
            }

            if (!parcel && order.store != null) {
              for (ZoneData zData
                  in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
                if (zData.id == order.store!.zoneId) {
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
                for (Modules m in zData.modules!) {
                  if (m.id == order.store!.moduleId) {
                    _maxCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
              }
            }

            if (order.store != null) {
              if (order.store!.storeBusinessModel == 'commission') {
                showChatPermission = true;
              } else if (order.store!.storeSubscription != null &&
                  order.store!.storeBusinessModel == 'subscription') {
                showChatPermission = order.store!.storeSubscription!.chat == 1;
              } else {
                showChatPermission = false;
              }
            } else {
              showChatPermission = AuthHelper.isLoggedIn();
            }

            ongoing = (order.orderStatus != 'delivered' &&
                order.orderStatus != 'failed' &&
                order.orderStatus != 'canceled' &&
                order.orderStatus != 'refund_requested' &&
                order.orderStatus != 'refunded' &&
                order.orderStatus != 'refund_request_canceled');
          }
          double subTotal = itemsPrice + addOns;
          double total = itemsPrice +
              addOns -
              discount +
              (taxIncluded ? 0 : tax) +
              deliveryCharge -
              couponDiscount +
              dmTips +
              additionalCharge +
              extraPackagingCharge -
              referrerBonusAmount;

          // Check if this is a voucher order
          bool isVoucherOrder = _isVoucherOrder(orderController.orderDetails);

          return orderController.orderDetails != null &&
                  order != null &&
                  orderController.trackModel != null
              ? Column(children: [
                  ResponsiveHelper.isDesktop(context)
                      ? Container(
                          height: 64,
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.10),
                          child: Center(
                              child: Text('order_details'.tr,
                                  style: robotoMedium)),
                        )
                      : const SizedBox(),
                  Expanded(
                      child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: isVoucherOrder
                        ? FooterView(
                            child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: _buildVoucherOrderUI(
                                orderController, order, parcel, total),
                          ))
                        : FooterView(
                            child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(
                                  children: [
                                    ResponsiveHelper.isDesktop(context)
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: OrderInfoWidget(
                                                    order: order,
                                                    ongoing: ongoing,
                                                    parcel: parcel,
                                                    prescriptionOrder:
                                                        prescriptionOrder,
                                                    timerCancel: () =>
                                                        _timer?.cancel(),
                                                    startApiCall: () =>
                                                        _startApiCall(),
                                                    orderController:
                                                        orderController,
                                                    showChatPermission:
                                                        showChatPermission,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeLarge),
                                                Expanded(
                                                  flex: 4,
                                                  child: OrderCalculationWidget(
                                                    orderController:
                                                        orderController,
                                                    order: order,
                                                    ongoing: ongoing,
                                                    parcel: parcel,
                                                    prescriptionOrder:
                                                        prescriptionOrder,
                                                    deliveryCharge:
                                                        deliveryCharge,
                                                    itemsPrice: itemsPrice,
                                                    discount: discount,
                                                    couponDiscount:
                                                        couponDiscount,
                                                    tax: tax,
                                                    addOns: addOns,
                                                    dmTips: dmTips,
                                                    taxIncluded: taxIncluded,
                                                    subTotal: subTotal,
                                                    total: total,
                                                    bottomView: _bottomView(
                                                        orderController,
                                                        order,
                                                        parcel,
                                                        total),
                                                    extraPackagingAmount:
                                                        extraPackagingCharge,
                                                    referrerBonusAmount:
                                                        referrerBonusAmount,
                                                    timerCancel: () =>
                                                        _timer?.cancel(),
                                                    startApiCall: () =>
                                                        _startApiCall(),
                                                  ),
                                                ),
                                              ])
                                        : const SizedBox(),
                                    ResponsiveHelper.isDesktop(context)
                                        ? const SizedBox()
                                        : OrderInfoWidget(
                                            order: order,
                                            ongoing: ongoing,
                                            parcel: parcel,
                                            prescriptionOrder:
                                                prescriptionOrder,
                                            timerCancel: () => _timer?.cancel(),
                                            startApiCall: () => _startApiCall(),
                                            orderController: orderController,
                                            showChatPermission:
                                                showChatPermission,
                                          ),
                                    ResponsiveHelper.isDesktop(context)
                                        ? const SizedBox()
                                        : OrderCalculationWidget(
                                            orderController: orderController,
                                            order: order,
                                            ongoing: ongoing,
                                            parcel: parcel,
                                            prescriptionOrder:
                                                prescriptionOrder,
                                            deliveryCharge: deliveryCharge,
                                            itemsPrice: itemsPrice,
                                            discount: discount,
                                            couponDiscount: couponDiscount,
                                            tax: tax,
                                            addOns: addOns,
                                            dmTips: dmTips,
                                            taxIncluded: taxIncluded,
                                            subTotal: subTotal,
                                            total: total,
                                            bottomView: _bottomView(
                                                orderController,
                                                order,
                                                parcel,
                                                total),
                                            extraPackagingAmount:
                                                extraPackagingCharge,
                                            referrerBonusAmount:
                                                referrerBonusAmount,
                                            timerCancel: () => _timer?.cancel(),
                                            startApiCall: () => _startApiCall(),
                                          ),
                                  ],
                                ))),
                  )),
                  ResponsiveHelper.isDesktop(context)
                      ? const SizedBox()
                      : _bottomView(orderController, order, parcel, total),
                ])
              : const Center(child: CircularProgressIndicator());
        })),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                child: PhotoView(
                  tightMode: true,
                  imageProvider: NetworkImage(imageUrl),
                  heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    splashRadius: 5,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                  )),
            ]),
          );
        },
      );

  Widget _bottomView(OrderController orderController, OrderModel order,
      bool parcel, double totalPrice) {
    return Column(children: [
      !orderController.showCancelled
          ? Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(children: [
                  const SizedBox(),
                  (order.orderStatus == 'pending' &&
                          order.paymentStatus == 'unpaid' &&
                          order.paymentMethod == 'digital_payment' &&
                          _isCashOnDeliveryActive!)
                      ? CustomButton(
                          buttonText: 'switch_to_cod'.tr,
                          margin: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall),
                          onPressed: () {
                            Get.dialog(ConfirmationDialog(
                                icon: Images.warning,
                                description: 'are_you_sure_to_switch'.tr,
                                onYesPressed: () {
                                  if ((((_maxCodOrderAmount != null &&
                                                  totalPrice <
                                                      _maxCodOrderAmount!) ||
                                              _maxCodOrderAmount == null ||
                                              _maxCodOrderAmount == 0) &&
                                          !parcel) ||
                                      parcel) {
                                    orderController
                                        .switchToCOD(order.id.toString());
                                  } else {
                                    if (Get.isDialogOpen!) {
                                      Get.back();
                                    }
                                    showCustomSnackBar(
                                        '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                                  }
                                }));
                          },
                        )
                      : const SizedBox(),
                  (order.orderStatus == 'pending' &&
                          (Get.find<AuthController>().isLoggedIn()
                              ? true
                              : (orderController.orderDetails != null &&
                                      orderController
                                          .orderDetails!.isNotEmpty &&
                                      orderController
                                              .orderDetails?[0].isGuest ==
                                          1
                                  ? true
                                  : false)))
                      ? Padding(
                          padding: ResponsiveHelper.isDesktop(context)
                              ? EdgeInsets.zero
                              : const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall),
                          child: CustomButton(
                            isBorder: true,
                            color: Colors.transparent,
                            onPressed: () {
                              orderController.setOrderCancelReason('');
                              Get.dialog(CancellationDialogueWidget(
                                  orderId: order.id,
                                  contactNumber: widget.contactNumber));
                            },
                            buttonText: parcel
                                ? 'cancel_delivery'.tr
                                : 'cancel_order'.tr,
                            textColor: Theme.of(context).disabledColor,
                          ),
                        )
                      : const SizedBox(),
                ]),
              ),
            )
          : Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                height: 50,
                margin: ResponsiveHelper.isDesktop(context)
                    ? null
                    : const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2, color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text('order_cancelled'.tr,
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor)),
              ),
            ),
      !AuthHelper.isGuestLoggedIn() &&
              (order.orderStatus == 'delivered' &&
                  (parcel
                      ? order.deliveryMan != null
                      : (orderController.orderDetails!.isNotEmpty &&
                          orderController.orderDetails![0].itemCampaignId ==
                              null)))
          ? Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                padding: ResponsiveHelper.isDesktop(context)
                    ? null
                    : const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall),
                child: CustomButton(
                  buttonText: 'review'.tr,
                  onPressed: () {
                    List<OrderDetailsModel> orderDetailsList = [];
                    List<int?> orderDetailsIdList = [];
                    for (var orderDetail in orderController.orderDetails!) {
                      if (orderDetail.itemDetails != null &&
                          !orderDetailsIdList
                              .contains(orderDetail.itemDetails!.id)) {
                        orderDetailsList.add(orderDetail);
                        orderDetailsIdList.add(orderDetail.itemDetails!.id);
                      }
                    }
                    Get.toNamed(RouteHelper.getReviewRoute(),
                        arguments: RateReviewScreen(
                          orderDetailsList: orderDetailsList,
                          deliveryMan: order.deliveryMan,
                          orderID: order.id,
                        ));
                  },
                ),
              ),
            )
          : const SizedBox(),
      (order.orderStatus == 'failed' &&
              Get.find<SplashController>().configModel!.cashOnDelivery!)
          ? Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  buttonText: 'switch_to_cash_on_delivery'.tr,
                  onPressed: () {
                    Get.dialog(ConfirmationDialog(
                        icon: Images.warning,
                        description: 'are_you_sure_to_switch'.tr,
                        onYesPressed: () {
                          orderController
                              .switchToCOD(order.id.toString())
                              .then((isSuccess) {
                            Get.back();
                            if (isSuccess) {
                              Get.back();
                            }
                          });
                        }));
                  },
                ),
              ),
            )
          : const SizedBox(),
    ]);
  }

  bool _isVoucherOrder(List<OrderDetailsModel>? orderDetails) {
    if (orderDetails == null || orderDetails.isEmpty) return false;

    // Check if any item in the order is a voucher
    for (var detail in orderDetails) {
      if (detail.itemDetails?.type == 'voucher') {
        return true;
      }
    }
    return false;
  }

  Widget _buildVoucherOrderUI(OrderController orderController, OrderModel order,
      bool parcel, double total) {
    // Get the first voucher item (assuming one voucher per order)
    OrderDetailsModel? voucherDetail;
    for (var detail in orderController.orderDetails!) {
      if (detail.itemDetails?.type == 'voucher') {
        voucherDetail = detail;
        break;
      }
    }

    if (voucherDetail == null) return const SizedBox();

    Item? item = voucherDetail.itemDetails;
    if (item == null) return const SizedBox();

    // Extract QR code from order object (from track API)
    String? qrCode = order.qrCode;

    // Use branches from voucherDetail if available (newly parsed fields)
    List<Store>? branches = voucherDetail.branches ?? item.branches;

    // Parse branches from branch_ids as fallback
    if ((branches == null || branches.isEmpty) &&
        item.branchIds != null &&
        item.branchIds!.isNotEmpty) {
      try {
        dynamic branchData = item.branchIds;
        if (branchData is String &&
            branchData.isNotEmpty &&
            branchData != 'null') {
          branchData = jsonDecode(branchData);
        }
      } catch (e) {}
    }

    // Use how_it_works from voucherDetail or order
    List<HowItWorks>? howItWorks = voucherDetail.howItWorks ?? item.howItWorks;
    if (order.voucherUsageTerms != null &&
        order.voucherUsageTerms!.isNotEmpty) {
      howItWorks = order.voucherUsageTerms;
    }

    // Use voucherSettings from order
    VoucherSettings? voucherSettings = order.voucherSettings;
    List<Item>? voucherProducts = voucherDetail.products ?? [];
    if (voucherProducts.isEmpty) {
      if (item.product != null) {
        voucherProducts.addAll(item.product!);
      }
      if (item.productB != null) {
        voucherProducts.addAll(item.productB!);
      }
    }

    // Get store logo from branches (first branch ki logo use karenge)
    String? storeLogo;
    if (branches != null && branches.isNotEmpty) {
      storeLogo = branches.first.logoFullUrl;
    }

    // Get actual product order items (non-voucher) with selected variation/addons
    List<OrderDetailsModel> orderProductItems = orderController.orderDetails!
        .where((d) => d.itemDetails?.type != 'voucher')
        .toList();

    // Build expandable sections list
    List<Widget> expandableSections = [];

    // Voucher Info Section — use actual order product items if available
    bool hasVoucherInfo = (item.bundleType == 'simple x') ||
        ((orderProductItems.isNotEmpty || voucherProducts.isNotEmpty) &&
            item.bundleType != 'gift');
    if (hasVoucherInfo) {
      expandableSections.add(
        ExpandableVoucherSection(
          title: 'Voucher Info',
          voucherProducts: voucherProducts,
          orderProductDetails:
              orderProductItems.isNotEmpty ? orderProductItems : null,
          bundleType: item.bundleType,
          type: VoucherSectionType.voucherInfo,
          hasGiftDetail:
              (order.giftDetails != null || voucherDetail.giftDetails != null),
          item: item,
          order: order,
        ),
      );
    }

    // Gift Voucher Info Section
    if (item.bundleType == 'gift') {
      expandableSections.add(
        ExpandableVoucherSection(
          title: 'Voucher Info',
          item: item,
          order: order,
          bundleType: item.bundleType,
          hasGiftDetail:
              (order.giftDetails != null || voucherDetail.giftDetails != null),
          type: VoucherSectionType.giftVoucherInfo,
        ),
      );
    }

    // Redemption at Outlets Section
    if (branches != null && branches.isNotEmpty) {
      expandableSections.add(
        ExpandableVoucherSection(
          title:
              'Redeemable at ${branches.length} ${branches.length > 1 ? 'outlets' : 'outlet'}',
          branches: branches,
          type: VoucherSectionType.branches,
          item: item,
        ),
      );
    }

    // Usage Term Section
    if (voucherSettings != null) {
      expandableSections.add(
        ExpandableVoucherSection(
          title: 'Usage Term',
          voucherSettings: voucherSettings,
          type: VoucherSectionType.usageTerms,
        ),
      );
    }

    // How to use cards Section
    if (howItWorks != null && howItWorks.isNotEmpty) {
      expandableSections.add(
        ExpandableVoucherSection(
          title: 'How to use card',
          howItWorks: howItWorks,
          type: VoucherSectionType.howToUse,
        ),
      );
    }

    return Column(
      children: [
        // Voucher Card with all sections inside
        VoucherOrderCardWidget(
          orderDetail: voucherDetail,
          order: order,
          qrCode: qrCode,
          storeLogo: storeLogo,
          expandableSections: expandableSections,
        ),

        ResponsiveHelper.isDesktop(context)
            ? _bottomView(orderController, order, parcel, total)
            : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }
}
