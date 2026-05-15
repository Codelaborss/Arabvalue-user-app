import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/web_hot_voucher_card_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';

class WebHotVoucherViewAllScreen extends StatefulWidget {
  const WebHotVoucherViewAllScreen({super.key});

  @override
  State<WebHotVoucherViewAllScreen> createState() =>
      _WebHotVoucherViewAllScreenState();
}

class _WebHotVoucherViewAllScreenState
    extends State<WebHotVoucherViewAllScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebMenuBar(),
      body: GetBuilder<ItemController>(builder: (itemController) {
        final voucherItems = itemController.hotVoucherItemList;

        return SingleChildScrollView(
          controller: _scrollController,
          child: FooterView(
            child: Column(
              children: [
                WebScreenTitleWidget(title: 'Hot Vouchers'.tr),
                Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: (voucherItems != null && voucherItems.isNotEmpty)
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: Dimensions.paddingSizeDefault,
                              crossAxisSpacing: Dimensions.paddingSizeDefault,
                              childAspectRatio:
                                  1.2, // Increased height to fix overflow
                            ),
                            itemCount: voucherItems.length,
                            itemBuilder: (context, index) {
                              return WebHotVoucherCardWidget(
                                  item: voucherItems[index], width: null);
                            },
                          )
                        : Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 100),
                              child: Text('no_items_found'.tr,
                                  style: robotoMedium),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class WebScreenTitleWidget extends StatelessWidget {
  final String title;
  const WebScreenTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                title,
                style:
                    robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
