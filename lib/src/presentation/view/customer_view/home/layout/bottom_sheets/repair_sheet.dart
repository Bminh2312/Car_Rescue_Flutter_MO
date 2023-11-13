import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/layout/home_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

TextEditingController paymentMethodController = TextEditingController();
TextEditingController customerNoteController = TextEditingController();
TextEditingController urlController = TextEditingController();
List<String> dropdownItems = ["Quận 1", "Quận 2", "Quận 3"];
String selectedDropdownItem = dropdownItems[0];
int selectedPaymentOption = 0;

Future<void> repairBottomSheet(BuildContext context, String location) {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 3,
                          width: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xffE0E0E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "Bảng sửa chữa chi tiết",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          text: "Giá",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Divider(
                      color: FrontendConfigs.kIconColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    HomeSelectionWidget(
                      icon: 'assets/svg/pickup_icon.svg',
                      title: 'Pick up Location',
                      body: '$location',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedDropdownItem,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDropdownItem = newValue!;
                        });
                      },
                      items: dropdownItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Khu vực hỗ trợ',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Hãy chọn một mục trong dropdown';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: 'Hình ảnh chứng thực (nếu có)',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: customerNoteController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Hãy ghi chú';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RadioListTile<int>(
                        title: Row(
                          children: [
                            Image.asset('assets/images/momo.png'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text("Trả bằng momo"),
                          ],
                        ),
                        value: 0,
                        groupValue: selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentOption = value!;
                          });
                        },
                        activeColor: Color(0xFF5BB85D)),
                    RadioListTile<int>(
                        title: Row(
                          children: [
                            Image.asset('assets/images/money.png'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text("Trả bằng tiền mặt"),
                          ],
                        ),
                        value: 1,
                        groupValue: selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentOption = value!;
                          });
                        },
                        activeColor: Color(0xFF5BB85D)),
                    const SizedBox(
                      height: 10,
                    ),
                    AppButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid, proceed with booking
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const SelectCarView(),
                          //   ),
                          // );
                        }
                      },
                      btnLabel: "Đặt cứu hộ",
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
