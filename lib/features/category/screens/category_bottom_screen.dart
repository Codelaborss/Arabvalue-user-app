import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryBottomScreen extends StatefulWidget {
  const CategoryBottomScreen({super.key});

  @override
  State<CategoryBottomScreen> createState() => _CategoryBottomScreenState();
}

class _CategoryBottomScreenState extends State<CategoryBottomScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'categories'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return categoryController.categoryList != null
              ? categoryController.categoryList!.isNotEmpty
                  ? GridView.builder(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isDesktop(context)
                            ? 4
                            : ResponsiveHelper.isTab(context)
                                ? 3
                                : 2,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                      ),
                      itemCount: categoryController.categoryList!.length,
                      itemBuilder: (context, index) {
                        final category =
                            categoryController.categoryList![index];

                        final List<Color> colors = [
                          const Color(0xFFFE7F6E),
                          const Color(0xFFA06EFE),
                          const Color(0xFF6E84FE),
                          const Color(0xFFFE8F35),
                          const Color(0xFFEFA800),
                          const Color(0xFF41C0EF),
                        ];
                        final Color mainColor = colors[index % colors.length];

                        return InkWell(
                          onTap: () => Get.toNamed(
                            RouteHelper.getCategoryItemRoute(
                              category.id,
                              category.name!,
                            ),
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.lerp(mainColor, Colors.white, 0.6)!,
                                  mainColor,
                                ],
                                stops: const [0.1, 0.9],
                              ),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                            child: Stack(
                              children: [
                                // Name at bottom left
                                Positioned(
                                  bottom: Dimensions.paddingSizeSmall,
                                  left: Dimensions.paddingSizeSmall,
                                  right: Dimensions.paddingSizeLarge,
                                  child: Text(
                                    category.name!,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Image at top right, straight
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    child: CustomImage(
                                      image: '${category.imageFullUrl}',
                                      height: 85,
                                      width: 85,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'no_category_found'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    )
              : GridView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isDesktop(context)
                        ? 4
                        : ResponsiveHelper.isTab(context)
                            ? 3
                            : 2,
                    childAspectRatio: 1,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
