import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/features/gift/domain/models/delivery_option_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class GiftScreen6 extends StatefulWidget {
  const GiftScreen6({super.key});

  @override
  State<GiftScreen6> createState() => _GiftScreen6State();
}

class _GiftScreen6State extends State<GiftScreen6> {
  int _selectedDeliveryIndex = 0;
  int _selectedTimingIndex = 0;
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _deliveryMethods = [
    {'icon': Icons.chat, 'title': 'WhatsApp'},
    {'icon': Icons.email_outlined, 'title': 'Email'},
    {'icon': Icons.sms_outlined, 'title': 'SMS'},
    {'icon': Icons.download_outlined, 'title': 'Direct Download'},
    {'icon': Icons.share_outlined, 'title': 'Social Media'},
  ];

  final List<String> _timingOptions = [
    'Send Now',
    'Schedule for Later',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Send Gift Card'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Method', style: robotoMedium),
                  GetBuilder<GiftController>(builder: (giftController) {
                    List<DeliveryOptionModel>? apiOptions =
                        giftController.selectedVoucher?.deliveryOptions;
                    bool hasApiOptions =
                        apiOptions != null && apiOptions.isNotEmpty;

                    int itemCount = hasApiOptions
                        ? apiOptions.length
                        : _deliveryMethods.length;

                    return Container(
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
                        children: List.generate(itemCount, (index) {
                          String title = hasApiOptions
                              ? apiOptions[index].title ?? ''
                              : _deliveryMethods[index]['title'];
                          String? icon =
                              hasApiOptions ? apiOptions[index].icon : null;
                          IconData? defaultIcon = hasApiOptions
                              ? null
                              : _deliveryMethods[index]['icon'];

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDeliveryIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  child: Row(children: [
                                    if (hasApiOptions && icon != null)
                                      CustomImage(
                                        image: icon.startsWith('http')
                                            ? icon
                                            : '${AppConstants.baseUrl}/$icon',
                                        height: 20,
                                        width: 20,
                                        fit: BoxFit.contain,
                                      )
                                    else if (defaultIcon != null)
                                      Icon(defaultIcon,
                                          color:
                                              Theme.of(context).disabledColor,
                                          size: 20),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                        child:
                                            Text(title, style: robotoRegular)),
                                    Icon(
                                      _selectedDeliveryIndex == index
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: _selectedDeliveryIndex == index
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).disabledColor,
                                      size: 20,
                                    ),
                                  ]),
                                ),
                              ),
                              if (index != itemCount - 1)
                                Divider(
                                    height: 1,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withOpacity(0.1)),
                            ],
                          );
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('Delivery Timing', style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                          color:
                              Theme.of(context).disabledColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: List.generate(_timingOptions.length, (index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (index == 1) {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now()
                                        .add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedTimingIndex = index;
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _selectedTimingIndex = index;
                                    _selectedDate = null;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_timingOptions[index],
                                          style: robotoRegular),
                                      if (index == 1 && _selectedDate != null)
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(_selectedDate!),
                                          style: robotoMedium.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize:
                                                  Dimensions.fontSizeSmall),
                                        ),
                                    ],
                                  )),
                                  Icon(
                                    _selectedTimingIndex == index
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: _selectedTimingIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor,
                                    size: 20,
                                  ),
                                ]),
                              ),
                            ),
                            if (index != _timingOptions.length - 1)
                              Divider(
                                  height: 1,
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.1)),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GetBuilder<GiftController>(builder: (giftController) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButton(
                buttonText: 'Review Gift Card',
                onPressed: () {
                  List<DeliveryOptionModel>? apiOptions =
                      giftController.selectedVoucher?.deliveryOptions;
                  bool hasApiOptions =
                      apiOptions != null && apiOptions.isNotEmpty;

                  DeliveryOptionModel? selectedMethod;
                  if (hasApiOptions) {
                    selectedMethod = apiOptions[_selectedDeliveryIndex];
                  } else {
                    // Create a mockup for default methods if needed, or just send null title
                    selectedMethod = DeliveryOptionModel(
                      title: _deliveryMethods[_selectedDeliveryIndex]['title'],
                    );
                  }

                  giftController.saveDeliveryInfo(
                      selectedMethod, _selectedDate);
                  Get.toNamed(RouteHelper.getGiftRoute7());
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
