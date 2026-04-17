import 'package:flutter/material.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:get/get.dart';

class GiftScreen2 extends StatefulWidget {
  const GiftScreen2({super.key});

  @override
  State<GiftScreen2> createState() => _GiftScreen2State();
}

class _GiftScreen2State extends State<GiftScreen2> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gift Card'),
      body: GetBuilder<GiftController>(builder: (giftController) {
        return giftController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Input
                      CustomTextField(
                        titleText: 'Search for occasion or color',
                        hintText: 'Search for occasion or color',
                        prefixIcon: Icons.search,
                        inputType: TextInputType.text,
                        controller: _searchController,
                        showLabelText: false,
                        onChanged: (String value) {},
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Text('Occasions',
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // Occasions Grid
                      if (giftController.giftOccasionList != null)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            childAspectRatio: 3,
                          ),
                          itemCount: giftController.giftOccasionList!.length,
                          itemBuilder: (context, index) {
                            return _buildOccasionItem(context,
                                giftController.giftOccasionList![index], index);
                          },
                        ),
                    ]),
              );
      }),
    );
  }

  Widget _buildOccasionItem(
      BuildContext context, GiftOccasionModel occasion, int index) {
    List<IconData> iconList = [
      Icons.favorite,
      Icons.card_giftcard,
      Icons.cake,
      Icons.celebration,
      Icons.event,
      Icons.redeem,
      Icons.stars,
      Icons.auto_awesome,
    ];
    return InkWell(
      onTap: () {
        Get.find<GiftController>().selectOccasion(occasion);
        Get.toNamed(RouteHelper.getGiftRoute3(occasion));
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .primaryColor
              .withOpacity(0.05), // Light background
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.1)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconList[index % iconList.length],
                color: Theme.of(context).primaryColor, size: 15),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              occasion.title ?? '',
              style:
                  robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}
