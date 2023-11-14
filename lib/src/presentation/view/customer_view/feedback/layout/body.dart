import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _noteController = TextEditingController();
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
                    color: Colors.white),
                child: Column(
                  children: [
                    _buildTechInfo(),
                    _buildRatingStars(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildFeedbackHints(),
              _buildFeedbackNoteField(),
              SizedBox(height: 20),
              _buildSendButton(),

              // SizedBox(height: 20),
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
          iconSize: 35,
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

  Widget _buildTechInfo() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: FrontendConfigs.kBackgrColor,
            radius: 40.0, // Adjust the size of the CircleAvatar
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: 'Tên KTV',
            fontSize: 18,
          ),
          SizedBox(
            height: 8,
          ),
          CustomText(
            text: 'SĐT',
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
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        hintText: "Hãy góp ý về dịch vụ",
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      child: Text('Gửi đánh giá'),
      style: ElevatedButton.styleFrom(
        primary: FrontendConfigs.kActiveColor, // Background color
        onPrimary: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
        minimumSize: Size(double.infinity, 36), // Button minimum size
      ),
      onPressed: () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => FeedbackScreen(),
        //   ),
        // );
      },
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
