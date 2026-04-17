import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart'
    as item_model;
import 'package:sixam_mart/features/order/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart/common/widgets/voucher_divider_clipper.dart';
import 'package:sixam_mart/common/widgets/voucher_divider_border_painter.dart';
import 'package:sixam_mart/common/widgets/vertical_dashed_line_painter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  final bool isStore;
  final String? status;
  final bool isNested;
  const OrderViewWidget(
      {super.key,
      required this.isRunning,
      this.isStore = false,
      this.status,
      this.isNested = false});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return GetBuilder<OrderController>(builder: (orderController) {
      PaginatedOrderModel? paginatedOrderModel;
      // All status tabs (All/Active/Redeemed/Expired) use history orders from /api/v1/customer/order/list
      if (status != null) {
        paginatedOrderModel = orderController.historyOrderModel;
      } else {
        paginatedOrderModel = isRunning
            ? orderController.runningOrderModel
            : orderController.historyOrderModel;
      }

      List<OrderModel>? filteredOrders;
      if (status == 'all') {
        // 'All' tab now shows only History (finalized) orders as per user request
        filteredOrders =
            paginatedOrderModel != null && paginatedOrderModel.orders != null
                ? paginatedOrderModel.orders
                : [];
      } else {
        if (paginatedOrderModel != null && paginatedOrderModel.orders != null) {
          if (isRunning && status == null) {
            if (isStore) {
              filteredOrders = paginatedOrderModel.orders!
                  .where((order) => order.orderStatus == 'hold')
                  .toList();
            } else {
              // Exclude 'hold' from running orders explicitly as requested
              filteredOrders = paginatedOrderModel.orders!
                  .where((order) => order.orderStatus != 'hold')
                  .toList();
            }
          } else {
            filteredOrders = paginatedOrderModel.orders;
          }

          if (status != null) {
            if (status == 'active') {
              // ACTIVE TAB: Show only In-Store and Gift vouchers with 'active' status
              filteredOrders = filteredOrders!.where((order) {
                String? voucherType = order.voucherType?.toLowerCase();
                bool isInStoreOrGift = voucherType != null &&
                    ((voucherType.contains('in') &&
                            voucherType.contains('store')) ||
                        voucherType.contains('gift'));

                return isInStoreOrGift && order.orderStatus == 'active';
              }).toList();
            } else if (status == 'redeemed') {
              // REDEEMED TAB: Show everything that is NOT in Active or Expired/Canceled tabs
              filteredOrders = filteredOrders!.where((order) {
                if (order.orderStatus == 'expired' ||
                    order.orderStatus == 'canceled') return false;

                String? voucherType = order.voucherType?.toLowerCase();
                bool isInStoreOrGift = voucherType != null &&
                    ((voucherType.contains('in') &&
                            voucherType.contains('store')) ||
                        voucherType.contains('gift'));

                if (isInStoreOrGift) {
                  // In-Store/Gift only go to Redeemed if NOT active
                  return order.orderStatus != 'active';
                }

                // All other types (Flat, Delivery, etc.) go to Redeemed (if not expired/refunded)
                return true;
              }).toList();
            } else if (status == 'expired') {
              // EXPIRED TAB: Show orders that are either expired or canceled
              filteredOrders = filteredOrders!
                  .where((order) =>
                      order.orderStatus == 'expired' ||
                      order.orderStatus == 'canceled')
                  .toList();
            }
          }
        }
      }

      // Ensure newest orders show first (most recent at top)
      if (filteredOrders != null && filteredOrders.isNotEmpty) {
        try {
          filteredOrders.sort((a, b) {
            DateTime da = DateTime.tryParse(a.createdAt ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            DateTime db = DateTime.tryParse(b.createdAt ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return db.compareTo(da);
          });
        } catch (e) {
          // ignore parse/sort errors and leave original order
        }
      }

      return paginatedOrderModel != null
          ? (filteredOrders != null && filteredOrders.isNotEmpty)
              ? isNested
                  ? _buildOrderGrid(context, filteredOrders)
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (status != null) {
                          await orderController.getHistoryOrders(1,
                              isUpdate: true);
                        } else {
                          if (isRunning) {
                            await orderController.getRunningOrders(1,
                                isUpdate: true);
                          } else {
                            await orderController.getHistoryOrders(1,
                                isUpdate: true);
                          }
                        }
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: FooterView(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: ResponsiveHelper.isDesktop(context)
                                      ? 0
                                      : 100),
                              child: Column(
                                children: [
                                  // Order List
                                  PaginatedListView(
                                    scrollController: scrollController,
                                    onPaginate: (int? offset) async {
                                      if (status != null) {
                                        await orderController.getHistoryOrders(
                                            offset!,
                                            isUpdate: true);
                                      } else if (isRunning) {
                                        await orderController.getRunningOrders(
                                            offset!,
                                            isUpdate: true);
                                      } else {
                                        await orderController.getHistoryOrders(
                                            offset!,
                                            isUpdate: true);
                                      }
                                    },
                                    totalSize: isRunning
                                        ? orderController
                                            .runningOrderModel?.totalSize
                                        : orderController
                                            .historyOrderModel?.totalSize,
                                    offset: isRunning
                                        ? orderController
                                            .runningOrderModel?.offset
                                        : orderController
                                            .historyOrderModel?.offset,
                                    itemView: _buildOrderGrid(
                                        context, filteredOrders),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
              : NoDataScreen(text: 'no_order_found'.tr, showFooter: false)
          : OrderShimmerWidget(orderController: orderController);
    });
  }

  Widget _buildOrderGrid(
      BuildContext context, List<OrderModel> filteredOrders) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeExtremeLarge
            : Dimensions.paddingSizeLarge,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeExtremeLarge
            : 0,
        mainAxisExtent: 138,
        crossAxisCount: ResponsiveHelper.isDesktop(context)
            ? 3
            : ResponsiveHelper.isMobile(context)
                ? 1
                : 2,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge)
          : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        OrderModel order = filteredOrders[index];
        bool isParcel = order.orderType == 'parcel';
        bool isVoucher = order.moduleType == 'voucher' ||
            (order.voucherItems != null && order.voucherItems!.isNotEmpty);

        item_model.Item? voucherItem =
            (order.voucherItems != null && order.voucherItems!.isNotEmpty)
                ? order.voucherItems![0]
                : null;

        Color primaryColor = Theme.of(context).primaryColor;
        List<Color> voucherColors = [
          primaryColor,
          primaryColor.withValues(alpha: 0.7)
        ];
        String ribbonText = 'Order';

        if (isParcel) {
          ribbonText = 'Parcel';
        } else if (isVoucher) {
          ribbonText = voucherItem?.voucherType ?? 'Voucher';
          if (ribbonText.toLowerCase().contains('in-store')) {
            voucherColors = [const Color(0xFF1ABC9C), const Color(0xFFA8E063)];
          } else if (ribbonText.toLowerCase().contains('delivery')) {
            voucherColors = [const Color(0xFFF43F8C), const Color(0xFFFB8B5E)];
          } else if (ribbonText.toLowerCase().contains('gift')) {
            voucherColors = [const Color(0xFF6A4DF4), const Color(0xFFC084FC)];
          } else if (ribbonText.toLowerCase().contains('flat')) {
            voucherColors = [const Color(0xFFFF8A2B), const Color(0xFFFFD54F)];
          } else {
            voucherColors = [primaryColor, primaryColor.withValues(alpha: 0.7)];
          }
        }

        double cutoutX = 125;

        return Center(
          child: SizedBox(
            width: ResponsiveHelper.isDesktop(context)
                ? null
                : ResponsiveHelper.isMobile(context)
                    ? Get.width * 0.9
                    : Get.width,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: ClipPath(
                clipper: VoucherDividerClipper(cutoutX: cutoutX),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: CustomPaint(
                    painter: VoucherDividerBorderPainter(
                      colors: voucherColors,
                      stops: const [0.7, 1.0],
                      cutoutX: cutoutX,
                    ),
                    child: CustomInkWell(
                      onTap: () {
                        Get.toNamed(
                          RouteHelper.getOrderDetailsRoute(order.id),
                          arguments: OrderDetailsScreen(
                            orderId: order.id,
                            orderModel: order,
                          ),
                        );
                      },
                      radius: Dimensions.radiusDefault,
                      padding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              // Image Section
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImage(
                                    image: isParcel
                                        ? '${order.parcelCategory != null ? order.parcelCategory!.imageFullUrl : ''}'
                                        : isVoucher
                                            ? voucherItem?.imageFullUrl ?? ''
                                            : '${order.store != null ? order.store!.logoFullUrl : ''}',
                                    height: 105,
                                    width: 105,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),

                              // Vertical Divider
                              SizedBox(
                                height: 120,
                                width: 1,
                                child: CustomPaint(
                                  painter: VerticalDashedLinePainter(
                                    color:
                                        voucherColors[0].withValues(alpha: 0.8),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),

                              // Details Section
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isParcel
                                            ? order.parcelCategory?.name ??
                                                'Parcel Delivery'
                                            : isVoucher
                                                ? voucherItem?.name ?? 'Voucher'
                                                : order.store?.name ??
                                                    'Store Order',
                                        style: robotoMedium.copyWith(
                                            fontSize: 14,
                                            color:
                                                Theme.of(context).primaryColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        PriceConverter.convertPrice(
                                            order.totalOrderAmount ??
                                                order.orderAmount),
                                        style:
                                            robotoBold.copyWith(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateConverter.dateTimeStringToDateTime(
                                            order.createdAt!),
                                        style: robotoRegular.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Right Section (Saved Badge & Status)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Save Badge
                                    if (isVoucher &&
                                        (voucherItem?.discount ?? 0) > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: voucherColors),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault),
                                        ),
                                        child: Text(
                                          '${'save'.tr}\n${voucherItem!.discountType == 'amount' ? PriceConverter.convertPrice(voucherItem.discount) : '${voucherItem.discount}%'}',
                                          style: robotoBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                              height: 1.1),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 35),

                                    // Status Badge (color derived from API status)
                                    Builder(builder: (context) {
                                      String _statusKey =
                                          order.orderStatus?.toLowerCase() ??
                                              '';
                                      final Color _badgeBg;
                                      final Color _badgeTextColor;
                                      final Color _disabled =
                                          Theme.of(context).disabledColor;
                                      if ([
                                        'failed',
                                        'canceled',
                                        'refund_requested',
                                        'refunded',
                                        'payment_failed'
                                      ].contains(_statusKey)) {
                                        _badgeBg =
                                            _disabled.withValues(alpha: 0.1);
                                        _badgeTextColor = _disabled;
                                      } else {
                                        _badgeBg =
                                            Theme.of(context).primaryColor;
                                        _badgeTextColor = Colors.white;
                                      }
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: _badgeBg,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          (_statusKey == 'delivered' ||
                                                      _statusKey == 'confirmed'
                                                  ? 'completed'.tr
                                                  : order.orderStatus!.tr)
                                              .toUpperCase(),
                                          style: robotoBold.copyWith(
                                            color: _badgeTextColor,
                                            fontSize: 9,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Voucher Type Badge (absolute far left vertical ribbon)
                          Positioned(
                            left: 0,
                            top: 15,
                            bottom: 15,
                            child: Container(
                              width: 22,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: voucherColors,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8)),
                              ),
                              child: Center(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    ribbonText.toUpperCase(),
                                    style: robotoBold.copyWith(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
