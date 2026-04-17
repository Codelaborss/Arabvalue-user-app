import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_partner_store_card_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

class WebVoucherRecommendedStoreViewWidget extends StatefulWidget {
  const WebVoucherRecommendedStoreViewWidget({super.key});

  @override
  State<WebVoucherRecommendedStoreViewWidget> createState() =>
      _WebVoucherRecommendedStoreViewWidgetState();
}

class _WebVoucherRecommendedStoreViewWidgetState
    extends State<WebVoucherRecommendedStoreViewWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackButton = false;
  bool _showForwardButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      setState(() {
        _showBackButton = _scrollController.position.pixels > 0;
        _showForwardButton = _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.recommendedStoreList;

      if (storeList != null && storeList.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _checkScrollPosition());
      }

      return (storeList != null && storeList.isNotEmpty)
          ? Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'recommended_store'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.black),
                      ),
                      InkWell(
                        onTap: () => Get.toNamed(
                            RouteHelper.getAllStoreRoute('recommended')),
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
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Stack(
                    children: [
                      SizedBox(
                        height: 210, // Adjusted for store card height
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: storeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      Get.find<LocalizationController>().isLtr
                                          ? Dimensions.paddingSizeDefault
                                          : 0,
                                  left: Get.find<LocalizationController>().isLtr
                                      ? 0
                                      : Dimensions.paddingSizeDefault,
                                  bottom: Dimensions.paddingSizeSmall,
                                  top: Dimensions.paddingSizeSmall),
                              child: WebPartnerStoreCardWidget(
                                  store: storeList[index]),
                            );
                          },
                        ),
                      ),
                      if (_showBackButton)
                        Positioned(
                          top: 70, // Centered vertically in 210 height
                          left: 0,
                          child: ArrowIconButton(
                            isRight: false,
                            onTap: () => _scrollController.animateTo(
                                _scrollController.offset -
                                    Dimensions.webMaxWidth / 3,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                          ),
                        ),
                      if (_showForwardButton)
                        Positioned(
                          top: 70,
                          right: 0,
                          child: ArrowIconButton(
                            onTap: () => _scrollController.animateTo(
                                _scrollController.offset +
                                    Dimensions.webMaxWidth / 3,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox();
    });
  }
}
