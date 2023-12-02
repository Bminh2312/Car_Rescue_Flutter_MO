import 'dart:convert';
import 'dart:io';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
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
    if (reportText.isNotEmpty && imageFile != null && image2File != null) {
      // Assuming you have createReport in a separate file named `your_report_file.dart`
      await createReport(widget.orderId, reportText, imageFile!, image2File!);

      // Optionally, you can show a success message or navigate to another screen
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Thành công'),
            content: Text(
                'Cảm ơn bạn đã gửi báo cáo.\nHệ thống đã tiếp nhận và giải quyết cho bạn trong thời gian sớm nhất'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Optionally, navigate to another screen
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, text: 'Báo cáo sự cố', showText: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Đơn hàng ${widget.orderId}',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 16),
            Text(
              'Mô tả sự cố:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: 5,
              onChanged: (value) {
                setState(() {
                  reportText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Nhập mô tả sự cố...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _getImage(ImageSource.gallery, 1);
                  },
                  icon: Icon(Icons.photo),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _getImage(ImageSource.camera, 1);
                  },
                  icon: Icon(Icons.camera_alt),
                ),
                SizedBox(width: 16),
                if (imageFile != null) Image.file(imageFile!, height: 100),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _getImage(ImageSource.gallery, 2);
                  },
                  icon: Icon(Icons.photo),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _getImage(ImageSource.camera, 2);
                  },
                  icon: Icon(Icons.camera_alt),
                ),
                SizedBox(width: 16),
                if (image2File != null) Image.file(image2File!, height: 100),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _onSubmitReport();
                if (reportText.isNotEmpty) {
                  // Update other fields based on your logic
                  // ...
                }
              },
              child: Text('Báo cáo'),
            ),
          ],
        ),
      ),
    );
  }
}
