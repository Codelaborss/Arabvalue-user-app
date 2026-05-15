import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';

class WebPartnerStoreCardWidget extends StatelessWidget {
  final Store store;
  final bool isRecommended;
  const WebPartnerStoreCardWidget(
      {super.key, required this.store, this.isRecommended = false});

  @override
  Widget build(BuildContext context) {
    double distance = (store.distance ?? 0) / 1000;

    return OnHover(
      isItem: true,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2)
          ],
        ),
        child: InkWell(
          onTap: () {
            if (Get.find<SplashController>().moduleList != null) {
              for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                if (module.id == store.moduleId) {
                  if (Get.find<SplashController>().module?.id != module.id) {
                    Get.find<SplashController>()
                        .setModule(module, notify: false);
                  }
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Name row
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.1),
                                width: 1),
                          ),
                          child: ClipOval(
                            child: CustomImage(
                              image: '${store.logoFullUrl}',
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            store.name ?? '',
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Badges Row (km, rating, offers)
                    Row(
                      children: [
                        _buildBadge(context, Icons.swap_horiz,
                            '${distance > 100 ? '100+' : distance.toStringAsFixed(1)}km'),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _buildBadge(context, Icons.star,
                            store.avgRating?.toStringAsFixed(1) ?? '0.0',
                            iconColor: Colors.amber),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _buildBadge(context, Icons.confirmation_number_outlined,
                            '${store.vouchers?.length ?? 0} ${'offers'.tr}'),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Address and Status Row
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: Colors.black87),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store.address ?? '',
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _buildBadge(
                          context,
                          Icons.circle,
                          Get.find<StoreController>().isOpenNow(store)
                              ? 'open_now'.tr
                              : 'closed_now'.tr,
                          iconColor:
                              Get.find<StoreController>().isOpenNow(store)
                                  ? Colors.green
                                  : Colors.red,
                          textColor:
                              Get.find<StoreController>().isOpenNow(store)
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),

                // Favorite
                AddFavouriteView(
                  top: 0,
                  right: 0,
                  item: null,
                  storeId: store.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text,
      {Color? iconColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: icon == Icons.circle ? 10 : 16,
              color: iconColor ?? Colors.black87),
          const SizedBox(width: 4),
          Text(text,
              style: robotoBlack.copyWith(
                  fontSize: 11, color: textColor ?? Colors.black)),
        ],
      ),
    );
  }
}
