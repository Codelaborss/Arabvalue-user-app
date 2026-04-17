import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';

class FlashSaleDialogWidget extends StatefulWidget {
  const FlashSaleDialogWidget({super.key});

  @override
  State<FlashSaleDialogWidget> createState() => _FlashSaleDialogWidgetState();
}

class _FlashSaleDialogWidgetState extends State<FlashSaleDialogWidget> {
  final PageController _pageController = PageController();
  Timer? _timer;
  Timer? _autoSliderTimer;
  Duration? _remainingTime;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
    _startAutoSliderTimer();
  }

  void _calculateRemainingTime() {
    final flashSaleController = Get.find<FlashSaleController>();
    if (flashSaleController.flashSaleModel?.endDate != null) {
      try {
        DateTime endDate =
            DateTime.parse(flashSaleController.flashSaleModel!.endDate!);
        DateTime now = DateTime.now();
        _remainingTime = endDate.difference(now);
      } catch (e) {
        _remainingTime = null;
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime != null && _remainingTime!.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoSliderTimer() {
    _autoSliderTimer?.cancel();
    _autoSliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTimeUnit(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlashSaleController>(
      builder: (flashSaleController) {
        final flashSale = flashSaleController.flashSaleModel;
        final products = flashSale?.activeProducts ?? [];

        if (flashSale == null || products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
            vertical: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Flash Sale Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: Text(
                    flashSale.title ?? 'Flash Sale',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Countdown Timer - Centered
                if (_remainingTime != null && _remainingTime!.inSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTimeUnit(_remainingTime!.inDays, 'Days'),
                        _buildTimeSeparator(),
                        _buildTimeUnit(_remainingTime!.inHours % 24, 'Hours'),
                        _buildTimeSeparator(),
                        _buildTimeUnit(_remainingTime!.inMinutes % 60, 'mins'),
                        _buildTimeSeparator(),
                        _buildTimeUnit(_remainingTime!.inSeconds % 60, 'sec'),
                      ],
                    ),
                  ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Products Horizontal Scroll
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                            'No products available',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int index) {
                            _currentPage = index;
                          },
                          itemBuilder: (context, index) {
                            final product = products[index % products.length];
                            return Center(
                              child: _buildProductCard(product.item, product),
                            );
                          },
                        ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _formatTimeUnit(value),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProductCard(Item? item, dynamic flashSaleProduct) {
    if (item == null) return const SizedBox.shrink();

    // Get flash sale specific data
    double flashSalePrice =
        flashSaleProduct.price?.toDouble() ?? item.price ?? 0.0;
    int availableStock =
        flashSaleProduct.availableStock ?? flashSaleProduct.stock ?? 0;
    double discount =
        flashSaleProduct.discount?.toDouble() ?? item.discount ?? 0.0;

    return GestureDetector(
      onTap: () {
        _showProductBottomSheet(item, flashSalePrice, availableStock, discount);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Container
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusDefault),
                    ),
                    child: CustomImage(
                      image: item.imageFullUrl ?? '',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Discount Badge
                  if (discount > 0)
                    Positioned(
                      top: Dimensions.paddingSizeDefault,
                      left: Dimensions.paddingSizeDefault,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          '${discount.toStringAsFixed(0)}% OFF',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      item.name ?? '',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Section
                        Row(
                          children: [
                            if (discount > 0) ...[
                              Text(
                                '\$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '\$${flashSalePrice.toStringAsFixed(2)}',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Stock Status
                        Text(
                          'Available: $availableStock Item${availableStock > 1 ? 's' : ''}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color:
                                availableStock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductBottomSheet(
      Item item, double price, int stock, double discount) {
    Get.bottomSheet(
      ItemBottomSheet(
        itemId: item.id ?? 0,
        isCampaign: false,
      ),
      enableDrag: true,
      isScrollControlled: true,
    ).then((_) {
      // Optionally close the dialog after bottom sheet closes
      if (mounted) {
        Get.back();
      }
    });
  }
}
