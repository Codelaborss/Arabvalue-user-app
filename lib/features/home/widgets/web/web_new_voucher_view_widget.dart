import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_hot_voucher_card_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

class WebNewVoucherViewWidget extends StatefulWidget {
  const WebNewVoucherViewWidget({super.key});

  @override
  State<WebNewVoucherViewWidget> createState() =>
      _WebNewVoucherViewWidgetState();
}

class _WebNewVoucherViewWidgetState extends State<WebNewVoucherViewWidget> {
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
    return GetBuilder<ItemController>(builder: (itemController) {
      final itemList = itemController.newVoucherItemList;

      if (itemList != null && itemList.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _checkScrollPosition());
      }

      return (itemList != null && itemList.isNotEmpty)
          ? Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  TitleWidget(
                    title: 'new_voucher'.tr,
                    image: Images.coupon,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Stack(
                    children: [
                      SizedBox(
                        height: 330,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: itemList.length,
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
                                  item: itemList[index]),
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
