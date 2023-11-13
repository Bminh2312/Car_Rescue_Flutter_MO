import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletStatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            StatisticItem(
              label: 'Total Balance:',
              value: '\$1500.00', // Placeholder value
            ),
            SizedBox(height: 10),
            StatisticItem(
              label: 'Last Transaction:',
              value: '-\$30.00', // Placeholder value
            ),
            SizedBox(height: 10),
            StatisticItem(
              label: 'Total Transactions This Month:',
              value: '15', // Placeholder value
            ),
            SizedBox(height: 12), // Gap before the button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle Withdraw action
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // This ensures the column doesn't take more space than needed
                    children: [
                      Icon(CupertinoIcons.creditcard),
                      Text('Rút tiền'),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: FrontendConfigs.kIconColor,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;

  StatisticItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: (value.contains('-')) ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
}
