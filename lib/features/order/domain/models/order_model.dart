import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'dart:convert';

class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset =
        (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
            ? int.parse(json['offset'].toString())
            : null;
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderModel {
  int? id;
  int? userId;
  String? qrCode;
  double? orderAmount;
  double? couponDiscountAmount;
  String? couponDiscountTitle;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? couponCode;
  String? orderNote;
  String? orderType;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  int? scheduled;
  double? storeDiscountAmount;
  String? failed;
  int? detailsCount;
  List<String?>? orderAttachmentFullUrl;
  String? chargePayer;
  String? moduleType;
  DeliveryMan? deliveryMan;
  Store? store;
  AddressModel? deliveryAddress;
  AddressModel? receiverDetails;
  ParcelCategoryModel? parcelCategory;
  double? dmTips;
  String? refundCancellationNote;
  String? refundCustomerNote;
  Refund? refund;
  bool? prescriptionOrder;
  bool? taxStatus;
  String? cancellationReason;
  int? processingTime;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  double? taxPercentage;
  double? additionalCharge;
  double? partiallyPaidAmount;
  List<Payments>? payments;
  List<String>? orderProofFullUrl;
  OfflinePayment? offlinePayment;
  double? flashAdminDiscountAmount;
  double? flashStoreDiscountAmount;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  String? voucherType;
  double? discountAmount;
  double? totalOrderAmount;
  String? offerType;
  List<Item>? voucherItems;
  List<OrderDetailsModel>? details;
  GiftDetails? giftDetails;
  List<HowItWorks>? voucherUsageTerms;
  VoucherSettings? voucherSettings;

  OrderModel({
    this.id,
    this.userId,
    this.qrCode,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.couponCode,
    this.orderNote,
    this.orderType,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.scheduled,
    this.storeDiscountAmount,
    this.failed,
    this.detailsCount,
    this.chargePayer,
    this.moduleType,
    this.deliveryMan,
    this.deliveryAddress,
    this.receiverDetails,
    this.parcelCategory,
    this.store,
    this.orderAttachmentFullUrl,
    this.dmTips,
    this.refundCancellationNote,
    this.refundCustomerNote,
    this.refund,
    this.prescriptionOrder,
    this.taxStatus,
    this.cancellationReason,
    this.processingTime,
    this.cutlery,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.taxPercentage,
    this.additionalCharge,
    this.partiallyPaidAmount,
    this.payments,
    this.orderProofFullUrl,
    this.offlinePayment,
    this.flashAdminDiscountAmount,
    this.flashStoreDiscountAmount,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.voucherType,
    this.discountAmount,
    this.totalOrderAmount,
    this.offerType,
    this.voucherItems,
    this.details,
    this.giftDetails,
    this.voucherUsageTerms,
    this.voucherSettings,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    qrCode = json['qr_code']?.toString();
    orderAmount = json['order_amount'] != null
        ? double.parse(json['order_amount'].toString())
        : 0;
    couponDiscountAmount = json['coupon_discount_amount'] != null
        ? double.parse(json['coupon_discount_amount'].toString())
        : 0;
    couponDiscountTitle = json['coupon_discount_title'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = json['total_tax_amount'] != null
        ? double.parse(json['total_tax_amount'].toString())
        : 0;
    paymentMethod = json['payment_method'];
    couponCode = json['coupon_code'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge'] != null
        ? double.parse(json['delivery_charge'].toString())
        : 0;
    scheduleAt = json['schedule_at'];
    otp = json['otp'];
    pending = json['pending'];
    accepted = json['accepted'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    refundRequested = json['refund_requested'];
    refunded = json['refunded'];
    scheduled = json['scheduled'];
    storeDiscountAmount = json['store_discount_amount'] != null
        ? double.parse(json['store_discount_amount'].toString())
        : 0;
    failed = json['failed'];
    detailsCount = json['details_count'];
    if (json['order_attachment_full_url'] != null) {
      orderAttachmentFullUrl = [];
      json['order_attachment_full_url'].forEach((v) {
        orderAttachmentFullUrl!.add(v);
      });
    }
    chargePayer = json['charge_payer'];
    moduleType = json['module_type'];
    deliveryMan = json['delivery_man'] != null
        ? DeliveryMan.fromJson(json['delivery_man'])
        : null;
    store = json['store'] != null ? Store.fromJson(json['store']) : null;
    deliveryAddress = json['delivery_address'] != null
        ? AddressModel.fromJson(json['delivery_address'])
        : null;
    receiverDetails = json['receiver_details'] != null
        ? AddressModel.fromJson(json['receiver_details'])
        : null;
    parcelCategory = json['parcel_category'] != null
        ? ParcelCategoryModel.fromJson(json['parcel_category'])
        : null;
    dmTips =
        json['dm_tips'] != null ? double.parse(json['dm_tips'].toString()) : 0;
    refundCancellationNote = json['refund_cancellation_note'];
    refundCustomerNote = json['refund_customer_note'];
    refund = json['refund'] != null ? Refund.fromJson(json['refund']) : null;
    prescriptionOrder = json['prescription_order'];
    taxStatus = json['tax_status'] == 'included' ? true : false;
    cancellationReason = json['cancellation_reason'];
    processingTime = json['processing_time'];
    cutlery = json['cutlery'];
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    taxPercentage = json['tax_percentage']?.toDouble();
    additionalCharge = json['additional_charge']?.toDouble() ?? 0;
    if (json['partially_paid_amount'] != null) {
      partiallyPaidAmount =
          double.parse(json['partially_paid_amount'].toString());
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
    if (json['order_proof_full_url'] != null) {
      orderProofFullUrl = [];
      json['order_proof_full_url'].forEach((v) {
        if (v != null) {
          orderProofFullUrl!.add(v.toString());
        }
      });
    }
    offlinePayment = json['offline_payment'] != null
        ? OfflinePayment.fromJson(json['offline_payment'])
        : null;
    flashAdminDiscountAmount = json['flash_admin_discount_amount']?.toDouble();
    flashStoreDiscountAmount = json['flash_store_discount_amount']?.toDouble();
    extraPackagingAmount = json['extra_packaging_amount']?.toDouble();
    referrerBonusAmount = json['ref_bonus_amount']?.toDouble();
    voucherType = json['voucher_type'];
    discountAmount = json['discount_amount'] != null
        ? double.parse(json['discount_amount'].toString())
        : 0;
    totalOrderAmount = json['total_order_amount'] != null
        ? double.parse(json['total_order_amount'].toString())
        : 0;
    offerType = json['offer_type'];
    if (json['voucher_items'] != null) {
      voucherItems = [];
      dynamic voucherData = json['voucher_items'];
      if (voucherData is String &&
          voucherData.isNotEmpty &&
          voucherData != 'null') {
        try {
          voucherData = jsonDecode(voucherData);
        } catch (e) {
          voucherData = [];
        }
      }
      if (voucherData is List) {
        for (var v in voucherData) {
          if (v is Map<String, dynamic>) {
            voucherItems!.add(Item.fromJson(v));
          }
        }
      }
    }
    if (json['details'] != null) {
      details = [];
      dynamic detailsData = json['details'];
      if (detailsData is String &&
          detailsData.isNotEmpty &&
          detailsData != 'null') {
        try {
          detailsData = jsonDecode(detailsData);
        } catch (e) {
          detailsData = [];
        }
      }
      if (detailsData is List) {
        for (var v in detailsData) {
          if (v is Map<String, dynamic>) {
            details!.add(OrderDetailsModel.fromJson(v));
          } else if (v is String && v.isNotEmpty && v != 'null') {
            try {
              details!.add(OrderDetailsModel.fromJson(jsonDecode(v)));
            } catch (e) {}
          }
        }
      }
    }
    if (json['gift_details'] != null) {
      dynamic giftData = json['gift_details'];
      if (giftData is String && giftData.isNotEmpty && giftData != 'null') {
        try {
          giftData = jsonDecode(giftData);
        } catch (e) {
          giftData = null;
        }
      }
      if (giftData is Map<String, dynamic>) {
        giftDetails = GiftDetails.fromJson(giftData);
      }
    }
    if (json['voucher_usage_term_and_conditions'] != null) {
      voucherUsageTerms = [];
      json['voucher_usage_term_and_conditions'].forEach((v) {
        voucherUsageTerms!.add(HowItWorks.fromJson(v));
      });
    }
    if (json['voucher_setting'] != null) {
      voucherSettings = VoucherSettings.fromJson(json['voucher_setting']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['qr_code'] = qrCode;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['coupon_code'] = couponCode;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    data['scheduled'] = scheduled;
    data['store_discount_amount'] = storeDiscountAmount;
    data['failed'] = failed;
    data['order_attachment_full_url'] = orderAttachmentFullUrl;
    data['charge_payer'] = chargePayer;
    data['module_type'] = moduleType;
    data['details_count'] = detailsCount;
    if (deliveryMan != null) {
      data['delivery_man'] = deliveryMan!.toJson();
    }
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    if (parcelCategory != null) {
      data['parcel_category'] = parcelCategory!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['refund_cancellation_note'] = refundCancellationNote;
    data['refund_customer_note'] = refundCustomerNote;
    if (deliveryAddress != null) {
      data['refund'] = refund!.toJson();
    }
    data['prescription_order'] = prescriptionOrder;
    data['processing_time'] = processingTime;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['additional_charge'] = additionalCharge;
    data['partially_paid_amount'] = partiallyPaidAmount;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['order_proof_full_url'] = orderProofFullUrl;
    if (offlinePayment != null) {
      data['offline_payment'] = offlinePayment!.toJson();
    }
    data['offline_payment'] = offlinePayment;
    data['flash_admin_discount_amount'] = flashAdminDiscountAmount;
    data['flash_store_discount_amount'] = flashStoreDiscountAmount;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    data['voucher_type'] = voucherType;
    data['discount_amount'] = discountAmount;
    data['total_order_amount'] = totalOrderAmount;
    data['offer_type'] = offerType;
    if (voucherItems != null) {
      data['voucher_items'] = voucherItems!.map((v) => v.toJson()).toList();
    }
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    if (giftDetails != null) {
      data['gift_details'] = giftDetails!.toJson();
    }
    if (voucherUsageTerms != null) {
      data['voucher_usage_term_and_conditions'] =
          voucherUsageTerms!.map((v) => v.toJson()).toList();
    }
    if (voucherSettings != null) {
      data['voucher_setting'] = voucherSettings!.toJson();
    }
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  int? zoneId;
  int? active;
  int? available;
  double? avgRating;
  int? ratingCount;
  String? lat;
  String? lng;
  String? location;

  DeliveryMan({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.zoneId,
    this.active,
    this.available,
    this.avgRating,
    this.ratingCount,
    this.lat,
    this.lng,
    this.location,
  });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    zoneId = json['zone_id'];
    active = json['active'];
    available = json['available'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count'];
    lat = json['lat'];
    lng = json['lng'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['available'] = available;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['lat'] = lat;
    data['lng'] = lng;
    data['location'] = location;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments(
      {this.id,
      this.orderId,
      this.amount,
      this.paymentStatus,
      this.paymentMethod,
      this.createdAt,
      this.updatedAt});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble();
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OfflinePayment {
  List<Input>? input;
  Data? data;
  List<MethodFields>? methodFields;

  OfflinePayment({this.input, this.data, this.methodFields});

  OfflinePayment.fromJson(Map<String, dynamic> json) {
    if (json['input'] != null) {
      input = <Input>[];
      json['input'].forEach((v) {
        input!.add(Input.fromJson(v));
      });
    }
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (input != null) {
      data['input'] = input!.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (methodFields != null) {
      data['method_fields'] = input!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Input {
  String? userInput;
  String? userData;

  Input({this.userInput, this.userData});

  Input.fromJson(Map<String, dynamic> json) {
    userInput = json['user_input'];
    userData = json['user_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_input'] = userInput;
    data['user_data'] = userData;
    return data;
  }
}

class Data {
  String? status;
  String? methodId;
  String? methodName;
  String? customerNote;

  Data({this.status, this.methodId, this.methodName, this.customerNote});

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    methodId = json['method_id'].toString();
    methodName = json['method_name'];
    customerNote = json['customer_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['method_id'] = methodId;
    data['method_name'] = methodName;
    data['customer_note'] = customerNote;
    return data;
  }
}

class MethodFields {
  String? inputName;
  String? inputData;

  MethodFields({this.inputName, this.inputData});

  MethodFields.fromJson(Map<String, dynamic> json) {
    inputName = json['input_name'];
    inputData = json['input_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_name'] = inputName;
    data['input_data'] = inputData;
    return data;
  }
}
