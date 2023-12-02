import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final bool isSelected;
  final Function(bool) onSelected;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool localSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0₫', 'vi_VN');

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: localSelected
              ? FrontendConfigs.kPrimaryColorCustomer
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(64, 158, 158, 158).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CheckboxListTile(
          title: Text(
            widget.service.name,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            currencyFormat.format(widget.service.price),
            style: TextStyle(
              color: FrontendConfigs.kAuthColor,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          value: localSelected,
          onChanged: (value) {
            print("Current isSelected: $value");
            setState(() {
              localSelected = value ?? false;
            });
            widget.onSelected(localSelected);
          },
        ),
      ),
    );
  }
}