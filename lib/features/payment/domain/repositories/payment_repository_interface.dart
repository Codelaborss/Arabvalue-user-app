import 'package:get/get.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class PaymentRepositoryInterface extends RepositoryInterface {
  Future<bool> saveOfflineInfo(String data);
  Future<bool> updateOfflineInfo(String data);
  Future<Response> submitCybersourcePayment(String token);
  Future<Response> deleteOrder(String paymentId);
}
