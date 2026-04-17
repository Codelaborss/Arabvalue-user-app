import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_partner_store_card_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebNewOnMartViewWidget extends StatefulWidget {
  const WebNewOnMartViewWidget({super.key});

  @override
  State<WebNewOnMartViewWidget> createState() => _WebNewOnMartViewWidgetState();
}

class _WebNewOnMartViewWidgetState extends State<WebNewOnMartViewWidget> {
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

      if (storeList != null && storeList.length > 5 && isFirstTime) {
        showForwardButton = true;
        isFirstTime = false;
      }

      return (storeList != null && storeList.isEmpty)
          ? const SizedBox()
          : Stack(children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'new_on'.tr} ${AppConstants.appName}',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.black),
                      ),
                      InkWell(
                        onTap: () =>
                            Get.toNamed(RouteHelper.getAllStoreRoute('latest')),
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
                SizedBox(
                  height: 200,
                  width: Get.width,
                  child: storeList != null
                      ? ListView.builder(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: storeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeSmall,
                              ),
                              child: WebPartnerStoreCardWidget(
                                  store: storeList[index]),
                            );
                          },
                        )
                      : WebNewOnMartShimmer(storeController: storeController),
                ),
              ]),
              if (showBackButton)
                Positioned(
                  top: 100,
                  left: 0,
                  child: ArrowIconButton(
                    isRight: false,
                    onTap: () => scrollController.animateTo(
                        scrollController.offset - (Dimensions.webMaxWidth / 3),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut),
                  ),
                ),
              if (showForwardButton)
                Positioned(
                  top: 100,
                  right: 0,
                  child: ArrowIconButton(
                    onTap: () => scrollController.animateTo(
                        scrollController.offset + (Dimensions.webMaxWidth / 3),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut),
                  ),
                ),
            ]);
    });
  }
}

class WebNewOnMartShimmer extends StatelessWidget {
  final StoreController storeController;
  const WebNewOnMartShimmer({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ScrollController(),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall,
            top: Dimensions.paddingSizeDefault,
          ),
          child: Container(
            height: 160,
            width: 275,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        height: 10,
                                        width: 100,
                                        color: Colors.grey[300]),
                                    Row(children: [
                                      Icon(Icons.star,
                                          size: 15,
                                          color:
                                              Theme.of(context).disabledColor),
                                      const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Container(
                                          height: 10,
                                          width: 20,
                                          color: Colors.grey[300]),
                                      const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Container(
                                          height: 10,
                                          width: 20,
                                          color: Colors.grey[300]),
                                    ]),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
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
                      child: Container(
                          height: 10, width: 100, color: Colors.grey[300]),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}
