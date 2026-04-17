import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'categories'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
          child: SingleChildScrollView(
              controller: scrollController,
              child: FooterView(
                  child: Column(
                children: [
                  WebScreenTitleWidget(title: 'categories'.tr),
                  SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<CategoryController>(
                        builder: (catController) {
                      return catController.categoryList != null
                          ? catController.categoryList!.isNotEmpty
                              ? GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        ResponsiveHelper.isDesktop(context)
                                            ? 6
                                            : ResponsiveHelper.isTab(context)
                                                ? 4
                                                : 3,
                                    childAspectRatio: (1 / 1),
                                    mainAxisSpacing:
                                        Dimensions.paddingSizeSmall,
                                    crossAxisSpacing:
                                        Dimensions.paddingSizeSmall,
                                  ),
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  itemCount: catController.categoryList!.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () => Get.toNamed(
                                          RouteHelper.getCategoryItemRoute(
                                        catController.categoryList![index].id,
                                        catController
                                            .categoryList![index].name!,
                                      )),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.lerp(
                                                  [
                                                    const Color(0xFFFE7F6E),
                                                    const Color(0xFFA06EFE),
                                                    const Color(0xFF6E84FE),
                                                    const Color(0xFFFE8F35),
                                                    const Color(0xFFEFA800),
                                                    const Color(0xFF41C0EF),
                                                  ][index % 6],
                                                  Colors.white,
                                                  0.6)!,
                                              [
                                                const Color(0xFFFE7F6E),
                                                const Color(0xFFA06EFE),
                                                const Color(0xFF6E84FE),
                                                const Color(0xFFFE8F35),
                                                const Color(0xFFEFA800),
                                                const Color(0xFF41C0EF),
                                              ][index % 6],
                                            ],
                                            stops: const [0.1, 0.9],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusLarge),
                                        ),
                                        child: Stack(children: [
                                          Positioned(
                                            bottom: Dimensions.paddingSizeSmall,
                                            left: Dimensions.paddingSizeSmall,
                                            right: Dimensions.paddingSizeLarge,
                                            child: Text(
                                              catController
                                                  .categoryList![index].name!,
                                              style: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall,
                                                  color: Colors.white),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              child: CustomImage(
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.contain,
                                                image:
                                                    '${catController.categoryList![index].imageFullUrl}',
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    );
                                  },
                                )
                              : NoDataScreen(text: 'no_category_found'.tr)
                          : const Center(child: CircularProgressIndicator());
                    }),
                  ),
                ],
              )))),
    );
  }
}
