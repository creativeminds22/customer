// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:http/http.dart' as http;

class SendNotification {
  static sendOneNotification({required String token, required String title, required String body, required Map<String, dynamic> payload}) async {
    http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constant.serverKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': token
        },
      ),
    );
    log(response.body);
  }

  static sendMultiPleNotification({required List<dynamic> tokens, required String title, required String body, Map<String, dynamic>? payload}) async {
    http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constant.serverKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': tokens.join(",")
        },
      ),
    );
    log(response.body);
  }
}
