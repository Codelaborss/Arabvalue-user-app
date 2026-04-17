class GiftMessageModel {
  int? id;
  String? title;
  String? subTitle;
  String? icon;
  String? status;
  String? createdAt;
  String? updatedAt;

  GiftMessageModel(
      {this.id,
      this.title,
      this.subTitle,
      this.icon,
      this.status,
      this.createdAt,
      this.updatedAt});

  GiftMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subTitle = json['sub_title'];
    icon = json['icon'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['sub_title'] = subTitle;
    data['icon'] = icon;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
