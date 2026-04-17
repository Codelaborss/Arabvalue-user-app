import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'dart:convert';

import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class OrderDetailsModel {
  int? id;
  int? itemId;
  int? orderId;
  double? price;
  Item? itemDetails;
  List<Variation>? variation;
  List<FoodVariation>? foodVariation;
  List<AddOn>? addOns;
  double? discountOnItem;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  String? imageFullUrl;
  int? isGuest;
  List<HowItWorks>? howItWorks;
  List<Store>? branches;
  List<Item>? products;
  GiftDetails? giftDetails;

  OrderDetailsModel({
    this.id,
    this.itemId,
    this.orderId,
    this.price,
    this.itemDetails,
    this.variation,
    this.foodVariation,
    this.addOns,
    this.discountOnItem,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.imageFullUrl,
    this.isGuest,
    this.giftDetails,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    orderId = json['order_id'];
    price = json['price'] != null ? double.parse(json['price'].toString()) : 0;

    if (json['item_details'] != null) {
      dynamic itemData = json['item_details'];
      if (itemData is String && itemData.isNotEmpty && itemData != 'null') {
        try {
          itemData = jsonDecode(itemData);
        } catch (e) {
          itemData = null;
        }
      }
      if (itemData is Map<String, dynamic>) {
        itemDetails = Item.fromJson(itemData);
      }
    }
    variation = [];
    foodVariation = [];
    dynamic variationData = json['variation'];
    if (variationData is String &&
        variationData.isNotEmpty &&
        variationData != 'null') {
      try {
        variationData = jsonDecode(variationData);
      } catch (e) {
        variationData = null;
      }
    }

    if (variationData != null &&
        variationData is List &&
        variationData.isNotEmpty) {
      try {
        if (variationData[0]['values'] != null) {
          variationData.forEach((v) {
            foodVariation!.add(FoodVariation.fromJson(v));
          });
        } else {
          variationData.forEach((v) {
            variation!.add(Variation.fromJson(v));
          });
        }
      } catch (e) {}
    }

    dynamic addOnData = json['add_ons'];
    if (addOnData is String && addOnData.isNotEmpty && addOnData != 'null') {
      try {
        addOnData = jsonDecode(addOnData);
      } catch (e) {
        addOnData = null;
      }
    }

    if (addOnData != null && addOnData is List) {
      addOns = [];
      addOnData.forEach((v) {
        if (v is Map<String, dynamic>) {
          addOns!.add(AddOn.fromJson(v));
        }
      });
    }
    discountOnItem = json['discount_on_item'] != null
        ? double.parse(json['discount_on_item'].toString())
        : 0;
    discountType = json['discount_type'];
    quantity =
        json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0;
    taxAmount = json['tax_amount'] != null
        ? double.parse(json['tax_amount'].toString())
        : 0;
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price'] != null
        ? double.parse(json['total_add_on_price'].toString())
        : 0;
    imageFullUrl = json['image_full_url'];
    isGuest = json['is_guest'];

    if (json['how_it_works'] != null) {
      howItWorks = [];
      json['how_it_works'].forEach((v) {
        howItWorks!.add(HowItWorks.fromJson(v));
      });
    }

    if (json['branches'] != null) {
      branches = [];
      json['branches'].forEach((v) {
        branches!.add(Store.fromJson(v));
      });
    }

    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(Item.fromJson(v));
      });
    }

    if (json['gift_details'] != null) {
      giftDetails = GiftDetails.fromJson(json['gift_details']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (itemDetails != null) {
      data['item_details'] = itemDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    } else if (foodVariation != null) {
      data['variation'] = foodVariation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_item'] = discountOnItem;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['image_full_url'] = imageFullUrl;
    data['is_guest'] = isGuest;
    if (giftDetails != null) {
      data['gift_details'] = giftDetails!.toJson();
    }
    return data;
  }
}

class GiftDetails {
  String? occasion;
  String? image;
  String? senderName;
  String? recipientName;
  String? recipientEmail;
  String? message;
  String? deliveryTime;
  double? amount;

  GiftDetails({
    this.occasion,
    this.image,
    this.senderName,
    this.recipientName,
    this.recipientEmail,
    this.message,
    this.deliveryTime,
    this.amount,
  });

  GiftDetails.fromJson(Map<String, dynamic> json) {
    occasion = json['occasion'];
    image = json['image'];
    if (image != null && image!.isNotEmpty && !image!.startsWith('http')) {
      if (image!.startsWith('public/')) {
        image = '${AppConstants.baseUrl}/$image';
      } else {
        image = '${AppConstants.baseUrl}/public/uploads/gift_occasions/$image';
      }
    }
    senderName = json['sender_name'];
    recipientName = json['recipient_name'];
    recipientEmail = json['recipient_email'];
    message = json['message'];
    deliveryTime = json['delivery_time'];
    amount =
        json['amount'] != null ? double.parse(json['amount'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['occasion'] = occasion;
    data['image'] = image;
    data['sender_name'] = senderName;
    data['recipient_name'] = recipientName;
    data['recipient_email'] = recipientEmail;
    data['message'] = message;
    data['delivery_time'] = deliveryTime;
    data['amount'] = amount;
    return data;
  }
}

class AddOn {
  String? name;
  double? price;
  int? quantity;

  AddOn({
    this.name,
    this.price,
    this.quantity,
  });

  AddOn.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] != null ? double.parse(json['price'].toString()) : 0;
    quantity =
        json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}
