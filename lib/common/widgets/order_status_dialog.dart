import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';

class OrderStatusDialog extends StatefulWidget {
  final String cartGroupId;
  const OrderStatusDialog({Key? key, required this.cartGroupId})
      : super(key: key);

  @override
  State<OrderStatusDialog> createState() => _OrderStatusDialogState();
}

class _OrderStatusDialogState extends State<OrderStatusDialog> {
  bool _isFirstBuild = true;
  bool _cancelled = false;

  @override
  Widget build(BuildContext context) {
    if (_isFirstBuild) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _isFirstBuild = false;
          });
        }
      });
      return _buildLoadingState(context, 'sending_order'.tr);
    }

    return GetBuilder<CartController>(builder: (cartController) {
      if (cartController.isLoading) {
        return _buildLoadingState(context, 'sending_order'.tr);
      }

      var cartItem;
      try {
        cartItem = cartController.cartList.firstWhere(
          (c) => c.cartGroupId == widget.cartGroupId,
        );
      } catch (e) {
        cartItem = null;
      }

      String status = cartItem?.status ?? 'pending';

      if (status == 'approved' && !_cancelled) {
        Future.delayed(Duration.zero, () {
          if (Get.isDialogOpen ?? false) {
            Get.back();
            Get.toNamed(RouteHelper.getCheckoutRoute('buy_now'),
                arguments: CheckoutScreen(
                  storeId: null,
                  fromCart: true,
                  cartList: null,
                  isBuyNow: true,
                ));
          }
        });
        return const SizedBox();
      }

      if (status == 'pending' || status == 'not_responded') {
        return _buildLoadingState(context, 'order_sent'.tr);
      }

      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline,
                size: 50, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text('request_rejected'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('vendor_has_rejected_your_request'.tr,
                textAlign: TextAlign.center, style: robotoRegular),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('close'.tr))
          ]),
        ),
      );
    });
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return GetBuilder<CartController>(builder: (cartController) {
      return Dialog(
        alignment: const Alignment(0, -0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        insetPadding: const EdgeInsets.all(30),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(message,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Divider(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('please_wait_to_continue'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Cancel button — always enabled during wait
            TextButton(
              onPressed: () {
                // Stop the loading spinner on Buy Now button immediately
                cartController.resetLoading();
                // Close dialog immediately and return a 'cancelled' signal
                _cancelled = true;
                if (Get.isDialogOpen ?? false) {
                  Get.back(result: 'cancelled');
                }
                // Try removing from cart in background (may not exist yet)
                // We also schedule a delayed removal check just in case it's mid-flight
                _cleanupCartItem(cartController);
              },
              child: Text(
                'cancel'.tr,
                style: robotoBold.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ]),
        ),
      );
    });
  }

  void _cleanupCartItem(CartController cartController) {
    print(
        '====> [ORDER_STATUS_DIALOG] Initiating cleanup for cartGroupId: ${widget.cartGroupId}');
    // Attempt immediate removal
    _attemptRemoval(cartController);

    // One delayed attempt in case the server was slow
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        print(
            '====> [ORDER_STATUS_DIALOG] Background retry cleanup for cartGroupId: ${widget.cartGroupId}');
        _attemptRemoval(cartController);
      }
    });
  }

  void _attemptRemoval(CartController cartController) async {
    // Proactively refresh cart data to ensure we catch the item even if it was just added
    await cartController.getCartDataOnline();

    try {
      final cartItem = cartController.cartList.firstWhere(
        (c) => c.cartGroupId == widget.cartGroupId,
      );
      if (cartItem.id != null) {
        print(
            '====> [ORDER_STATUS_DIALOG] Found item with cartId: ${cartItem.id}. Sending removal request.');
        cartController.removeCartItemOnline(cartItem.id!);
      }
    } catch (_) {
      print(
          '====> [ORDER_STATUS_DIALOG] Item with cartGroupId: ${widget.cartGroupId} not found in cart list yet.');
    }
  }
}
