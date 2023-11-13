import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ... other necessary imports ...

void showRegisterShiftModal(BuildContext context, DateTime? _selectedDay,
    String? selectedShift, DateTime selectedDate, Function _selectDate) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 350,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'Đăng kí ca làm việc',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: FrontendConfigs.kAuthColor,
                  ),
                ),
              ],
            ),

            // DatePickerWidget(onDateSelected: (datetime) {}),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(CupertinoIcons.time),
                SizedBox(width: 10),
                Text(
                  'Chọn ca làm việc',
                  style: TextStyle(
                      fontSize: 18,
                      color: FrontendConfigs.kAuthColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ChoiceChip(
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        label: Text('08:00 - 16:00'),
                        selected: selectedShift == 'morning',
                        onSelected: (bool selected) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ChoiceChip(
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        label: Text('16:00 - 00:00'),
                        selected: selectedShift == 'morning',
                        onSelected: (bool selected) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ChoiceChip(
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        label: Text('00:00 - 08:00'),
                        selected: selectedShift == 'morning',
                        onSelected: (bool selected) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(CupertinoIcons.calendar),
                SizedBox(width: 10),
                Text(
                  'Chọn ngày làm việc',
                  style: TextStyle(
                      fontSize: 18,
                      color: FrontendConfigs.kAuthColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs.kActiveColor),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );

                    if (picked != null && picked != selectedDate) {
                      _selectDate(picked);
                      setState(() {});
                    }
                  },
                  child: Text('Chọn ngày'),
                )
              ],
            ),
            SizedBox(height: 20),
            // RegisteredShiftsTimeline(),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs.kActiveColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Xác nhận'),
                    onPressed: () {},
                  ),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

void setState(Null Function() param0) {}
