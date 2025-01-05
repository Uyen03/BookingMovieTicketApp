class OrderInfoModel {
  final String fullName;
  final String orderId;
  final String orderInfo;
  final double amount;

  OrderInfoModel({
    required this.fullName,
    required this.orderId,
    required this.orderInfo,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'order_id': orderId,
      'order_info': orderInfo,
      'amount': amount,
    };
  }
}
