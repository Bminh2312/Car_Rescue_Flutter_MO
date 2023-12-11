import 'dart:convert';
import 'dart:io';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ReportScreen extends StatefulWidget {
  final String orderId;

  ReportScreen({required this.orderId});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String reportText = '';
  String content = '';
  DateTime createdAt = DateTime.now();
  String status = '';
  File? imageFile;
  File? image2File;
  String reportTextError = '';
  String image1Error = '';
  String image2Error = '';
  String contentError = '';
  bool isSubmitting = false;
  Future<void> _getImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        if (imageIndex == 1) {
          imageFile = File(pickedFile.path);
        } else {
          image2File = File(pickedFile.path);
        }
      }
    });
  }

  Future<void> createReport(
    String orderId,
    String content,
    File imageFile,
    File image2File,
  ) async {
    try {
      if (imageFile == null || image2File == null) {
        // Handle case where images are not selected
        print('Please select both images');
        return;
      }
      // Upload images to Firebase and get download URLs
      String? imageUrl =
          await AuthService().uploadImageToFirebase(imageFile, 'images');
      String? image2Url =
          await AuthService().uploadImageToFirebase(image2File, 'images');

      final apiUrl =
          'https://rescuecapstoneapi.azurewebsites.net/api/Report/Create'; // Replace with your actual API endpoint
      final uuid = Uuid();

      final Map<String, dynamic> requestBody = {
        "id": uuid.v4(),
        "orderId": orderId,
        "content": content,
        "createdAt": DateTime.now().toUtc().toIso8601String(),
        "status": "NEW",
        "image": imageUrl,
        "image2": image2Url,
      };

      print(requestBody);

      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers if needed
        },
      );

      if (response.statusCode == 200) {
        // Report created successfully
        print('Report created successfully');
      } else {
        // Handle error if needed
        print('Error creating report - Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error creating report: $error');
    }
  }

  Future<void> _onSubmitReport() async {
    setState(() {
      // Set loading state
      isSubmitting = true;

      if (reportText.isEmpty) {
        reportTextError = 'Vui lòng nhập mô tả sự cố'; // Set error message
      } else {
        reportTextError = ''; // Clear error if text is not empty
      }

      if (imageFile == null) {
        image1Error = 'Vui lòng chọn hình ảnh '; // Set error message
      } else {
        image1Error = ''; // Clear error if image is selected
      }

      if (image2File == null) {
        image2Error = 'Vui lòng chọn hình ảnh '; // Set error message
      } else {
        image2Error = ''; // Clear error if image is selected
      }
    });

    try {
      print('Attempting to create report...');
      await createReport(widget.orderId, reportText, imageFile ?? File(''),
          image2File ?? File(''));

      print('Report created successfully!');

      // Hide loading indicator
      setState(() {
        isSubmitting = false;
      });

      // Pop the current screen
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Thành công'),
            content: Text(
              'Hệ thống đã tiếp nhận báo cáo của bạn\nChúng tôi sẽ giải quyết vấn đề trong thời gian sớm nhất',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Hide loading indicator on error
      setState(() {
        isSubmitting = false;
      });

      print('Error creating report: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, text: 'Báo cáo sự cố', showText: true),
        body: isSubmitting
            ? LoadingState()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'Đơn hàng ${widget.orderId}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mô tả sự cố',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        maxLines: 5,
                        onChanged: (value) {
                          setState(() {
                            reportText = value;
                            reportTextError = '';
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả sự cố...',
                          border: OutlineInputBorder(),
                          errorText: reportTextError.isNotEmpty
                              ? reportTextError
                              : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomText(
                        text: 'Hình ảnh sự cố',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildImageFrame(imageFile, image1Error),
                          _buildImageFrame(image2File, image2Error),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageButton(1, Icons.photo, "gallery"),
                          _buildImageButton(1, Icons.camera_alt, "camera"),
                          SizedBox(width: 1),
                          _buildImageButton(2, Icons.photo, "gallery"),
                          _buildImageButton(2, Icons.camera_alt, "camera"),
                        ],
                      ),
                      SizedBox(height: 100),
                      Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _onSubmitReport();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: FrontendConfigs
                                  .kActiveColor, // Background color
                              onPrimary: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12), // Button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Button border radius
                              ),
                              textStyle: TextStyle(
                                fontSize: 18, // Text font size
                                fontWeight: FontWeight.bold, // Text font weight
                              ),
                            ),
                            child: Text('Báo cáo'),
                          )),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildImageFrame(File? imageFile, String error) {
    return Column(
      children: [
        Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      imageFile,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container()),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildImageButton(int imageIndex, IconData icon, String action) {
    return GestureDetector(
      onTap: () {
        _getImage(action == "camera" ? ImageSource.camera : ImageSource.gallery,
            imageIndex);
      },
      child: Container(
        width: 40, // Adjust the width as needed
        height: 40, // Adjust the height as needed
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.3),
        ),
        child: Icon(icon),
      ),
    );
  }
}
