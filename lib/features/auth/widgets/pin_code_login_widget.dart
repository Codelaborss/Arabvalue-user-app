import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/auth_response_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class PinCodeLoginWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const PinCodeLoginWidget(
      {super.key, required this.exitFromApp, required this.backFromThis});

  @override
  State<PinCodeLoginWidget> createState() => _PinCodeLoginWidgetState();
}

class _PinCodeLoginWidgetState extends State<PinCodeLoginWidget> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_pinController.text.isEmpty) {
      showCustomSnackBar('please_enter_pin_code'.tr);
      return;
    }

    final authController = Get.find<AuthController>();

    final response =
        await authController.loginWithPin(_pinController.text.trim());

    if (response.isSuccess) {
      AuthResponseModel? authResponse = response.authResponseModel;
      if (authResponse != null) {
        bool isProfileComplete = (authResponse.fName != null &&
                authResponse.fName!.isNotEmpty) &&
            (authResponse.phone != null && authResponse.phone!.isNotEmpty) &&
            (authResponse.email != null && authResponse.email!.isNotEmpty);

        showCustomSnackBar(
          response.message ?? 'logged_in_successfully'.tr,
          isError: false,
          getXSnackBar: true,
        );

        if (isProfileComplete) {
          if (widget.backFromThis) {
            Get.back();
            if (ResponsiveHelper.isDesktop(Get.context)) {
              Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
            }
          } else {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        } else {
          Get.find<ProfileController>().setFromLogin(true);
          if (ResponsiveHelper.isDesktop(Get.context)) {
            Get.back(); // Close dialog
            Get.toNamed(RouteHelper.getUpdateProfileRoute());
          } else {
            Get.toNamed(RouteHelper.getUpdateProfileRoute());
          }
        }
      } else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    } else {
      showCustomSnackBar(response.message ?? 'Invalid PIN code',
          getXSnackBar: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop
          ? 400
          : context.width > 700
              ? 500
              : context.width,
      padding: isDesktop
          ? const EdgeInsets.all(0)
          : context.width > 700
              ? const EdgeInsets.all(50)
              : const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraLarge),
      child: GetBuilder<AuthController>(builder: (authController) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(Images.logo, width: 125),
              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'enter_pin_code'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                labelText: 'pin_code'.tr,
                titleText: 'enter_your_pin_code'.tr,
                controller: _pinController,
                focusNode: _pinFocus,
                inputType: TextInputType.text,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                inputAction: TextInputAction.done,
                onSubmit: (text) => _handleSubmit(),
                validator: (value) => ValidateCheck.validateEmptyText(
                  value,
                  "please_enter_pin_code".tr,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'to_get_pin_code_contact_bank'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              CustomButton(
                height: isDesktop ? 50 : null,
                width: isDesktop ? 250 : null,
                buttonText: 'submit'.tr,
                radius: isDesktop
                    ? Dimensions.radiusSmall
                    : Dimensions.radiusDefault,
                isBold: !isDesktop,
                isLoading: authController.isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        );
      }),
    );
  }
}
