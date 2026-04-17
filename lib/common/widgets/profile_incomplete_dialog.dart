import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ProfileIncompleteDialog extends StatelessWidget {
  final Function onYesPressed;
  const ProfileIncompleteDialog({super.key, required this.onYesPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.person_outline,
                  size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                'profile_incomplete'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'please_complete_your_profile_to_place_order'.tr,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Row(children: [
                Expanded(
                    child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    minimumSize: const Size(Dimensions.webMaxWidth, 50),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall)),
                  ),
                  child: Text(
                    'cancel'.tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                )),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                Expanded(
                    child: CustomButton(
                  buttonText: 'update_now'.tr,
                  onPressed: () => onYesPressed(),
                  radius: Dimensions.radiusSmall,
                  height: 50,
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
