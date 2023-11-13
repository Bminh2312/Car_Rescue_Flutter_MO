import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class ServiceCategoryWidget extends StatelessWidget {
  final String category;

  const ServiceCategoryWidget({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              getCategoryIcon(),
              size: 20,
            ),
            SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
                onPressed: () {},
                child: Text('Yêu cầu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrontendConfigs.kIconColor,
                )) // Background color
          ],
        ),
      ),
    );
  }

  IconData getCategoryIcon() {
    switch (category) {
      case 'Đổ xăng':
        return Icons.battery_charging_full;
      case 'Thay bánh xe':
        return Icons.build;
      case 'Bơm bánh xe':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}
