import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class GiftScreen8 extends StatelessWidget {
  const GiftScreen8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(Icons.check,
                    color: Theme.of(context).primaryColor, size: 40),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Payment Successful!',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('Your gift card has been sent to adan.',
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.2), // Light blue background
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(Dimensions.radiusDefault)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Blossom Boutique',
                                  style: robotoMedium.copyWith(
                                      color: Colors.black87)),
                              Text('\$29',
                                  style:
                                      robotoBold.copyWith(color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text('Happy Wedding',
                              style: robotoBold.copyWith(
                                  fontSize: 18, color: Colors.black)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraLarge),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_2, size: 150, color: Colors.black),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text('CARD CODE',
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('TW5I-LZIL-MZK',
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      letterSpacing: 2)),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(
                                      text: 'TW5I-LZIL-MZK'));
                                  Get.snackbar('Copied',
                                      'Card code copied to clipboard');
                                },
                                child: Icon(Icons.copy,
                                    size: 18,
                                    color: Theme.of(context).disabledColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text(
                            'Scan QR code at checkout or present the code above to redeem.',
                            style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeSmall),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download,
                              size: 18, color: Theme.of(context).disabledColor),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text('Save Image',
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share,
                              size: 18, color: Theme.of(context).disabledColor),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text('Share',
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              TextButton.icon(
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                icon: Icon(Icons.home, color: Theme.of(context).primaryColor),
                label: Text('Return to Home',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
