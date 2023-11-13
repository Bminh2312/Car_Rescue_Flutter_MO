import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String filter;
  final bool isActive;
  final Function(String) onSelect;

  FilterButton(this.filter, this.isActive, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onSelect(filter);
      },
      style: ButtonStyle(
        backgroundColor: isActive
            ? MaterialStateProperty.all(Colors.blue) // Active background color
            : MaterialStateProperty.all(
                Colors.white), // Inactive background color
        foregroundColor: isActive
            ? MaterialStateProperty.all(Colors.white) // Active text color
            : MaterialStateProperty.all(Colors.black), // Inactive text color
      ),
      child: Text(
        filter,
        style: TextStyle(
          fontWeight:
              isActive ? FontWeight.bold : FontWeight.bold, // Bold when active
        ),
      ),
    );
  }
}
