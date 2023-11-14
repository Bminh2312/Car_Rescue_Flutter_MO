import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/layout/body.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatelessWidget {
  final String orderId;
  String? techId;
  OrderDetail({Key? key, required this.orderId,  this.techId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Đơn đặt xe', showText: true),
      body: OrderDetailBody(orderId: orderId, techId: techId!),
    );
  }
}