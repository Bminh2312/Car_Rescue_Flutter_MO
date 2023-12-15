import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/banking_info.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/widgets/withdraw_form.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletStatisticsCard extends StatefulWidget {
  final List<WalletTransaction> walletTrans;
  final Wallet wallet;
  final Function onSuccessfulWithdrawal;
  const WalletStatisticsCard(
      {super.key,
      required this.walletTrans,
      required this.wallet,
      required this.onSuccessfulWithdrawal});
  @override
  State<WalletStatisticsCard> createState() => _WalletStatisticsCardState();
}

class _WalletStatisticsCardState extends State<WalletStatisticsCard> {
  List<BankingInfo> bankings = [];
  final _formKey = GlobalKey<FormState>();
  String? _dropdownError;
  String? _phoneNumber;
  String? _accountName;
  int? _amount;
  String? radioGroupValue;
  @override
  void initState() {
    super.initState();
    loadBankingInfo();
  }

  Future<void> loadBankingInfo() async {
    try {
      final List<BankingInfo> bankingInfoFromAPI =
          await AuthService().getBankingInfo();

      // Sort the list by the latest date (assuming WorkShift has a date property)

      // Update the state variable with the sorted data
      setState(() {
        bankings = bankingInfoFromAPI;
        print(bankings);
      });
    } catch (e) {
      // Handle the error or return an empty list based on your requirements
      print('Error loading banking info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.walletTrans.isNotEmpty) {
      widget.walletTrans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      var latestTransaction = widget.walletTrans.first;
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
                'Thống kê giao dịch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 10),

              StatisticItem(
                label: 'Tổng số dư ví:',
                value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(widget.wallet.total), // Placeholder value
              ),
              SizedBox(height: 10),
              StatisticItem(
                label: 'Giao dịch gần nhất:',
                value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(latestTransaction
                        .transactionAmount), // Placeholder value
              ),
              SizedBox(height: 10),
              StatisticItem(
                label: 'Tổng số giao dịch:',
                value:
                    widget.walletTrans.length.toString(), // Placeholder value
              ),
              SizedBox(height: 12), // Gap before the button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WithdrawFormScreen(wallet: widget.wallet)),
                    );

// Check the result here
                    if (result == 'success') {
                      widget.onSuccessfulWithdrawal();
                    }
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
    } else {
      // Handle the case when there are no transactions
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Không có giao dịch nào'),
        ),
      );
    }
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
