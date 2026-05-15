class NotificationModel {
  int? id;
  Data? data;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;
  String? notificationLink;
  int? voucherId;
  Voucher? voucher;

  NotificationModel({
    this.id,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
    this.notificationLink,
    this.voucherId,
    this.voucher,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
    notificationLink = json['notification_link'];
    voucherId = json['voucher_id'] != null ? int.tryParse(json['voucher_id'].toString()) : null;
    voucher = json['voucher'] != null ? Voucher.fromJson(json['voucher']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    data['notification_link'] = notificationLink;
    data['voucher_id'] = voucherId;
    if (voucher != null) {
      data['voucher'] = voucher!.toJson();
    }
    return data;
  }
}

class Voucher {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;

  Voucher({this.id, this.name, this.description, this.imageFullUrl});

  Voucher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class Data {
  String? title;
  String? description;
  String? imageFullUrl;
  String? type;
  int? orderId;
  String? expiryDate;

  Data({
    this.title,
    this.description,
    this.imageFullUrl,
    this.type,
    this.orderId,
    this.expiryDate,
  });

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'].toString();
    imageFullUrl = json['image_full_url'];
    type = json['type'];
    orderId = json['order_id'] != null ? int.tryParse(json['order_id'].toString()) : null;
    expiryDate = json['expiry_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['type'] = type;
    data['order_id'] = orderId;
    data['expiry_date'] = expiryDate;
    return data;
  }
}
