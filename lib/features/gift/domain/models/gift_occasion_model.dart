import 'dart:convert';

class GiftOccasionModel {
  int? id;
  String? title;
  List<String>? icon;
  List<String>? message;
  String? status;
  String? createdAt;
  String? updatedAt;

  GiftOccasionModel({
    this.id,
    this.title,
    this.icon,
    this.message,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  GiftOccasionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];

    // Parse icon field
    if (json['icon'] != null) {
      if (json['icon'] is String) {
        if (json['icon'].toString().startsWith('[')) {
          try {
            icon = List<String>.from(jsonDecode(json['icon']));
          } catch (e) {
            icon = [];
          }
        } else {
          icon = [json['icon']];
        }
      } else {
        icon = json['icon'].cast<String>();
      }
      // Fix icon URLs to include /public/ after base URL
      _fixIconUrls();
    }

    // Parse message field
    if (json['message'] != null) {
      if (json['message'] is String) {
        if (json['message'].toString().startsWith('[')) {
          try {
            message = List<String>.from(jsonDecode(json['message']));
          } catch (e) {
            message = [];
          }
        } else {
          message = [json['message']];
        }
      } else {
        message = json['message'].cast<String>();
      }
    }

    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  /// Fix icon URLs to include /public/ in the path if not already present
  void _fixIconUrls() {
    if (icon == null) return;

    for (int i = 0; i < icon!.length; i++) {
      String url = icon![i];

      // Check if URL contains /public/ already or is relative
      if (url.contains('/public/') || !url.startsWith('http')) {
        continue;
      }

      // Find /uploads/ and insert /public/ before it
      if (url.contains('/uploads/')) {
        icon![i] = url.replaceFirst('/uploads/', '/public/uploads/');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['icon'] = icon;
    data['message'] = message;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
