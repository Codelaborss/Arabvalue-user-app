import 'package:sixam_mart/features/item/domain/models/item_model.dart'
    as product_variation;
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'dart:convert';

class OnlineCartModel {
  int? id;
  int? userId;
  int? moduleId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  double? price;
  int? quantity;
  List<Variation>? foodVariation;
  List<product_variation.Variation>? productVariation;
  String? createdAt;
  String? updatedAt;
  List<product_variation.AddOns>? addOns;
  product_variation.Item? item;
  String? cartGroupId; // Added field
  String? type;
  String? status;
  GiftDetails? giftDetails;
  double? discountAmount; // Bonus-based flat voucher discount from API
  double? totalPrice; // Original price before discount from API
  bool? isPaid;

  OnlineCartModel({
    this.id,
    this.userId,
    this.moduleId,
    this.itemId,
    this.isGuest,
    this.addOnIds,
    this.addOnQtys,
    this.itemType,
    this.price,
    this.quantity,
    this.foodVariation,
    this.createdAt,
    this.updatedAt,
    this.addOns,
    this.item,
    this.cartGroupId,
    this.type,
    this.status,
    this.giftDetails,
    this.discountAmount,
    this.totalPrice,
    this.isPaid,
  });

  OnlineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    moduleId = json['module_id'];
    itemId = json['item_id'];
    isGuest = json['is_guest'];
    addOnIds = json['add_on_ids'].cast<int>();
    addOnQtys = json['add_on_qtys'].cast<int>();
    itemType = json['item_type'];
    if (json['price'] != null) {
      dynamic priceValue = json['price'];
      if (priceValue is int) {
        price = priceValue.toDouble();
      } else if (priceValue is double) {
        price = priceValue;
      } else if (priceValue is String) {
        price = double.tryParse(priceValue);
      }
    }
    quantity = json['quantity'];
    if (json['variation'] != null) {
      foodVariation = [];
      productVariation = [];
      json['variation'].forEach((v) {
        if (v['name'] == null) {
          productVariation!.add(product_variation.Variation.fromJson(v));
        } else {
          foodVariation!.add(Variation.fromJson(v));
        }
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['add_ons'] != null ||
        json['addons'] != null ||
        json['addOns'] != null) {
      addOns = [];
      dynamic addOnsData = json['add_ons'] ?? json['addons'] ?? json['addOns'];
      if (addOnsData is List) {
        for (var v in addOnsData) {
          addOns!.add(product_variation.AddOns.fromJson(v));
        }
      }
    }
    item = json['item'] != null
        ? product_variation.Item.fromJson(json['item'])
        : null;
    if (json['cart_group'] != null) {
      cartGroupId = json['cart_group'].toString();
    }

    type = json['type'];
    status = json['status'];
    // Parse discount_amount for flat vouchers (bonus-based discount)
    if (json['discount_amount'] != null) {
      dynamic da = json['discount_amount'];
      if (da is num) {
        discountAmount = da.toDouble();
      } else if (da is String) {
        discountAmount = double.tryParse(da);
      }
    }
    if (json['total_price'] != null) {
      dynamic tp = json['total_price'];
      if (tp is num) {
        totalPrice = tp.toDouble();
      } else if (tp is String) {
        totalPrice = double.tryParse(tp);
      }
    }
    if (json['gift_details'] != null) {
      if (json['gift_details'] is String) {
        try {
          giftDetails = GiftDetails.fromJson(jsonDecode(json['gift_details']));
        } catch (e) {
          giftDetails = null;
        }
      } else if (json['gift_details'] is Map<String, dynamic>) {
        giftDetails = GiftDetails.fromJson(json['gift_details']);
      }
    }
    isPaid = json['is_paid'] is bool
        ? json['is_paid']
        : (json['is_paid'] == 1 || json['is_paid'] == '1');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['module_id'] = moduleId;
    data['item_id'] = itemId;
    data['is_guest'] = isGuest;
    data['add_on_ids'] = addOnIds;
    data['add_on_qtys'] = addOnQtys;
    data['item_type'] = itemType;
    data['price'] = price;
    data['quantity'] = quantity;
    if (foodVariation != null) {
      data['variation'] = foodVariation!.map((v) => v.toJson()).toList();
    }
    if (productVariation != null) {
      if (data['variation'] != null) {
        data['variation']
            .addAll(productVariation!.map((v) => v.toJson()).toList());
      } else {
        data['variation'] = productVariation!.map((v) => v.toJson()).toList();
      }
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (item != null) {
      data['item'] = item!.toJson();
    }
    data['cart_group'] = cartGroupId;
    data['type'] = type;
    data['status'] = status;
    if (giftDetails != null) {
      data['gift_details'] = giftDetails!.toJson();
    }
    data['discount_amount'] = discountAmount;
    data['total_price'] = totalPrice;
    data['is_paid'] = isPaid;
    return data;
  }
}

class Variation {
  String? name;
  String? type;
  int? min;
  int? max;
  String? required;
  List<Value>? values;

  Variation(
      {this.name, this.type, this.min, this.max, this.required, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    min = json['min'];
    max = json['max'];
    required = json['required'];
    if (json['values'] != null) {
      values = [];
      json['values'].forEach((v) {
        values!.add(Value.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Value {
  String? label;
  String? optionPrice;

  Value({this.label, this.optionPrice});

  Value.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    optionPrice = json['optionPrice']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['optionPrice'] = optionPrice;
    return data;
  }
}
