import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
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
import 'package:sixam_mart/common/widgets/scalloped_edge_clipper.dart';
import 'package:sixam_mart/common/widgets/curved_border_painter.dart';
import 'package:sixam_mart/common/widgets/horizontal_dashed_line_painter.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  const WebItemWidget(
      {super.key,
      required this.item,
      required this.isStore,
      required this.store,
      required this.index,
      required this.length,
      this.inStore = false,
      this.isCampaign = false,
      this.isFeatured = false,
      this.fromCartSuggestion = false});

  @override
  Widget build(BuildContext context) {
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
      return InkWell(
        onTap: () {
          if (isStore) {
            if (store != null) {
              if (isFeatured &&
                  Get.find<SplashController>().moduleList != null) {
                for (ModuleModel module
                    in Get.find<SplashController>().moduleList!) {
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
              for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                if (module.id == item!.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.find<ItemController>().navigateToItemPage(item, context,
                inStore: inStore, isCampaign: isCampaign);
          }
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: OnHover(
          isItem: true,
          child: Stack(
            children: [
              Container(
                margin: ResponsiveHelper.isDesktop(context)
                    ? null
                    : const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(1),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(children: [
                        Stack(children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft:
                                    Radius.circular(Dimensions.radiusSmall),
                                topRight:
                                    Radius.circular(Dimensions.radiusSmall)),
                            child: CustomImage(
                              isHovered: hovered,
                              image:
                                  '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                              height: desktop
                                  ? 140
                                  : length == null
                                      ? 100
                                      : 65,
                              width: desktop
                                  ? isStore
                                      ? 275
                                      : 300
                                  : 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: discount,
                            discountType: discountType,
                            freeDelivery: isStore ? store!.freeDelivery : false,
                          ),
                          !isStore
                              ? OrganicTag(
                                  item: item!,
                                  placeInImage: false,
                                  placeTop: false)
                              : const SizedBox(),
                          isStore
                              ? const SizedBox()
                              : Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: CartCountView(
                                    item: item!,
                                    index: index,
                                  ),
                                ),
                          isAvailable
                              ? const SizedBox()
                              : NotAvailableWidget(isStore: isStore),
                        ]),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall),
                            child: SizedBox(
                              width: desktop
                                  ? isStore
                                      ? 275
                                      : 219
                                  : 80,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            isStore
                                                ? store!.name!
                                                : item!.name!,
                                            style: robotoMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall),
                                            maxLines: desktop ? 1 : 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          (Get.find<SplashController>()
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
                                        ]),
                                    SizedBox(
                                        height: isStore
                                            ? Dimensions.paddingSizeExtraSmall
                                            : 0),
                                    (genericName.isNotEmpty)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Text(
                                              genericName,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeOverSmall,
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : const SizedBox(),
                                    (isStore
                                            ? store!.address != null
                                            : item!.storeName != null)
                                        ? Text(
                                            isStore
                                                ? store!.address ?? ''
                                                : item!.storeName ?? '',
                                            style: robotoRegular.copyWith(
                                              fontWeight: FontWeight.w300,
                                              fontSize:
                                                  Dimensions.fontSizeOverSmall,
                                              color: isStore
                                                  ? Theme.of(context)
                                                      .disabledColor
                                                  : Theme.of(context)
                                                      .primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : const SizedBox(),
                                    SizedBox(
                                        height: ((desktop || isStore) &&
                                                (isStore
                                                    ? store!.address != null
                                                    : item!.storeName != null))
                                            ? 5
                                            : 0),
                                    isStore
                                        ? RatingBar(
                                            rating: isStore
                                                ? store!.avgRating
                                                : item!.avgRating,
                                            size: desktop ? 15 : 12,
                                            ratingCount: isStore
                                                ? store!.ratingCount
                                                : item!.ratingCount,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                                (item!.type == 'voucher')
                                                    ? const SizedBox()
                                                    : Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            PriceConverter
                                                                .convertPrice(
                                                                    item!.price,
                                                                    discount:
                                                                        discount,
                                                                    discountType:
                                                                        discountType),
                                                            style: robotoMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeExtraSmall),
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr,
                                                          ),
                                                          SizedBox(
                                                              width: discount! >
                                                                      0
                                                                  ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                  : 0),
                                                          discount > 0
                                                              ? Text(
                                                                  PriceConverter
                                                                      .convertPrice(
                                                                          item!
                                                                              .price),
                                                                  style: robotoMedium
                                                                      .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeOverSmall,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                  ),
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3,
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                              alpha: 0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.star,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: 12),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Text(
                                                        item!.ratingCount
                                                            .toString(),
                                                        style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeOverSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ]),
                                  ]),
                            ),
                          ),
                        ),
                      ])),
                    ]),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                  bool isWished = isStore
                      ? favouriteController.wishStoreIdList.contains(store!.id)
                      : favouriteController.wishItemIdList.contains(item!.id);
                  return CustomFavouriteWidget(
                    isWished: isWished,
                    isStore: isStore,
                    store: store,
                    item: item,
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
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
                  onTap: () {
                    if (isFeatured &&
                        Get.find<SplashController>().moduleList != null) {
                      for (ModuleModel module
                          in Get.find<SplashController>().moduleList!) {
                        if (module.id == item!.moduleId) {
                          Get.find<SplashController>().setModule(module);
                          break;
                        }
                      }
                    }
                    Get.find<ItemController>().navigateToItemPage(item, context,
                        inStore: inStore, isCampaign: isCampaign);
                  },
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
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
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
                            const SizedBox(height: 6),
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
                                        style: robotoBold.copyWith(
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
                                        displayDiscountType == 'amount'
                                            ? PriceConverter.convertPrice(
                                                displayDiscount)
                                            : '${displayDiscount % 1 == 0 ? displayDiscount.toInt() : displayDiscount.toStringAsFixed(1)}%',
                                        style: robotoBlack.copyWith(
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
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
                                      style: robotoMedium.copyWith(
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
                                        style: robotoBold.copyWith(
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
