import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:get/get.dart';

class GiftScreen7 extends StatelessWidget {
  const GiftScreen7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Preview'),
      body: GetBuilder<GiftController>(builder: (giftController) {
        String storeName = giftController.selectedStore?.name ?? '';
        double cardTotalValue = giftController.selectedAmount ?? 0;
        double bonus = giftController.bonusAmount ?? 0;
        double subtotal = cardTotalValue;
        double totalToPay = cardTotalValue - bonus;
        String recipientName =
            '${giftController.recipientFirstName ?? ''} ${giftController.recipientLastName ?? ''}'
                .trim();
        if (recipientName.isEmpty) recipientName = 'Recipient Name';
        String occasionTitle = giftController.selectedOccasion?.title ?? '';
        String deliveryMethod = giftController.selectedDeliveryMethod?.title ??
            'Digital Send'; // Fallback
        String timing =
            giftController.selectedScheduleDate != null ? 'Scheduled' : 'Now';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gift Card Preview
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Colors.blue
                            .withOpacity(0.2), // Light blue background
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        // Removed placeholder image as requested
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(storeName,
                                  style: robotoMedium.copyWith(
                                      color: Colors.black87)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                child: Text('Gift Card',
                                    style: robotoRegular.copyWith(
                                        fontSize: 10, color: Colors.black54)),
                              ),
                            ],
                          ),
                          Text(cardTotalValue.toStringAsFixed(0),
                              style: robotoBold.copyWith(
                                  fontSize: 24, color: Colors.black)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(occasionTitle,
                                  style: robotoBold.copyWith(
                                      fontSize: 18, color: Colors.black)),
                              const SizedBox(height: 4),
                              Text('To: $recipientName',
                                  style: robotoRegular.copyWith(
                                      color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Order Summary
                    Text('Order Summary',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Recipient', recipientName),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          _buildSummaryRow('Merchant', storeName),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          _buildSummaryRow(
                              'Delivery', '$deliveryMethod ($timing)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Payment Breakdown
                    Text('Payment Breakdown',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                              'Card Value', subtotal.toStringAsFixed(2)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          if (bonus > 0)
                            _buildSummaryRow('Bonus Applied (Discount)',
                                '-${bonus.toStringAsFixed(2)}',
                                isGreen: true),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total to Pay',
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge)),
                              Text(totalToPay.toStringAsFixed(2),
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButton(
                buttonText: 'Confirm & Pay ${totalToPay.toStringAsFixed(0)}',
                onPressed: () {
                  Get.toNamed(RouteHelper.getGiftRoute8());
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: robotoRegular.copyWith(color: Colors.grey)),
        Text(value,
            style: robotoMedium.copyWith(color: isGreen ? Colors.green : null)),
      ],
    );
  }
}
