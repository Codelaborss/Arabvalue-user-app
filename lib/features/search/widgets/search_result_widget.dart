import 'package:sixam_mart/features/search/controllers/search_controller.dart'
    as search;
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  const SearchResultWidget({super.key, required this.searchText});

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search.SearchController>(builder: (searchController) {
      int itemLength = searchController.searchItemList?.length ?? 0;
      int storeLength = searchController.searchStoreList?.length ?? 0;
      int totalLength = itemLength + storeLength;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        totalLength == 0 &&
                searchController.searchItemList == null &&
                searchController.searchStoreList == null
            ? const SizedBox()
            : Center(
                child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Text(
                          totalLength.toString(),
                          style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                            child: Text(
                          'results_found'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall),
                        )),
                      ]),
                    ))),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (itemLength > 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall),
                        child: Text('vouchers'.tr,
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge)),
                      ),
                      ItemsView(
                        isStore: false,
                        items: searchController.searchItemList,
                        stores: null,
                        isPartner: false,
                      ),
                    ],
                    if (storeLength > 0) ...[
                        Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall),
                        child: Text(AppConstants.partnerLabel(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                        ),
                      ItemsView(
                        isStore: true,
                        items: null,
                        stores: searchController.searchStoreList,
                        isPartner: true,
                      ),
                    ],
                    if (totalLength == 0 &&
                        searchController.searchItemList != null &&
                        searchController.searchStoreList != null)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: context.height * 0.2),
                          child:
                              Text('no_vouchers_found'.tr, style: robotoMedium),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]);
    });
  }
}
