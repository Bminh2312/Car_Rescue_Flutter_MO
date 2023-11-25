import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/booking.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/service_detailed.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/elements/tooltip.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/widgets/vehicle_info.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/completed_booking/completed_booking_view.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/waiting_payment/waiting_payment.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/customer_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../models/payment.dart';

class BookingDetailsBody extends StatefulWidget {
  final String userId;
  final String accountId;
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final Function? updateTabCallback;
  final Function? reloadData;
  BookingDetailsBody(
    this.userId,
    this.accountId,
    this.booking,
    this.addressesDepart,
    this.subAddressesDepart,
    this.addressesDesti,
    this.subAddressesDesti,
    this.updateTabCallback,
    this.reloadData,
  );

  @override
  State<BookingDetailsBody> createState() => _BookingDetailsBodyState();
}

class _BookingDetailsBodyState extends State<BookingDetailsBody> {
  bool _isLoading = true;
  AuthService authService = AuthService();
  CustomerInfo? customerInfo;
  Vehicle? vehicleInfo;
  Payment? _payment;
  int desiredTabIndex = 0;
  List<String> _imageUrls = [];
  List<String> pickedImages = [];
  Booking? _currentBooking;
  ServiceData? serviceData;
  List<Map<String, dynamic>> orderDetails = [];
  num totalQuantity = 0;
  num totalAmount = 0;
  int total = 0;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  Future<void> _loadPayment(String orderId) async {
    try {
      Map<String, dynamic>? paymentInfo =
          await authService.fetchPayment(widget.booking.id);
      print(paymentInfo);
      // Assuming Payment.fromJson is a constructor that returns a Payment object
      Payment payment = Payment.fromJson(paymentInfo);
      print(payment);
      setState(() {
        _payment = payment;

        _isLoading = false;
      });
    } catch (e) {
      // Handle any potential errors, such as network issues
      print('Error loading payment: $e');
      // Optionally, set some state to show an error message in the UI
    }
  }

