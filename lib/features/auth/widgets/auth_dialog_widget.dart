import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/pin_code_login_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';

class AuthDialogWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool canSkip;
  const AuthDialogWidget(
      {super.key,
      required this.exitFromApp,
      required this.backFromThis,
      this.canSkip = true});

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget> {
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetOtpView(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canSkip,
      child: SizedBox(
        width: 450,
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          backgroundColor: Theme.of(context).cardColor,
          insetPadding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.canSkip)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.clear)),
                ),
              if (!widget.canSkip)
                const SizedBox(height: Dimensions.paddingSizeLarge),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtremeLarge),
                  child: PinCodeLoginWidget(
                    exitFromApp: widget.exitFromApp,
                    backFromThis: widget.backFromThis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
