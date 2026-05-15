import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_hot_voucher_card_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

class WebHotVoucherViewWidget extends StatefulWidget {
  const WebHotVoucherViewWidget({super.key});

  @override
  State<WebHotVoucherViewWidget> createState() =>
      _WebHotVoucherViewWidgetState();
}

class _WebHotVoucherViewWidgetState extends State<WebHotVoucherViewWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackButton = false;
  bool _showForwardButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
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
    return GetBuilder<ItemController>(builder: (itemController) {
      final voucherItems = itemController.hotVoucherItemList;

      if (voucherItems != null && voucherItems.isNotEmpty) {
        // Trigger forward button check after build
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _checkScrollPosition());
      }

      return (voucherItems != null && voucherItems.isNotEmpty)
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
                        'Hot Vouchers'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.black),
                      ),
                      InkWell(
                        onTap: () => Get.toNamed(
                            RouteHelper.getHotVoucherVoucherViewAllRoute()),
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
                        height: 330, // Adjusted for web card height
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: voucherItems.length,
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
                              child: WebHotVoucherCardWidget(
                                  item: voucherItems[index]),
                            );
                          },
                        ),
                      ),
                      if (_showBackButton)
                        Positioned(
                          top: 130,
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
                          top: 130,
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
