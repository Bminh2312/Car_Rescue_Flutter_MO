// import 'dart:async';
// import 'package:flutter/material.dart';

// import 'package:CarRescue/src/configuration/frontend_configs.dart';
// import 'package:CarRescue/src/models/booking.dart';
// import 'package:CarRescue/src/models/customerInfo.dart';
// import 'package:CarRescue/src/models/vehicle_item.dart';
// import 'package:CarRescue/src/presentation/elements/booking_status.dart';
// import 'package:CarRescue/src/presentation/elements/custom_text.dart';
// import 'package:CarRescue/src/presentation/elements/slide_confirm_button.dart';
// import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/widgets/customer_info.dart';
// import 'package:CarRescue/src/utils/api.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/homepage/homepage_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:slider_button/slider_button.dart';

// class BookingCompletedBody extends StatefulWidget {
//   final Booking booking;
//   final Map<String, String> addressesDepart;
//   final Map<String, String> subAddressesDepart;
//   final Map<String, String> addressesDesti;
//   final Map<String, String> subAddressesDesti;
//   final Function onDataChange;
//   BookingCompletedBody(
//       this.booking,
//       this.addressesDepart,
//       this.subAddressesDepart,
//       this.addressesDesti,
//       this.subAddressesDesti,
//       this.onDataChange);

//   @override
//   State<BookingCompletedBody> createState() => _BookingCompletedBodyState();
// }

// class _BookingCompletedBodyState extends State<BookingCompletedBody> {
//   bool isLoading = true;
//   AuthService authService = AuthService();
//   CustomerInfo? customerInfo;
//   Vehicle? vehicleInfo;
//   Timer? _timer;
//   List<String> imageUrls = [
//     "assets/images/towtruck.png",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadCustomerInfo(widget.booking.customerId);
//     _loadVehicleInfo(widget.booking.vehicleId ?? '');
//   }

//   Future<void> _loadCustomerInfo(String customerId) async {
//     Map<String, dynamic>? userProfile =
//         await authService.fetchCustomerInfo(customerId);
//     print(userProfile);
//     if (userProfile != null) {
//       setState(() {
//         customerInfo = CustomerInfo.fromJson(userProfile);
//       });
//     }
//     _updateLoadingStatus();
//   }

//   Future<void> _loadVehicleInfo(String vehicleId) async {
//     try {
//       Vehicle? fetchedVehicleInfo =
//           await authService.fetchVehicleInfo(vehicleId);
//       print('Fetched vehicle: $fetchedVehicleInfo');

//       setState(() {
//         vehicleInfo = fetchedVehicleInfo;
//       });
//     } catch (e) {
//       print('Error loading vehicle info: $e');
//     }
//     _updateLoadingStatus();
//   }

//   void _updateLoadingStatus() {
//     if (customerInfo != null && vehicleInfo != null) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _addImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       // Add the file path to your imageUrls list
//       setState(() {
//         imageUrls.add(pickedFile.path);
//       });
//     } else {
//       print('No image selected.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Image URLs (replace with your actual image URLs)

//     if (isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }
//     if (isLoading)
//       Opacity(
//         opacity: 0.3,
//         child: ModalBarrier(dismissible: false),
//       );
//     // Define a function to display the tapped image in a dialog
//     void _showImageDialog(BuildContext context, String imageUrl) {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return Dialog(
//             child: Container(
//               width: 400, // Set the width of the dialog as needed
//               height: 400, // Set the height of the dialog as needed
//               child: Image.asset(
//                 imageUrl, // Display the tapped image
//                 fit: BoxFit.contain, // Fit the image to the dialog
//               ),
//             ),
//           );
//         },
//       );
//     }

// // ...

