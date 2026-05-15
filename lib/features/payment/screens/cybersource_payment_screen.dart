import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/payment/controllers/payment_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

class CybersourcePaymentScreen extends StatefulWidget {
  final String orderID;
  final double amount;
  final String paymentID;
  const CybersourcePaymentScreen(
      {super.key,
      required this.orderID,
      required this.amount,
      required this.paymentID});

  @override
  State<CybersourcePaymentScreen> createState() =>
      _CybersourcePaymentScreenState();
}

class _CybersourcePaymentScreenState extends State<CybersourcePaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _hideCardNumber = false;
  bool _hideCVV = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(title: 'cybersource_payment'.tr),
      body: GetBuilder<PaymentController>(builder: (paymentController) {
        return SingleChildScrollView(
          child: FooterView(
            child: Center(
              child: SizedBox(
                width: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.webMaxWidth
                    : double.infinity,
                child: Column(children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  // --- TOP SUMMARY CARD (DARK) ---
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    decoration: const BoxDecoration(
                      color: Color(0xFF121D2D),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: GetBuilder<ProfileController>(
                        builder: (profileController) {
                      var user = profileController.userInfoModel;
                      return Column(children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('Cybersource',
                              style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: Dimensions.fontSizeSmall)),
                        ),
                        const SizedBox(height: 30),
                        _buildSummaryRow('order_type'.tr, 'order'.tr),
                        _buildSummaryRow(
                            'reference_id'.tr, '#${widget.orderID}'),
                        _buildSummaryRow('currency'.tr, 'USD'),
                        _buildSummaryRow('receiver'.tr, 'receiver_name'.tr),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(color: Colors.white10),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('total'.tr,
                                  style: robotoBold.copyWith(
                                      color: Colors.white, fontSize: 20)),
                              Text(
                                  '${Get.find<SplashController>().configModel!.currencySymbol} ${widget.amount.toStringAsFixed(2)}',
                                  style: robotoBold.copyWith(
                                      color: Colors.white, fontSize: 20)),
                            ]),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('customer_information'.tr,
                              style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeLarge)),
                        ),
                        const SizedBox(height: 15),
                        _buildCustomerInfoRow(
                            'name'.tr, user?.fName ?? 'guest'.tr),
                        _buildCustomerInfoRow('email'.tr, user?.email ?? ''),
                        _buildCustomerInfoRow('phone'.tr, user?.phone ?? ''),
                        const SizedBox(height: 10),
                      ]);
                    }),
                  ),

                  // --- BOTTOM PAYMENT CARD (WHITE) ---
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('secure_checkout'.tr,
                                style: robotoBold.copyWith(fontSize: 22)),
                            const SizedBox(height: 5),
                            Text('complete_payment_securely'.tr,
                                style: robotoRegular.copyWith(
                                    color: Colors.grey,
                                    fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: 25),
                            Text('card_details'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                            const SizedBox(height: 20),
                            _buildInputLabel('card_number'.tr),
                            _buildTextField(
                              _cardNumberController,
                              '1234 5678 9012 3456',
                              Icons.credit_card,
                              isObscure: _hideCardNumber,
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _hideCardNumber
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey),
                                onPressed: () => setState(
                                    () => _hideCardNumber = !_hideCardNumber),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    _buildInputLabel('expiry_date'.tr),
                                    _buildTextField(
                                      _expiryController,
                                      'MM/YY',
                                      null,
                                      keyboardType: TextInputType.number,
                                      formatters: [CardExpirationFormatter()],
                                      maxLength: 5,
                                    ),
                                  ])),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    _buildInputLabel('CVV'),
                                    _buildTextField(
                                      _cvvController,
                                      '123',
                                      null,
                                      isObscure: _hideCVV,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _hideCVV
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey),
                                        onPressed: () => setState(
                                            () => _hideCVV = !_hideCVV),
                                      ),
                                    ),
                                  ])),
                            ]),
                            const SizedBox(height: 30),
                            CustomButton(
                              buttonText:
                                  '${'pay'.tr} ${Get.find<SplashController>().configModel!.currencySymbol} ${widget.amount.toStringAsFixed(2)} USD',
                              radius: 12,
                              isLoading: paymentController.isLoading,
                              onPressed: () =>
                                  _processPayment(paymentController),
                            ),
                            const SizedBox(height: 15),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock,
                                      size: 14, color: Color(0xFFFBC02D)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      child: Text('payment_security_notice'.tr,
                                          textAlign: TextAlign.center,
                                          style: robotoRegular.copyWith(
                                              color: Colors.grey,
                                              fontSize: 11))),
                                ]),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: robotoRegular.copyWith(color: Colors.white60)),
        Text(value, style: robotoBold.copyWith(color: Colors.white)),
      ]),
    );
  }

  Widget _buildCustomerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text('$label: ',
            style: robotoBold.copyWith(
                color: Colors.white70, fontSize: Dimensions.fontSizeSmall)),
        Text(value,
            style: robotoRegular.copyWith(
                color: Colors.white60, fontSize: Dimensions.fontSizeSmall)),
      ]),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData? icon,
      {bool isObscure = false,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? formatters,
      int? maxLength,
      Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: robotoRegular.copyWith(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
      ),
    );
  }

  void _processPayment(PaymentController paymentController) async {
    String cardNumber = _cardNumberController.text.trim().replaceAll(' ', '');
    String expiryDate = _expiryController.text.trim();
    String cvv = _cvvController.text.trim();

    if (cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty) {
      showCustomSnackBar('please_fill_all_fields'.tr);
      return;
    }

    final payload = {
      "payment_id": widget.paymentID,
      "card_number": cardNumber,
      "expiry_date": expiryDate,
      "cvv": cvv,
    };

    try {
      const String secretKey =
          "8f4c2d9a7e31b6f0c5a8d3e9b2f7a1c4d6e8f9a0b3c5d7e1f2a4b6c8d9e0f1a3";
      final jwt = JWT(payload);
      String token = jwt.sign(SecretKey(secretKey));

      debugPrint('=====> [Cybersource] Sending token to API...');

      Response response =
          await paymentController.submitCybersourcePayment(token);

      debugPrint('=====> [Cybersource] statusCode: ${response.statusCode}');
      debugPrint('=====> [Cybersource] statusText: ${response.statusText}');
      debugPrint('=====> [Cybersource] body: ${response.body}');

      // statusCode 1 means network/CORS failure
      if (response.statusCode == 1) {
        debugPrint('=====> [Cybersource] CORS or Network error!');
        showCustomSnackBar('connection_to_api_server_failed'.tr);
        return;
      }

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['success'] == true) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID, null));
      } else {
        String errorMsg = 'payment_failed'.tr;
        if (response.body != null && response.body is Map) {
          errorMsg = response.body['message'] ?? errorMsg;
        } else if (response.statusText != null &&
            response.statusText!.isNotEmpty) {
          errorMsg = response.statusText!;
        }
        debugPrint('=====> [Cybersource] Payment failed: $errorMsg');
        showCustomSnackBar(errorMsg);
      }
    } catch (e) {
      debugPrint('=====> [Cybersource] Exception: $e');
      showCustomSnackBar('payment_failed'.tr);
    }
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final containsSlash = valueToReturn.contains('/');
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !containsSlash) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}
