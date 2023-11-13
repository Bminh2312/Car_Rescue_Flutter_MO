import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'layout/body.dart';

class OrderView extends StatelessWidget {
  const OrderView({Key? key}) : super(key: key);

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
          "Đơn của tôi",
          style: TextStyle(
            color: FrontendConfigs.kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // if (!isLoading) // Only show the sorting option button when data is loaded
          //   IconButton(
          //     onPressed: () {
          //       setState(() {
          //         selectedSortingOption =
          //             selectedSortingOption == SortingOption.byName
          //                 ? SortingOption.defaultSort
          //                 : SortingOption.byName;
          //         // Toggle the sorting order
          //         isAscending = !isAscending;
          //       });
          //     },
          //     icon: Icon(
          //       Icons.sort_by_alpha,
          //       color: FrontendConfigs.kIconColor,
          //     ),
          //   ),
        ],
      ),
      body: OrderList(),
    );
  }
}
