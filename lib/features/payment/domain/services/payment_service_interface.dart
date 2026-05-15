import 'package:get/get.dart';
import 'package:sixam_mart/features/payment/domain/models/offline_method_model.dart';

abstract class PaymentServiceInterface {
  Future<List<OfflineMethodModel>?> getOfflineMethodList();
  Future<bool> saveOfflineInfo(String data);
  Future<bool> updateOfflineInfo(String data);
  Future<Response> submitCybersourcePayment(String token);
}
