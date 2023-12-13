import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/wallet_transation.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/wallet/layout/widgets/wallet_statistics.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'widgets/debit_card.dart';
import 'widgets/wallet_driver_widget.dart';
import 'package:intl/intl.dart';

class WalletBody extends StatefulWidget {
  const WalletBody({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  Wallet? _wallet;
  List<WalletTransaction> walletTransactions = [];
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();
    loadWalletInfo(widget.userId);
  }

  @override
  void dispose() {
    // Clean up resources, cancel asynchronous operations, etc.
    super.dispose();
  }

  void reloadData() {
    loadWalletInfo(widget.userId);
    // Optionally, reload other necessary data
  }

  Future<void> loadWalletInfo(String userId) async {
    try {
      final Wallet walletInfoFromApi =
          await AuthService().getWalletInfo(widget.userId);
      setState(() {
        _wallet = walletInfoFromApi;
        isLoaded = true;
        // After obtaining currentWeek.id, call loadWeeklyShift with it
      });
      loadWalletTransaction(_wallet!.id);
    } catch (e) {
      // Handle any exceptions here, such as network errors or errors from getCurrentWeek()
      print('Error loading wallet info: $e');
      throw e; // Rethrow the exception if needed
    }
  }

  Future<void> loadWalletTransaction(String walletId) async {
    try {
      final List<WalletTransaction> walletTransactionsFromAPI =
          await AuthService().getWalletTransaction(walletId);

      // Sort the list by the latest date (assuming WorkShift has a date property)
      walletTransactionsFromAPI
          .sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Update the state variable with the sorted data
      setState(() {
        walletTransactions = walletTransactionsFromAPI;
        print(walletTransactions);
      });
    } catch (e) {
      // Handle the error or return an empty list based on your requirements
      print('Error loading wallet transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_wallet == null) {
      return Center(
        child: LoadingState(),
      );
    }
    if (walletTransactions.length < 2) {
      return LoadingState();
    }
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              WalletCardWidget(
                userId: widget.userId,
                wallet: _wallet!,
              ),
              const SizedBox(
                height: 18,
              ),
              WalletStatisticsCard(
                walletTrans: walletTransactions,
                wallet: _wallet!,
                onSuccessfulWithdrawal: reloadData,
              ),
              const SizedBox(
                height: 18,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Giao dịch gần đây',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return WalletTransactionScreen(
                                wallet: _wallet!,
                                transactions:
                                    walletTransactions); // Replace with your list of transactions
                          }));
                        },
                        icon: Icon(
                          CupertinoIcons.arrow_right_circle,
                          color: FrontendConfigs.kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Container(
                    color: Colors.white,
                    height: 350,
                    child: !isLoaded
                        ? Center(
                            child:
                                CircularProgressIndicator()) // Loading indicator
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              final walletTrans = walletTransactions[
                                  index % walletTransactions.length];
                              return Container(
                                padding: EdgeInsets.all(16),
                                child: WalletDriverWidget(
                                    name: '',
                                    details: 'details',
                                    type: walletTrans.type,
                                    createdAt: DateFormat('dd-MM-yyyy | hh:mm')
                                        .format(walletTrans.createdAt
                                            .toUtc()
                                            .add(Duration(hours: 14))),
                                    description: walletTrans.description,
                                    totalAmount: walletTrans.totalAmount,
                                    status: walletTrans.status,
                                    transactionAmount:
                                        walletTrans.transactionAmount),
                              );
                            },
                          ),
                  ),
                ],
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}
