import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';

class GiftScreen3 extends StatefulWidget {
  final GiftOccasionModel occasion;
  const GiftScreen3({super.key, required this.occasion});

  @override
  State<GiftScreen3> createState() => _GiftScreen3State();
}

class _GiftScreen3State extends State<GiftScreen3> {
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Select Design'),
      body: GetBuilder<GiftController>(builder: (giftController) {
        return giftController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Row(children: [
                          Icon(Icons.favorite,
                              color: Theme.of(context).primaryColor, size: 20),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text('Selecting for ${widget.occasion.title}',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor)),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      if (widget.occasion.icon != null)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: Dimensions.paddingSizeDefault,
                            mainAxisSpacing: Dimensions.paddingSizeDefault,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: widget.occasion.icon!.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredIndex = index),
                              onExit: (_) =>
                                  setState(() => _hoveredIndex = null),
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(RouteHelper.getGiftRoute4());
                                },
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1)
                                    ],
                                  ),
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      child: CustomImage(
                                        image: (widget.occasion.icon![index]
                                                .startsWith('http')
                                            ? widget.occasion.icon![index]
                                            : '${AppConstants.baseUrl}/${widget.occasion.icon![index]}'),
                                        height: double.infinity,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
                    ]),
              );
      }),
    );
  }
}
