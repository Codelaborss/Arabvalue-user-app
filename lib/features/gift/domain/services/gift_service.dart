import 'package:sixam_mart/features/gift/domain/models/gift_message_model.dart';
import 'package:sixam_mart/features/gift/domain/repositories/gift_repository_interface.dart';
import 'package:sixam_mart/features/gift/domain/services/gift_service_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class GiftService implements GiftServiceInterface {
  final GiftRepositoryInterface giftRepositoryInterface;
  GiftService({required this.giftRepositoryInterface});

  @override
  Future<List<GiftMessageModel>?> getGiftMessageList() async {
    return await giftRepositoryInterface.getMessageList();
  }

  @override
  Future<ItemModel?> getStoreItems(int storeId) async {
    return await giftRepositoryInterface.getStoreItems(storeId);
  }
}
