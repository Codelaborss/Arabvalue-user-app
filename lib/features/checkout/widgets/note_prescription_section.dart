import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/helper/string_extension.dart';

class NoteAndPrescriptionSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final int? storeId;
  final bool isGift;
  final bool isBuyNow;
  final bool isGiftVoucher;
  const NoteAndPrescriptionSection(
      {super.key,
      required this.checkoutController,
      this.storeId,
      this.isGift = false,
      this.isBuyNow = false,
      this.isGiftVoucher = false});

  @override
  Widget build(BuildContext context) {
    if (isGift && !isGiftVoucher) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('recipient_name'.tr.replaceAll('_', ' ').toTitleCase(),
            style: robotoBold.copyWith(color: Colors.black)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomTextField(
          controller: checkoutController.giftNameController,
          titleText: 'enter_recipient_name'.tr,
          hintText: 'enter_recipient_name'.tr,
          inputType: TextInputType.name,
          inputAction: TextInputAction.next,
          capitalization: TextCapitalization.words,
          fillColor: Colors.white,
          hintColor: Colors.black.withAlpha(100),
          showLabelText: false,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Text('gift_message'.tr.replaceAll('_', ' ').toTitleCase(),
            style: robotoBold.copyWith(color: Colors.black)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomTextField(
          controller: checkoutController.giftMessageController,
          titleText: 'enter_gift_message'.tr,
          hintText: 'enter_gift_message'.tr,
          maxLines: 3,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.done,
          capitalization: TextCapitalization.sentences,
          fillColor: Colors.white,
          hintColor: Colors.black.withAlpha(100),
          showLabelText: false,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ]);
    }

    return const SizedBox();
  }
}
