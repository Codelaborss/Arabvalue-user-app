import 'package:sixam_mart/common/widgets/card_design/partner_store_card.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class NewOnMartView extends StatelessWidget {
  final bool isPharmacy;
  final bool isShop;
  final bool isNewStore;
  const NewOnMartView(
      {super.key,
      required this.isPharmacy,
      required this.isShop,
      this.isNewStore = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.latestStoreList;

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
                        title: '${'new_on'.tr} ${AppConstants.appName}',
                        onTap: () =>
                            Get.toNamed(RouteHelper.getAllStoreRoute('latest')),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      height: 194,
                      width: Get.width,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
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
                                store: storeList[index],
                                isRecommended: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                )
              : const SizedBox.shrink()
          : const NewOnMartShimmerView();
    });
  }
}

class NewOnMartShimmerView extends StatelessWidget {
  const NewOnMartShimmerView({super.key});

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
                      borderRadius: BorderRadius.circular(16),
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
