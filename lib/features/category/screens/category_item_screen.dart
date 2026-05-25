import 'package:flutter/foundation.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/profile_notification_widget.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFilterMenuOpen = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    Get.find<CategoryController>().getCategoryStoreList(
      widget.categoryID,
      1,
      Get.find<CategoryController>().type,
      false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.find<CategoryController>()
        .setVoucherFilter('Voucher Type', notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item =
          catController.getFilteredItems(searching: catController.isSearching);
      List<Store>? stores;
      if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (catController.isSearching) {
            catController.toggleSearch();
          } else {
            return;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  backgroundColor: Theme.of(context).cardColor,
                  surfaceTintColor: Theme.of(context).cardColor,
                  shadowColor:
                      Theme.of(context).disabledColor.withValues(alpha: 0.5),
                  elevation: 2,
                  title: catController.isSearching
                      ? SizedBox(
                          height: 45,
                          child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => catController.toggleSearch(),
                                  icon: Icon(
                                    catController.isSearching
                                        ? Icons.close_sharp
                                        : Icons.search,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ),
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge),
                              onSubmitted: (String query) {
                                catController.searchData(
                                  query,
                                  catController.subCategoryIndex == 0
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  catController.type,
                                );
                              }),
                        )
                      : Text(widget.categoryName,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if (catController.isSearching) {
                        catController.toggleSearch();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  actions: [
                    const ProfileNotificationWidget(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                )),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: ResponsiveHelper.isDesktop(context)
              ? SingleChildScrollView(
                  child: FooterView(
                    child: Center(
                        child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(children: [
                        /*(catController.subCategoryList != null &&
                                !catController.isSearching)
                            ? Center(
                                child: Container(
                                height: 40,
                                width: Dimensions.webMaxWidth,
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: ListView.builder(
                                  key: scaffoldKey,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      catController.subCategoryList!.length,
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () =>
                                          catController.setSubCategoryIndex(
                                              index, widget.categoryID),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: index ==
                                                  catController.subCategoryIndex
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                catController
                                                    .subCategoryList![index]
                                                    .name!,
                                                style: index ==
                                                        catController
                                                            .subCategoryIndex
                                                    ? robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .primaryColor)
                                                    : robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                ),
                              ))
                            : const SizedBox(),*/
                        Center(
                            child: Container(
                          width: Dimensions.webMaxWidth,
                          color: Theme.of(context).cardColor,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withValues(alpha: 0.2)),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraLarge,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraSmall,
                                vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TabBar(
                                    controller: _tabController,
                                    indicatorColor: Colors.transparent,
                                    labelColor: Colors.white,
                                    unselectedLabelColor:
                                        Theme.of(context).primaryColor,
                                    unselectedLabelStyle: robotoMedium.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeSmall),
                                    labelStyle: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.white),
                                    indicator: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicatorPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                    tabs: [
                                      Tab(text: 'voucher'.tr),
                                      Tab(
                                          text: Get.find<SplashController>()
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .showRestaurantText!
                                              ? 'partners'.tr
                                              : 'stores'.tr),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 38,
                                  width: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isFilterMenuOpen
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .disabledColor
                                              .withValues(alpha: 0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: PopupMenuButton<String>(
                                    offset: Offset(
                                        Directionality.of(context) ==
                                                TextDirection.ltr
                                            ? 40
                                            : -40,
                                        45),
                                    surfaceTintColor: Colors.white,
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusLarge)),
                                    child: Icon(Icons.menu,
                                        color: Theme.of(context).primaryColor,
                                        size: 22),
                                    onOpened: () => setState(
                                        () => _isFilterMenuOpen = true),
                                    onCanceled: () => setState(
                                        () => _isFilterMenuOpen = false),
                                    onSelected: (String value) {
                                      catController.setVoucherFilter(value);
                                      setState(() => _isFilterMenuOpen = false);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'all',
                                        'Delivery/Pickup',
                                        'In-Store',
                                        'Flat',
                                        'Gift'
                                      ].map((String choice) {
                                        bool isSelected = (choice == 'all' &&
                                                catController.voucherFilter ==
                                                    'Voucher Type') ||
                                            (catController.voucherFilter ==
                                                choice);
                                        String displayLabel = choice == 'all'
                                            ? 'all'.tr
                                            : (choice == 'Gift'
                                                ? 'gift_cards'.tr
                                                : (choice == 'Delivery/Pickup'
                                                    ? 'delivery'.tr
                                                    : choice.tr));

                                        return PopupMenuItem<String>(
                                          value: choice == 'all'
                                              ? 'Voucher Type'
                                              : choice,
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Center(
                                            child: Container(
                                              width: 120,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusExtraLarge),
                                              ),
                                              child: Text(displayLabel,
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Theme.of(context)
                                                            .primaryColor,
                                                  )),
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        SizedBox(
                          height: 600,
                          child: NotificationListener(
                            onNotification: (dynamic scrollNotification) {
                              if (scrollNotification is ScrollEndNotification) {
                                if ((_tabController!.index == 1 &&
                                        !catController.isStore) ||
                                    _tabController!.index == 0 &&
                                        catController.isStore) {
                                  catController.setRestaurant(
                                      _tabController!.index == 1);
                                  if (catController.isSearching) {
                                    catController.searchData(
                                      catController.searchText,
                                      catController.subCategoryIndex == 0
                                          ? widget.categoryID
                                          : catController
                                              .subCategoryList![catController
                                                  .subCategoryIndex]
                                              .id
                                              .toString(),
                                      catController.type,
                                    );
                                  } else {
                                    if (_tabController!.index == 1) {
                                      catController.getCategoryStoreList(
                                        catController.subCategoryIndex == 0
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        1,
                                        catController.type,
                                        false,
                                      );
                                    } else {
                                      catController.getCategoryItemList(
                                        catController.subCategoryIndex == 0
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        1,
                                        catController.type,
                                        false,
                                      );
                                    }
                                  }
                                }
                              }
                              return false;
                            },
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  controller: scrollController,
                                  child: PaginatedListView(
                                    scrollController: scrollController,
                                    totalSize: catController.pageSize,
                                    offset: catController.offset,
                                    onPaginate: (int? offset) async {
                                      catController.showBottomLoader();
                                      catController.getCategoryItemList(
                                        catController.subCategoryIndex == 0
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        offset!,
                                        catController.type,
                                        false,
                                      );
                                    },
                                    itemView: ItemsView(
                                      isStore: false,
                                      items: item,
                                      stores: null,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeExtraLarge,
                                          vertical:
                                              Dimensions.paddingSizeDefault),
                                      noDataText:
                                          'no_category_voucher_found'.tr,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  controller: storeScrollController,
                                  child: PaginatedListView(
                                    scrollController: storeScrollController,
                                    totalSize: catController.restPageSize,
                                    offset: catController.offset,
                                    onPaginate: (int? offset) async {
                                      catController.showBottomLoader();
                                      catController.getCategoryStoreList(
                                        catController.subCategoryIndex == 0
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        offset!,
                                        catController.type,
                                        false,
                                      );
                                    },
                                    itemView: ItemsView(
                                      isStore: true,
                                      items: null,
                                      stores: stores,
                                      isPartner: true,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeExtraLarge,
                                          vertical:
                                              Dimensions.paddingSizeDefault),
                                      noDataText: Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .showRestaurantText!
                                          ? 'no_category_partner_found'.tr
                                          : 'no_category_store_found'.tr,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        catController.isLoading
                            ? Center(
                                child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor)),
                              ))
                            : const SizedBox(),
                      ]),
                    )),
                  ),
                )
              : SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [
                    const SizedBox(height: 10),
                    /*(catController.subCategoryList != null &&
                            !catController.isSearching)
                        ? Column(
                            children: [
                              Center(
                                  child: Container(
                                height: 40,
                                width: Dimensions.webMaxWidth,
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: ListView.builder(
                                  key: scaffoldKey,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      catController.subCategoryList!.length,
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () =>
                                          catController.setSubCategoryIndex(
                                              index, widget.categoryID),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: index ==
                                                  catController.subCategoryIndex
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                catController
                                                    .subCategoryList![index]
                                                    .name!,
                                                style: index ==
                                                        catController
                                                            .subCategoryIndex
                                                    ? robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .primaryColor)
                                                    : robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                ),
                              )),
                              Center(
                                  child: Container(
                                height: 40,
                                width: Dimensions.webMaxWidth,
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: [
                                    'Voucher Type',
                                    'Delivery/Pickup',
                                    'Gift',
                                    'In-Store',
                                    'Flat'
                                  ].length,
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    List<String> vouchers = [
                                      'Voucher Type',
                                      'Delivery/Pickup',
                                      'Gift',
                                      'In-Store',
                                      'Flat'
                                    ];
                                    String value = vouchers[index];
                                    bool isSelected =
                                        catController.voucherFilter == value;

                                    return InkWell(
                                      onTap: () =>
                                          catController.setVoucherFilter(value),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                value,
                                                style: isSelected
                                                    ? robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .primaryColor)
                                                    : robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall),
                                              ),
                                            ]),
                                      ),
                                    );
                                  },
                                ),
                              )),
                            ],
                          )
                        : const SizedBox(),*/
                    Center(
                        child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).cardColor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge),
                          border: Border.all(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withOpacity(0.2)),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraLarge,
                            vertical: Dimensions.paddingSizeExtraSmall),
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraSmall,
                            vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                unselectedLabelColor:
                                    Theme.of(context).primaryColor,
                                unselectedLabelStyle: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeSmall),
                                labelStyle: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.white),
                                indicator: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                tabs: [
                                  Tab(text: 'voucher'.tr),
                                  Tab(
                                      text: Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .showRestaurantText!
                                          ? 'partners'.tr
                                          : 'stores'.tr),
                                ],
                              ),
                            ),
                            Container(
                              height: 38,
                              width: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isFilterMenuOpen
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .disabledColor
                                          .withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: PopupMenuButton<String>(
                                offset: Offset(
                                    Directionality.of(context) ==
                                            TextDirection.ltr
                                        ? 40
                                        : -40,
                                    45),
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusLarge)),
                                child: Icon(Icons.menu,
                                    color: Theme.of(context).primaryColor,
                                    size: 22),
                                onOpened: () =>
                                    setState(() => _isFilterMenuOpen = true),
                                onCanceled: () =>
                                    setState(() => _isFilterMenuOpen = false),
                                onSelected: (String value) {
                                  catController.setVoucherFilter(value);
                                  setState(() => _isFilterMenuOpen = false);
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    'all',
                                    'Delivery/Pickup',
                                    'In-Store',
                                    'Flat',
                                    'Gift'
                                  ].map((String choice) {
                                    bool isSelected = (choice == 'all' &&
                                            catController.voucherFilter ==
                                                'Voucher Type') ||
                                        (catController.voucherFilter == choice);
                                    String displayLabel = choice == 'all'
                                        ? 'all'.tr
                                        : (choice == 'Gift'
                                            ? 'gift_cards'.tr
                                            : (choice == 'Delivery/Pickup'
                                                ? 'delivery'.tr
                                                : choice.tr));

                                    return PopupMenuItem<String>(
                                      value: choice == 'all'
                                          ? 'Voucher Type'
                                          : choice,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Center(
                                        child: Container(
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusExtraLarge),
                                          ),
                                          child: Text(displayLabel,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .primaryColor,
                                              )),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    Expanded(
                        child: NotificationListener(
                      onNotification: (dynamic scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          if ((_tabController!.index == 1 &&
                                  !catController.isStore) ||
                              _tabController!.index == 0 &&
                                  catController.isStore) {
                            catController
                                .setRestaurant(_tabController!.index == 1);
                            if (catController.isSearching) {
                              catController.searchData(
                                catController.searchText,
                                catController.subCategoryIndex == 0
                                    ? widget.categoryID
                                    : catController
                                        .subCategoryList![
                                            catController.subCategoryIndex]
                                        .id
                                        .toString(),
                                catController.type,
                              );
                            } else {
                              if (_tabController!.index == 1) {
                                catController.getCategoryStoreList(
                                  catController.subCategoryIndex == 0
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  1,
                                  catController.type,
                                  false,
                                );
                              } else {
                                catController.getCategoryItemList(
                                  catController.subCategoryIndex == 0
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  1,
                                  catController.type,
                                  false,
                                );
                              }
                            }
                          }
                        }
                        return false;
                      },
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SingleChildScrollView(
                            controller: scrollController,
                            child: PaginatedListView(
                              scrollController: scrollController,
                              totalSize: catController.pageSize,
                              offset: catController.offset,
                              onPaginate: (int? offset) async {
                                catController.showBottomLoader();
                                catController.getCategoryItemList(
                                  catController.subCategoryIndex == 0
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  offset!,
                                  catController.type,
                                  false,
                                );
                              },
                              itemView: ItemsView(
                                isStore: false,
                                items: item,
                                stores: null,
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraLarge,
                                    vertical: Dimensions.paddingSizeDefault),
                                noDataText: 'no_category_voucher_found'.tr,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            controller: storeScrollController,
                            child: PaginatedListView(
                              scrollController: storeScrollController,
                              totalSize: catController.restPageSize,
                              offset: catController.offset,
                              onPaginate: (int? offset) async {
                                catController.showBottomLoader();
                                catController.getCategoryStoreList(
                                  catController.subCategoryIndex == 0
                                      ? widget.categoryID
                                      : catController
                                          .subCategoryList![
                                              catController.subCategoryIndex]
                                          .id
                                          .toString(),
                                  offset!,
                                  catController.type,
                                  false,
                                );
                              },
                              itemView: ItemsView(
                                isStore: true,
                                items: null,
                                stores: stores,
                                isPartner: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraLarge,
                                    vertical: Dimensions.paddingSizeDefault),
                                noDataText: Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'no_category_partner_found'.tr
                                    : 'no_category_store_found'.tr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    catController.isLoading
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)),
                          ))
                        : const SizedBox(),
                  ]),
                ),
        ),
      );
    });
  }
}
