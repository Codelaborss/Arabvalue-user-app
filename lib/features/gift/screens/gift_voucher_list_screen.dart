import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class GiftVoucherListScreen extends StatefulWidget {
  final int? storeId;
  const GiftVoucherListScreen({super.key, required this.storeId});

  @override
  State<GiftVoucherListScreen> createState() => _GiftVoucherListScreenState();
}

class _GiftVoucherListScreenState extends State<GiftVoucherListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      Get.find<GiftController>().getStoreItems(widget.storeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Select Gift Card'),
      body: GetBuilder<GiftController>(builder: (giftController) {
        return giftController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : giftController.storeVoucherList == null ||
                    giftController.storeVoucherList!.isEmpty
                ? const Center(
                    child: Text('No Gift Cards available for this store'))
                : SingleChildScrollView(
                    child: FooterView(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: GridView.builder(
                          key: UniqueKey(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: Dimensions.paddingSizeLarge,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisExtent: 121,
                            crossAxisCount: 1,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: giftController.storeVoucherList!.length,
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          itemBuilder: (context, index) {
                            Item item = giftController.storeVoucherList![index];
                            return ItemWidget(
                              item: item,
                              isStore: false,
                              store: null,
                              index: index,
                              length: giftController.storeVoucherList!.length,
                              showCartCount: false,
                              onTap: () {
                                Get.find<GiftController>().selectVoucher(item);
                                Get.toNamed(RouteHelper.getGiftRoute2());
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
      }),
    );
  }
}
