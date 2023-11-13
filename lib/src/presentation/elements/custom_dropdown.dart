import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

class CustomDropdownField extends StatefulWidget {
  final String text;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;

  const CustomDropdownField({
    Key? key,
    required this.text,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownFieldState createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: DropdownButtonFormField<String>(
        value: widget.selectedValue,
        onChanged: widget.onChanged,
        items: widget.options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        decoration: InputDecoration(
          hintText: widget.text,
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          fillColor: FrontendConfigs.kAuthColor,
          filled: true,
        ),
      ),
    );
  }
}
