import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Light grey background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Ensures that it doesn't take more space than needed
            children: [
              Icon(
                Icons.search,
                size: 50,
                color: Colors.grey[500], // Light grey icon
              ),
              SizedBox(height: 20),
              Text(
                "Không có đơn hàng",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700], // Dark grey text for contrast
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Bạn chưa có đơn hàng nào",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Medium grey text for contrast
                ),
              ),
            ],
          )),
    );
  }
}
