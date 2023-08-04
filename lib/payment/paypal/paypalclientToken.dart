import 'dart:convert';

import 'package:customer/constant/constant.dart';
import 'package:customer/model/payment_model.dart';
import 'package:customer/payment/paypal/paypalClientTokenModel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PayPalClientTokenGen {
  static Future<PayPalClientTokenModel> paypalClientToken({required Paypal paypalSettingData}) async {
    const url = "${Constant.globalUrl}payments/paypalclientid";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isSandbox == false ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintreeMerchantid,
        "public_key": paypalSettingData.braintreePublickey,
        "private_key": paypalSettingData.braintreePrivatekey,
      },
    );
    debugPrint(response.body.toString());

    final data = jsonDecode(response.body);
    debugPrint(data.toString());

    return PayPalClientTokenModel.fromJson(data);
  }

  static paypalSettleAmount({required nonceFromTheClient, required amount, required deviceDataFromTheClient, required Paypal paypalSettingData}) async {
    const url = "${Constant.globalUrl}payments/paypaltransaction";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isSandbox == false ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintreeMerchantid,
        "public_key": paypalSettingData.braintreePublickey,
        "private_key": paypalSettingData.braintreePrivatekey,
        "nonceFromTheClient": nonceFromTheClient,
        "amount": amount,
        "deviceDataFromTheClient": deviceDataFromTheClient,
      },
    );

    final data = jsonDecode(response.body);

    return data; //PayPalClientSettleModel.fromJson(data);
  }
}
