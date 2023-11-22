import 'package:CarRescue/src/models/wallet.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:intl/intl.dart';

class WalletCardWidget extends StatefulWidget {
  const WalletCardWidget({Key? key, required this.userId, required this.wallet})
      : super(key: key);
  final String userId;
  final Wallet wallet;
  
  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  String userName = '';
  void initState() {
    super.initState();
    // Call the function to fetch user data when the widget is initialized
    fetchUserProfileData();
  }

  void fetchUserProfileData() async {
    try {
      final userProfile =
          await AuthService().fetchRescueCarOwnerProfile(widget.userId);

      if (userProfile != null) {
        // Extract the 'data' map from the response
        final Map<String, dynamic> data = userProfile['data'];

        // Extract 'fullname' and 'phone' values from the 'data' map
        final String fullName = data['fullname'];

        // Check if the widget is still in the widget tree before calling setState
        if (mounted) {
          setState(() {
            userName = fullName;
          });
        }
      } else {
        // Handle the case where the userProfile is null
        // Set default values for userName and phoneNumber
      }
    } catch (e) {
      // Handle any exceptions that occur during the API request
      print('Error fetching user profile: $e');
      // You can set an error message or handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
    final formattedTotal = formatter.format(widget.wallet.total);
    return Container(
      width: 370,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(186, 46, 46, 46), // Starting color
            Colors.black, // Ending color
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số dư ví',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              Text(
                formattedTotal,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ],
          ),
          Image.asset(
            'assets/images/chip.png', // You'll need to replace this with the path to your chip icon
            width: 60,
            height: 60,
          ),
          // Text(
          //   '• • • •   • • • •   • • • •   2541',
          //   style: TextStyle(
          //       fontSize: 18,
          //       letterSpacing: 2,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.white),
          // ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    '03/18',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: [
                  Image(
                    image: AssetImage(
                        'assets/images/card_icon.png'), // Replace this with your card type
                    width: 60,
                    height: 30,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Mastercard',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
