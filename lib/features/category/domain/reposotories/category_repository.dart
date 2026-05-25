import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  @override
  Future getList({
    int? offset,
    bool categoryList = false,
    bool subCategoryList = false,
    bool categoryItemList = false,
    bool categoryStoreList = false,
    bool? allCategory,
    String? id,
    String? type,
    DataSourceEnum? source,
    bool isGift = false,
  }) async {
    if (categoryList) {
      return await _getCategoryList(
          allCategory!, source ?? DataSourceEnum.client);
    } else if (subCategoryList) {
      return await _getSubCategoryList(id);
    } else if (categoryItemList) {
      return await _getCategoryItemList(id, offset!, type!);
    } else if (categoryStoreList) {
      return await _getCategoryStoreList(id, offset!, type!, isGift: isGift);
    }
  }

  Future<List<CategoryModel>?> _getCategoryList(
      bool allCategory, DataSourceEnum source) async {
    List<CategoryModel>? categoryList;
    Map<String, String>? header = allCategory
        ? {
            'Content-Type': 'application/json; charset=UTF-8',
            AppConstants.localizationKey:
                Get.find<LocalizationController>().locale.languageCode,
          }
        : null;

    Map<String, String>? cacheHeader = header ?? apiClient.getHeader();

    String cacheId = AppConstants.categoryUri +
        Get.find<SplashController>().module!.id!.toString();

    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if (address != null &&
        address.zoneIds != null &&
        address.zoneIds!.isNotEmpty) {
      cacheId += '-${address.zoneIds!.join('_')}';
    }

    switch (source) {
      case DataSourceEnum.client:
        Response response =
            await apiClient.getData(AppConstants.categoryUri, headers: header);
        if (response.statusCode == 200) {
          categoryList = [];
          response.body.forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), cacheHeader);
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
            DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
        }
    }

    return categoryList;
  }

  Future<List<CategoryModel>?> _getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Response response =
        await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
    if (response.statusCode == 200) {
      subCategoryList = [];
      response.body.forEach(
          (category) => subCategoryList!.add(CategoryModel.fromJson(category)));
    }
    return subCategoryList;
  }

  Future<ItemModel?> _getCategoryItemList(
      String? categoryID, int offset, String type) async {
    ItemModel? categoryItem;
    // Get headers with user ID from login response
    Map<String, String> headers = await apiClient.getHeaderWithUserId();
    if (kDebugMode) {
      print('====> Categories API - Headers with X-User-ID: $headers');
    }
    Response response = await apiClient.getData(
        '${AppConstants.categoryItemUri}$categoryID?limit=10&offset=$offset&type=$type',
        headers: headers);
    if (response.statusCode == 200) {
      categoryItem = ItemModel.fromJson(response.body);
    }
    return categoryItem;
  }

  Future<StoreModel?> _getCategoryStoreList(
      String? categoryID, int offset, String type,
      {bool isGift = false}) async {
    StoreModel? categoryStore;
    String uri =
        isGift ? AppConstants.giftAllStoreUri : AppConstants.categoryStoreUri;
    String idParam =
        (categoryID == null || categoryID == 'gift') ? '' : categoryID;
    // Get headers with user ID from login response
    Map<String, String> headers = await apiClient.getHeaderWithUserId();
    if (kDebugMode) {
      print('====> Categories Stores API - Headers with userId: $headers');
    }
    Response response = await apiClient.getData(
        '$uri$idParam?limit=10&offset=$offset&type=$type',
        headers: headers);
    if (response.statusCode == 200) {
      categoryStore = StoreModel.fromJson(response.body);
    }
    return categoryStore;
  }

  @override
  Future<Response> getSearchData(
      String? query, String? categoryID, bool isStore, String type) async {
    // Get headers with user ID from login response
    Map<String, String> headers = await apiClient.getHeaderWithUserId();
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
      headers: headers,
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    // Get headers with user ID from login response
    Map<String, String> headers = await apiClient.getHeaderWithUserId();
    Response response = await apiClient.postData(
        AppConstants.interestUri, {"interest": interests},
        headers: headers);
    return (response.statusCode == 200);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
