import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class ProfileNotificationWidget extends StatelessWidget {
  const ProfileNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return GetBuilder<NotificationController>(
          builder: (notificationController) {
        int notificationCount = 0;
        if (notificationController.notificationList != null) {
          notificationCount = notificationController.notificationList!.length -
              (notificationController.getSeenNotificationCount() ?? 0);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => DashboardScreenState.instance?.setPage(5),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                  ],
                ),
                child: ClipOval(
                  child: CustomImage(
                    image: profileController.userInfoModel?.imageFullUrl ?? '',
                    height: 35,
                    width: 35,
                    placeholder: Images.guestIcon,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -5,
              right: -5,
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 1.5, color: Theme.of(context).cardColor),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 2, spreadRadius: 1)
                    ],
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: robotoRegular.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      });
    });
  }
}
