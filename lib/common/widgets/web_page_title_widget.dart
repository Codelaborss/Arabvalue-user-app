import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class WebScreenTitleWidget extends StatelessWidget {
  final String title;
  const WebScreenTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? Container(
            height: 64,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(title, style: robotoMedium),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
