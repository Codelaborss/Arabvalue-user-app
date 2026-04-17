import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/home/widgets/components/voucher_card.dart';

class SpecialOfferView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const SpecialOfferView(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;
      if (discountedItemList != null) {
        discountedItemList =
            discountedItemList.where((item) => item.type == 'voucher').toList();
      }

      return discountedItemList != null
          ? discountedItemList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      child: TitleWidget(
                        title: 'special_offer'.tr,
                        image: Images.discountOfferIcon,
                        onTap: () => Get.toNamed(
                            RouteHelper.getItemViewAllScreen(false, true)),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: 255,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault),
                        itemCount: discountedItemList!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeSmall,
                                right: Dimensions.paddingSizeDefault,
                                top: Dimensions.paddingSizeSmall),
                            child:
                                VoucherCard(item: discountedItemList![index]),
                          );
                        },
                      ),
                    ),
                  ]),
                )
              : const SizedBox()
          : const ItemShimmerView(isPopularItem: false);
    });
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: TitleWidget(
            title: isPopularItem ? 'most_popular_items'.tr : 'special_offer'.tr,
            image: isPopularItem
                ? Images.mostPopularIcon
                : Images.discountOfferIcon,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          height: 255,
          width: Get.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeDefault,
                    top: Dimensions.paddingSizeSmall),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    height: 255,
                    width: 210,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                    child: Column(children: [
                      Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            height: 15,
                            width: 100,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            height: 20,
                            width: 150,
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
