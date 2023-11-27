// view/select_car_view.dart
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_car/layout/body.dart';
import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/home_view.dart';
  // Import the body

class SelectCarView extends StatefulWidget {
  final String rescueType;
  const SelectCarView({Key? key, required this.rescueType}) : super(key: key);

  @override
  _SelectCarViewState createState() => _SelectCarViewState();
}

class _SelectCarViewState extends State<SelectCarView> {
  String? _carId;
  NotifyMessage notifyMessage = NotifyMessage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: "Xe của bạn", showText: true),
      body: SelectCarBody(
        onCarSelected: (carId) {
          print("Selected car ID: $carId");
          setState(() {
            _carId = carId;
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 8,
            ),
            AppButton(
              onPressed: () {
                if(_carId != null){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeView(
                      rescueType: widget.rescueType,
                      carId: _carId!,
                    ),
                  ),
                );
                }else{
                  notifyMessage.showToast("Hãy chọn 1 xe.");
                }
                
              },
              btnLabel: 'Continue',
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
