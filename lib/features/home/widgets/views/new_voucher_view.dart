import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/widgets/store_item_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';

class NewVoucherView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const NewVoucherView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 0),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? allItemList = itemController.newVoucherItemList;
        List<Item>? itemList = allItemList;

        return (itemList != null)
            ? itemList.isNotEmpty
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault),
                      child: TitleWidget(
                        title: 'new_voucher'.tr,
                        image: Images.coupon,
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