  Future<void> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        setState(() {
          orderDetails = List<Map<String, dynamic>>.from(responseData['data']);
          print(orderDetails);
        });
        fetchServiceNameAndQuantity(
            orderDetails[0]['serviceId']); // Get the first serviceId
      } else {
        throw Exception('API response does not contain a valid list of data.');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<Map<String, dynamic>> fetchServiceNameAndQuantity(
      String serviceId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Service/Get?id=$serviceId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = data['data'];
        final String name = responseData['name'];
        final int price = responseData['price'];
        final int quantity = orderDetails
            .firstWhere((order) => order['serviceId'] == serviceId)['quantity'];

        return {'name': name, 'quantity': quantity, 'price': price};
      }
    }
    throw Exception('Failed to load service name and quantity from API');
  }

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    fetchServiceData(widget.booking.id);
    // _calculateTotal(widget.booking.id);
    _loadCustomerInfo(widget.booking.customerId);
    _loadVehicleInfo(widget.booking.vehicleId ?? '');
    _loadImageUrls();

    _loadPayment(widget.booking.id);
  }

  // void calculateTotals() {
  //   int totalQuantity = 0;
  //   double totalAmount = 0.0;

  //   for (var order in orderDetails) {
  //     int quantity = order['quantity'] ?? 0; // Giả định 'quantity' là một int
  //     double total = double.tryParse(order['tOtal'].toString()) ??
  //         0.0; // Chuyển 'total' sang double

  //     totalQuantity += quantity;
  //     totalAmount += total;
  //   }

  //   // Cập nhật state với tổng số lượng và tổng giá trị
  //   setState(() {
  //     this.totalQuantity = totalQuantity;
  //     this.totalAmount = totalAmount;
  //   });
  // }

  // Future<List<Service>> _loadServicesOfCustomer(String orderId) async {
  //   try {
  //     final List<String> listId =
  //         await AuthService().getServiceIdInOrderDetails(orderId);
  //     if (listId.isNotEmpty) {
  //       final List<Service> listService =
  //           await AuthService().getServiceById(listId);

  //       return listService;
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     return [];
  //   }
  // }

  Future<void> _loadImageUrls() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final urls = await authService.fetchImageUrls(widget.booking.id);

      if (urls.isNotEmpty) {
        // If URLs are not empty, update the state with these URLs.
        setState(() {
          _imageUrls = urls;
        });
      } else {
        // If URLs are empty, you might want to update the state accordingly or show a message.
        print('No image URLs found');
      }
    } catch (e) {
      // Handle exception by showing an error or a message to the user.
      print('Failed to fetch image URLs: $e');
      // You might want to set _imageUrls to an empty list or handle the error state.
    } finally {
      // Stop loading whether the fetch was successful or not.
      setState(() {
        _isLoading = false;
      });
    }
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
    _updateLoadingStatus();
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
    _updateLoadingStatus();
  }

  void _updateLoadingStatus() {
    if (customerInfo != null && vehicleInfo != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Add the file path to your imageUrls list
      setState(() {
        _imageUrls.add(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _openImageDialog(
      BuildContext context, int index, List<String> allImages) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PhotoViewGallery.builder(
          itemCount: allImages.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: allImages[index].startsWith('http')
                  ? NetworkImage(allImages[index])
                  : allImages[index].startsWith('assets/')
                      ? AssetImage(allImages[index]) as ImageProvider<Object>
                      : FileImage(File(allImages[index])),
              minScale: PhotoViewComputedScale.contained * 0.1,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: const Color.fromARGB(0, 0, 0, 0),
          ),
          pageController: PageController(initialPage: index),
          onPageChanged: (int index) {
            // You can track page changes if you need to.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Image URLs (replace with your actual image URLs)

    if (_isLoading) {
      return LoadingState();
    }
    if (_isLoading)
      Opacity(
        opacity: 0.3,
        child: ModalBarrier(dismissible: false),
      );
    // Define a function to display the tapped image in a dialog

// ...
    Future<void> _refreshData() async {
      // reloadBookingsData();
    }

    return Scaffold(
        backgroundColor: FrontendConfigs.kBackgrColor,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      children: [
                        CustomText(
                          text: "Mã đơn hàng",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          text: " ${widget.booking.id}",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: CustomerInfoRow(
                    name: customerInfo?.fullname ?? '',
                    phone: customerInfo?.phone ?? 'Chưa thêm số điện thoại',
                    avatar: customerInfo?.avatar ?? '',
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: VehicleInfoRow(
                    manufacturer: vehicleInfo?.manufacturer ?? '',
                    type: vehicleInfo?.type ?? '',
                    licensePlate: vehicleInfo?.licensePlate ?? '',
                    image: vehicleInfo?.image ?? '',
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Thông tin đơn hàng'),
                      _buildInfoRow(
                          "Trạng thái",
                          BookingStatus(
                            status: _currentBooking?.status ?? '',
                            fontSize: 14,
                          )),
                      _buildInfoRow(
                          "Điểm đi",
                          Text(' ${widget.addressesDepart[widget.booking.id]}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15))),
                      _buildInfoRow(
                          "Điểm đến",
                          Text('${widget.addressesDesti[widget.booking.id]}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15))),
                      _buildInfoRow(
                          "Loại dịch vụ",
                          Text(widget.booking.rescueType,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15))),
                      _buildInfoRow(
                          "Ghi chú",
                          Container(
                            width: 250,
                            child: Text(
                              "${widget.booking.customerNote}",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines:
                                  4, // Set the maximum number of lines to 2
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      if (widget.booking.status.toUpperCase() == 'CANCELLED')
                        _buildInfoRow(
                            "Lí do hủy đơn",
                            Text(
                                widget.booking.cancellationReason ??
                                    'Không Cung Cấp Lí Do',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15))),
                      if (widget.booking.status.toUpperCase() == 'COMPLETED')
                        _buildInfoRow(
                          'Đánh giá',
                          Container(
                            child: RatingBar.builder(
                              itemSize: 19,
                              initialRating: widget.booking.rating ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                        ),
                      if (widget.booking.status.toUpperCase() == 'COMPLETED')
                        _buildInfoRow(
                            'Nội dung đánh giá',
                            Text(
                              widget.booking.note ?? 'Không có',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                    ],
                  ),
                ),

                // Image
                if (_imageUrls.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildImageSection(_imageUrls),
                      ],
                      // _buildInfoRow(
                      //     "Ghi chú NV",
                      //     Text(widget.booking.staffNote ?? '',
                      //         style: TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ),
                // _buildInfoRow("Lí do huỷ đơn", booking.cancellationReason),

                // Timing

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Thời gian'),
                      widget.booking.startTime != null
                          ? _buildInfoRow(
                              "Bắt đầu",
                              Text(
                                DateFormat('dd-MM-yyyy | HH:mm').format(widget
                                    .booking.startTime!
                                    .toUtc()
                                    .add(Duration(hours: 14))),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : Container(),
                      // Empty container when startTime is null
                      widget.booking.endTime != null
                          ? _buildInfoRow(
                              "Kết thúc ",
                              Text(
                                DateFormat('dd-MM-yyyy | HH:mm').format(
                                    _currentBooking!.endTime!
                                        .toUtc()
                                        .add(Duration(hours: 14))),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : Container(),
                      _buildInfoRow(
                        "Được tạo lúc",
                        Text(
                          DateFormat('dd-MM-yyyy | HH:mm').format(widget
                              .booking.createdAt!
                              .toUtc()
                              .add(Duration(hours: 14))),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: _buildSummarySection(),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 1),
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   color: Colors.white,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       _buildPaymentMethod(
                //         'Trả qua MoMo',
                //         NumberFormat('#,##0₫', 'vi_VN').format(totalAmount),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize
                    .min, // Quan trọng để đảm bảo Column không chiếm toàn bộ không gian
                children: [
                  if (widget.booking.status == 'ASSIGNED')
                    Container(
                      width: double.infinity,
                      child: SliderButton(
                        alignLabel: Alignment.center,
                        shimmer: true,
                        baseColor: Colors.white,
                        buttonSize: 45,
                        height: 60,
                        backgroundColor: FrontendConfigs.kActiveColor,
                        action: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          bool isSuccess =
                              await authService.startOrder(widget.booking.id);
                          if (isSuccess) {
                            setState(() {
                              _isLoading = false;
                            });
                            //
                            //Navigate back to the previous screen
                            widget.updateTabCallback!(2);

                            Navigator.pop(context,
                                'reload'); // This pops the `BookingDetailsBody` screen.

                            // Set the specific tab you want to navigate to
                          }
                        },
                        label: const Text(
                          "Bắt đầu",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
                      ),
                    )
                  else if (widget.booking.status == 'ASSIGNING')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green, // color for accept button
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              bool decision = true;
                              bool isSuccess = await authService.acceptOrder(
                                  widget.booking.id, decision);

                              if (isSuccess) {
                                setState(() {
                                  _isLoading = false;
                                });
                                widget.updateTabCallback!(1);

                                Navigator.pop(context,
                                    'reload'); // This pops the `BookingDetailsBody` screen.
                              }
                              // widget.updateTabCallback!(1);
                            },
                            child: Text(
                              "Đồng ý",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                            width:
                                2), // Optional: you can use this for a small gap between the buttons
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // color for cancel button
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              bool decision = false;
                              await authService.acceptOrder(
                                  widget.booking.id, decision);
                            },
                            child: Text(
                              "Hủy",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_currentBooking != null &&
                      _currentBooking?.status == 'INPROGRESS')
                    Container(
                      width: double.infinity,
                      child: SliderButton(
                        alignLabel: Alignment.center,
                        shimmer: true,
                        baseColor: Colors.white,
                        buttonSize: 45,
                        height: 60,
                        backgroundColor: FrontendConfigs.kActiveColor,
                        action: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          dynamic data = await authService
                              .endOrder(widget.booking.id); // Get the data

                          // Fetch the updated data and wait for it to complete
                          Booking updatedBooking = await authService
                              .fetchBookingById(widget.booking.id);

                          // Update the local state with the fetched booking details
                          setState(() {
                            _currentBooking = updatedBooking;
                            _isLoading = false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WaitingForPaymentScreen(
                                accountId: widget.accountId,
                                addressesDepart: widget.addressesDepart,
                                subAddressesDepart: widget.subAddressesDepart,
                                addressesDesti: widget.addressesDesti,
                                subAddressesDesti: widget.subAddressesDesti,
                                booking: widget.booking,
                                payment: _payment!,
                                userId: widget.userId,
                                data: data ??
                                    '', // Pass the retrieved data to WaitingForPaymentScreen
                              ),
                            ),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => BookingCompletedScreen(
                          //       widget.userId,
                          //       widget.accountId,
                          //       _currentBooking!,
                          //       widget.addressesDepart,
                          //       widget.subAddressesDepart,
                          //       widget.addressesDesti,
                          //       widget.subAddressesDesti,
                          //     ),
                          //   ),
                          // );
                        },
                        label: const Text(
                          "Kết thúc",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
                      ),
                    )
                ])));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: CustomText(
          text: title,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ));
  }

  Widget _buildImageSection(List<String> imageUrls) {
    final allImages = [...imageUrls, ...pickedImages];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Hình ảnh"),
        Container(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // fixed to 5 slots for images
            itemBuilder: (context, index) {
              // If there's an image at this index, show it
              if (index < allImages.length) {
                ImageProvider imageProvider;

                // Check if the image is an asset or a picked image

                if (allImages[index].startsWith('http')) {
                  imageProvider = NetworkImage(allImages[index]);
                } else if (allImages[index].startsWith('assets/')) {
                  imageProvider = AssetImage(allImages[index]);
                } else {
                  imageProvider = FileImage(File(allImages[index]));
                }

                // imageProvider = FileImage(File(allImages[index]));

                return Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      _openImageDialog(context, index, allImages);
                    },
                    child: Container(
                      width: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                );
              }

              // Otherwise, show an add button
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrderItemSection(),
        SizedBox(
          height: 8,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomText(
        //       text: 'Khoảng cách',
        //       fontSize: 16,
        //     ),
        //     Text(totalQuantity.toString(),
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        //   ],
        // ),
        // Divider(thickness: 1),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomText(
        //       text: 'Số lượng',
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //     ),
        //     Text(totalQuantity.toString(),
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        //   ],
        // ),
        // SizedBox(
        //   height: 8,
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomText(
        //       text: 'Tổng tiền',
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //     ),
        //     Text(currencyFormat.format(totalAmount),
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        //   ],
        // ),
        // _buildInfoRow(
        //   "Tổng cộng",
        //   Text(currencyFormat.format(totalAmount),
        //       style: TextStyle(fontWeight: FontWeight.bold)),
        // ),
      ],
    );
  }

  Widget _buildPaymentMethod(String title, String total) {
    String displayTitle;
    if (title == 'Banking') {
      displayTitle = 'Trả bằng chuyển khoản';
    } else if (title == 'Cash') {
      displayTitle = 'Tiền mặt';
    } else {
      displayTitle = 'Thanh toán';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomText(
                text: displayTitle,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              SizedBox(width: 10.0),
              if (displayTitle == 'Trả bằng chuyển khoản')
                Image.asset(
                  'assets/images/banking.png',
                  height: 25,
                  width: 25,
                )
              else if (displayTitle == 'Tiền mặt')
                Image.asset(
                  'assets/images/money.png', // Replace with your cash image asset
                  height: 25,
                  width: 25,
                )
              else
                Image.asset(
                  'assets/images/money.png', // Replace with your desired asset
                  height: 25,
                  width: 25,
                ),
            ],
          ),
          CustomText(
            text: total,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemSection() {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: 'Phí dịch vụ',
                      fontSize: 16,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message:
                          'Phí dịch vụ mặc định được tính 300.000đ mỗi đơn hàng\n\nTổng cộng = Phí dịch vụ + (Đơn giá x Khoảng cách) ',
                      textStyle: TextStyle(color: Colors.white),
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(5),
                      waitDuration: Duration(seconds: 1),
                      showDuration: Duration(seconds: 7),
                      child: Icon(Icons.info),
                    ),
                  ],
                ),
                CustomText(
                  text: '300.000đ',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: orderDetails.map((orderDetail) {
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchServiceNameAndQuantity(
                  orderDetail['serviceId']), // Fetch service name and quantity
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final name = snapshot.data?['name'] ?? 'Name not available';
                  final quantity = orderDetail['quantity'] ?? 0;
                  final price = snapshot.data?['price'] ?? 0;
                  final total = orderDetail['tOtal'] ?? 0.0;
                  // Accumulate the total quantity and total amount
                  totalQuantity = quantity as int;
                  totalAmount = total as int;
                  final formatter =
                      NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
                  final formattedTotal = formatter.format(price);

                  return Column(
                    children: [
                      _buildInfoRow(
                        '$name (Đơn giá/km) ',
                        Text(
                          '$formattedTotal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error fetching service name and quantity');
                } else {
                  return CircularProgressIndicator(); // Show a loading indicator
                }
              },
            );
          }).toList(),
        ),
        _buildInfoRow(
          'Khoảng cách',
          Text(
            '$totalQuantity km',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPaymentMethod(_payment?.method ?? '', ''),
            Text(currencyFormat.format(totalAmount),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    Widget value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.0), // Add spacing between label and value
          value
        ],
      ),
    );
  }
}
