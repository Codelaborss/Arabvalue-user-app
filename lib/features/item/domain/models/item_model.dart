import 'dart:convert';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_occasion_model.dart';
import 'package:sixam_mart/features/gift/domain/models/gift_message_model.dart';
import 'package:sixam_mart/features/gift/domain/models/delivery_option_model.dart';

class ItemModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Item>? items;
  List<Categories>? categories;

  ItemModel(
      {this.totalSize, this.limit, this.offset, this.items, this.categories});

  ItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset =
        (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
            ? int.parse(json['offset'].toString())
            : null;
    if (json['products'] != null) {
      items = [];
      json['products'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        if (v['module_type'] == null ||
            !Get.find<SplashController>()
                .getModuleConfig(v['module_type'])
                .newVariation! ||
            v['variations'] == null ||
            v['variations'].isEmpty ||
            (v['food_variations'] != null && v['food_variations'].isNotEmpty)) {
          items!.add(Item.fromJson(v));
        }
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (items != null) {
      data['products'] = items!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Item {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  List<String>? imagesFullUrl;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<FoodVariation>? foodVariations;
  List<AddOns>? addOns;
  List<ChoiceOptions>? choiceOptions;
  double? price;
  double? tax;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? storeId;
  String? storeName;
  String? storeLogoFullUrl;
  int? zoneId;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  int? moduleId;
  String? moduleType;
  String? unitType;
  int? stock;
  String? availableDateStarts;
  int? organic;
  int? quantityLimit;
  int? flashSale;
  bool? isStoreHalalActive;
  bool? isHalalItem;
  bool? isPrescriptionRequired;
  List<String>? nutritionsName;
  List<String>? allergiesName;
  List<String>? genericName;
  String? type;
  String? voucherIds;
  String? branchIds;
  String? validUntil;
  List<Item>? product;
  List<HowItWorks>? howItWorks;
  List<Store>? branches;
  Store? store;
  VoucherSettings? settings;
  String? bundleType;
  List<Item>? productB;
  int? requiredQuantity;
  List<GiftOccasionModel>? giftOccasions;
  List<String>? fixedAmountOptions;
  List<String?>? minMaxAmount;
  String? enableCustomAmount;
  List<BonusConfiguration>? bonusConfiguration;
  RecipientInfoFormFields? recipientInfoFormFields;
  String? messageTemplateStyle;
  List<String>? occasionsId;
  List<GiftMessageModel>? messageTemplates;
  List<DeliveryOptionModel>? deliveryOptions;
  String? voucherType;
  double? actualPrice;
  String? offerType;
  List<VoucherTerm>? termAndConditionIds;
  AvailabilityForCurrentUser? availabilityForCurrentUser;
  List<Reviews>? reviews;
  double? storeCommission;
  String? commissionPaidBy;

  Item({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.imagesFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.foodVariations,
    this.addOns,
    this.choiceOptions,
    this.price,
    this.tax,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.storeId,
    this.storeName,
    this.storeLogoFullUrl,
    this.zoneId,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.moduleId,
    this.moduleType,
    this.unitType,
    this.stock,
    this.organic,
    this.quantityLimit,
    this.flashSale,
    this.isStoreHalalActive,
    this.isHalalItem,
    this.isPrescriptionRequired,
    this.nutritionsName,
    this.allergiesName,
    this.genericName,
    this.type,
    this.voucherIds,
    this.branchIds,
    this.validUntil,
    this.product,
    this.howItWorks,
    this.branches,
    this.store,
    this.settings,
    this.bundleType,
    this.productB,
    this.requiredQuantity,
    this.giftOccasions,
    this.fixedAmountOptions,
    this.minMaxAmount,
    this.enableCustomAmount,
    this.bonusConfiguration,
    this.recipientInfoFormFields,
    this.messageTemplateStyle,
    this.occasionsId,
    this.messageTemplates,
    this.deliveryOptions,
    this.voucherType,
    this.actualPrice,
    this.offerType,
    this.termAndConditionIds,
    this.availabilityForCurrentUser,
    this.reviews,
    this.storeCommission,
    this.commissionPaidBy,
  });

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'] ??
        (json['product_id'] != null
            ? int.tryParse(json['product_id'].toString())
            : null);
    name = json['name'] ?? json['product_name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    if ((imageFullUrl == null || imageFullUrl!.isEmpty) &&
        json['image'] != null &&
        json['image'].isNotEmpty) {
      if (json['image'].startsWith('http')) {
        imageFullUrl = json['image'];
      } else {
        imageFullUrl =
            'https://fortestingweb.com/storage/app/public/product/${json['image']}';
      }
    }

    // ✅ FIX FOR IMAGES - Handle both string and array
    if (json['images_full_url'] != null) {
      imagesFullUrl = [];
      dynamic imagesData = json['images_full_url'];

      // If it's a string, try to decode it
      if (imagesData is String &&
          imagesData.isNotEmpty &&
          imagesData != 'null') {
        try {
          imagesData = jsonDecode(imagesData);
        } catch (e) {
          print('❌ Error parsing images_full_url: $e');
          imagesData = [];
        }
      }

      // Now process as array
      if (imagesData is List) {
        for (var v in imagesData) {
          if (v != null) {
            imagesFullUrl!.add(v.toString());
          }
        }
      }
    }

    // ✅ ALSO HANDLE 'images' field if 'images_full_url' is empty
    if ((imagesFullUrl == null || imagesFullUrl!.isEmpty) &&
        json['images'] != null) {
      imagesFullUrl = [];
      dynamic imagesData = json['images'];

      // If it's a string, try to decode it
      if (imagesData is String &&
          imagesData.isNotEmpty &&
          imagesData != 'null') {
        try {
          imagesData = jsonDecode(imagesData);
        } catch (e) {
          print('❌ Error parsing images: $e');
          imagesData = [];
        }
      }

      // Now process as array
      if (imagesData is List) {
        for (var v in imagesData) {
          if (v is Map<String, dynamic> && v['img'] != null) {
            // Handle format like: [{"img":"2025-12-23-694a989cbbbbf.png","storage":"public"}]
            String baseUrl =
                'https://fortestingweb.com/storage/app/public/product/';
            imagesFullUrl!.add(baseUrl + v['img']);
          } else if (v is String) {
            imagesFullUrl!.add(v);
          }
        }
      }
    }

    categoryId = json['category_id'];

    if (json['category_ids'] != null) {
      categoryIds = [];
      dynamic categoriesData = json['category_ids'];
      if (categoriesData is String &&
          categoriesData.isNotEmpty &&
          categoriesData != 'null') {
        try {
          categoriesData = jsonDecode(categoriesData);
        } catch (e) {
          categoriesData = [];
        }
      }
      if (categoriesData is List) {
        for (var v in categoriesData) {
          if (v is Map<String, dynamic>) {
            categoryIds!.add(CategoryIds.fromJson(v));
          }
        }
      }
    }

    variations = [];
    if (json['variations'] != null) {
      dynamic variationsData = json['variations'];
      if (variationsData is String &&
          variationsData.isNotEmpty &&
          variationsData != 'null') {
        try {
          variationsData = jsonDecode(variationsData);
        } catch (e) {
          variationsData = [];
        }
      }
      if (variationsData is List) {
        for (var v in variationsData) {
          if (v is Map<String, dynamic>) {
            variations!.add(Variation.fromJson(v));
          } else if (v is String) {
            variations!.add(Variation(type: v));
          }
        }
      }
    }

    foodVariations = [];
    if (json['food_variations'] != null && json['food_variations'].isNotEmpty) {
      dynamic foodVariationsData = json['food_variations'];
      if (foodVariationsData is String &&
          foodVariationsData.isNotEmpty &&
          foodVariationsData != 'null') {
        try {
          foodVariationsData = jsonDecode(foodVariationsData);
        } catch (e) {
          foodVariationsData = [];
        }
      }
      if (foodVariationsData is List) {
        for (var v in foodVariationsData) {
          if (v is Map<String, dynamic>) {
            foodVariations!.add(FoodVariation.fromJson(v));
          }
        }
      }
    }

    if (json['add_ons'] != null || json['addons'] != null) {
      addOns = [];
      dynamic addOnsData = json['add_ons'] ?? json['addons'];
      if (addOnsData is String &&
          addOnsData.isNotEmpty &&
          addOnsData != 'null') {
        try {
          addOnsData = jsonDecode(addOnsData);
        } catch (e) {
          addOnsData = [];
        }
      }
      if (addOnsData is List) {
        for (var v in addOnsData) {
          if (v is Map<String, dynamic>) {
            addOns!.add(AddOns.fromJson(v));
          } else if (v is String) {
            addOns!.add(AddOns(id: int.tryParse(v)));
          }
        }
      }
    }

    if (json['choice_options'] != null) {
      choiceOptions = [];
      dynamic choiceOptionsData = json['choice_options'];
      if (choiceOptionsData is String &&
          choiceOptionsData.isNotEmpty &&
          choiceOptionsData != 'null') {
        try {
          choiceOptionsData = jsonDecode(choiceOptionsData);
        } catch (e) {
          choiceOptionsData = [];
        }
      }
      if (choiceOptionsData is List) {
        for (var v in choiceOptionsData) {
          if (v is Map<String, dynamic>) {
            choiceOptions!.add(ChoiceOptions.fromJson(v));
          }
        }
      }
    }

    // ✅ FIX: Handle null and different types for price
    dynamic priceValue = json['price'];
    if (priceValue == null || priceValue == 0 || priceValue == '0') {
      priceValue = json['base_price'];
    }
    if (priceValue != null) {
      if (priceValue is int) {
        price = (priceValue).toDouble();
      } else if (priceValue is double) {
        price = priceValue;
      } else if (priceValue is String) {
        price = double.tryParse(priceValue) ?? 0.0;
      }
    }

    tax = json['tax']?.toDouble();

    // ✅ FIX: Handle null and different types for discount
    if (json['discount'] != null) {
      if (json['discount'] is int) {
        discount = (json['discount'] as int).toDouble();
      } else if (json['discount'] is double) {
        discount = json['discount'];
      } else if (json['discount'] is String) {
        discount = double.tryParse(json['discount']) ?? 0.0;
      }
    } else {
      discount = 0.0; // Default to 0 if null
    }

    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeLogoFullUrl = json['store_logo_full_url'] ?? json['store_logo'];
    zoneId = json['zone_id'];
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    moduleId = json['module_id'];
    moduleType = json['module_type'];
    veg = json['veg'] != null ? int.parse(json['veg'].toString()) : 0;
    stock = json['stock'];
    unitType = json['unit_type'];
    availableDateStarts = json['available_date_starts'];
    if (json['actual_price'] != null) {
      actualPrice = double.tryParse(json['actual_price'].toString());
    }
    organic = json['organic'];
    quantityLimit = json['maximum_cart_quantity'];
    flashSale = json['flash_sale'];
    isStoreHalalActive = json['halal_tag_status'] == 1;
    isHalalItem = json['is_halal'] == 1;
    isPrescriptionRequired = json['is_prescription_required'] == 1;
    if (json['nutritions_name'] != null) {
      if (json['nutritions_name'] is String) {
        if (json['nutritions_name'].toString().startsWith('[')) {
          try {
            nutritionsName =
                List<String>.from(jsonDecode(json['nutritions_name']));
          } catch (e) {
            nutritionsName = [];
          }
        } else {
          nutritionsName = [json['nutritions_name']];
        }
      } else {
        nutritionsName = json['nutritions_name']?.cast<String>();
      }
    }

    if (json['allergies_name'] != null) {
      if (json['allergies_name'] is String) {
        if (json['allergies_name'].toString().startsWith('[')) {
          try {
            allergiesName =
                List<String>.from(jsonDecode(json['allergies_name']));
          } catch (e) {
            allergiesName = [];
          }
        } else {
          allergiesName = [json['allergies_name']];
        }
      } else {
        allergiesName = json['allergies_name']?.cast<String>();
      }
    }

    if (json['generic_name'] != null) {
      if (json['generic_name'] is String) {
        if (json['generic_name'].toString().startsWith('[')) {
          try {
            genericName = List<String>.from(jsonDecode(json['generic_name']));
          } catch (e) {
            genericName = [];
          }
        } else {
          genericName = [json['generic_name']];
        }
      } else {
        genericName = json['generic_name']?.cast<String>();
      }
    }
    type = json['type'];
    voucherIds = json['voucher_ids'] is List
        ? jsonEncode(json['voucher_ids'])
        : json['voucher_ids']?.toString();
    branchIds = json['branch_ids'] is List
        ? jsonEncode(json['branch_ids'])
        : json['branch_ids']?.toString();
    validUntil = json['valid_until'];
    if (json['product'] != null) {
      product = [];
      dynamic productData = json['product'];
      if (productData is String &&
          productData.isNotEmpty &&
          productData != 'null') {
        try {
          productData = jsonDecode(productData);
        } catch (e) {
          productData = [];
        }
      }
      if (productData is List) {
        for (var v in productData) {
          product!.add(Item.fromJson(v));
        }
      }
    }
    if (json['how_it_works'] != null) {
      howItWorks = [];
      json['how_it_works'].forEach((v) {
        howItWorks!.add(HowItWorks.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = [];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    // Handle both new nested structure: all_branches.branches
    // and old flat structure: branches
    dynamic branchesData;
    if (json['all_branches'] != null && json['all_branches'] is Map) {
      branchesData = json['all_branches']['branches'];
    }
    branchesData ??= json['branches'];
    if (branchesData != null && branchesData is List) {
      branches = [];
      for (var v in branchesData) {
        if (v is Map<String, dynamic>) {
          branches!.add(Store.fromJson(v));
        }
      }
    }
    store = json['store_details'] != null
        ? Store.fromJson(json['store_details'])
        : (json['store'] != null ? Store.fromJson(json['store']) : null);
    settings = json['settings'] != null
        ? VoucherSettings.fromJson(json['store_details'] != null
            ? json['voucher_setting']
            : json['settings'])
        : null;
    bundleType = json['bundle_type'];
    if (json['required_quantity'] != null) {
      requiredQuantity = int.tryParse(json['required_quantity'].toString());
    }
    if (json['product_b'] != null) {
      productB = [];
      dynamic productBData = json['product_b'];
      if (productBData is String &&
          productBData.isNotEmpty &&
          productBData != 'null') {
        try {
          productBData = jsonDecode(productBData);
        } catch (e) {
          productBData = [];
        }
      }
      if (productBData is List) {
        for (var v in productBData) {
          productB!.add(Item.fromJson(v));
        }
      }
    }
    if (json['gift_occasions'] != null || json['occasions'] != null) {
      giftOccasions = [];
      dynamic giftOccasionsData = json['gift_occasions'] ?? json['occasions'];
      if (giftOccasionsData is String &&
          giftOccasionsData.isNotEmpty &&
          giftOccasionsData != 'null') {
        try {
          giftOccasionsData = jsonDecode(giftOccasionsData);
        } catch (e) {
          giftOccasionsData = [];
        }
      }
      if (giftOccasionsData is List) {
        for (var v in giftOccasionsData) {
          giftOccasions!.add(GiftOccasionModel.fromJson(v));
        }
      }
    }
    if (json['fixed_amount_options'] != null) {
      if (json['fixed_amount_options'] is String) {
        if (json['fixed_amount_options'].toString().startsWith('[')) {
          try {
            fixedAmountOptions =
                List<String>.from(jsonDecode(json['fixed_amount_options']));
          } catch (e) {
            fixedAmountOptions = [];
          }
        } else {
          fixedAmountOptions = [];
        }
      } else {
        fixedAmountOptions = json['fixed_amount_options']?.cast<String>();
      }
    }

    if (json['min_max_amount'] != null) {
      if (json['min_max_amount'] is String) {
        if (json['min_max_amount'].toString().startsWith('[')) {
          try {
            minMaxAmount =
                List<String>.from(jsonDecode(json['min_max_amount']));
          } catch (e) {
            minMaxAmount = [];
          }
        } else {
          minMaxAmount = [];
        }
      } else {
        minMaxAmount = json['min_max_amount']?.cast<String?>();
      }
    }
    enableCustomAmount = json['enable_custom_amount']?.toString();
    // Parse bonus_configuration or discount_configuration
    if (json['bonus_configuration'] != null) {
      bonusConfiguration = [];
      dynamic bonusData = json['bonus_configuration'];
      if (bonusData is String && bonusData.isNotEmpty && bonusData != 'null') {
        try {
          bonusData = jsonDecode(bonusData);
        } catch (e) {
          bonusData = [];
        }
      }
      if (bonusData is List) {
        for (var v in bonusData) {
          if (v is Map<String, dynamic>) {
            bonusConfiguration!.add(BonusConfiguration.fromJson(v));
          }
        }
      } else if (bonusData is Map) {
        bonusData.forEach((key, v) {
          if (v is Map<String, dynamic>) {
            bonusConfiguration!.add(BonusConfiguration.fromJson(v));
          }
        });
      }
    } else if (json['discount_configuration'] != null) {
      // Fallback to discount_configuration if bonus_configuration is null
      bonusConfiguration = [];
      dynamic discountData = json['discount_configuration'];
      if (discountData is String &&
          discountData.isNotEmpty &&
          discountData != 'null') {
        try {
          discountData = jsonDecode(discountData);
        } catch (e) {
          discountData = [];
        }
      }
      if (discountData is List) {
        for (var v in discountData) {
          if (v is Map<String, dynamic>) {
            bonusConfiguration!.add(BonusConfiguration.fromJson(v));
          }
        }
      } else if (discountData is Map) {
        discountData.forEach((key, v) {
          if (v is Map<String, dynamic>) {
            bonusConfiguration!.add(BonusConfiguration.fromJson(v));
          }
        });
      }
    }
    if (json['recipient_info_form_fields'] != null &&
        json['recipient_info_form_fields'] is Map) {
      recipientInfoFormFields =
          RecipientInfoFormFields.fromJson(json['recipient_info_form_fields']);
    }
    messageTemplateStyle = json['message_template_style']?.toString();
    if (json['occasions_id'] != null) {
      if (json['occasions_id'] is String) {
        if (json['occasions_id'].toString().startsWith('[')) {
          try {
            occasionsId = List<String>.from(jsonDecode(json['occasions_id']));
          } catch (e) {
            occasionsId = [];
          }
        } else {
          occasionsId = [];
        }
      } else {
        occasionsId = json['occasions_id']?.cast<String>();
      }
    }
    if (json['message_templates'] != null) {
      messageTemplates = [];
      json['message_templates'].forEach((v) {
        messageTemplates!.add(GiftMessageModel.fromJson(v));
      });
    }
    if (json['delivery_options'] != null) {
      deliveryOptions = [];
      json['delivery_options'].forEach((v) {
        deliveryOptions!.add(DeliveryOptionModel.fromJson(v));
      });
    }
    voucherType = json['voucher_type']?.toString();
    offerType = json['offer_type']?.toString();

    if (json['terms_conditions'] != null) {
      termAndConditionIds = [];
      dynamic termsData = json['terms_conditions'];
      if (termsData is String && termsData.isNotEmpty && termsData != 'null') {
        try {
          termsData = jsonDecode(termsData);
        } catch (e) {
          termsData = [];
        }
      }
      if (termsData is List) {
        for (var v in termsData) {
          if (v is Map<String, dynamic>) {
            termAndConditionIds!.add(VoucherTerm.fromJson(v));
          }
        }
      }
    }
    availabilityForCurrentUser =
        json['availability_for_current_user'] != null &&
                json['availability_for_current_user'] is Map
            ? AvailabilityForCurrentUser.fromJson(
                json['availability_for_current_user'])
            : null;
    storeCommission = json['store_commission']?.toDouble();
    commissionPaidBy = json['commission_paid_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['images_full_url'] = imagesFullUrl;
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (foodVariations != null) {
      data['food_variations'] = foodVariations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (choiceOptions != null) {
      data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['zone_id'] = zoneId;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['veg'] = veg;
    data['module_id'] = moduleId;
    data['module_type'] = moduleType;
    data['stock'] = stock;
    data['unit_type'] = unitType;
    data['available_date_starts'] = availableDateStarts;
    data['organic'] = organic;
    data['maximum_cart_quantity'] = quantityLimit;
    data['flash_sale'] = flashSale;
    data['halal_tag_status'] = isStoreHalalActive;
    data['is_halal'] = isHalalItem;
    data['is_prescription_required'] = isPrescriptionRequired;
    data['nutritions_name'] = nutritionsName;
    data['allergies_name'] = allergiesName;
    data['generic_name'] = genericName;
    data['type'] = type;
    data['voucher_ids'] = voucherIds;
    if (product != null) {
      data['product'] = product!.map((v) => v.toJson()).toList();
    }
    if (howItWorks != null) {
      data['how_it_works'] = howItWorks!.map((v) => v.toJson()).toList();
    }
    if (branches != null) {
      data['branches'] = branches!.map((v) => v.toJson()).toList();
    }
    if (settings != null) {
      data['settings'] = settings!.toJson();
    }
    data['bundle_type'] = bundleType;
    data['required_quantity'] = requiredQuantity;
    if (productB != null) {
      data['product_b'] = productB!.map((v) => v.toJson()).toList();
    }
    if (giftOccasions != null) {
      data['gift_occasions'] = giftOccasions!.map((v) => v.toJson()).toList();
    }
    data['fixed_amount_options'] = fixedAmountOptions;
    data['min_max_amount'] = minMaxAmount;
    data['enable_custom_amount'] = enableCustomAmount;
    if (bonusConfiguration != null) {
      data['bonus_configuration'] =
          bonusConfiguration!.map((v) => v.toJson()).toList();
    }
    if (recipientInfoFormFields != null) {
      data['recipient_info_form_fields'] = recipientInfoFormFields!.toJson();
    }
    data['message_template_style'] = messageTemplateStyle;
    data['occasions_id'] = occasionsId;
    if (messageTemplates != null) {
      data['message_templates'] =
          messageTemplates!.map((v) => v.toJson()).toList();
    }
    if (deliveryOptions != null) {
      data['delivery_options'] =
          deliveryOptions!.map((v) => v.toJson()).toList();
    }
    data['offer_type'] = offerType;
    if (termAndConditionIds != null) {
      data['term_and_condition_ids'] =
          termAndConditionIds!.map((v) => v.toJson()).toList();
    }
    if (availabilityForCurrentUser != null) {
      data['availability_for_current_user'] =
          availabilityForCurrentUser!.toJson();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['store_commission'] = storeCommission;
    data['commission_paid_by'] = commissionPaidBy;
    return data;
  }
}

class AvailabilityForCurrentUser {
  String? status;
  String? msg;
  UsageDetails? userUsage;
  UsageDetails? storeUsage;

  AvailabilityForCurrentUser(
      {this.status, this.msg, this.userUsage, this.storeUsage});

  AvailabilityForCurrentUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    userUsage = json['user_usage'] != null
        ? UsageDetails.fromJson(json['user_usage'])
        : null;
    storeUsage = json['store_usage'] != null
        ? UsageDetails.fromJson(json['store_usage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (userUsage != null) {
      data['user_usage'] = userUsage!.toJson();
    }
    if (storeUsage != null) {
      data['store_usage'] = storeUsage!.toJson();
    }
    return data;
  }
}

class UsageDetails {
  int? limit;
  int? used;
  int? remaining;
  String? period;

  UsageDetails({this.limit, this.used, this.remaining, this.period});

  UsageDetails.fromJson(Map<String, dynamic> json) {
    limit = int.tryParse(json['limit'].toString());
    used = int.tryParse(json['used'].toString());
    remaining = int.tryParse(json['remaining'].toString());
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    data['used'] = used;
    data['remaining'] = remaining;
    data['period'] = period;
    return data;
  }
}

class CategoryIds {
  int? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    position = int.tryParse(json['position'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class Variation {
  String? type;
  double? price;
  int? stock;

  Variation({this.type, this.price, this.stock});

  Variation.fromJson(Map<String, dynamic> json) {
    type = json['type'];

    // ✅ FIX: Handle null and different types
    if (json['price'] != null) {
      if (json['price'] is int) {
        price = (json['price'] as int).toDouble();
      } else if (json['price'] is double) {
        price = json['price'];
      } else if (json['price'] is String) {
        price = double.tryParse(json['price']) ?? 0.0;
      }
    }

    stock = int.parse(json['stock'] != null ? json['stock'].toString() : '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    data['stock'] = stock;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;
  int? productId;

  AddOns({this.id, this.name, this.price, this.productId});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];

    // ✅ FIX: Handle null and different types
    if (json['price'] != null) {
      if (json['price'] is int) {
        price = (json['price'] as int).toDouble();
      } else if (json['price'] is double) {
        price = json['price'];
      } else if (json['price'] is String) {
        price = double.tryParse(json['price']) ?? 0.0;
      }
    }
    if (json['product_id'] != null) {
      productId = int.parse(json['product_id'].toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    if (productId != null) {
      data['product_id'] = productId;
    }
    return data;
  }
}

class ChoiceOptions {
  String? name;
  String? title;
  List<String>? options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class FoodVariation {
  String? name;
  bool? multiSelect;
  int? min;
  int? max;
  bool? required;
  List<VariationValue>? variationValues;
  int? productId;

  FoodVariation(
      {this.name,
      this.multiSelect,
      this.min,
      this.max,
      this.required,
      this.variationValues,
      this.productId});

  FoodVariation.fromJson(Map<String, dynamic> json) {
    if (json['name'] != null || json['values'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min = (json['min'] != null) ? int.parse(json['min'].toString()) : 0;
      max = (json['max'] != null) ? int.parse(json['max'].toString()) : 0;
      required = (json['required'] == 'on' ||
              json['required'] == true ||
              json['required'] == '1' ||
              json['required'] == 1) ||
          (min! > 0);
      if (json['values'] != null) {
        variationValues = [];
        json['values'].forEach((v) {
          variationValues!.add(VariationValue.fromJson(v));
        });
      }
      if (json['product_id'] != null) {
        productId = int.parse(json['product_id'].toString());
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = multiSelect;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    if (productId != null) {
      data['product_id'] = productId;
    }
    return data;
  }
}

class VariationValue {
  String? level;
  double? optionPrice;
  bool? isSelected;

  VariationValue({this.level, this.optionPrice, this.isSelected});

  VariationValue.fromJson(Map<String, dynamic> json) {
    level = json['label'];
    optionPrice = double.parse(json['optionPrice'].toString());
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    data['isSelected'] = isSelected;
    return data;
  }
}

class HowItWorks {
  int? id;
  String? voucherId;
  String? guideTitle;
  List<Sections>? sections;
  String? status;

  HowItWorks(
      {this.id, this.voucherId, this.guideTitle, this.sections, this.status});

  HowItWorks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    voucherId = json['voucher_id'];
    guideTitle = json['guide_title'];
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['voucher_id'] = voucherId;
    data['guide_title'] = guideTitle;
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Sections {
  String? title;
  List<String>? steps;

  Sections({this.title, this.steps});

  Sections.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['steps'] != null) {
      steps = json['steps'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['steps'] = steps;
    return data;
  }
}

class VoucherSettings {
  ValidityPeriod? validityPeriod;
  SpecificDaysOfWeek? specificDaysOfWeek;
  List<HolidayOccasion>? holidaysOccasions;
  List<CustomBlackoutDate>? customBlackoutDates;
  List<AgeRestriction>? ageRestriction;
  int? groupSizeRequirement;
  String? groupSizeText;
  UsageLimit? usageLimitPerUser;
  UsageLimit? usageLimitPerStore;
  int? offerValidityAfterPurchase;
  String? offerValidityText;
  List<GeneralRestriction>? generalRestrictions;
  String? status;

  VoucherSettings({
    this.validityPeriod,
    this.specificDaysOfWeek,
    this.holidaysOccasions,
    this.customBlackoutDates,
    this.ageRestriction,
    this.groupSizeRequirement,
    this.groupSizeText,
    this.usageLimitPerUser,
    this.usageLimitPerStore,
    this.offerValidityAfterPurchase,
    this.offerValidityText,
    this.generalRestrictions,
    this.status,
  });

  dynamic _safeJsonExtract(dynamic data, {bool takeFirst = true}) {
    if (data == null) return null;
    if (data is String) {
      if (data.isEmpty || data == 'null') return null;
      try {
        return _safeJsonExtract(jsonDecode(data), takeFirst: takeFirst);
      } catch (e) {
        return data;
      }
    }
    if (data is List) {
      if (data.isEmpty) return null;
      if (takeFirst) return _safeJsonExtract(data[0], takeFirst: takeFirst);
      return data.map((e) => _safeJsonExtract(e, takeFirst: true)).toList();
    }
    return data;
  }

  VoucherSettings.fromJson(Map<String, dynamic> json) {
    // Parsing validity_period which comes as a Stringified JSON in some cases or Object
    dynamic validityData = _safeJsonExtract(json['validity_period']);
    if (validityData is Map<String, dynamic>) {
      validityPeriod = ValidityPeriod.fromJson(validityData);
    }

    // Parsing specific_days_of_week
    dynamic daysData = _safeJsonExtract(json['specific_days_of_week']);
    if (daysData is Map<String, dynamic>) {
      specificDaysOfWeek = SpecificDaysOfWeek.fromJson(daysData);
    }

    if (json['holidays_occasions'] != null) {
      holidaysOccasions = <HolidayOccasion>[];
      dynamic holidaysData = json['holidays_occasions'];
      if (holidaysData is String) {
        try {
          if (holidaysData.startsWith('[')) {
            holidaysData = jsonDecode(holidaysData);
          }
        } catch (e) {
          holidaysData = [];
        }
      }
      if (holidaysData is List) {
        holidaysData.forEach((v) {
          dynamic extractedV = _safeJsonExtract(v);
          if (extractedV is Map<String, dynamic>) {
            holidaysOccasions!.add(HolidayOccasion.fromJson(extractedV));
          }
        });
      }
    }

    if (json['custom_blackout_dates'] != null) {
      customBlackoutDates = <CustomBlackoutDate>[];
      dynamic blackoutData = json['custom_blackout_dates'];
      if (blackoutData is String) {
        try {
          blackoutData = jsonDecode(blackoutData);
        } catch (e) {
          blackoutData = [];
        }
      }
      if (blackoutData is List) {
        blackoutData.forEach((v) {
          dynamic extractedV = _safeJsonExtract(v);
          if (extractedV is Map<String, dynamic>) {
            customBlackoutDates!.add(CustomBlackoutDate.fromJson(extractedV));
          }
        });
      }
    }

    if (json['age_restriction'] != null) {
      ageRestriction = <AgeRestriction>[];
      dynamic ageData = json['age_restriction'];
      if (ageData is String) {
        try {
          ageData = jsonDecode(ageData);
        } catch (e) {
          ageData = [];
        }
      }
      if (ageData is List) {
        ageData.forEach((v) {
          dynamic extractedV = _safeJsonExtract(v);
          if (extractedV is Map<String, dynamic>) {
            ageRestriction!.add(AgeRestriction.fromJson(extractedV));
          } else if (extractedV is List) {
            extractedV.forEach((subV) {
              dynamic finalV = _safeJsonExtract(subV);
              if (finalV is Map<String, dynamic>) {
                ageRestriction!.add(AgeRestriction.fromJson(finalV));
              } else if (finalV != null) {
                // Handle case where it's a simple value (e.g. "30")
                ageRestriction!.add(AgeRestriction(
                  value: int.tryParse(finalV.toString()),
                  text: '${finalV}+ Only',
                ));
              }
            });
          }
        });
      }
    }

    dynamic groupData = _safeJsonExtract(json['group_size_requirement']);
    if (groupData is Map<String, dynamic>) {
      groupSizeRequirement = int.tryParse(groupData['value']?.toString() ?? '');
      groupSizeText = groupData['text']?.toString();
    } else if (groupData != null) {
      groupSizeRequirement = int.tryParse(groupData.toString());
    }

    dynamic userLimitData =
        _safeJsonExtract(json['usage_limit_per_user'], takeFirst: false);
    if (userLimitData is Map<String, dynamic>) {
      usageLimitPerUser = UsageLimit.fromJson(userLimitData);
    } else if (userLimitData is List && userLimitData.isNotEmpty) {
      usageLimitPerUser = UsageLimit(
        value: userLimitData[0]?.toString(),
        period: userLimitData.length > 1 ? userLimitData[1]?.toString() : null,
      );
    }

    dynamic storeLimitData =
        _safeJsonExtract(json['usage_limit_per_store'], takeFirst: false);
    if (storeLimitData is Map<String, dynamic>) {
      usageLimitPerStore = UsageLimit.fromJson(storeLimitData);
    } else if (storeLimitData is List && storeLimitData.isNotEmpty) {
      usageLimitPerStore = UsageLimit(
        value: storeLimitData[0]?.toString(),
        period:
            storeLimitData.length > 1 ? storeLimitData[1]?.toString() : null,
      );
    }

    dynamic validityAfterData =
        _safeJsonExtract(json['offer_validity_after_purchase']);
    if (validityAfterData is Map<String, dynamic>) {
      offerValidityAfterPurchase =
          int.tryParse(validityAfterData['value']?.toString() ?? '');
      offerValidityText = validityAfterData['text']?.toString();
    } else if (validityAfterData != null) {
      offerValidityAfterPurchase = int.tryParse(validityAfterData.toString());
    }

    dynamic generalRestrictionsData = _safeJsonExtract(
        json['general_restrictions'] ??
            json['general_restriction_data'] ??
            json['general_restriction']);
    if (generalRestrictionsData != null) {
      generalRestrictions = <GeneralRestriction>[];
      if (generalRestrictionsData is List) {
        generalRestrictionsData.forEach((v) {
          dynamic extractedV = _safeJsonExtract(v);
          if (extractedV is Map<String, dynamic>) {
            generalRestrictions!.add(GeneralRestriction.fromJson(extractedV));
          }
        });
      }
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (validityPeriod != null) {
      data['validity_period'] = validityPeriod!.toJson();
    }
    if (specificDaysOfWeek != null) {
      data['specific_days_of_week'] = specificDaysOfWeek!.toJson();
    }
    if (holidaysOccasions != null) {
      data['holidays_occasions'] =
          holidaysOccasions!.map((v) => v.toJson()).toList();
    }
    if (customBlackoutDates != null) {
      data['custom_blackout_dates'] =
          customBlackoutDates!.map((v) => v.toJson()).toList();
    }
    data['age_restriction'] = ageRestriction;
    data['group_size_requirement'] = groupSizeRequirement;
    data['group_size_text'] = groupSizeText;
    if (usageLimitPerUser != null) {
      data['usage_limit_per_user'] = usageLimitPerUser!.toJson();
    }
    if (usageLimitPerStore != null) {
      data['usage_limit_per_store'] = usageLimitPerStore!.toJson();
    }
    data['offer_validity_after_purchase'] = offerValidityAfterPurchase;
    data['offer_validity_text'] = offerValidityText;
    data['general_restrictions'] = generalRestrictions;
    data['status'] = status;
    return data;
  }
}

class ValidityPeriod {
  String? start;
  String? end;

  ValidityPeriod({this.start, this.end});

  ValidityPeriod.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class SpecificDaysOfWeek {
  DaySchedule? monday;
  DaySchedule? tuesday;
  DaySchedule? wednesday;
  DaySchedule? thursday;
  DaySchedule? friday;
  DaySchedule? saturday;
  DaySchedule? sunday;

  SpecificDaysOfWeek({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  SpecificDaysOfWeek.fromJson(Map<String, dynamic> json) {
    monday =
        json['monday'] != null ? DaySchedule.fromJson(json['monday']) : null;
    tuesday =
        json['tuesday'] != null ? DaySchedule.fromJson(json['tuesday']) : null;
    wednesday = json['wednesday'] != null
        ? DaySchedule.fromJson(json['wednesday'])
        : null;
    thursday = json['thursday'] != null
        ? DaySchedule.fromJson(json['thursday'])
        : null;
    friday =
        json['friday'] != null ? DaySchedule.fromJson(json['friday']) : null;
    saturday = json['saturday'] != null
        ? DaySchedule.fromJson(json['saturday'])
        : null;
    sunday =
        json['sunday'] != null ? DaySchedule.fromJson(json['sunday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (monday != null) data['monday'] = monday!.toJson();
    if (tuesday != null) data['tuesday'] = tuesday!.toJson();
    if (wednesday != null) data['wednesday'] = wednesday!.toJson();
    if (thursday != null) data['thursday'] = thursday!.toJson();
    if (friday != null) data['friday'] = friday!.toJson();
    if (saturday != null) data['saturday'] = saturday!.toJson();
    if (sunday != null) data['sunday'] = sunday!.toJson();
    return data;
  }
}

class DaySchedule {
  String? start;
  String? end;

  DaySchedule({this.start, this.end});

  DaySchedule.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class HolidayOccasion {
  int? id;
  String? nameAr;
  String? nameEn;
  String? startDate;
  String? endDate;

  HolidayOccasion(
      {this.id, this.nameAr, this.nameEn, this.startDate, this.endDate});

  HolidayOccasion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class CustomBlackoutDate {
  int? id;
  String? date;
  String? description;

  CustomBlackoutDate({this.id, this.date, this.description});

  CustomBlackoutDate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['description'] = description;
    return data;
  }
}

class UsageLimit {
  String? value;
  String? period;

  UsageLimit({this.value, this.period});

  UsageLimit.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['period'] = period;
    return data;
  }
}

class AgeRestriction {
  int? id;
  int? value;
  String? text;

  AgeRestriction({this.id, this.value, this.text});

  AgeRestriction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = int.tryParse(json['value'].toString());
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    data['text'] = text;
    return data;
  }
}

class GeneralRestriction {
  int? id;
  String? nameAr;
  String? nameEn;

  GeneralRestriction({this.id, this.nameAr, this.nameEn});

  GeneralRestriction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    return data;
  }
}

class BonusConfiguration {
  String? minAmount;
  String? maxAmount;
  String? bonusPercentage;

  BonusConfiguration({this.minAmount, this.maxAmount, this.bonusPercentage});

  BonusConfiguration.fromJson(Map<String, dynamic> json) {
    minAmount = json['min_amount']?.toString();
    maxAmount = json['max_amount']?.toString();
    bonusPercentage = json['bonus_percentage']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min_amount'] = minAmount;
    data['max_amount'] = maxAmount;
    data['bonus_percentage'] = bonusPercentage;
    return data;
  }
}

class RecipientInfoFormFields {
  List<String>? formFields;
  List<String>? requiredFields;

  RecipientInfoFormFields({this.formFields, this.requiredFields});

  RecipientInfoFormFields.fromJson(Map<String, dynamic> json) {
    formFields = json['form_fields']?.cast<String>();
    requiredFields = json['required_fields']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['form_fields'] = formFields;
    data['required_fields'] = requiredFields;
    return data;
  }
}

class VoucherTerm {
  int? id;
  String? title;
  String? description;
  List<String>? days;
  String? timeFrom;
  String? timeTo;
  String? validFromDate;
  String? validUntilDate;
  List<String>? holidayRestrictions;
  String? blackoutDates;
  List<String>? specialOccasions;
  String? limitPerUser;
  String? limitPeriod;
  String? minPurchAccount;
  String? maxDiscountAmount;
  String? advanceBookingRequired;
  String? groupSizeRequired;
  List<String>? venueTypes;
  String? specificBranch;
  String? city;
  String? deliveryRadius;
  String? customerType;
  String? ageRestriction;
  String? minMembershipRadius;
  List<String>? restrictionTypes;
  String? cancellationPolicy;
  String? excludedProduct;
  String? surchargeAccount;
  String? surchargeApple;
  String? voucherId;

  VoucherTerm({
    this.id,
    this.title,
    this.description,
    this.days,
    this.timeFrom,
    this.timeTo,
    this.validFromDate,
    this.validUntilDate,
    this.holidayRestrictions,
    this.blackoutDates,
    this.specialOccasions,
    this.limitPerUser,
    this.limitPeriod,
    this.minPurchAccount,
    this.maxDiscountAmount,
    this.advanceBookingRequired,
    this.groupSizeRequired,
    this.venueTypes,
    this.specificBranch,
    this.city,
    this.deliveryRadius,
    this.customerType,
    this.ageRestriction,
    this.minMembershipRadius,
    this.restrictionTypes,
    this.cancellationPolicy,
    this.excludedProduct,
    this.surchargeAccount,
    this.surchargeApple,
    this.voucherId,
  });

  VoucherTerm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['baseinfor_condition_title'];
    description = json['baseinfor_description'];
    days = json['timeandday_config_days']?.cast<String>();
    timeFrom = json['timeandday_config_time_range_from'];
    timeTo = json['timeandday_config_time_range_to'];
    validFromDate = json['timeandday_config_valid_from_date'];
    validUntilDate = json['timeandday_config_valid_until_date'];
    holidayRestrictions =
        json['holiday_occasions_holiday_restrictions']?.cast<String>();
    blackoutDates = json['holiday_occasions_customer_blackout_dates'];
    specialOccasions =
        json['holiday_occasions_special_occasions']?.cast<String>();
    limitPerUser = json['usage_limits_limit_per_user'];
    limitPeriod = json['usage_limits_period'];
    minPurchAccount = json['usage_limits_min_purch_account'];
    maxDiscountAmount = json['usage_limits_max_discount_amount'];
    advanceBookingRequired = json['usage_limits_advance_booking_required'];
    groupSizeRequired = json['usage_limits_group_size_required'];
    venueTypes = json['location_availability_venue_types']?.cast<String>();
    specificBranch = json['location_availability_specific_branch'];
    city = json['location_availability_city'];
    deliveryRadius = json['location_availability_delivery_radius'];
    customerType = json['customer_membership_customer_type'];
    ageRestriction = json['customer_membership_age_restriction'];
    minMembershipRadius = json['customer_membership_min_membership_radius'];
    restrictionTypes =
        json['restriction_polices_restriction_type']?.cast<String>();
    cancellationPolicy = json['restriction_polices_cancellation_policy'];
    excludedProduct = json['restriction_polices_excluded_product'];
    surchargeAccount = json['restriction_polices_surchange_account'];
    surchargeApple = json['restriction_polices_surchange_apple'];
    voucherId = json['voucher_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['baseinfor_condition_title'] = title;
    data['baseinfor_description'] = description;
    data['timeandday_config_days'] = days;
    data['timeandday_config_time_range_from'] = timeFrom;
    data['timeandday_config_time_range_to'] = timeTo;
    data['timeandday_config_valid_from_date'] = validFromDate;
    data['timeandday_config_valid_until_date'] = validUntilDate;
    data['holiday_occasions_holiday_restrictions'] = holidayRestrictions;
    data['holiday_occasions_customer_blackout_dates'] = blackoutDates;
    data['holiday_occasions_special_occasions'] = specialOccasions;
    data['usage_limits_limit_per_user'] = limitPerUser;
    data['usage_limits_period'] = limitPeriod;
    data['usage_limits_min_purch_account'] = minPurchAccount;
    data['usage_limits_max_discount_amount'] = maxDiscountAmount;
    data['usage_limits_advance_booking_required'] = advanceBookingRequired;
    data['usage_limits_group_size_required'] = groupSizeRequired;
    data['location_availability_venue_types'] = venueTypes;
    data['location_availability_specific_branch'] = specificBranch;
    data['location_availability_city'] = city;
    data['location_availability_delivery_radius'] = deliveryRadius;
    data['customer_membership_customer_type'] = customerType;
    data['customer_membership_age_restriction'] = ageRestriction;
    data['customer_membership_min_membership_radius'] = minMembershipRadius;
    data['restriction_polices_restriction_type'] = restrictionTypes;
    data['restriction_polices_cancellation_policy'] = cancellationPolicy;
    data['restriction_polices_excluded_product'] = excludedProduct;
    data['restriction_polices_surchange_account'] = surchargeAccount;
    data['restriction_polices_surchange_apple'] = surchargeApple;
    data['voucher_id'] = voucherId;
    return data;
  }
}

class Reviews {
  int? id;
  int? itemId;
  int? userId;
  String? comment;
  int? rating;
  int? orderId;
  String? createdAt;
  Customer? customer;

  Reviews(
      {this.id,
      this.itemId,
      this.userId,
      this.comment,
      this.rating,
      this.orderId,
      this.createdAt,
      this.customer});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    userId = json['user_id'];
    comment = json['comment'];
    rating = json['rating'];
    orderId = json['order_id'];
    createdAt = json['created_at'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['user_id'] = userId;
    data['comment'] = comment;
    data['rating'] = rating;
    data['order_id'] = orderId;
    data['created_at'] = createdAt;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;

  Customer(
      {this.id,
      this.fName,
      this.lName,
      this.phone,
      this.email,
      this.imageFullUrl});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}
