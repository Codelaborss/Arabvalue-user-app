import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class UsageTermsScreen extends StatelessWidget {
  final List<HowItWorks>? howItWorks;
  final List<Store>? branches;
  const UsageTermsScreen({super.key, this.howItWorks, this.branches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'usage_terms'.tr),
      backgroundColor: Theme.of(context).cardColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (howItWorks != null && howItWorks!.isNotEmpty) ...[
            Row(children: [
              Icon(Icons.info_outline,
                  color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('how_it_works'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: howItWorks!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (howItWorks![index].guideTitle != null)
                          Text(howItWorks![index].guideTitle!,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor)),
                        if (howItWorks![index].sections != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: howItWorks![index].sections!.length,
                            itemBuilder: (context, sIndex) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (howItWorks![index]
                                            .sections![sIndex]
                                            .title !=
                                        null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall),
                                        child: Text(
                                            howItWorks![index]
                                                .sections![sIndex]
                                                .title!,
                                            style: robotoMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeDefault)),
                                      ),
                                    if (howItWorks![index]
                                            .sections![sIndex]
                                            .steps !=
                                        null)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: howItWorks![index]
                                            .sections![sIndex]
                                            .steps!
                                            .length,
                                        itemBuilder: (context, stepIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 2,
                                                      right: Dimensions
                                                          .paddingSizeSmall),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  child: Text(
                                                      '${stepIndex + 1}',
                                                      style:
                                                          robotoBold.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10)),
                                                ),
                                                Expanded(
                                                    child: Text(
                                                        howItWorks![index]
                                                            .sections![sIndex]
                                                            .steps![stepIndex],
                                                        style: robotoRegular
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color
                                                                    ?.withValues(
                                                                        alpha:
                                                                            0.7)))),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ]);
                            },
                          ),
                      ]),
                );
              },
            ),
          ],
          if (branches != null && branches!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Icon(Icons.storefront,
                  color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('branches'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('voucher_is_only_valid_for_these_branches'.tr,
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: branches!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Icon(Icons.check_circle_outline,
                                size: 16,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                                child: Text(branches![index].name ?? '',
                                    style: robotoRegular)),
                          ]),
                        );
                      },
                    ),
                  ]),
            ),
          ],
        ]),
      ),
    );
  }
}
