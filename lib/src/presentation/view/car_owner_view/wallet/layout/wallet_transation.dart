import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';

import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/widgets/wallet_driver_widget.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/wallet_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletTransactionScreen extends StatefulWidget {
  final List<WalletTransaction> transactions;
  final Wallet wallet;
  WalletTransactionScreen({required this.transactions, required this.wallet});

  @override
  State<WalletTransactionScreen> createState() =>
      _WalletTransactionScreenState();
}

class _WalletTransactionScreenState extends State<WalletTransactionScreen> {
  List<WalletTransaction>? filteredTransactions;
  TextEditingController searchController = TextEditingController();
  bool isSortedByStatus = false;
  @override
  void initState() {
    super.initState();
    filteredTransactions = widget.transactions;
  }

  void _searchTransaction(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredTransactions = widget.transactions
            .where((transaction) =>
                transaction.description
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                transaction.status.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredTransactions = widget.transactions;
      });
    }
  }

  void _filterTransactionsByStatus(String? selectedStatus) {
    if (selectedStatus == null) return;

    setState(() {
      filteredTransactions = widget.transactions
          .where((transaction) =>
              transaction.status.toUpperCase() == selectedStatus)
          .toList();
    });
  }

  void _showTransactionDetails(WalletTransaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _transactionDetailItem('ID:', transaction.id),
                _transactionDetailItem('Loại:', transaction.type),
                _transactionDetailItem('Số tiền:',
                    '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.transactionAmount)}'),
                _transactionDetailItem(
                    'Thời gian:',
                    DateFormat('dd-MM-yyyy | HH:mm')
                        .format(transaction.createdAt)),
                _transactionDetailItem('Mô tả:', transaction.description),
                _transactionDetailItem('Số dư ví:',
                    '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.totalAmount)}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Trạng thái',
                    ),
                    BookingStatus(status: transaction.status, fontSize: 12)
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _transactionDetailItem(
    String title,
    String value,
  ) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: title,
            ),
            Container(
              width: 300,
              child: CustomText(
                text: value,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Lịch sử giao dịch",
          style: TextStyle(
            color: FrontendConfigs.kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Only show the sorting option button when data is loaded
          PopupMenuButton<String>(
            onSelected: _filterTransactionsByStatus,
            itemBuilder: (BuildContext context) {
              return [
                'COMPLETED',
                'NEW',
                'FAILD'
              ] // Replace with your actual statuses
                  .map((String status) => PopupMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList();
            },
            icon: Icon(
              Icons.filter_list,
              color: FrontendConfigs.kIconColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8), // Updated padding
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch', // Added hint text
                border: OutlineInputBorder(
                  // Added border
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: searchController.text.isEmpty
                    ? Icon(Icons.search) // Search icon
                    : IconButton(
                        icon: Icon(Icons.clear), // Clear text icon
                        onPressed: () {
                          searchController.clear(); // Clear text field
                          _searchTransaction(''); // Reset search/filter
                        },
                      ),
              ),
              onChanged: _searchTransaction,
            ),
          ),
          Expanded(
            child: filteredTransactions!.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredTransactions!.length,
                    itemBuilder: (context, index) {
                      WalletTransaction transaction =
                          filteredTransactions![index];
                      return InkWell(
                        onTap: () => _showTransactionDetails(transaction),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Column(
                            children: [
                              WalletDriverWidget(
                                  name: '',
                                  details: 'details',
                                  type: transaction.type,
                                  createdAt: DateFormat('dd-MM-yyyy | hh:mm')
                                      .format(transaction.createdAt
                                          .toUtc()
                                          .add(Duration(hours: 14))),
                                  description: transaction.description,
                                  totalAmount: transaction.totalAmount,
                                  status: transaction.status,
                                  transactionAmount:
                                      transaction.transactionAmount),
                              Divider(),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/transaction.png'),
                      Text(
                        'Không có giao dịch.',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  )),
          ),
        ],
      ),
    );
  }
}
