import 'package:sixam_mart/features/gift/domain/models/gift_message_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

abstract class GiftServiceInterface {
  Future<List<GiftMessageModel>?> getGiftMessageList();
  Future<ItemModel?> getStoreItems(int storeId);
}
