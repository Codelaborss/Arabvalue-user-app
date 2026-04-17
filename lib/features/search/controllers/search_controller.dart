import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/search/domain/models/popular_categories_model.dart';
import 'package:sixam_mart/features/search/domain/models/search_suggestion_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/search/domain/services/search_service_interface.dart';

class SearchController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;
  SearchController({required this.searchServiceInterface});

  List<Item>? _searchItemList;
  List<Item>? get searchItemList => _searchItemList;

  List<Item>? _allItemList;
  List<Item>? get allItemList => _allItemList;

  List<Item>? _suggestedItemList;
  List<Item>? get suggestedItemList => _suggestedItemList;

  List<Store>? _searchStoreList;
  List<Store>? get searchStoreList => _searchStoreList;

  List<Store>? _allStoreList;
  List<Store>? get allStoreList => _allStoreList;

  String? _searchText = '';
  String? get searchText => _searchText;

  String? _storeResultText = '';

  String? _itemResultText = '';

  double _lowerValue = 0;
  double get lowerValue => _lowerValue;

  double _upperValue = 0;
  double get upperValue => _upperValue;

  List<String> _historyList = [];
  List<String> get historyList => _historyList;

  bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;

  final List<String> _sortList = ['ascending'.tr, 'descending'.tr];
  List<String> get sortList => _sortList;

  int _sortIndex = -1;
  int get sortIndex => _sortIndex;

  int _storeSortIndex = -1;
  int get storeSortIndex => _storeSortIndex;

  int _rating = -1;
  int get rating => _rating;

  int _storeRating = -1;
  int get storeRating => _storeRating;

  bool _isStore = false;
  bool get isStore => _isStore;

  bool _isAvailableItems = false;
  bool get isAvailableItems => _isAvailableItems;

  bool _isAvailableStore = false;
  bool get isAvailableStore => _isAvailableStore;

  bool _isDiscountedItems = false;
  bool get isDiscountedItems => _isDiscountedItems;

  bool _isDiscountedStore = false;
  bool get isDiscountedStore => _isDiscountedStore;

  bool _veg = false;
  bool get veg => _veg;

  bool _storeVeg = false;
  bool get storeVeg => _storeVeg;

  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  bool _storeNonVeg = false;
  bool get storeNonVeg => _storeNonVeg;

  String? _searchHomeText = '';
  String? get searchHomeText => _searchHomeText;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<PopularCategoryModel?>? _popularCategoryList;
  List<PopularCategoryModel?>? get popularCategoryList => _popularCategoryList;

  String _voucherFilter = 'All';
  String get voucherFilter => _voucherFilter;

  void toggleVeg() {
    _veg = !_veg;
    update();
  }

  void toggleStoreVeg() {
    _storeVeg = !_storeVeg;
    update();
  }

  void toggleNonVeg() {
    _nonVeg = !_nonVeg;
    update();
  }

  void toggleStoreNonVeg() {
    _storeNonVeg = !_storeNonVeg;
    update();
  }

  void toggleAvailableItems() {
    _isAvailableItems = !_isAvailableItems;
    update();
  }

  void toggleAvailableStore() {
    _isAvailableStore = !_isAvailableStore;
    update();
  }

  void toggleDiscountedItems() {
    _isDiscountedItems = !_isDiscountedItems;
    update();
  }

  void toggleDiscountedStore() {
    _isDiscountedStore = !_isDiscountedStore;
    update();
  }

  void setStore(bool isStore) {
    _isStore = isStore;
    update();
  }

  void setSearchMode(bool isSearchMode, {bool canUpdate = true}) {
    _isSearchMode = isSearchMode;
    if (isSearchMode) {
      _searchText = '';
      _itemResultText = '';
      _storeResultText = '';
      _allStoreList = null;
      _allItemList = null;
      _searchItemList = null;
      _searchStoreList = null;
      _sortIndex = -1;
      _storeSortIndex = -1;
      _isDiscountedItems = false;
      _isDiscountedStore = false;
      _isAvailableItems = false;
      _isAvailableStore = false;
      _veg = false;
      _storeVeg = false;
      _nonVeg = false;
      _storeNonVeg = false;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
    }
    if (_isStore) {
      _isStore = !_isStore;
    }
    if (canUpdate) {
      update();
    }
  }

  void setVoucherFilter(String filter) {
    _voucherFilter = filter;
    if (_allItemList != null) {
      _searchItemList = getFilteredItems(_allItemList!);
    }
    update();
  }

  List<Item> getFilteredItems(List<Item> items) {
    List<Item> filteredList = [];
    for (var item in items) {
      if (item.type == 'voucher') {
        if (_voucherFilter == 'All') {
          filteredList.add(item);
        } else {
          String filterType = _voucherFilter;
          if (filterType == 'Gift Cards') {
            filterType = 'Gift';
          }
          if ((item.voucherIds != null &&
                  item.voucherIds!.contains(filterType)) ||
              (item.voucherType != null &&
                  item.voucherType!.contains(filterType)) ||
              (item.offerType != null &&
                  item.offerType!.contains(filterType))) {
            filteredList.add(item);
          }
        }
      }
    }
    return filteredList;
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void sortItemSearchList() {
    _searchItemList = searchServiceInterface.sortItemSearchList(
        _allItemList,
        _upperValue,
        _lowerValue,
        _rating,
        _veg,
        _nonVeg,
        _isAvailableItems,
        _isDiscountedItems,
        _sortIndex);
    update();
  }

  void sortStoreSearchList() {
    _searchStoreList = searchServiceInterface.sortStoreSearchList(
        _allStoreList,
        _storeRating,
        _storeVeg,
        _storeNonVeg,
        _isAvailableStore,
        _isDiscountedStore,
        _storeSortIndex);
    update();
  }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void getSuggestedItems() async {
    List<Item>? suggestedItemList =
        await searchServiceInterface.getSuggestedItems();
    if (suggestedItemList != null) {
      _suggestedItemList = [];
      for (var item in suggestedItemList) {
        if (item.type == 'voucher') {
          _suggestedItemList!.add(item);
        }
      }
    }
    update();
  }

  void searchData(String? query, bool fromHome) async {
    if (query!.isNotEmpty &&
        (query != _itemResultText || query != _storeResultText || fromHome)) {
      _searchHomeText = query;
      _searchText = query;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;

      // Clear both lists to show loading
      _searchItemList = null;
      _allItemList = null;
      _searchStoreList = null;
      _allStoreList = null;

      if (!_historyList.contains(query)) {
        _historyList.insert(0, query);
      }
      searchServiceInterface.saveSearchHistory(_historyList);
      _isSearchMode = false;
      if (!fromHome) {
        update();
      }

      _itemResultText = query;
      _storeResultText = query;

      // Fetch Items and Stores in parallel
      await Future.wait([
        searchServiceInterface.getSearchData(query, false).then((response) {
          if (response.statusCode == 200) {
            _searchItemList = [];
            _allItemList = [];
            _allItemList!.addAll(ItemModel.fromJson(response.body).items!);
            _searchItemList = getFilteredItems(_allItemList!);
          }
        }),
        searchServiceInterface.getSearchData(query, true).then((response) {
          if (response.statusCode == 200) {
            _searchStoreList = [];
            _allStoreList = [];
            _searchStoreList!
                .addAll(StoreModel.fromJson(response.body).stores!);
            _allStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
          }
        }),
      ]);

      update();
    }
  }

  void getHistoryList() {
    _isSearchMode = true;
    _searchText = '';
    _historyList = [];
    _historyList.addAll(searchServiceInterface.getSearchAddress());
  }

  void removeHistory(int index) {
    _historyList.removeAt(index);
    searchServiceInterface.saveSearchHistory(_historyList);
    update();
  }

  void clearSearchHistory() async {
    searchServiceInterface.clearSearchHistory();
    _historyList = [];
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setStoreRating(int rate) {
    _storeRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  void setStoreSortIndex(int index) {
    _storeSortIndex = index;
    update();
  }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _isAvailableItems = false;
    _isDiscountedItems = false;
    _veg = false;
    _nonVeg = false;
    _sortIndex = -1;
    update();
  }

  void resetStoreFilter() {
    _storeRating = -1;
    _isAvailableStore = false;
    _isDiscountedStore = false;
    _storeVeg = false;
    _storeNonVeg = false;
    _storeSortIndex = -1;
    update();
  }

  void clearSearchHomeText() {
    _searchHomeText = '';
    update();
  }

  Future<List<String>> getSearchSuggestions(String searchText) async {
    List<String> items = <String>[];
    _searchSuggestionModel =
        await searchServiceInterface.getSearchSuggestions(searchText);
    if (_searchSuggestionModel != null) {
      for (var item in _searchSuggestionModel!.items!) {
        if (item.type == 'voucher') {
          items.add(item.name!);
        }
      }
      for (var store in _searchSuggestionModel!.stores!) {
        items.add(store.name!);
      }
    }
    return items;
  }

  Future<void> getPopularCategories() async {
    _popularCategoryList = null;
    _popularCategoryList = await searchServiceInterface.getPopularCategories();
    update();
  }
}
