import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_hot_voucher_card_widget.dart';

class WebSpecialOfferView extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  final bool isVoucher;
  const WebSpecialOfferView(
      {super.key,
      required this.isFood,
      required this.isShop,
      this.isVoucher = false});

  @override
  State<WebSpecialOfferView> createState() => _WebSpecialOfferViewState();
}

class _WebSpecialOfferViewState extends State<WebSpecialOfferView> {
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
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;

      if (discountedItemList != null &&
          discountedItemList.length > 5 &&
          isFirstTime) {
        showForwardButton = true;
        isFirstTime = false;
      }

      return discountedItemList != null
          ? discountedItemList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'special_offer'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Colors.black),
                        ),
                        InkWell(
                          onTap: () => Get.toNamed(
                              RouteHelper.getPopularItemRoute(false, true)),
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
                    Stack(children: [
                      SizedBox(
                        height: widget.isVoucher ? 281 : 285,
                        width: Get.width,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: discountedItemList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeExtraLarge,
                                  right: Dimensions.paddingSizeDefault,
                                  top: Dimensions.paddingSizeExtraSmall),
                              child: widget.isVoucher
                                  ? WebHotVoucherCardWidget(
                                      item: discountedItemList[index],
                                      showLogo: false,
                                      showPrice: false,
                                    )
                                  : ItemCard(
                                      item: discountedItemList[index],
                                      isShop: widget.isShop,
                                      isFood: widget.isFood,
                                    ),
                            );
                          },
                        ),
                      ),
                      if (showBackButton)
                        Positioned(
                          top: 110,
                          left: 0,
                          child: ArrowIconButton(
                            isRight: false,
                            onTap: () => scrollController.animateTo(
                                scrollController.offset -
                                    Dimensions.webMaxWidth,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                          ),
                        ),
                      if (showForwardButton)
                        Positioned(
                          top: 110,
                          right: 0,
                          child: ArrowIconButton(
                            isRight: true,
                            onTap: () => scrollController.animateTo(
                                scrollController.offset +
                                    Dimensions.webMaxWidth,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                          ),
                        ),
                    ]),
                  ]),
                )
              : const SizedBox()
          : WebItemShimmerView(
              itemController: itemController, isVoucher: widget.isVoucher);
    });
  }
}

class WebItemShimmerView extends StatelessWidget {
  final ItemController itemController;
  final bool isPopularItem;
  final bool isVoucher;
  const WebItemShimmerView(
      {super.key,
      required this.itemController,
      this.isPopularItem = false,
      this.isVoucher = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 25,
                width: 150,
                color: Colors.grey[300],
              ),
              Container(
                height: 20,
                width: 60,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: isPopularItem ? 240 : (isVoucher ? 281 : 285),
            width: Get.width,
            child: isPopularItem
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisExtent: 370,
                    ),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                          child: Row(children: [
                            Container(
                              height: 90,
                              width: 90,
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                            ),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Container(
                                      height: 15,
                                      width: 100,
                                      color: Colors.grey[300]),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Container(
                                      height: 15,
                                      width: 150,
                                      color: Colors.grey[300]),
                                ])),
                          ]),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraLarge,
                            right: Dimensions.paddingSizeDefault,
                            top: Dimensions.paddingSizeExtraSmall),
                        child: Container(
                          height: 285,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                          child: Column(children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Column(children: [
                                Container(
                                  height: 20,
                                  width: 100,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                Container(
                                  height: 20,
                                  width: 200,
                                  color: Colors.grey[300],
                                ),
                                if (!isVoucher)
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                if (!isVoucher)
                                  Container(
                                    height: 20,
                                    width: 100,
                                    color: Colors.grey[300],
                                  ),
                              ]),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
