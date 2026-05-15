import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if (Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if (AuthHelper.isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: 'notification'.tr,
            bgColor: Colors.white,
            onBackPressed: () {
              if (widget.fromNotification) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Navigator.pop(context);
              }
            }),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: AuthHelper.isLoggedIn()
            ? GetBuilder<NotificationController>(
                builder: (notificationController) {
                if (notificationController.notificationList != null) {
                  notificationController.saveSeenNotificationCount(
                      notificationController.notificationList!.length);
                }
                List<DateTime> dateTimeList = [];
                return notificationController.notificationList != null
                    ? notificationController.notificationList!.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await notificationController
                                  .getNotificationList(true);
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: FooterView(
                                child: Column(children: [
                                  WebScreenTitleWidget(
                                      title: 'notification'.tr),
                                  Center(
                                    child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: ListView.builder(
                                          itemCount: notificationController
                                              .notificationList!.length,
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            DateTime originalDateTime =
                                                DateConverter
                                                    .dateTimeStringToDate(
                                                        notificationController
                                                            .notificationList![
                                                                index]
                                                            .createdAt!);
                                            DateTime convertedDate = DateTime(
                                                originalDateTime.year,
                                                originalDateTime.month,
                                                originalDateTime.day);
                                            bool addTitle = false;
                                            if (!dateTimeList
                                                .contains(convertedDate)) {
                                              addTitle = true;
                                              dateTimeList.add(convertedDate);
                                            }

                                            bool isSeen = notificationController
                                                .getSeenNotificationIdList()!
                                                .contains(notificationController
                                                    .notificationList![index]
                                                    .id);

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeDefault),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    addTitle
                                                        ? Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                bottom: Dimensions
                                                                    .paddingSizeDefault),
                                                            child: Text(
                                                              DateConverter.convertTodayYesterdayDate(
                                                                  notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .createdAt!),
                                                              style: robotoMedium.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    InkWell(
                                                      onTap: () async {
                                                        final notification =
                                                            notificationController
                                                                    .notificationList![
                                                                index];
                                                        notificationController
                                                            .addSeenNotificationId(
                                                                notification
                                                                    .id!);

                                                        if (notification.data
                                                                    ?.type ==
                                                                'voucher_expiry' &&
                                                            notification.data
                                                                    ?.orderId !=
                                                                null) {
                                                          // 1. Handle voucher expiry - Go to order
                                                          Get.toNamed(RouteHelper
                                                              .getOrderDetailsRoute(
                                                                  notification
                                                                      .data
                                                                      ?.orderId,
                                                                  fromNotification:
                                                                      true));
                                                        } else if (notification
                                                                    .voucher !=
                                                                null &&
                                                            notification
                                                                    .voucherId !=
                                                                null) {
                                                          // 2. Handle voucher notification - Open Item Details
                                                          Get.dialog(
                                                              const Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                              barrierDismissible:
                                                                  false);
                                                          try {
                                                            await Get.find<
                                                                    ItemController>()
                                                                .getItemDetails(
                                                                    itemId: notification
                                                                        .voucherId!);
                                                            Navigator.of(Get
                                                                    .context!)
                                                                .pop();
                                                            showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              useRootNavigator:
                                                                  true,
                                                              context:
                                                                  Get.context!,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(
                                                                        Dimensions
                                                                            .radiusExtraLarge),
                                                                    topRight: Radius.circular(
                                                                        Dimensions
                                                                            .radiusExtraLarge)),
                                                              ),
                                                              builder: (context) =>
                                                                  ConstrainedBox(
                                                                constraints: BoxConstraints(
                                                                    maxHeight: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.9),
                                                                child: ItemBottomSheet(
                                                                    itemId: notification
                                                                        .voucherId!),
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            Navigator.of(Get
                                                                    .context!)
                                                                .pop();
                                                            Get.snackbar(
                                                                'error'.tr,
                                                                'could_not_load_details'
                                                                    .tr);
                                                          }
                                                        } else if (notification
                                                                    .notificationLink !=
                                                                null &&
                                                            notification
                                                                .notificationLink!
                                                                .isNotEmpty) {
                                                          // 3. Handle External Link
                                                          try {
                                                            final Uri url = Uri
                                                                .parse(notification
                                                                    .notificationLink!);
                                                            if (await canLaunchUrl(
                                                                url)) {
                                                              await launchUrl(
                                                                  url,
                                                                  mode: LaunchMode
                                                                      .externalApplication);
                                                            }
                                                          } catch (e) {
                                                            Get.snackbar(
                                                                'error'.tr,
                                                                'invalid_link'
                                                                    .tr);
                                                          }
                                                        } else {
                                                          // 4. Fallback - Show Notification Detail
                                                          ResponsiveHelper
                                                                  .isDesktop(
                                                                      context)
                                                              ? showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return NotificationDialogWidget(
                                                                        notificationModel:
                                                                            notification);
                                                                  })
                                                              : showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  useRootNavigator:
                                                                      true,
                                                                  context: Get
                                                                      .context!,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(Dimensions
                                                                                .radiusExtraLarge),
                                                                        topRight:
                                                                            Radius.circular(Dimensions.radiusExtraLarge)),
                                                                  ),
                                                                  builder:
                                                                      (context) =>
                                                                          ConstrainedBox(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                            maxHeight:
                                                                                MediaQuery.of(context).size.height * 0.8),
                                                                    child: NotificationBottomSheet(
                                                                        notificationModel:
                                                                            notification),
                                                                  ),
                                                                );
                                                        }
                                                      },
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .radiusDefault),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusDefault),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.10),
                                                              blurRadius: 10,
                                                              spreadRadius: 1,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeDefault),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // ── Left Image ──────────────────────────────────────
                                                              _buildNotificationImage(
                                                                  context,
                                                                  notificationController,
                                                                  index),

                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeDefault),

                                                              // ── Right Content ───────────────────────────────────
                                                              Expanded(
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    // Title row with time
                                                                    Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              notificationController.notificationList![index].data!.title ?? '',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: robotoBold.copyWith(
                                                                                fontSize: Dimensions.fontSizeDefault,
                                                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                                                                fontWeight: FontWeight.w700,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: Dimensions.paddingSizeSmall),
                                                                          // Unread dot
                                                                          if (!isSeen)
                                                                            Container(
                                                                              width: 8,
                                                                              height: 8,
                                                                              margin: const EdgeInsets.only(top: 4),
                                                                              decoration: BoxDecoration(
                                                                                color: Theme.of(context).primaryColor,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                        ]),

                                                                    const SizedBox(
                                                                        height:
                                                                            4),

                                                                    // Description
                                                                    Text(
                                                                      notificationController
                                                                              .notificationList![index]
                                                                              .data!
                                                                              .description ??
                                                                          '',
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: robotoRegular
                                                                          .copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeSmall,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.color
                                                                            ?.withValues(alpha: 0.65),
                                                                        height:
                                                                            1.4,
                                                                      ),
                                                                    ),

                                                                    // Voucher Details (if available)
                                                                    if (notificationController
                                                                            .notificationList![
                                                                                index]
                                                                            .voucher !=
                                                                        null)
                                                                      Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                                            Text(
                                                                              notificationController.notificationList![index].voucher!.name ?? '',
                                                                              style: robotoBold.copyWith(
                                                                                fontSize: Dimensions.fontSizeSmall,
                                                                                color: Theme.of(context).primaryColor,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            Text(
                                                                              notificationController.notificationList![index].voucher!.description ?? '',
                                                                              style: robotoRegular.copyWith(
                                                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                                                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.65),
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ]),

                                                                    const SizedBox(
                                                                        height:
                                                                            8),

                                                                    // Bottom row: time
                                                                    Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Row(children: [
                                                                            Icon(Icons.access_time_rounded,
                                                                                size: 11,
                                                                                color: Theme.of(context).hintColor),
                                                                            const SizedBox(width: 3),
                                                                            Text(
                                                                              DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].createdAt!),
                                                                              style: robotoRegular.copyWith(
                                                                                color: Theme.of(context).hintColor,
                                                                                fontSize: Dimensions.fontSizeSmall - 1,
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                        ]),

                                                                    // Voucher expiry warning
                                                                    if (notificationController.notificationList![index].data!.type ==
                                                                            'voucher_expiry' &&
                                                                        notificationController.notificationList![index].data!.expiryDate !=
                                                                            null)
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                6),
                                                                        child: Row(
                                                                            children: [
                                                                              const Icon(Icons.warning_amber_rounded, size: 13, color: Colors.red),
                                                                              const SizedBox(width: 4),
                                                                              Text(
                                                                                '${'expires'.tr}: ${DateConverter.convertDateTimeStringToDateTime(notificationController.notificationList![index].data!.expiryDate!)}',
                                                                                style: robotoRegular.copyWith(
                                                                                  color: Colors.red,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                      ),
                                                                  ])),
                                                            ]),
                                                      ),
                                                    ),
                                                  ]),
                                            );
                                          },
                                        )),
                                  ),
                                ]),
                              ),
                            ),
                          )
                        : NoDataScreen(
                            text: 'no_notification_found'.tr, showFooter: true)
                    : const Center(child: CircularProgressIndicator());
              })
            : NotLoggedInScreen(callBack: (value) {
                _loadData();
                setState(() {});
              }),
      ),
    );
  }

  // ── Helper: Left Image / Placeholder ─────────────────────────────────────
  Widget _buildNotificationImage(
      BuildContext context, NotificationController ctrl, int index) {
    final notification = ctrl.notificationList![index];
    final String? imageUrl = (notification.imageFullUrl != null &&
            notification.imageFullUrl!.isNotEmpty)
        ? notification.imageFullUrl
        : (notification.voucher?.imageFullUrl != null &&
                notification.voucher!.imageFullUrl!.isNotEmpty)
            ? notification.voucher!.imageFullUrl
            : null;

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: CustomImage(
          image: imageUrl,
          height: 95,
          width: 95,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback Icon Placeholder
    final String type = notification.data?.type ?? '';
    IconData iconData;
    Color iconBg;
    Color iconColor;

    if (type == 'push_notification') {
      iconData = Icons.campaign_rounded;
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF43A047);
    } else if (type == 'order_status') {
      iconData = Icons.receipt_long_rounded;
      iconBg = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1E88E5);
    } else if (type == 'voucher_expiry') {
      iconData = Icons.card_giftcard_rounded;
      iconBg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFFB8C00);
    } else {
      iconData = Icons.notifications_rounded;
      iconBg = Theme.of(context).primaryColor.withValues(alpha: 0.10);
      iconColor = Theme.of(context).primaryColor;
    }

    return Container(
      height: 95,
      width: 95,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Icon(iconData, size: 36, color: iconColor),
    );
  }
}
