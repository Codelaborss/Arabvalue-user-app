import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/gift/controllers/gift_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class GiftScreen4 extends StatefulWidget {
  const GiftScreen4({super.key});

  @override
  State<GiftScreen4> createState() => _GiftScreen4State();
}

class _GiftScreen4State extends State<GiftScreen4> {
  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;
  double _bonusAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        if (_amountController.text.isNotEmpty) {
          _amount = double.tryParse(_amountController.text) ?? 0;
        } else {
          _amount = 0;
        }
        _calculateBonus();
      });
    });
  }

  void _calculateBonus() {
    Item? item = Get.find<GiftController>().selectedItem;
    _bonusAmount = 0; // Reset before calculation
    if (item != null && item.bonusConfiguration != null) {
      debugPrint(
          '====> Calculating bonus for Item ID: ${item.id}, Amount: $_amount');
      for (var config in item.bonusConfiguration!) {
        double min = double.tryParse(config.minAmount ?? '0') ?? 0;
        double maxString = double.tryParse(config.maxAmount ?? '0') ?? 0;
        double max = (maxString == 0 &&
                (config.maxAmount == null || config.maxAmount == '0'))
            ? double.infinity
            : maxString;

        if (_amount >= min && _amount <= max) {
          double percentage =
              double.tryParse(config.bonusPercentage ?? '0') ?? 0;
          _bonusAmount = (_amount * percentage) / 100;
          debugPrint(
              '====> [MATCHED] Item ${item.id}: Range $min-$max found in API with $percentage% bonus. Calculated Bonus: $_bonusAmount');
          break;
        }
      }
    }
    if (_bonusAmount == 0) {
      debugPrint('====> No bonus range matched for amount: $_amount');
    }
  }

  void _selectAmount(double value) {
    setState(() {
      _amount = value;
      _amountController.text = value.toStringAsFixed(0);
      _calculateBonus();
    });
  }

  String _formatPrice(double value) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String symbol = Get.find<SplashController>().configModel!.currencySymbol!;
    // Show 2 decimals if there's a fraction, otherwise show none
    String priceStr = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    return isRightSide ? '$priceStr $symbol' : '$symbol$priceStr';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Value'),
      body: GetBuilder<GiftController>(builder: (giftController) {
        Item? item = giftController.selectedItem;
        debugPrint('====> GiftScreen4 Build - Item: ${item?.id}');
        if (item != null) {
          debugPrint(
              '====> GiftScreen4 Fixed Options: ${item.fixedAmountOptions}');
          debugPrint(
              '====> GiftScreen4 Custom Enabled: ${item.enableCustomAmount}');
          debugPrint(
              '====> GiftScreen4 Bonus config: ${item.bonusConfiguration?.length}');
        }
        bool hasFixedOptions = item?.fixedAmountOptions != null &&
            item!.fixedAmountOptions!.isNotEmpty;
        bool isCustomEnabled = item?.enableCustomAmount == '1';

        List<String?> minMax = item?.minMaxAmount ?? [null, null];
        String? minAmountStr = minMax.isNotEmpty ? minMax[0] : null;
        String? maxAmountStr = minMax.length > 1 ? minMax[1] : null;

        double? minAmount = double.tryParse(minAmountStr ?? '');
        double? maxAmount = double.tryParse(maxAmountStr ?? '');

        bool hasValidRange = (minAmount != null && minAmount > 0) ||
            (maxAmount != null && maxAmount > 0);
        bool showFixedOptions = hasFixedOptions && !hasValidRange;

        double bonusValue = _bonusAmount;
        double totalToPay = _amount - bonusValue;
        double cardValue = _amount;

        bool isRangeValid = true;
        if (hasValidRange) {
          if (minAmount != null && _amount < minAmount) {
            isRangeValid = false;
          }
          if (maxAmount != null && _amount > maxAmount) {
            isRangeValid = false;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showFixedOptions) ...[
              Text('Select Amount',
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: Dimensions.paddingSizeSmall,
                runSpacing: Dimensions.paddingSizeSmall,
                children: item!.fixedAmountOptions!.map((amountStr) {
                  double amount = double.tryParse(amountStr) ?? 0;
                  bool isSelected = _amount == amount;
                  return InkWell(
                    onTap: () => _selectAmount(amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        '${Get.find<SplashController>().configModel!.currencySymbol}$amountStr',
                        style: robotoMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
            Text('Custom Amount',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            CustomTextField(
              hintText:
                  isCustomEnabled ? 'Enter amount' : 'Custom amount disabled',
              controller: _amountController,
              inputType: TextInputType.number,
              showLabelText: false,
              isEnabled: isCustomEnabled,
              prefixIcon: Icons.attach_money,
            ),
            if (hasValidRange) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                '${minAmount != null ? 'Min: $minAmount' : ''}${minAmount != null && maxAmount != null ? ', ' : ''}${maxAmount != null ? 'Max: $maxAmount' : ''}',
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isRangeValid
                        ? Theme.of(context).hintColor
                        : Colors.red),
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.1)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Value Breakdown',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Card Value',
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor)),
                          Text(_formatPrice(cardValue), style: robotoMedium),
                        ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      height: 6,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(children: [
                        Expanded(
                          flex: (_amount > 0) ? 100 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: (_amount > 0) ? 0 : 100,
                            child: const SizedBox()),
                      ]),
                    ),
                    if (bonusValue > 0)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bonus Applied (Discount)',
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor)),
                            Text('- ${_formatPrice(bonusValue)}',
                                style:
                                    robotoMedium.copyWith(color: Colors.green)),
                          ]),
                    if (bonusValue > 0)
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    if (bonusValue > 0)
                      Container(
                        height: 6,
                        width: 100,
                        margin: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                    const Divider(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total to Pay',
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                          Text(_formatPrice(totalToPay),
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        ]),
                  ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
            CustomButton(
              buttonText: (_amount > 0 && !isRangeValid)
                  ? (minAmount != null && _amount < minAmount)
                      ? 'Amount too low'
                      : 'Amount too high'
                  : 'Add Value',
              onPressed: (_amount > 0 && isRangeValid)
                  ? () {
                      Get.find<GiftController>()
                          .saveSelectedAmount(_amount, _bonusAmount);
                      Get.toNamed(RouteHelper.getGiftRoute5());
                    }
                  : null,
            ),
          ]),
        );
      }),
    );
  }
}
