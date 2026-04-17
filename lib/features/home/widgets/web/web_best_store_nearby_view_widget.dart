import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_partner_store_card_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';

class WebBestStoreNearbyViewWidget extends StatefulWidget {
  const WebBestStoreNearbyViewWidget({super.key});

  @override
  State<WebBestStoreNearbyViewWidget> createState() =>
      _WebBestStoreNearbyViewWidgetState();
}

class _WebBestStoreNearbyViewWidgetState
    extends State<WebBestStoreNearbyViewWidget> {
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
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.latestStoreList;

      return storeList != null
          ? storeList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'best_store_nearby'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Colors.black),
                        ),
                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute(
                              'latest',
                              isNearbyStore: true)),
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
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Stack(children: [
                      SizedBox(
                        height: 200,
                        width: Get.width,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: storeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeDefault,
                                  bottom: Dimensions.paddingSizeSmall),
                              child: WebPartnerStoreCardWidget(
                                  store: storeList[index]),
                            );
                          },
                        ),
                      ),
                      if (showBackButton)
                        Positioned(
                          top: 70,
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
                          top: 70,
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
          : WebBestStoreNearbyShimmerView(storeController: storeController);
    });
  }
}

class WebBestStoreNearbyShimmerView extends StatelessWidget {
  final StoreController storeController;
  const WebBestStoreNearbyShimmerView(
      {super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    final bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            'pharmacy';

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: isPharmacy ? 0 : Dimensions.paddingSizeDefault),
        itemCount: 8,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                top: Dimensions.paddingSizeDefault),
            child: Container(
              height: 160,
              width: 275,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ],
              ),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                ),
                                child: Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    child: Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              Expanded(
                                flex: 9,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      isPharmacy
                                          ? Container(
                                              height: 10,
                                              width: 100,
                                              color: Colors.grey[300])
                                          : Row(children: [
                                              Container(
                                                  height: 10,
                                                  width: 50,
                                                  color: Colors.grey[300]),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Container(
                                                  height: 10,
                                                  width: 20,
                                                  color: Colors.grey[300]),
                                            ]),
                                      isPharmacy
                                          ? Row(children: [
                                              Icon(Icons.storefront,
                                                  size: 15,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Expanded(
                                                child: Container(
                                                    height: 10,
                                                    width: 100,
                                                    color: Colors.grey[300]),
                                              ),
                                            ])
                                          : Row(children: [
                                              Icon(Icons.star,
                                                  size: 15,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Container(
                                                  height: 10,
                                                  width: 20,
                                                  color: Colors.grey[300]),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Container(
                                                  height: 10,
                                                  width: 20,
                                                  color: Colors.grey[300]),
                                            ]),
                                      isPharmacy
                                          ? Container(
                                              height: 10,
                                              width: 20,
                                              color: Colors.grey[300])
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusSmall),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 5,
                                                      spreadRadius: 1)
                                                ],
                                              ),
                                              child: Row(children: [
                                                Container(
                                                    height: 10,
                                                    width: 20,
                                                    color: Colors.grey[300]),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall),
                                                Container(
                                                    height: 10,
                                                    width: 20,
                                                    color: Colors.grey[300]),
                                              ]),
                                            ),
                                    ]),
                              ),
                            ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Expanded(
                        flex: 2,
                        child: isPharmacy
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: Row(children: [
                                  Container(
                                      height: 10,
                                      width: 20,
                                      color: Colors.grey[300]),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Container(
                                      height: 10,
                                      width: 20,
                                      color: Colors.grey[300]),
                                ]),
                              )
                            : Container(
                                height: 10,
                                width: 100,
                                color: Colors.grey[300]),
                      ),
                    ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
