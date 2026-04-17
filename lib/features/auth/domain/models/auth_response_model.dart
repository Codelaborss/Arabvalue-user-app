class AuthResponseModel {
  String? token;
  bool? isPhoneVerified;
  bool? isEmailVerified;
  bool? isPersonalInfo;
  IsExistUser? isExistUser;
  String? loginType;
  String? email;
  String? username;
  String? phone;
  String? fName;
  String? lName;
  Client? client;

  AuthResponseModel({
    this.token,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.isPersonalInfo,
    this.isExistUser,
    this.loginType,
    this.email,
    this.fName,
    this.lName,
    this.client,
  });

  AuthResponseModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    isPhoneVerified = json['is_phone_verified'] == 1;
    isEmailVerified = json['is_email_verified'] == 1;
    isPersonalInfo = json['is_personal_info'] == 1;
    isExistUser = json['is_exist_user'] != null
        ? IsExistUser.fromJson(json['is_exist_user'])
        : null;
    loginType = json['login_type'];
    email = json['email'];
    username = json['username'];
    phone = json['phone'];
    fName = json['f_name'] ?? (isExistUser != null ? isExistUser!.name : null);
    lName = json['l_name'];
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_personal_info'] = isPersonalInfo;
    if (isExistUser != null) data['is_exist_user'] = isExistUser!.toJson();
    data['login_type'] = loginType;
    data['email'] = email;
    data['username'] = username;
    data['phone'] = phone;
    data['f_name'] = fName;
    data['l_name'] = lName;
    if (client != null) data['client'] = client!.toJson();
    return data;
  }
}

class IsExistUser {
  int? id;
  String? name;
  String? image;

  IsExistUser({this.id, this.name, this.image});

  IsExistUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };
}

// ===== New Classes =====

class Client {
  int? id;
  String? name;
  String? email;
  String? logo;
  String? cover;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;
  Segment? segment;
  App? app;

  Client({
    this.id,
    this.name,
    this.email,
    this.logo,
    this.cover,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.segment,
    this.app,
  });

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    logo = json['logo'];
    cover = json['cover'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    segment =
        json['segment'] != null ? Segment.fromJson(json['segment']) : null;
    app = json['app'] != null ? App.fromJson(json['app']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['logo'] = logo;
    data['cover'] = cover;
    data['type'] = type;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (segment != null) data['segment'] = segment!.toJson();
    if (app != null) data['app'] = app!.toJson();
    return data;
  }
}

class Segment {
  int? id;
  String? clientId;
  String? name;
  String? type;
  String? validationDate;
  String? validityDays;
  String? status;
  String? createdAt;
  String? updatedAt;

  Segment({
    this.id,
    this.clientId,
    this.name,
    this.type,
    this.validationDate,
    this.validityDays,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Segment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id']?.toString();
    name = json['name'];
    type = json['type'];
    validationDate = json['validation_date'];
    validityDays = json['validity_days']?.toString();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'name': name,
        'type': type,
        'validation_date': validationDate,
        'validity_days': validityDays,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class App {
  int? id;
  String? clientId;
  String? appName;
  String? appLogo;
  String? appDec;
  String? appType;
  String? status;
  String? banner;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? banners;
  List<AppTheme>? themes;

  App({
    this.id,
    this.clientId,
    this.appName,
    this.appLogo,
    this.appDec,
    this.appType,
    this.status,
    this.banner,
    this.createdAt,
    this.updatedAt,
    this.banners,
    this.themes,
  });

  App.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id']?.toString();
    appName = json['app_name'];
    appLogo = json['app_logo'];
    appDec = json['app_dec'];
    appType = json['app_type'];
    status = json['status'];
    banner = json['banner']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    banners = json['banners'];
    if (json['themes'] != null) {
      themes = <AppTheme>[];
      json['themes'].forEach((v) => themes!.add(AppTheme.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['app_name'] = appName;
    data['app_logo'] = appLogo;
    data['app_dec'] = appDec;
    data['app_type'] = appType;
    data['status'] = status;
    data['banner'] = banner;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['banners'] = banners;
    if (themes != null)
      data['themes'] = themes!.map((v) => v.toJson()).toList();
    return data;
  }
}

class AppTheme {
  int? id;
  String? name;
  String? status;
  String? startDate;
  String? endDate;
  List<ColorCode>? colorCodes;

  AppTheme({
    this.id,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.colorCodes,
  });

  AppTheme.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    if (json['colorCodes'] != null) {
      colorCodes = <ColorCode>[];
      json['colorCodes'].forEach((v) => colorCodes!.add(ColorCode.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'colorCodes': colorCodes?.map((v) => v.toJson()).toList(),
      };
}

class ColorCode {
  int? id;
  String? colorName;
  String? colorCode;
  String? colorGradient;
  String? colorType;
  String? status;
  String? createdAt;
  String? updatedAt;

  ColorCode({
    this.id,
    this.colorName,
    this.colorCode,
    this.colorGradient,
    this.colorType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ColorCode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    colorName = json['color_name'];
    colorCode = json['color_code'];
    colorGradient = json['color_gradient']?.toString();
    colorType = json['color_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'color_name': colorName,
        'color_code': colorCode,
        'color_gradient': colorGradient,
        'color_type': colorType,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
