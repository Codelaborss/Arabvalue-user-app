import 'package:flutter/material.dart';
import 'package:sixam_mart/features/auth/widgets/pin_code_login_widget.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:get/get.dart';

class PinCodeLogin extends StatefulWidget {
  const PinCodeLogin({super.key});

  @override
  State<PinCodeLogin> createState() => _PinCodeLoginState();
}

class _PinCodeLoginState extends State<PinCodeLogin> {
  @override
  void initState() {
    super.initState();

    if (ResponsiveHelper.isDesktop(Get.context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(
            const AuthDialogWidget(
                exitFromApp: false, backFromThis: false, canSkip: false),
            barrierDismissible: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: Center(
            child: ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : const PinCodeLoginWidget(
                    exitFromApp: true, backFromThis: false),
          ),
        ),
      ),
    );
  }
}
