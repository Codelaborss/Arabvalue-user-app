import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class UserStatsHelper extends StatelessWidget {
  const UserStatsHelper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      // User ka first name ya full name
      String userName = profileController.userInfoModel?.fName ?? 'user'.tr;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello User Name
            Text(
              '${'hello'.tr} $userName',
              style: robotoBold.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // 3 Stats in one Container
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 236, 254),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(
                children: [
                  // You've saved
                  Expanded(
                    flex: 10,
                    child: _buildStatItem(
                      context: context,
                      title: 'you_have_saved'.tr,
                      value: (profileController.userInfoModel?.totalSaving ?? 0)
                          .toStringAsFixed(2),
                      currency: Get.find<SplashController>()
                          .configModel!
                          .currencySymbol!,
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white,
                  ),

                  // Wallet
                  Expanded(
                    flex: 13,
                    child: _buildStatItem(
                      context: context,
                      title: 'wallet'.tr,
                      value:
                          (profileController.userInfoModel?.walletBalance ?? 0)
                              .toStringAsFixed(2),
                      currency: Get.find<SplashController>()
                          .configModel!
                          .currencySymbol!,
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white,
                  ),

                  // Points
                  Expanded(
                    flex: 7,
                    child: _buildStatItem(
                      context: context,
                      title: 'points'.tr,
                      value:
                          (profileController.userInfoModel?.loyaltyPoint ?? 0)
                              .toString(),
                      currency: '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required String currency,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              if (currency.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    currency,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
