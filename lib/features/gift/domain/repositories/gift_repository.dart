import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_message_model.dart';
import 'package:sixam_mart/features/gift/domain/repositories/gift_repository_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class GiftRepository implements GiftRepositoryInterface {
  final ApiClient apiClient;

  GiftRepository({required this.apiClient});

  @override
  Future<List<GiftMessageModel>?> getMessageList() async {
    List<GiftMessageModel>? giftMessages;
    Map<String, String> header = apiClient.getHeader();
    header.addAll({
      'Content-Type': 'application/json',
    });

    Response response = await apiClient.getData(
      AppConstants.giftMessageUri,
      headers: header,
    );
    if (response.statusCode == 200) {
      giftMessages = [];
      response.body['data'].forEach((message) {
        giftMessages!.add(GiftMessageModel.fromJson(message));
      });
    }
    return giftMessages;
  }

  @override
  Future<ItemModel?> getStoreItems(int storeId) async {
    ItemModel? itemModel;
    Response response = await apiClient
        .getData('${AppConstants.storeItemsUri}$storeId?limit=100&offset=1');
    if (response.statusCode == 200) {
      itemModel = ItemModel.fromJson(response.body);
    }
    return itemModel;
  }
}
