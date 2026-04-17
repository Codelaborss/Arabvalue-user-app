import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_order_view_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/taxi_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/guest_track_order_input_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  final int? index;
  const OrderScreen({super.key, this.index = 0});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoggedIn = AuthHelper.isLoggedIn();
  List<String> type = ['orders', 'trips'];
  int selectTypeIndex = 0;
  bool haveTaxiModule = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    selectTypeIndex = widget.index!;
    haveTaxiModule = TaxiHelper.haveTaxiModule();

    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      if (selectTypeIndex == 0) {
        Get.find<OrderController>().getRunningOrders(1);
        Get.find<OrderController>().getHistoryOrders(1);
      } else {
        Get.find<TaxiOrderController>().getTripList(1, isRunning: true);
        Get.find<TaxiOrderController>().getTripList(1, isRunning: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: haveTaxiModule && !ResponsiveHelper.isDesktop(context)
          ? null
          : CustomAppBar(
              title: 'my_orders'.tr,
              backButton: ResponsiveHelper.isDesktop(context)),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            return Column(
              children: [
                haveTaxiModule && !ResponsiveHelper.isDesktop(context)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeSmall),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Text('my_orderss'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              SizedBox(
                                height: 30,
                                child: ListView.builder(
                                    itemCount: type.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      bool selected = index == selectTypeIndex;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusLarge),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              width: 0.3),
                                        ),
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        child: CustomInkWell(
                                          onTap: () {
                                            setState(() {
                                              selectTypeIndex = index;
                                            });
                                            initCall();
                                          },
                                          radius: Dimensions.radiusLarge,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .paddingSizeDefault),
                                          child: Text(type[index].tr,
                                              style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: selected
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color!
                                                          .withValues(
                                                              alpha: 0.7))),
                                        ),
                                      );
                                    }),
                              ),
                            ]),
                      )
                    : const SizedBox(),
                _isLoggedIn
                    ? Expanded(
                        child: Column(children: [
                          if (selectTypeIndex == 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeExtraSmall),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusLarge),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusLarge),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    padding: EdgeInsets.zero,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeLarge),
                                    labelColor: Colors.white,
                                    unselectedLabelColor:
                                        Theme.of(context).disabledColor,
                                    dividerColor: Colors.transparent,
                                    unselectedLabelStyle:
                                        robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                    labelStyle: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault),
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.center,
                                    tabs: [
                                      Tab(text: 'all'.tr),
                                      Tab(text: 'active'.tr),
                                      Tab(text: 'redeemed'.tr),
                                      Tab(text: 'expired'.tr),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          selectTypeIndex == 0
                              ? Expanded(
                                  child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    const OrderViewWidget(
                                        isRunning: false, status: 'all'),
                                    const OrderViewWidget(
                                        isRunning: true, status: 'active'),
                                    const OrderViewWidget(
                                        isRunning: false, status: 'redeemed'),
                                    const OrderViewWidget(
                                        isRunning: false, status: 'expired'),
                                  ],
                                ))
                              : Expanded(
                                  child: TabBarView(
                                  controller: _tabController,
                                  children: const [
                                    TripOrderViewWidget(isRunning: false),
                                    TripOrderViewWidget(isRunning: false),
                                    TripOrderViewWidget(isRunning: false),
                                    TripOrderViewWidget(isRunning: false),
                                  ],
                                )),
                        ]),
                      )
                    : GuestTrackOrderInputViewWidget(
                        selectType: selectTypeIndex),
              ],
            );
          },
        ),
      ),
    );
  }
}
