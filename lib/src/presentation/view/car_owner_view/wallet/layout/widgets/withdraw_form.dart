import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/banking_info.dart';
import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import the intl package

class WithdrawFormScreen extends StatefulWidget {
  final Wallet wallet;

  WithdrawFormScreen({Key? key, required this.wallet}) : super(key: key);

  @override
  _WithdrawFormScreenState createState() => _WithdrawFormScreenState();
}

class _WithdrawFormScreenState extends State<WithdrawFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedBanking;
  String? _phoneNumber;
  String? _accountName;
  int? _amount;
  String? _dropdownError;
  String? radioGroupValue;
  String? _bankNumber;
  String? accessToken = GetStorage().read<String>("accessToken");
  List<BankingInfo> bankings =
      []; // Make sure to fetch or pass this data as required
  TextEditingController _amountController = TextEditingController();
  final NumberFormat numberFormat = NumberFormat("#,##0");
  void handleSubmit() {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save(); // Ensure that other form fields are saved

      // Use the controller's value directly, ensuring it's formatted correctly
      String amountText = _amountController.text.replaceAll(',', '');
      final numericValue = int.tryParse(amountText) ?? 0;

      // Now numericValue should have the correct value, and you can use it in your create function
      createWithdrawRequest(
        walletId: widget.wallet.id,
        accountInfo: radioGroupValue == 'Momo'
            ? _phoneNumber!
            : _accountName! + _bankNumber!,
        bank: radioGroupValue == 'Momo' ? 'Momo' : _selectedBanking!,
        amount: numericValue,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadBankingInfo();
    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _formatAmount() {
    if (_amountController.text.isEmpty) return;

    String text = _amountController.text;
    text = text.replaceAll(',', ''); // Remove existing commas
    final numericValue = int.tryParse(text) ?? 0;

    final formattedValue = NumberFormat("#,###", "en_US").format(numericValue);
    if (formattedValue != _amountController.text) {
      _amountController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tạo đơn thành công'),
          content: Text('Vui lòng chờ quản lí duyệt đơn.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Include the rest of the logic and UI from _showWithdrawForm here
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
        Uri.parse('$apiUrl'),headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
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

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nhập số tiền';
    }

    final numericValue = int.tryParse(value.replaceAll(',', ''));

    if (numericValue == null || numericValue <= 0) {
      return 'Số tiền không hợp lệ';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Tạo đơn rút tiền', showText: true),
      body: Column(
        children: [
          Expanded(
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
                                ? FrontendConfigs.kActiveColor
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
                            activeColor: FrontendConfigs.kActiveColor,
                            value: 'Ngân hàng',
                            groupValue: radioGroupValue,
                            onChanged: (String? value) {
                              setState(() {
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
                                ? FrontendConfigs.kActiveColor
                                : Color.fromARGB(0, 158, 158, 158),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/images/logo-momo-png-1.png',
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
                            activeColor: FrontendConfigs.kActiveColor,
                            value: 'Momo',
                            groupValue: radioGroupValue,
                            onChanged: (String? value) {
                              setState(() {
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
                            setState(() {
                              _selectedBanking = newValue;
                              // Validate the dropdown selection
                              _dropdownError =
                                  null; // Clear error message on new selection
                            });
                          },
                          underline: Container(),
                          value: _selectedBanking,
                          hint: Text("Chọn ngân hàng"),
                          items:
                              bankings.map<DropdownMenuItem<String>>((banking) {
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
                            hintText: 'Nhập số điện thoại',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FrontendConfigs.kActiveColor,
                                  width:
                                      2.0), // Change the color and width to fit your needs
                            ),
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          cursorColor: FrontendConfigs.kActiveColor,
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (radioGroupValue == 'Ngân hàng')
                        CustomText(
                          text: 'Số tài khoản',
                          fontWeight: FontWeight.bold,
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (radioGroupValue == 'Ngân hàng')
                        TextFormField(
                          onSaved: (value) => _bankNumber = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nhập số tài khoản';
                            }
                            // Additional validation logic here
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập số tài khoản',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FrontendConfigs.kActiveColor,
                                  width:
                                      2.0), // Change the color and width to fit your needs
                            ),
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          cursorColor: FrontendConfigs.kActiveColor,
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
                            hintText: 'Nhập tên tài khoản',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FrontendConfigs.kActiveColor,
                                  width:
                                      2.0), // Change the color and width to fit your needs
                            ),
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          cursorColor: FrontendConfigs.kActiveColor,
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
                          controller: _amountController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                                10), // Limit the length if needed
                          ],
                          onSaved: (value) {
                            final numericValue = int.tryParse(value ?? '0');
                            setState(() {
                              _amount =
                                  numericValue; // Store the numeric value as an int
                            });
                          },
                          validator: _validateAmount,
                          decoration: InputDecoration(
                            hintText: 'Nhập số tiền cần rút',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          cursorColor: Colors.blue,
                        )

                      // ... other widgets if any
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (radioGroupValue == 'Momo' || radioGroupValue == 'Ngân hàng')
            Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: FrontendConfigs.kActiveColor),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _dropdownError == null) {
                        _formKey.currentState!
                            .save(); // Save the form field values
                        try {
                          handleSubmit();

                          Navigator.pop(context, 'success');

                          _showSuccessDialog();
                          // Handle successful submission, e.g., show confirmation message
                        } catch (e) {
                          // Handle unsuccessful submission, e.g., show error message
                          print(e);
                        }
                      }
                    },
                    child: Text('Rút tiền'))),
        ],
      ),
    );
  }
}
