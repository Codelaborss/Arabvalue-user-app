import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/section_tab_bar.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_voucher_view.dart';
import 'package:sixam_mart/features/home/widgets/views/hot_voucher_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_voucher_view.dart';

class VoucherHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const VoucherHomeScreen({super.key, this.scrollController});

  @override
  State<VoucherHomeScreen> createState() => _VoucherHomeScreenState();
}

class _VoucherHomeScreenState extends State<VoucherHomeScreen> {
  final GlobalKey _hotVoucherKey = GlobalKey();
  final GlobalKey _recommendedStoreKey = GlobalKey();
  final GlobalKey _recommendedVoucherKey = GlobalKey();
  final GlobalKey _newVoucherKey = GlobalKey();
  final GlobalKey _specialOfferKey = GlobalKey();
  final GlobalKey _bestStoreKey = GlobalKey();
  final GlobalKey _itemYouLoveKey = GlobalKey();
  final GlobalKey _mostPopularKey = GlobalKey();
  final GlobalKey _newOnMartKey = GlobalKey();

  List<String> _getSections() {
    List<String> sections = [
      'Hot Vouchers',
      'Recommended Store',
      'Recommended Vouchers',
      'New Voucher',
      'Best Store Nearby',
      'Special Offer',
      'Item You Love',
      'Most Popular',
      'New on 6amMart',
    ];

    // Add first 3 categories to the end
    final categoryController = Get.find<CategoryController>();
    if (categoryController.categoryList != null &&
        categoryController.categoryList!.isNotEmpty) {
      int count = categoryController.categoryList!.length > 3
          ? 3
          : categoryController.categoryList!.length;
      for (int i = 0; i < count; i++) {
        sections.add(categoryController.categoryList![i].name ?? '');
      }
    }

    return sections;
  }

  void _scrollToSection(int index) {
    final categoryController = Get.find<CategoryController>();
    int baseSectionCount = 9;

    // If category clicked, navigate to category screen
    if (index >= baseSectionCount) {
      int categoryIndex = index - baseSectionCount;
      if (categoryController.categoryList != null &&
          categoryIndex < categoryController.categoryList!.length) {
        Get.toNamed(RouteHelper.getCategoryItemRoute(
          categoryController.categoryList![categoryIndex].id,
          categoryController.categoryList![categoryIndex].name!,
        ));
        return;
      }
    }

    GlobalKey? targetKey;

    switch (index) {
      case 0:
        targetKey = _hotVoucherKey;
        break;
      case 1:
        targetKey = _recommendedStoreKey;
        break;
      case 2:
        targetKey = _recommendedVoucherKey;
        break;
      case 3:
        targetKey = _newVoucherKey;
        break;
      case 4:
        targetKey = _bestStoreKey;
        break;
      case 5:
        targetKey = _specialOfferKey;
        break;
      case 6:
        targetKey = _itemYouLoveKey;
        break;
      case 7:
        targetKey = _mostPopularKey;
        break;
      case 8:
        targetKey = _newOnMartKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      final RenderBox box =
          targetKey.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero, ancestor: null).dy;
      final offset = widget.scrollController!.offset;

      widget.scrollController!.animateTo(
        offset + position - 160, // 160 offset for appbar + tab bar
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: Get.find<ThemeController>().darkTheme
              ? null
              : const BoxDecoration(),
          child: const Column(
            children: [
              BannerView(isFeatured: false),
              SizedBox(height: 5),
            ],
          ),
        ),

        // Tab Bar with categories
        if (widget.scrollController != null)
          SectionTabBar(
            sections: _getSections(),
            onTabTap: _scrollToSection,
            scrollController: widget.scrollController!,
          ),

        Container(key: _hotVoucherKey, child: const HotVoucherView()),
        Container(
            key: _recommendedStoreKey, child: const RecommendedStoreView()),
        Container(
            key: _recommendedVoucherKey, child: const RecommendedVoucherView()),
        Container(
            key: _newVoucherKey,
            child: const NewVoucherView(isFood: false, isShop: false)),
        Container(key: _bestStoreKey, child: const BestStoreNearbyView()),
        Container(
            key: _specialOfferKey,
            child: const SpecialOfferView(isFood: false, isShop: false)),
        Container(
            key: _itemYouLoveKey,
            child: const ItemThatYouLoveView(forShop: false)),
        Container(
            key: _mostPopularKey,
            child: const MostPopularItemView(isFood: false, isShop: false)),
        const HighlightWidget(),
        const TopOffersNearMe(),
        const BestReviewItemView(),
        const JustForYouView(),
        Container(
            key: _newOnMartKey,
            child: const NewOnMartView(
                isNewStore: true, isPharmacy: false, isShop: false)),
      ]);
    });
  }
}
