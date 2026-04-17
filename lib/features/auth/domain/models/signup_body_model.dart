class SignUpBodyModel {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? password;
  String? refCode;
  String? deviceToken;
  int? guestId;
  String? name;
  String? refId;

  SignUpBodyModel({
    this.fName,
    this.lName,
    this.phone,
    this.email = '',
    this.password,
    this.refCode = '',
    this.deviceToken, 
    this.guestId,
    this.name,
    this.refId,
  });

  SignUpBodyModel.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    refCode = json['ref_code'];
    deviceToken = json['cm_firebase_token'];
    guestId = json['guest_id'];
    name = json['name'];
    refId = json['ref_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['password'] = password;
    data['ref_code'] = refCode;
    data['cm_firebase_token'] = deviceToken;
    data['guest_id'] = guestId;
    data['name'] = name;
    if (refId != null && refId!.isNotEmpty) {
      data['ref_id'] = refId;
    }
    return data;
  }
}
