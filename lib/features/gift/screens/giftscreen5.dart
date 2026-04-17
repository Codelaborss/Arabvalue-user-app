import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:get/get.dart';

class GiftScreen5 extends StatefulWidget {
  const GiftScreen5({super.key});

  @override
  State<GiftScreen5> createState() => _GiftScreen5State();
}

class _GiftScreen5State extends State<GiftScreen5> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int _messageLength = 0;
  final int _maxMessageLength = 200;

  final List<String> _messageTemplates = [
    'Happy Birthday!',
    'Thank You!',
    'Congratulations!',
    'Best Wishes!',
    'Good Luck!',
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      if (_messageController.text.length > _maxMessageLength) {
        _messageController.text =
            _messageController.text.substring(0, _maxMessageLength);
        _messageController.selection =
            TextSelection.fromPosition(TextPosition(offset: _maxMessageLength));
      }
      setState(() {
        _messageLength = _messageController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addTemplateMessage(String template) {
    String currentText = _messageController.text;
    if ((currentText.length + template.length) <= _maxMessageLength) {
      _messageController.text =
          currentText.isEmpty ? template : '$currentText $template';
      _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Personalize Gift Card'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name Fields
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('First Name', style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      hintText: 'John',
                      controller: _firstNameController,
                      inputType: TextInputType.name,
                      showLabelText: false,
                    ),
                  ]),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Name', style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      hintText: 'Doe',
                      controller: _lastNameController,
                      inputType: TextInputType.name,
                      showLabelText: false,
                    ),
                  ]),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Phone Number
          Text('Phone Number (Optional)', style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'Enter phone number',
            controller: _phoneController,
            inputType: TextInputType.phone,
            showLabelText: false,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Email Address
          Text('Email Address', style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: 'email@example.com',
            controller: _emailController,
            inputType: TextInputType.emailAddress,
            showLabelText: false,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Personal Message
          Text('Personal Message', style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.1)),
            ),
            child: CustomTextField(
              hintText: 'Write your message here...',
              controller: _messageController,
              inputType: TextInputType.multiline,
              maxLines: 5,
              showLabelText: false,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          // Character Count
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(
              '$_messageLength/$_maxMessageLength',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Message Templates
          GetBuilder<GiftController>(builder: (giftController) {
            Item? voucher = giftController.selectedVoucher;
            List<String> messageTemplates = [];
            if (voucher != null &&
                voucher.messageTemplates != null &&
                voucher.messageTemplates!.isNotEmpty) {
              messageTemplates = voucher.messageTemplates!
                  .map((e) => e.title ?? '')
                  .where((title) => title.isNotEmpty)
                  .toList();
            }

            if (messageTemplates.isEmpty) {
              messageTemplates = _messageTemplates;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MESSAGE TEMPLATES',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: messageTemplates.map((template) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () => _addTemplateMessage(template),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)),
                            ),
                            child: Text(
                              template,
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

          CustomButton(
            buttonText: 'Choose Delivery',
            onPressed: () {
              Get.find<GiftController>().saveRecipientInfo(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                message: _messageController.text,
              );
              Get.toNamed(RouteHelper.getGiftRoute6());
            },
          ),
        ]),
      ),
    );
  }
}