//     // Widget _buildImageSection(List<String> imageUrls) {
//     //   return Column(
//     //     crossAxisAlignment: CrossAxisAlignment.start,
//     //     children: [
//     //       _buildSectionTitle("Hình ảnh"),
//     //       Container(
//     //         height: 200.0,
//     //         child: ListView.builder(
//     //           scrollDirection: Axis.horizontal,
//     //           itemCount: 5, // fixed to 5 slots for images
//     //           itemBuilder: (context, index) {
//     //             // If there's an image at this index, show it
//     //             if (index < imageUrls.length) {
//     //               return Padding(
//     //                 padding: EdgeInsets.only(right: 16.0),
//     //                 child: InkWell(
//     //                   onTap: () {
//     //                     // Show the image in a dialog when tapped
//     //                     // _showImageDialog(context, imageUrls[index]);
//     //                   },
//     //                   child: Container(
//     //                     width: 200.0,
//     //                     decoration: BoxDecoration(
//     //                       image: DecorationImage(
//     //                         image: AssetImage(imageUrls[index]),
//     //                         fit: BoxFit.cover,
//     //                       ),
//     //                       borderRadius: BorderRadius.circular(12.0),
//     //                     ),
//     //                   ),
//     //                 ),
//     //               );
//     //             }
//     //             // Otherwise, show an add button
//     //             else {
//     //               return Padding(
//     //                 padding: EdgeInsets.only(right: 16.0),
//     //                 child: InkWell(
//     //                   onTap: _addImage,
//     //                   child: Container(
//     //                     width: 200.0,
//     //                     decoration: BoxDecoration(
//     //                       borderRadius: BorderRadius.circular(12.0),
//     //                       border: Border.all(color: Colors.grey),
//     //                     ),
//     //                     child: Center(
//     //                       child: Icon(Icons.add,
//     //                           size: 60.0, color: Colors.grey[400]),
//     //                     ),
//     //                   ),
//     //                 ),
//     //               );
//     //             }
//     //           },
//     //         ),
//     //       ),
//     //     ],
//     //   );
//     // }

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           // Header
//           Center(
//             child: CustomText(
//               text: "Mã đơn hàng: ${widget.booking.id}",
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Divider(thickness: 3),
//           // Increased spacing

//           // Booking Information

