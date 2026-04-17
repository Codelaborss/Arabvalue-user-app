import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_item_widget.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return Padding(
      padding:
          const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 0),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? allItemList = itemController.popularItemList;
        // Filter to show only vouchers
        List<Item>? itemList =
            allItemList?.where((item) => item.type == 'voucher').toList();

        return (itemList != null)
            ? itemList.isNotEmpty
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault),
                      child: TitleWidget(
                        title: isShop
                            ? 'most_popular_products'.tr
                            : 'most_popular_items'.tr,
                        image: Images.mostPopularIcon,
                        onTap: () => Get.toNamed(
                            RouteHelper.getItemViewAllScreen(true, false)),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    SizedBox(
                      height: 280,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault),
                        itemCount: (itemList.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          int firstIndex = index * 2;
                          int secondIndex = (index * 2) + 1;

                          return Padding(
                            padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeDefault),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (firstIndex < itemList.length)
                                  SizedBox(
                                    width: 340,
                                    child: StoreItemWidget(
                                      item: itemList[firstIndex],
                                      index: firstIndex,
                                    ),
                                  ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                if (secondIndex < itemList.length)
                                  SizedBox(
                                    width: 340,
                                    child: StoreItemWidget(
                                      item: itemList[secondIndex],
                                      index: secondIndex,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ])
                : const SizedBox()
            : const ItemShimmerView(isPopularItem: true);
      }),
    );
  }
}
