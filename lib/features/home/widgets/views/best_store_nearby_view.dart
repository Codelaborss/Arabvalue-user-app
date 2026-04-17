import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/partner_store_card.dart';

class BestStoreNearbyView extends StatelessWidget {
  const BestStoreNearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;

    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = isPharmacy
          ? storeController.featuredStoreList
          : storeController.popularStoreList;

      return storeList != null
          ? storeList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault, top: 0),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      child: TitleWidget(
                        title: isPharmacy
                            ? 'featured_store'.tr
                            : 'best_store_nearby'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute(
                            isPharmacy ? 'featured' : 'popular',
                            isNearbyStore: true)),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      height: 194,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault),
                        itemCount: storeList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeSmall,
                                top: 0),
                            child: SizedBox(
                              width: 340,
                              child: PartnerStoreCard(
                                  store: storeList[index], isRecommended: true),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                )
              : const SizedBox()
          : const BestStoreNearbyShimmer();
    });
  }
}

class BestStoreNearbyShimmer extends StatelessWidget {
  const BestStoreNearbyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 20,
                width: 150,
                color: Colors.grey[300],
              ),
              Container(
                height: 15,
                width: 50,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          height: 180,
          width: Get.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeSmall,
                    top: Dimensions.paddingSizeSmall),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    width: 330,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
