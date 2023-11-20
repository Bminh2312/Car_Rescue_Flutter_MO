import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/banking_info.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/models/wallet_transaction.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class WalletStatisticsCard extends StatefulWidget {
  final List<WalletTransaction> walletTrans;
  final Wallet wallet;
  const WalletStatisticsCard(
      {super.key, required this.walletTrans, required this.wallet});
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

  Future<void> createWithdrawRequest({
    required String walletId,
    required String bank,
    required String accountInfo,
    required int amount,
  }) async {
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Transaction/CreateWithdrawRequest";

    print("Submitting Withdraw Request with the following details:");
    print("Wallet ID: $walletId");
    print("Bank: $bank");
    print("Account Info: $accountInfo");
    print("Amount: $amount");
    try {
      final response = await http.post(
        Uri.parse('$apiUrl'), // Replace with your actual API endpoint
        headers: {
          "Content-Type": "application/json",
          // Add other headers if needed, like authorization headers
        },
        body: json.encode({
          "walletId": walletId,
          "bank": bank,
          "accountInfo": accountInfo,
          "amount": amount,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Successfully created the weekly shift
        print('Withdraw request created successfully.');
      } else {
        // Failed to create the weekly shift
        print('Failed to create the withdraw request: ${response.body}');
        throw Exception('Failed to create the withdraw request');
      }
    } catch (e) {
      // Handle any exceptions or errors
      print('Error creating withdraw request: $e');
      throw Exception('Error creating withdraw request: $e');
    }
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

  void _showWithdrawForm(Wallet wallet) {
    String? selectedBanking; // Variable to hold the selected booking name

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        bool isKeyboardOpen = keyboardHeight > 0;
        String? _dropdownError;
        void validateDropdown() {
          if (selectedBanking == null || selectedBanking!.isEmpty) {
            _dropdownError = 'Please select a bank';
          } else {
            _dropdownError = null;
          }
        }

        return StatefulBuilder(
          // Using StatefulBuilder
          builder: (BuildContext context, StateSetter setModalState) {
            return AnimatedContainer(
              duration: Duration(
                  milliseconds:
                      300), // Smooth transition when keyboard opens/closes
              padding: EdgeInsets.only(
                bottom: keyboardHeight, // Add padding equal to keyboard height
              ),
              height: isKeyboardOpen
                  ? MediaQuery.of(context)
                      .size
                      .height // Full screen height when keyboard is open
                  : null, // Default height when keyboard is closed
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: FrontendConfigs.kBackgrColor,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomText(
                          text: 'Phương thức thanh toán',
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: radioGroupValue == 'Ngân hàng'
                                  ? FrontendConfigs.kPrimaryColor
                                  : Color.fromARGB(0, 158, 158, 158),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(CupertinoIcons.creditcard, size: 25),
                                SizedBox(
                                  width: 12,
                                ),
                                CustomText(text: 'Ngân hàng', fontSize: 18),
                              ],
                            ),
                            leading: Radio<String>(
                              activeColor: FrontendConfigs.kPrimaryColor,
                              value: 'Ngân hàng',
                              groupValue: radioGroupValue,
                              onChanged: (String? value) {
                                setModalState(() {
                                  radioGroupValue = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Option B
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: radioGroupValue == 'Momo'
                                  ? FrontendConfigs.kPrimaryColor
                                  : Color.fromARGB(0, 158, 158, 158),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Image.asset(
                                  'assets/images/momo.png',
                                  width: 26,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  text: 'Momo',
                                  fontSize: 18,
                                ),
                              ],
                            ),
                            leading: Radio<String>(
                              activeColor: FrontendConfigs.kPrimaryColor,
                              value: 'Momo',
                              groupValue: radioGroupValue,
                              onChanged: (String? value) {
                                setModalState(() {
                                  radioGroupValue = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Ngân hàng')
                          CustomText(
                            text: 'Tên ngân hàng',
                            fontWeight: FontWeight.bold,
                          ),
                        if (radioGroupValue == 'Momo')
                          CustomText(
                            text: 'Số điện thoại',
                            fontWeight: FontWeight.bold,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Ngân hàng')
                          // DropdownButton to list booking names
                          DropdownButton<String>(
                            onChanged: (newValue) {
                              setModalState(() {
                                selectedBanking = newValue;
                                validateDropdown(); // Validate the dropdown selection
                                _dropdownError =
                                    null; // Clear error message on new selection
                              });
                            },
                            underline: Container(),
                            value: selectedBanking,
                            hint: Text("Chọn ngân hàng"),
                            items: bankings
                                .map<DropdownMenuItem<String>>((banking) {
                              return DropdownMenuItem<String>(
                                value: banking.shortName,
                                child: Row(
                                  children: [
                                    Image.network(banking.logo, width: 70),
                                    Text(banking.shortName),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        if (_dropdownError != null)
                          Text(
                            _dropdownError!,
                            style: TextStyle(color: Colors.red),
                          ),
                        if (radioGroupValue == 'Momo')
                          TextFormField(
                            onSaved: (value) => _phoneNumber = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hãy nhập số điện thoại';
                              }
                              // Additional phone number validation logic here
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nhập số điện thoại',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            cursorColor: FrontendConfigs.kPrimaryColor,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Momo' ||
                            radioGroupValue == 'Ngân hàng')
                          CustomText(
                            text: 'Tên tài khoản',
                            fontWeight: FontWeight.bold,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Momo' ||
                            radioGroupValue == 'Ngân hàng')
                          TextFormField(
                            onSaved: (value) => _accountName = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập tên tài khoản';
                              }
                              // Additional validation logic here
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nhập tên tài khoản',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            cursorColor: FrontendConfigs.kPrimaryColor,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Momo' ||
                            radioGroupValue == 'Ngân hàng')
                          CustomText(
                            text: 'Số tiền',
                            fontWeight: FontWeight.bold,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        if (radioGroupValue == 'Momo' ||
                            radioGroupValue == 'Ngân hàng')
                          TextFormField(
                            onSaved: (value) {
                              if (value != null && value.isNotEmpty) {
                                _amount = int.tryParse(
                                    value); // Convert the string to a double
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập số tiền';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number'; // Check if the value is a valid number
                              }
                              // Additional validation logic here
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nhập số tiền cần rút',
                            ),
                            keyboardType: TextInputType
                                .number, // Ensure numeric keyboard for amount input
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            cursorColor: FrontendConfigs.kPrimaryColor,
                          ),

                        if (radioGroupValue == 'Momo' ||
                            radioGroupValue == 'Ngân hàng')
                          Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          FrontendConfigs.kActiveColor),
                                  onPressed: () async {
                                    validateDropdown();
                                    if (_formKey.currentState!.validate() &&
                                        _dropdownError == null) {
                                      _formKey.currentState!
                                          .save(); // Save the form field values
                                      try {
                                        await createWithdrawRequest(
                                          walletId: widget.wallet.id,
                                          accountInfo: radioGroupValue == 'Momo'
                                              ? _phoneNumber!
                                              : _accountName!,
                                          bank: radioGroupValue == 'Momo'
                                              ? 'Momo'
                                              : selectedBanking!, // Set bank based on radioGroupValue
                                          amount: _amount!,
                                        );

                                        // Handle successful submission, e.g., show confirmation message
                                      } catch (e) {
                                        // Handle unsuccessful submission, e.g., show error message
                                        print(e);
                                      }
                                    }
                                  },
                                  child: Text('Rút tiền'))),

                        // ... other widgets if any
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
                  onPressed: () => _showWithdrawForm(widget.wallet),
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
          child: Text('No wallet transactions available'),
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
