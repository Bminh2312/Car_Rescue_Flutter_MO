import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/providers/feedback_order.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  String? techId;
  final String orderId;
  final String customerId;
  Vehicle? vehicleInfo;
   FeedbackScreen(
      {Key? key,
      this.vehicleInfo,
      this.techId,
      required this.orderId,
      required this.customerId})
      : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _rating = 0;
  Technician? technicianInfo;
  FeedBackProvider feedBackProvider = FeedBackProvider();
  final TextEditingController _noteController = TextEditingController();
  AuthService authService = AuthService();
  NotifyMessage notifyMessage = NotifyMessage();
  final List<String> _feedbackHints = [
    "Dịch vụ tốt",
    "Nhiệt tình",
    "Nhanh nhẹn",
    "Hài lòng",
    "Không hài lòng",
    "Mất nhiều thời gian",
    "Thái độ không tốt",
    "Đợi lâu"
    // Add more hints as needed
  ];
  final Set<String> _selectedHints = {};

  void _loadTechInfo(String techId) async {
    Map<String, dynamic>? techProfile =
        await authService.fetchTechProfile(techId);
    print('day la ${techProfile}');
    if (techProfile != null) {
      setState(() {
        technicianInfo = Technician.fromJson(techProfile);
      });
    } else {
      return technicianInfo = null;
    }
  }

  void _submitFeedback() async {
    try {
      if (_formKey.currentState!.validate()) {
        String feedbackId = await feedBackProvider.getWaitingFeedbacks(
            widget.customerId, widget.orderId);
        print(feedbackId);
        // Now you have feedbackId, you can use it for updating feedback
        bool isSuccess = await feedBackProvider.updateFeedback(
            feedbackId, _rating, _noteController.text);

        if (isSuccess) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavBarView(
                        page: 0,
                      )));
          notifyMessage.showToast("Đã gửi đánh giá.");
        } else {
          notifyMessage.showToast("Đã xảy ra lỗi hệ thống.");
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
    }
  }

  @override
  void initState() {
    print(widget.techId);
    if(widget.techId != null){
      _loadTechInfo(widget.techId!);
    }
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: FrontendConfigs.kBackgrColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              CustomText(
                text: 'Đánh giá',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                text: 'Hãy đánh giá trải nghiệm của bạn về kĩ thuật viên',
                fontSize: 18,
                color: Colors.black54,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    if(technicianInfo != null)
                    _buildTechInfo(technicianInfo),
                    if(widget.vehicleInfo != null)
                    _buildCarOwnerInfo(widget.vehicleInfo),
                    _buildRatingStars(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildFeedbackHints(),
              Expanded(flex: 3, child: _buildFeedbackNoteField()),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          iconSize: 25,
          icon: Icon(
            _rating > index ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildTechInfo(Technician? technicianInfo) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: FrontendConfigs.kBackgrColor,
            backgroundImage: NetworkImage(technicianInfo?.avatar ?? ''),
            radius: 30.0, // Điều chỉnh kích thước của CircleAvatar
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: technicianInfo?.fullname ?? '',
            fontSize: 18,
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: technicianInfo?.phone ?? '',
            fontSize: 18,
          )
        ],
      ),
    );
  }

  Widget _buildCarOwnerInfo(Vehicle? vehicleInfo) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: FrontendConfigs.kBackgrColor,
            backgroundImage: NetworkImage(vehicleInfo?.image ?? ''),
            radius: 40.0, // Điều chỉnh kích thước của CircleAvatar
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: vehicleInfo?.manufacturer ?? '',
            fontSize: 18,
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: vehicleInfo?.licensePlate ?? '',
            fontSize: 18,
          )
        ],
      ),
    );
  }

  Widget _buildFeedbackHints() {
    return Wrap(
      spacing: 8.0,
      children: _feedbackHints.map((hint) {
        return ChoiceChip(
          selectedColor: FrontendConfigs.kPrimaryColor,
          label: Text(hint),
          selected: _selectedHints.contains(hint),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedHints.add(hint);
              } else {
                _selectedHints.remove(hint);
              }
              _updateNoteControllerText();
            });
          },
        );
      }).toList(),
    );
  }

  void _updateNoteControllerText() {
    _noteController.text = _selectedHints.join(", ");
  }

  Widget _buildFeedbackNoteField() {
    return Container(
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: "Hãy góp ý về dịch vụ",
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập góp ý của bạn';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      child: Text('Gửi'),
      style: ElevatedButton.styleFrom(
        primary: FrontendConfigs.kActiveColor,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: Size(double.infinity, 36),
      ),
      onPressed: () {
        // Thực hiện logic gửi đánh giá
        _submitFeedback();
      },
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
