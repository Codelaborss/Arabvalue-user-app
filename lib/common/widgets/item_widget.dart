import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/corner_banner/banner.dart';
import 'package:sixam_mart/common/widgets/corner_banner/corner_discount_tag.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/scalloped_edge_clipper.dart';
import 'package:sixam_mart/common/widgets/curved_border_painter.dart';
import 'package:sixam_mart/common/widgets/horizontal_dashed_line_painter.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  final double? imageHeight;
  final double? imageWidth;
  final bool? isCornerTag;
  final VoidCallback? onTap;
  final bool showCartCount;
  const ItemWidget(
      {super.key,
      required this.item,
      required this.isStore,
      required this.store,
      required this.index,
      required this.length,
      this.inStore = false,
      this.isCampaign = false,
      this.isFeatured = false,
      this.fromCartSuggestion = false,
      this.imageHeight,
      this.imageWidth,
      this.isCornerTag = false,
      this.onTap,
      this.showCartCount = true});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    String genericName = '';

    if (!isStore &&
        item!.genericName != null &&
        item!.genericName!.isNotEmpty) {
      for (String name in item!.genericName!) {
        genericName += name;
      }
    }
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType =
          store!.discount != null ? store!.discount!.discountType : 'percent';
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = item!.discount;
      discountType = item!.discountType;

      if (item!.type == 'voucher' &&
          (item!.voucherIds?.toLowerCase().trim() == 'flat discount' ||
              item!.bundleType == 'gift')) {
        if (item!.bonusConfiguration != null &&
            item!.bonusConfiguration!.isNotEmpty) {
          double maxBonus = 0;
          for (var config in item!.bonusConfiguration!) {
            double bonus = double.tryParse(config.bonusPercentage ?? '0') ?? 0;
            if (bonus > maxBonus) {
              maxBonus = bonus;
            }
          }
          if (maxBonus > 0) {
            discount = maxBonus;
            discountType = 'percent';
          }
        }
      } else if (item!.type == 'voucher' &&
          (item!.bundleType == 'bogo_free' ||
              (item!.voucherIds?.toLowerCase().trim().contains('bogo') ??
                  false))) {
        discount = 50;
        discountType = 'percent';
      }

      isAvailable = DateConverter.isAvailable(
          item!.availableTimeStarts, item!.availableTimeEnds);
    }

    bool isVoucher = !isStore && item != null && item!.type == 'voucher';

    return TextHover(builder: (hovered) {
      if (isVoucher) {
        return _buildVoucherCard(
            context, hovered, discount, discountType, isAvailable);
      }

      Widget content = Container(
        margin: ResponsiveHelper.isDesktop(context)
            ? null
            : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        child: CustomInkWell(
          onTap: () => _onTap(context),
          radius: Dimensions.radiusDefault,
          padding: ResponsiveHelper.isDesktop(context)
              ? EdgeInsets.all(fromCartSuggestion
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeSmall)
              : const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                Stack(children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      isHovered: hovered,
                      image:
                          '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                      height: imageHeight ??
                          (desktop
                              ? 120
                              : length == null
                                  ? 100
                                  : 90),
                      width: imageWidth ?? (desktop ? 120 : 90),
                      fit: BoxFit.cover,
                    ),
                  ),
                  (isStore || (isCornerTag ?? false))
                      ? DiscountTag(
                          discount: discount,
                          discountType: discountType,
                          freeDelivery: isStore ? store!.freeDelivery : false,
                        )
                      : const SizedBox(),
                  !isStore
                      ? OrganicTag(item: item!, placeInImage: true)
                      : const SizedBox(),
                  isAvailable
                      ? const SizedBox()
                      : NotAvailableWidget(isStore: isStore),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: GetBuilder<FavouriteController>(
                        builder: (favouriteController) {
                      bool isWished = isStore
                          ? favouriteController.wishStoreIdList
                              .contains(store?.id)
                          : favouriteController.wishItemIdList
                              .contains(item?.id);
                      return CustomFavouriteWidget(
                        isWished: isWished,
                        isStore: isStore,
                        store: store,
                        item: item,
                      );
                    }),
                  ),
                ]),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  isStore
                                      ? (store?.name ?? 'Store Name')
                                      : (item?.name ?? 'Item Name'),
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              (!isStore &&
                                      Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .vegNonVeg! &&
                                      Get.find<SplashController>()
                                          .configModel!
                                          .toggleVegNonVeg!)
                                  ? Image.asset(
                                      item != null && item!.veg == 0
                                          ? Images.nonVegImage
                                          : Images.vegImage,
                                      height: 10,
                                      width: 10,
                                      fit: BoxFit.contain)
                                  : const SizedBox(),
                              (Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .unit! &&
                                      item != null &&
                                      item!.unitType != null)
                                  ? Text(
                                      '(${item!.unitType ?? ''})',
                                      style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context).hintColor),
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  width: (item!.isStoreHalalActive ?? false) &&
                                          (item!.isHalalItem ?? false)
                                      ? Dimensions.paddingSizeExtraSmall
                                      : 0),
                              !isStore &&
                                      (item!.isStoreHalalActive ?? false) &&
                                      (item!.isHalalItem ?? false)
                                  ? const CustomAssetImageWidget(
                                      Images.halalTag,
                                      height: 13,
                                      width: 13)
                                  : const SizedBox(),
                              SizedBox(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 20
                                      : 0),
                            ]),
                        const SizedBox(height: 3),
                        inStore
                            ? const SizedBox()
                            : (isStore
                                    ? store?.address != null
                                    : item?.storeName != null)
                                ? Text(
                                    isStore
                                        ? store?.address ?? ''
                                        : item?.storeName ?? '',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox(),
                        (genericName.isNotEmpty)
                            ? Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    genericName,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                            height: ((desktop || isStore) &&
                                    (isStore
                                        ? store?.address != null
                                        : item?.storeName != null))
                                ? 3
                                : 3),
                        !isStore && ((item!.ratingCount ?? 0) > 0)
                            ? Row(children: [
                                Icon(Icons.star,
                                    size: 16,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  (item!.avgRating ?? 0).toStringAsFixed(1),
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  '(${item!.ratingCount ?? 0})',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor),
                                ),
                              ])
                            : const SizedBox(),
                        SizedBox(
                            height: (!isStore && desktop) ||
                                    (!isStore && ((item!.ratingCount ?? 0) > 0))
                                ? 3
                                : 0),
                        isStore &&
                                (store != null && (store!.ratingCount ?? 0) > 0)
                            ? Row(children: [
                                Icon(Icons.star,
                                    size: 16,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  (store!.avgRating ?? 0).toStringAsFixed(1),
                                  style: robotoMedium,
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  '(${store!.ratingCount ?? 0})',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor),
                                ),
                              ])
                            : Row(children: [
                                Text(
                                  PriceConverter.convertPrice(item!.price,
                                      discount: discount,
                                      discountType: discountType),
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                  textDirection: TextDirection.ltr,
                                ),
                                SizedBox(
                                    width: (discount ?? 0) > 0
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0),
                                (discount ?? 0) > 0
                                    ? Text(
                                        PriceConverter.convertPrice(
                                            item!.price),
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      )
                                    : const SizedBox(),
                              ]),
                      ]),
                ),
                showCartCount
                    ? Column(
                        mainAxisAlignment: isStore
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: [
                            const SizedBox(),
                            CartCountView(
                              item: item!,
                              index: index,
                            ),
                          ])
                    : const SizedBox(),
              ]),
            )),
          ]),
        ),
      );

      return Stack(
        children: [
          content,
          (!isStore && (isCornerTag ?? false) == false)
              ? Positioned(
                  right: ltr ? 0 : null,
                  left: ltr ? null : 0,
                  child: CornerDiscountTag(
                    bannerPosition: ltr
                        ? CornerBannerPosition.topRight
                        : CornerBannerPosition.topLeft,
                    elevation: 0,
                    discount: discount,
                    discountType: discountType,
                    freeDelivery:
                        isStore ? (store?.freeDelivery ?? false) : false,
                  ))
              : const SizedBox(),
        ],
      );
    });
  }

  void _onTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else if (isStore) {
      if (store != null) {
        if (isFeatured && Get.find<SplashController>().moduleList != null) {
          for (ModuleModel module in Get.find<SplashController>().moduleList!) {
            if (module.id == store!.moduleId) {
              Get.find<SplashController>().setModule(module);
              break;
            }
          }
        }
        Get.toNamed(
          RouteHelper.getStoreRoute(
              id: store!.id, page: isFeatured ? 'module' : 'item'),
          arguments: StoreScreen(store: store, fromModule: isFeatured),
        );
      }
    } else {
      if (isFeatured && Get.find<SplashController>().moduleList != null) {
        for (ModuleModel module in Get.find<SplashController>().moduleList!) {
          if (module.id == item!.moduleId) {
            Get.find<SplashController>().setModule(module);
            break;
          }
        }
      }
      Get.find<ItemController>().navigateToItemPage(item, context,
          inStore: inStore, isCampaign: isCampaign);
    }
  }

  Widget _buildVoucherCard(BuildContext context, bool hovered, double? discount,
      String? discountType, bool isAvailable) {
    List<Color> colors = _getVoucherColors(item!.voucherIds);
    Color mixedColor = Color.lerp(colors[0], colors[1], 0.3) ?? colors[0];

    double displayDiscount = discount ?? 0;
    String displayDiscountType = discountType ?? 'percent';
    String saveText = (item!.offerType?.toLowerCase() == 'cash back')
        ? 'cashback_uppercase'.tr
        : (item!.bundleType == 'gift'
            ? 'bonus_uppercase'.tr
            : 'save_uppercase'.tr);

    if ((Get.currentRoute.contains(RouteHelper.categoryItem) ||
            Get.currentRoute.contains(RouteHelper.store)) &&
        item!.commissionPaidBy == 'customer' &&
        (item!.storeCommission ?? 0) > 0 &&
        item!.bundleType != 'gift') {
      if (item!.bundleType == 'simple x') {
        saveText = 'save_uppercase'.tr;
        if (displayDiscountType == 'percent') {
          displayDiscount = displayDiscount -
              (1 - displayDiscount / 100) * item!.storeCommission!;
        } else {
          double priceForFormula = item!.actualPrice ?? item!.price ?? 100;
          if (priceForFormula > 0) {
            double afterD = priceForFormula - displayDiscount;
            double comm = afterD * (item!.storeCommission! / 100);
            displayDiscount =
                ((displayDiscount - comm) / priceForFormula) * 100;
            displayDiscountType = 'percent';
          }
        }
      } else {
        saveText = (item!.offerType?.toLowerCase() == 'cash back')
            ? 'cash_back_upto'.tr
            : 'save_upto'.tr;
      }
    }

    return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: ClipPath(
            clipper: ScallopedEdgeClipper(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: CustomPaint(
                painter: CurvedBorderPainter(
                  colors: colors,
                  stops: const [0.7, 1.0],
                ),
                child: CustomInkWell(
                  onTap: () => _onTap(context),
                  radius: Dimensions.radiusDefault,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Section (Image Area)
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomImage(
                                isHovered: hovered,
                                image: item!.imageFullUrl ?? '',
                                height: 165,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Voucher Type Badge (Top-Left)
                          if (item!.voucherIds != null &&
                              item!.voucherIds!.isNotEmpty)
                            Positioned(
                              top: 0,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: colors, stops: const [0.7, 1.0]),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  item!.voucherIds ?? 'Voucher',
                                  style: robotoBold.copyWith(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),

                          // Rating (Bottom-Left)
                          if ((item!.avgRating ?? 0) > 0)
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      (item!.avgRating ?? 0).toStringAsFixed(1),
                                      style: robotoBold.copyWith(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Favorite (Bottom-Right)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GetBuilder<FavouriteController>(
                                builder: (favouriteController) {
                              bool isWished = favouriteController.wishItemIdList
                                  .contains(item?.id);
                              return CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context)
                                    .cardColor
                                    .withValues(alpha: 0.8),
                                child: CustomFavouriteWidget(
                                  isWished: isWished,
                                  isStore: false,
                                  item: item,
                                ),
                              );
                            }),
                          ),

                          // Carousel Dots (Design Placeholder)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        shape: BoxShape.circle)),
                              ],
                            ),
                          ),

                          if (!isAvailable) NotAvailableWidget(isStore: false),
                        ],
                      ),

                      // Middle Divider
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 10,
                            color: Colors.transparent,
                          ),
                          CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: HorizontalDashedLinePainter(
                              color: mixedColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Section (Info Area)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item!.name ?? '',
                                        style: robotoBlack.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).primaryColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item!.availabilityForCurrentUser
                                              ?.status ==
                                          'not_available')
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'out_of_stock'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                        ),
                                      if (item!.availabilityForCurrentUser
                                              ?.userUsage !=
                                          null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '${'remaining'.tr}: ${item!.availabilityForCurrentUser!.userUsage!.remaining ?? 0}',
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Save Badge
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 11, right: 11, top: 14, bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: colors,
                                        stops: const [0.7, 1.0]),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        saveText,
                                        style: robotoBold.copyWith(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                      Text(
                                        (displayDiscountType == 'amount' ||
                                                displayDiscountType == 'fixed')
                                            ? PriceConverter.convertPrice(
                                                displayDiscount)
                                            : '${displayDiscount % 1 == 0 ? displayDiscount.toInt() : displayDiscount.toStringAsFixed(1)}%',
                                        style: robotoBlack.copyWith(
                                            color: Colors.white,
                                            fontSize: 18,
                                            height: 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CustomImage(
                                        image: (item!.store != null &&
                                                item!.store!.logoFullUrl !=
                                                    null &&
                                                item!.store!.logoFullUrl!
                                                    .isNotEmpty)
                                            ? item!.store!.logoFullUrl!
                                            : (item!.storeLogoFullUrl != null &&
                                                    item!.storeLogoFullUrl!
                                                        .isNotEmpty)
                                                ? item!.storeLogoFullUrl!
                                                : (Get.isRegistered<
                                                            CategoryController>() &&
                                                        Get.find<CategoryController>()
                                                                .categoryStoreList !=
                                                            null)
                                                    ? (Get.find<CategoryController>()
                                                            .categoryStoreList!
                                                            .firstWhereOrNull(
                                                                (s) =>
                                                                    s.id ==
                                                                    item!
                                                                        .storeId)
                                                            ?.logoFullUrl ??
                                                        '')
                                                    : '',
                                        height: 38,
                                        width: 38,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      item!.storeName ?? '',
                                      style: robotoBlack.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (item!.bundleType == 'simple x')
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          PriceConverter.convertPrice(
                                              item!.actualPrice ?? item!.price),
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color:
                                                Theme.of(context).disabledColor,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                    if (item!.bundleType == 'simple x')
                                      Text(
                                        PriceConverter.convertPrice(
                                            item!.price),
                                        style: robotoBlack.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Colors.black),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  List<Color> _getVoucherColors(String? voucherIds) {
    if (voucherIds == null) {
      return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
    }
    String ids = voucherIds.toLowerCase();
    if (ids.contains('delivery') || ids.contains('pickup')) {
      return [const Color(0xFFF43F8C), const Color(0xFFFB8B5E)];
    } else if (ids.contains('in-store') ||
        ids.contains('instore') ||
        ids.contains('in store')) {
      return [const Color(0xFF1ABC9C), const Color(0xFFA8E063)];
    } else if (ids.contains('flat') ||
        ids.contains('discount') ||
        ids.contains('voucher')) {
      return [const Color(0xFFFF8A2B), const Color(0xFFFFD54F)];
    } else if (ids.contains('gift')) {
      return [const Color(0xFF6A4DF4), const Color(0xFFC084FC)];
    }
    return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
  }
}
