import 'package:flutter/services.dart';

class ZaloPayService {
  static const MethodChannel _channel =
      MethodChannel('com.example.zalopay/transaction');

  // Hàm gọi thanh toán ZaloPay
  Future<void> payWithZaloPay(String zaloToken) async {
    try {
      final result =
          await _channel.invokeMethod('payOrder', {"zaloToken": zaloToken});
      print("Payment result: $result");
    } on PlatformException catch (e) {
      print("Payment failed: ${e.message}");
    }
  }
}
