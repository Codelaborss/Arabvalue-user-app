import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/widgets/web/web_special_offer_view_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/store/widgets/store_item_widget.dart';

class WebMostPopularItemViewWidget extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  const WebMostPopularItemViewWidget(
      {super.key, required this.isFood, required this.isShop});

  @override
  State<WebMostPopularItemViewWidget> createState() =>
      _WebMostPopularItemViewWidgetState();
}

class _WebMostPopularItemViewWidgetState
    extends State<WebMostPopularItemViewWidget> {
  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = itemController.popularItemList;
      if (itemList != null) {
        itemList = itemList.where((item) => item.type == 'voucher').toList();
      }

      if (itemList != null && itemList.length > 5 && isFirstTime) {
        showForwardButton = true;
        isFirstTime = false;
      }

      return itemList != null
          ? itemList.isNotEmpty
              ? Stack(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isShop
                                ? 'most_popular_products'.tr
                                : 'most_popular_items'.tr,
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                                color: Colors.black),
                          ),
                          InkWell(
                            onTap: () => Get.toNamed(
                                RouteHelper.getPopularItemRoute(true, false)),
                            child: Text(
                              'see_all'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      SizedBox(
                        height: 240,
                        width: Get.width,
                        child: GridView.builder(
                          key: UniqueKey(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisExtent: 370,
                          ),
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: itemList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeDefault),
                              child: StoreItemWidget(
                                item: itemList![index],
                                index: index,
                                backgroundColor: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                  if (showBackButton)
                    Positioned(
                      top: 115,
                      left: 0,
                      child: ArrowIconButton(
                        isRight: false,
                        onTap: () => scrollController.animateTo(
                            scrollController.offset -
                                (Dimensions.webMaxWidth / 3),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut),
                      ),
                    ),
                  if (showForwardButton)
                    Positioned(
                      top: 115,
                      right: 0,
                      child: ArrowIconButton(
                        onTap: () => scrollController.animateTo(
                            scrollController.offset +
                                (Dimensions.webMaxWidth / 3),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut),
                      ),
                    ),
                ])
              : const SizedBox()
          : WebItemShimmerView(
              itemController: itemController, isPopularItem: true);
    });
  }
}
