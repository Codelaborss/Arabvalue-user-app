import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/home/widgets/components/hot_voucher_card.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class HotVoucherView extends StatelessWidget {
  const HotVoucherView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      final voucherItems = itemController.hotVoucherItemList;

      return (voucherItems != null && voucherItems.isNotEmpty)
          ? Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hot Vouchers'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.black),
                        ),
                        InkWell(
                          onTap: () => Get.toNamed(
                              RouteHelper.getItemViewAllScreen(true, false)),
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
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  SizedBox(
                    height: 290,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: voucherItems.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeSmall,
                              top: Dimensions.paddingSizeSmall),
                          child: HotVoucherCard(item: voucherItems[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox();
    });
  }
}
