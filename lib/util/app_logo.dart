// lib/common/widgets/app_logo_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/util/images.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    Key? key,
    this.height = 50,
    this.width,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getLogoUrl(),
      builder: (context, snapshot) {
        // API logo mil gaya
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.network(
            snapshot.data!,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              // Network error? Fallback to asset
              return Image.asset(Images.logo, height: height, width: width, fit: fit);
            },
          );
        }
        
        // Loading ya no data? Show asset logo
        return Image.asset(Images.logo, height: height, width: width, fit: fit);
      },
    );
  }

  Future<String> _getLogoUrl() async {
    try {
      if (Get.isRegistered<AuthServiceInterface>()) {
        return await Get.find<AuthServiceInterface>().getAppLogoUrl();
      }
    } catch (e) {
      print('====> ⚠️ Could not load app logo: $e');
    }
    return '';
  }
}