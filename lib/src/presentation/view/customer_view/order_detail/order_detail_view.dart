import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/layout/body.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatelessWidget {
  final String orderId;
  final String? techId;
  final bool? hasFailedStatus;
  OrderDetail(
      {Key? key,
      required this.orderId,
      this.techId,
      required this.hasFailedStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Chi tiết đơn hàng', showText: true),
      body: OrderDetailBody(
          orderId: orderId,
          techId: techId!,
          hasFailedStatus: hasFailedStatus ?? false),
    );
  }
}