//           _buildSectionTitle("Thông tin khách hàng"),
//           CustomerInfoRow(
//             name: customerInfo?.fullname ?? '',
//             phone: customerInfo?.phone ?? 'Chưa thêm số điện thoại',
//           ),
//           Divider(thickness: 3),
//           _buildSectionTitle("Thông tin đơn hàng"),
//           _buildInfoRow(
//               "Trạng thái",
//               BookingStatus(
//                 status: widget.booking.status,
//               )),
//           _buildInfoRow(
//               "Điểm đi",
//               Text(' ${widget.addressesDepart[widget.booking.id]}',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow(
//               "Điểm đến",
//               Text('${widget.addressesDesti[widget.booking.id]}',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow(
//               "Loại xe",
//               Text(vehicleInfo!.type,
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow(
//               "Biển số xe",
//               Text(vehicleInfo!.licensePlate,
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow(
//               "Loại dịch vụ",
//               Text(widget.booking.rescueType,
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow(
//               "Ghi chú",
//               Text(widget.booking.customerNote,
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           Divider(thickness: 3),
//           SizedBox(height: 15.0),

//           // Image

//           // _buildImageSection(imageUrls),

//           // Additional Details
//           // You can replace this with the actual payment details

//           // Notes
//           _buildSectionTitle("Ghi chú của kĩ thuật viên"),
//           _buildInfoRow(
//               "Ghi chú",
//               Text(widget.booking.staffNote ?? '',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           // _buildInfoRow("Lí do huỷ đơn", booking.cancellationReason),
//           Divider(thickness: 3),
//           SizedBox(height: 8.0),

//           // Timing
//           _buildSectionTitle("Thời gian"),
//           _buildInfoRow(
//             "Bắt đầu",
//             Text(
//               DateFormat('yyyy-MM-dd HH:mm:ss')
//                   .format(widget.booking.startTime ?? DateTime.now()),
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           _buildInfoRow(
//             "Kết thúc ",
//             Text(
//               DateFormat('yyyy-MM-dd HH:mm:ss')
//                   .format(widget.booking.endTime ?? DateTime.now()),
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           _buildInfoRow(
//             "Được tạo lúc",
//             Text(
//               DateFormat('yyyy-MM-dd HH:mm:ss')
//                   .format(widget.booking.createdAt ?? DateTime.now()),
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),

//           SizedBox(height: 24.0),
//           Divider(thickness: 3),
//           SizedBox(height: 8.0),
//           _buildSectionTitle("Thanh toán"),
//           _buildInfoRow("Số lượng",
//               Text('2', style: TextStyle(fontWeight: FontWeight.bold))),
//           _buildInfoRow("Tổng cộng",
//               Text('2', style: TextStyle(fontWeight: FontWeight.bold))),
//           SizedBox(height: 24.0),
//           Divider(thickness: 3),
//           // Conditionally display the order item section
//           _buildOrderItemSection(),
//           // Action Buttons
//           SizedBox(height: 12.0),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16.0),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildAddImageSection() {
//     return Column(
//       children: [
//         _buildSectionTitle("Hình ảnh"),
//         Center(
//           child: Column(
//             children: [
//               Icon(Icons.camera_alt, size: 60.0, color: Colors.grey[400]),
//               TextButton(
//                 onPressed: _addImage,
//                 child: Text("Add Image"),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOrderItemSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionTitle("Đơn giá"), // Customize the section title
//         // Add order item details here
//         _buildInfoRow(
//             "Sửa bánh xe",
//             Text(
//               "\$200.00",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             )),
//         _buildInfoRow("Bơm bánh xe",
//             Text("\$5", style: TextStyle(fontWeight: FontWeight.bold))),
//         // Add more order item details as needed
//         Divider(thickness: 3),
//         if (widget.booking.status == 'ASSIGNING')
//           Container(
//             width: double.infinity,
//             child: SliderButton(
//               alignLabel: Alignment.center,
//               shimmer: true,
//               baseColor: Colors.white,
//               buttonSize: 45,
//               height: 60,
//               backgroundColor: FrontendConfigs.kActiveColor,
//               action: () {},
//               label: const Text(
//                 "Bắt đầu",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16),
//               ),
//               icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
//             ),
//           )
//         else if (widget.booking.status == 'INPROGRESS')
//           Container(
//             width: double.infinity,
//             child: SliderButton(
//               alignLabel: Alignment.center,
//               shimmer: true,
//               baseColor: Colors.white,
//               buttonSize: 45,
//               height: 60,
//               backgroundColor: FrontendConfigs.kActiveColor,
//               action: () async {
//                 final endResult = await authService.endOrder(widget.booking.id);
//                 if (endResult != null) {}
//               },
//               label: const Text(
//                 "Kết thúc",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16),
//               ),
//               icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
//             ),
//           )
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, Widget value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Flexible(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 16.0,
//               ),
//             ),
//           ),
//           SizedBox(width: 8.0), // Add spacing between label and value
//           value
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BookingCompletedScreen extends StatefulWidget {
  final String userId;
  final String accountId;
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  BookingCompletedScreen(
    this.userId,
    this.accountId,
    this.booking,
    this.addressesDepart,
    this.subAddressesDepart,
    this.addressesDesti,
    this.subAddressesDesti,
  );
  @override
  State<BookingCompletedScreen> createState() => _BookingCompletedScreenState();
}

class _BookingCompletedScreenState extends State<BookingCompletedScreen> {
  Booking? booking;
  AuthService authService = AuthService();
  CustomerInfo? customerInfo;
  Vehicle? vehicleInfo;
  void initState() {
    super.initState();
    booking = widget.booking;
    _loadCustomerInfo(widget.booking.customerId);
    _loadVehicleInfo(widget.booking.vehicleId ?? '');
  }

  Future<void> _loadCustomerInfo(String customerId) async {
    Map<String, dynamic>? userProfile =
        await authService.fetchCustomerInfo(customerId);
    print(userProfile);
    if (userProfile != null) {
      setState(() {
        customerInfo = CustomerInfo.fromJson(userProfile);
      });
    }
  }

  Future<void> _loadVehicleInfo(String vehicleId) async {
    try {
      Vehicle? fetchedVehicleInfo =
          await authService.fetchVehicleInfo(vehicleId);
      print('Fetched vehicle: $fetchedVehicleInfo');

      setState(() {
        vehicleInfo = fetchedVehicleInfo;
      });
    } catch (e) {
      print('Error loading vehicle info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrontendConfigs.kIconColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Checkmark Icon and Title
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset(
                        'assets/animations/Animation - 1698775742839.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill),
                    Text(
                      'Đơn đã hoàn thành',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Doctor's Details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(customerInfo?.avatar ?? ''),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerInfo?.fullname ?? '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(customerInfo?.phone ??
                                'Chưa thêm số điện thoại'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Location Details
                    ListTile(
                      title: Text(
                        'Điểm đến',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('${widget.addressesDepart[widget.booking.id]}'),
                    ),
                    // Date and Time
                    ListTile(
                      title: Text(
                        'Ngày',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd-MM-yyyy')
                            .format(widget.booking.endTime ?? DateTime.now()),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Thời gian',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat('HH:mm').format(
                              widget.booking.endTime ?? DateTime.now())),
                        ],
                      ),
                    ),
                    // Duration and Speciality
                    ListTile(
                      title: Text(
                        'Thời lượng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('20 phút'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Tổng cộng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('1.000.000Đ'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Bottom Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Xem chi tiết đơn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrontendConfigs.kActiveColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarView(
                            userId: widget.userId, accountId: widget.accountId),
                      ));
                },
                child: Text('Trang chủ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrontendConfigs.kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
