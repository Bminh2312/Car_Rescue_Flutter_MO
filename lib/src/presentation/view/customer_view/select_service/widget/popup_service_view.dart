import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:flutter/material.dart';

class OptionItem {
  final String imageAsset;
  final String title;
  final String description;

  OptionItem(
      {required this.imageAsset,
      required this.title,
      required this.description});
}

class PopupButton extends StatefulWidget {
  final Function(OptionItem) onConfirm;
  final Function(OptionItem) onOptionSelected; // Add this line
  PopupButton({required this.onConfirm, required this.onOptionSelected});
  @override
  _PopupButtonState createState() => _PopupButtonState();
}

class _PopupButtonState extends State<PopupButton> {
  int selectedOption = -1;
  List<OptionItem> options = [
    OptionItem(
      imageAsset: 'assets/images/towtruck-service2.png',
      title: 'Kéo xe cứu hộ',
      description:
          'Dịch vụ kéo xe chuyên nghiệp, an toàn và nhanh chóng, đảm bảo xe của bạn được bảo vệ tối đa',
    ),
    OptionItem(
      imageAsset: 'assets/images/tow-service.png',
      title: 'Cứu hộ tại chỗ',
      description:
          'Cung cấp giải pháp cứu hộ tận nơi, nhanh chóng khắc phục sự cố để bạn tiếp tục hành trình',
    ),
    OptionItem(
      imageAsset: 'assets/images/tow-service.png',
      title: 'Dịch vụ khác',
      description:
          'Dịch vụ đa dạng, từ bảo dưỡng xe định kỳ đến sửa chữa nhanh, phục vụ mọi nhu cầu của bạn.',
    ),
    // Thêm các lựa chọn khác theo cùng cách thức
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text('Chọn loại cứu hộ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: List.generate(
              options.length, (index) => buildOption(index, options[index])),
        ),
      ),
      actions: <Widget>[
        Divider(thickness: .5),
        Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedOption != -1) {
                  print("Confirm pressed with option: $selectedOption");
                  widget.onConfirm(options[selectedOption]);
                  widget.onOptionSelected(options[selectedOption]);
                }
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: FrontendConfigs.kActiveColor, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding
              ),
            )),
      ],
    );
  }

  Widget buildOption(int index, OptionItem item) {
    bool isSelected = index == selectedOption;
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = index;
          print("Selected option: $selectedOption");
        });
      },
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: isSelected
                ? Border.all(color: FrontendConfigs.kIconColor, width: 2)
                : Border.all(color: Color.fromARGB(24, 0, 0, 0)),
          ),
          child: Column(
            children: [
              Image.asset(
                item.imageAsset,
                height: 80,
                width: 80,
              ),
              Text(
                item.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(letterSpacing: .3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
