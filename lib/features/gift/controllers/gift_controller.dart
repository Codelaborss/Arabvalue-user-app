import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_message_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/gift/domain/models/delivery_option_model.dart';
import 'package:sixam_mart/features/gift/domain/services/gift_service_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class GiftController extends GetxController implements GetxService {
  final GiftServiceInterface giftServiceInterface;
  GiftController({required this.giftServiceInterface});

  List<GiftOccasionModel>? _giftOccasionList;
  List<GiftOccasionModel>? get giftOccasionList => _giftOccasionList;

  List<GiftMessageModel>? _giftMessageList;
  List<GiftMessageModel>? get giftMessageList => _giftMessageList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Item? _selectedVoucher;
  Item? get selectedVoucher => _selectedVoucher;

  GiftOccasionModel? _selectedOccasion;
  GiftOccasionModel? get selectedOccasion => _selectedOccasion;

  Store? _selectedStore;
  Store? get selectedStore => _selectedStore;

  double? _selectedAmount;
  double? get selectedAmount => _selectedAmount;

  double? _bonusAmount;
  double? get bonusAmount => _bonusAmount;

  String? _recipientFirstName;
  String? get recipientFirstName => _recipientFirstName;

  String? _recipientLastName;
  String? get recipientLastName => _recipientLastName;

  String? _recipientEmail;
  String? get recipientEmail => _recipientEmail;

  String? _recipientPhone;
  String? get recipientPhone => _recipientPhone;

  String? _giftMessage;
  String? get giftMessage => _giftMessage;

  DeliveryOptionModel? _selectedDeliveryMethod;
  DeliveryOptionModel? get selectedDeliveryMethod => _selectedDeliveryMethod;

  DateTime? _selectedScheduleDate;
  DateTime? get selectedScheduleDate => _selectedScheduleDate;

  List<Item>? _storeVoucherList;
  List<Item>? get storeVoucherList => _storeVoucherList;

  Item? get selectedItem =>
      _selectedVoucher; // Alias for backward compatibility if needed

  Future<void> getGiftMessageList() async {
    _isLoading = true;
    update();
    List<GiftMessageModel>? giftMessages =
        await giftServiceInterface.getGiftMessageList();
    if (giftMessages != null) {
      _giftMessageList = [];
      _giftMessageList!.addAll(giftMessages);
    }
    _isLoading = false;
    update();
  }

  Future<void> getStoreItems(int storeId) async {
    _isLoading = true;
    _giftOccasionList = null;
    _storeVoucherList = null;
    _selectedVoucher = null;
    update();
    ItemModel? itemModel = await giftServiceInterface.getStoreItems(storeId);
    if (itemModel != null && itemModel.items != null) {
      debugPrint(
          '====> Extracted ${itemModel.items!.length} products from store $storeId');
      _storeVoucherList = itemModel.items;
      if (_storeVoucherList!.isNotEmpty) {
        selectVoucher(_storeVoucherList![0]);
      }
    } else {
      debugPrint('====> ItemModel or items list is NULL for store $storeId');
    }
    _isLoading = false;
    update();
  }

  void selectVoucher(Item item) {
    debugPrint('=====> Selecting voucher: ${item.id} - ${item.name}');
    _selectedVoucher = item;
    debugPrint(
        '=====> Voucher has ${item.giftOccasions?.length ?? 0} occasions');

    // Auto-select first occasion if available
    if (item.giftOccasions != null && item.giftOccasions!.isNotEmpty) {
      selectOccasion(item.giftOccasions![0]);
      debugPrint(
          '=====> Auto-selected first occasion: ${item.giftOccasions![0].title}');
    } else {
      _selectedOccasion = null;
    }

    update();
  }

  void selectOccasion(GiftOccasionModel occasion) {
    debugPrint('====> Selecting occasion: ${occasion.id} - ${occasion.title}');
    _selectedOccasion = occasion;
    update();
  }

  void saveSelectedStore(Store store) {
    _selectedStore = store;
    update();
  }

  void saveSelectedAmount(double amount, double bonus) {
    _selectedAmount = amount;
    _bonusAmount = bonus;
    update();
  }

  void saveRecipientInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String message,
  }) {
    _recipientFirstName = firstName;
    _recipientLastName = lastName;
    _recipientEmail = email;
    _recipientPhone = phone;
    _giftMessage = message;
    update();
  }

  void saveDeliveryInfo(DeliveryOptionModel? method, DateTime? date) {
    _selectedDeliveryMethod = method;
    _selectedScheduleDate = date;
    update();
  }

  // Section completion helpers for unified screen
  bool get isStoreSelected => _selectedStore != null;

  bool get isVoucherSelected => _selectedVoucher != null;

  bool get isAmountSelected => _selectedAmount != null && _selectedAmount! > 0;

  bool get isOccasionSelected => _selectedOccasion != null;

  bool get isRecipientInfoComplete =>
      _recipientFirstName != null &&
      _recipientFirstName!.isNotEmpty &&
      _recipientLastName != null &&
      _recipientLastName!.isNotEmpty &&
      _recipientEmail != null &&
      _recipientEmail!.isNotEmpty;

  bool get isDeliveryInfoComplete => _selectedDeliveryMethod != null;

  // Reset all selections
  void resetGiftFlow() {
    _selectedStore = null;
    _selectedVoucher = null;
    _selectedOccasion = null;
    _selectedAmount = null;
    _bonusAmount = null;
    _recipientFirstName = null;
    _recipientLastName = null;
    _recipientEmail = null;
    _recipientPhone = null;
    _giftMessage = null;
    _selectedDeliveryMethod = null;
    _selectedScheduleDate = null;
    _storeVoucherList = null;
    _giftOccasionList = null;
    update();
  }
}
