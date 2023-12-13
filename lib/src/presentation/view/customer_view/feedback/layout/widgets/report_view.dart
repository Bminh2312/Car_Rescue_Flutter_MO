import 'dart:convert';
import 'dart:io';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/rescue_vehicle_owner.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/customer_view/orders/orders_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ReportScreen extends StatefulWidget {
  final String orderId;
  final Technician? tech;
  final Vehicle? vehicle;
  ReportScreen({required this.orderId, this.tech, this.vehicle});

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
  String avaTech =
      'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431';
  bool isSubmitting = false;
  Technician? _tech;
  Vehicle? _vehicle;
  String? accessToken = GetStorage().read<String>("accessToken");
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
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
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
        image1Error = 'Vui lòng chọn ít nhất 1 hình ảnh '; // Set error message
      } else {
        image1Error = ''; // Clear error if image is selected
      }

      // if (image2File == null) {
      //   image2Error = 'Vui lòng chọn hình ảnh '; // Set error message
      // } else {
      //   image2Error = ''; // Clear error if image is selected
      // }
    });

    try {
      if (reportTextError.isEmpty && image1Error.isEmpty) {
        print('Attempting to create report...');
        await createReport(
            widget.orderId, reportText, imageFile!, image2File ?? File(''));
        print('Report created successfully!');

        // Hide loading indicator
        setState(() {
          isSubmitting = false;
        });

        // Pop the current screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => OrderView())));

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
      } else {
        // Hide loading indicator on validation error
        setState(() {
          isSubmitting = false;
        });
      }
    } catch (error) {
      // Handle other errors
      setState(() {
        isSubmitting = false;
      });
      print('Error creating report: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.tech != null) {
      avaTech = widget.tech!.avatar!;
    }

    if (widget.vehicle != null) {
      avaTech = widget.vehicle!.image!;
    }
    _tech = widget.tech;
    _vehicle = widget.vehicle;
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
                      Column(
                        children: [
                          CustomText(
                            text: 'Đơn hàng ${widget.orderId}',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(avaTech),
                                ),
                                SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_tech != null)
                                      Text(
                                        'Kĩ thuật viên',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (_vehicle != null)
                                      Text(
                                        'Cứu hộ',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    SizedBox(height: 8.0),
                                    if (_tech != null)
                                      Text(
                                        widget.tech!.fullname!,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (_vehicle != null) SizedBox(height: 8.0),
                                    Text(
                                      _vehicle!.manufacturer,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade300),
                                      child: Text(
                                        _vehicle!.licensePlate,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: FrontendConfigs.kAuthColor),
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      _vehicle!.type,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
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
