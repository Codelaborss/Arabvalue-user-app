import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';

abstract class AuthServiceInterface {
  bool isSharedPrefNotificationActive();
  Future<ResponseModel> registration(SignUpBodyModel signUpBody);
  Future<ResponseModel> login(
      {required String emailOrPhone,
      required String password,
      required String loginType,
      required String fieldType,
      bool alreadyInApp = false});
  Future<ResponseModel> loginWithPin(
      {required String pinCode, bool alreadyInApp = false});
  Future<ResponseModel> otpLogin(
      {required String phone,
      required String otp,
      required String loginType,
      required String verified,
      bool alreadyInApp = false});
  Future<ResponseModel> updatePersonalInfo(
      {required String name,
      required String? phone,
      required String loginType,
      required String? email,
      required String? referCode,
      bool alreadyInApp = false});
  Future<ResponseModel> guestLogin();
  Future<ResponseModel> loginWithSocialMedia(SocialLogInBody socialLogInModel,
      {bool isCustomerVerificationOn = false});
  Future<void> updateToken();
  bool isLoggedIn();
  bool isGuestLoggedIn();
  String getSharedPrefGuestId();
  Future<bool> clearSharedData({bool removeToken = true});
  Future<bool> clearSharedAddress();
  Future<void> saveUserNumberAndPassword(
      String number, String password, String countryCode);
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();
  String getUserToken();
  Future updateZone();
  Future<bool> saveGuestContactNumber(String number);
  String getGuestContactNumber();
  Future<bool> saveDmTipIndex(String index);
  String getDmTipIndex();
  Future<bool> saveEarningPoint(String point);
  String getEarningPint();
  Future<void> setNotificationActive(bool isActive);
  Future<String?> saveDeviceToken();
  Future<void> saveFullLoginResponse(String responseData);
  Future<String> getFullLoginResponse();

  Future<void> saveClientData(String clientData);
  Future<String> getClientData();
  Future<void> saveClientAppData(String appData);
  Future<String> getClientAppData();
  Future<void> saveAppThemes(String themesJson);
  Future<String> getAppThemes();
  Future<void> clearAppThemes();
  Future<String> getAppLogo();
  Future<String> getAppLogoUrl();
  Future<void> saveClientAppThemes(
      String themesJson); // Client API theme (Priority 2)
  Future<String> getClientAppThemes();
  Future<void> clearClientAppThemes();
}
