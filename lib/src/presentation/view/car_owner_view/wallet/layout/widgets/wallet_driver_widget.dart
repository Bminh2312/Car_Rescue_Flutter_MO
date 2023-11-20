import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:intl/intl.dart';

class WalletDriverWidget extends StatelessWidget {
  const WalletDriverWidget({
    Key? key,
    required this.name,
    required this.details,
    required this.type,
    required this.description,
    required this.totalAmount,
    required this.status,
    required this.transactionAmount,
    required this.createdAt,
  }) : super(key: key);

  final String name;
  final String details;
  final String type;
  final String description;
  final String createdAt;
  final int totalAmount;
  final String status;
  final int transactionAmount;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Icon and text details
        Row(
          children: [
            Image.asset(
              type == 'Withdraw'
                  ? 'assets/icons/withdraw.png'
                  : 'assets/icons/deposit.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(
              width: 11,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  child: CustomText(
                    text: description,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                CustomText(
                  text: createdAt,
                  fontSize: 12,
                ),
                const SizedBox(
                  height: 3,
                ),
                CustomText(
                  text:
                      'Số dư ví: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount)}',
                  fontSize: 12,
                ),
              ],
            ),
          ],
        ),
        // Right side - Status and amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align to end of column
          children: [
            BookingStatus(
              status: status,
              fontSize: 12,
            ), // Status widget
            const SizedBox(height: 5),
            Container(
                child: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(transactionAmount),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 2, // Set the maximum number of lines to 2
              overflow: TextOverflow.ellipsis,
            )),
            // Include other widgets if needed
          ],
        ),
      ],
    );
  }
}
