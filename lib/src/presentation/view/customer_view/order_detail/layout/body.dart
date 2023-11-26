import 'dart:io';

import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/feedback_customer.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/feedback/layout/body.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/widget/customer_info.dart';
import 'package:CarRescue/src/providers/feedback_order.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';

class OrderDetailBody extends StatefulWidget {
  final String orderId;
  final String? techId;
  OrderDetailBody({Key? key, required this.orderId, required this.techId});

  @override
  State<OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<OrderDetailBody> {
  Technician? technicianInfo;
  AuthService authService = AuthService();
  FeedBackProvider feedBackProvider = FeedBackProvider();
  FeedbackCustomer? feedbackCustomer;
  double ratingParse = 0.0;
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  int total = 0;
  List<String> _imageUrls = [];
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  @override
  void initState() {
    print(widget.orderId);
    print(widget.techId);
    if (widget.techId != '' && widget.techId != null) {
      _loadTechInfo(widget.techId ?? '');
    }
    _loadImageOrders(widget.orderId);
    _calculateTotal(widget.orderId);
    fetchFeedback(widget.orderId);
    super.initState();
  }

  Future<void> fetchFeedback(String idOrder) async {
    try {
      FeedbackCustomer feedback =
          await feedBackProvider.getFeedbackOfOrder(idOrder);
      // Do something with the feedbackList
      setState(() {
        feedbackCustomer = feedback;
        ratingParse = feedback.rating.toDouble();
      });
      print(feedback);
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return null;
    }
  }

  Future<String> getPlaceDetails(String latLng) async {
    try {
      final locationProvider = LocationProvider();
      String address = await locationProvider.getAddressDetail(latLng);
      // Sau khi có được địa chỉ, bạn có thể xử lý nó tùy ý ở đây
      print("Địa chỉ từ tọa độ: $address");
      return address;
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Lỗi khi lấy địa chỉ: $e");
      return "Không tìm thấy";
    }
  }

  Future<void> _loadTechInfo(String techId) async {
    Map<String, dynamic>? techProfile =
        await authService.fetchTechProfile(techId);
    print('day la ${techProfile}');
    if (techProfile != null) {
      setState(() {
        technicianInfo = Technician.fromJson(techProfile);
      });
    }
  }

  Future<Order> fetchOrderDetail(String id) async {
    final orderProvider = OrderProvider();
    try {
      final order = await orderProvider.getOrderDetail(id);
      return order;
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch order details');
    }
  }

  Future<List<Service>> _loadServicesOfCustomer(String orderId) async {
    final OrderProvider orderProvider = OrderProvider();
    final ServiceProvider serviceProvider = ServiceProvider();
    try {
      final List<String> listId =
          await orderProvider.getServiceIdInOrderDetails(orderId);
      if (listId.isNotEmpty) {
        final List<Service> listService =
            await serviceProvider.getServiceById(listId);

        return listService;
      } else {
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<void> _calculateTotal(String orderId) async {
    final List<Service> services = await _loadServicesOfCustomer(orderId);
    for (var service in services) {
      setState(() {
        total += service.price;
      });
    }
  }

  Future<void> _loadImageOrders(String id) async {
    final orderProvider = OrderProvider();
    List<String> imgData = await orderProvider.getUrlImages(id);
    setState(() {
      _imageUrls = imgData;
    });
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
                  ? Image.network(allImages[index]).image
                  : allImages[index].startsWith('assets/')
                      ? Image.asset(allImages[index]).image
                      : Image.file(File(allImages[index])).image,
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
    return FutureBuilder<Order>(
      future: fetchOrderDetail(widget.orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display loading indicator or placeholder text
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          // Handle case where data is null
          return Text('Data is null');
        } else {
          Order order = snapshot.data!;
          print(order.id);
          return SingleChildScrollView(
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
                          text: " ${widget.orderId}",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.techId != '' && widget.techId != null)

                        // Use the 'order' object as needed

                        // Example: Text(order.id),

                        if (widget.techId != '' && widget.techId != null)
                          _buildSectionTitle("Thông tin kĩ thuật viên"),
                      if (widget.techId != '' && widget.techId != null)
                        CustomerInfoRow(
                          name: technicianInfo?.fullname ?? "",
                          phone: technicianInfo?.phone ?? "",
                          avt: technicianInfo?.avatar ?? "",
                        ),
                    ],
                  ),
                ),
                if (feedbackCustomer?.status == "COMPLETED")
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Đánh giá"),
                          if (feedbackCustomer?.status == "COMPLETED")
                            Center(
                              child: RatingBar.builder(
                                initialRating: ratingParse,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemSize: 30,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (newRating) {
                                  // Handle the updated rating if needed
                                },
                                ignoreGestures: true,
                              ),
                            ),
                          if (feedbackCustomer?.status == "COMPLETED")
                            _buildInfoRow(
                                "Nội dung đánh giá",
                                Text(feedbackCustomer?.note ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          SizedBox(height: 2.0),
                        ],
                      )),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Thông tin đơn hàng"),
                      _buildInfoRow(
                          "Trạng thái",
                          BookingStatus(
                            status: order.status,
                            fontSize: 14,
                          )),
                      _buildInfoRow(
                          "Loại dịch vụ",
                          Text(order.rescueType ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      FutureBuilder<String>(
                        future: getPlaceDetails(order.departure ?? ''),
                        builder: (context, addressSnapshot) {
                          if (addressSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Display loading indicator or placeholder text
                            return CircularProgressIndicator();
                          } else if (addressSnapshot.hasError) {
                            // Handle error
                            return Text('Error: ${addressSnapshot.error}');
                          } else {
                            String departureAddress =
                                addressSnapshot.data ?? '';
                            return _buildInfoRow(
                              "Điểm đi",
                              Flexible(
                                child: Text(
                                  departureAddress,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      if (order.rescueType == "Towing")
                        FutureBuilder<String>(
                          future: getPlaceDetails(order.destination ?? ''),
                          builder: (context, addressSnapshot) {
                            if (addressSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Display loading indicator or placeholder text
                              return CircularProgressIndicator();
                            } else if (addressSnapshot.hasError) {
                              // Handle error
                              return Text('Error: ${addressSnapshot.error}');
                            } else {
                              String destinationAddress =
                                  addressSnapshot.data ?? '';
                              return _buildInfoRow(
                                "Điểm đến",
                                Flexible(
                                  child: Text(
                                    destinationAddress,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      _buildInfoRow(
                          "Ghi chú",
                          Text(order.customerNote ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

                if (_imageUrls.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Hình ảnh hiện trường"),
                        _buildImageSection(_imageUrls),
                        SizedBox(height: 15.0),
                      ],
                    ),
                  ),

                SizedBox(height: 15.0),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.techId != '' && widget.techId != null)
                        _buildSectionTitle("Ghi chú của kĩ thuật viên"),
                      if (widget.techId != '' && widget.techId != null)
                        _buildInfoRow(
                            "Ghi chú",
                            Text(order.staffNote!,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      if (widget.techId != '' && widget.techId != null)
                        SizedBox(height: 15.0),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Thời gian"),
                      if (order.status != "ASSIGNED" && order.startTime != null)
                        _buildInfoRow(
                          "Bắt đầu",
                          Text(
                            DateFormat('dd-MM-yyyy | HH:mm').format(order
                                .startTime!
                                .toUtc()
                                .add(Duration(hours: 14))),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (order.status != "ASSIGNED" && order.endTime != null)
                        _buildInfoRow(
                          "Kết thúc ",
                          Text(
                            DateFormat('dd-MM-yyyy | HH:mm').format(order
                                .endTime!
                                .toUtc()
                                .add(Duration(hours: 14))),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      _buildInfoRow(
                        "Được tạo lúc",
                        Text(
                          DateFormat('dd-MM-yyyy | HH:mm').format(order
                              .createdAt!
                              .toUtc()
                              .add(Duration(hours: 14))),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.0),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildOrderItemSection(),
                        SizedBox(
                          height: 10,
                        ),
                        if (order.status != "CANCELLED")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: 'Tổng cộng',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              Text(currencyFormat.format(total),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19)),
                            ],
                          ),
                      ],
                    )),
                if (order.status != "CANCELLED" && order.rescueType != 'Towing')
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Thanh toán"),
                        _buildInfoRow(
                            "Người trả",
                            Text('${customer.fullname}',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        _buildInfoRow(
                            "Người nhận",
                            Text('${technicianInfo?.fullname ?? ''}',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                if (order.status == "COMPLETED" &&
                    feedbackCustomer?.status == "WAITING")
                  AppButton(
                      onPressed: () {
                        if (widget.techId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackScreen(
                                      techId: widget.techId!,
                                      orderId: widget.orderId,
                                      customerId: customer.id,
                                    )),
                          );
                        }
                      },
                      btnLabel: "Gửi đánh giá"),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildImageSection(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // fixed to 5 slots for images
            itemBuilder: (context, index) {
              // If there's an image at this index, show it
              if (index < imageUrls.length) {
                ImageProvider imageProvider;

                // Check if the image is an asset or a picked image

                if (imageUrls[index].startsWith('http')) {
                  imageProvider = NetworkImage(imageUrls[index]);
                } else if (imageUrls[index].startsWith('assets/')) {
                  imageProvider = AssetImage(imageUrls[index]);
                } else {
                  imageProvider = FileImage(File(imageUrls[index]));
                }

                // imageProvider = FileImage(File(allImages[index]));

                return Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      _openImageDialog(context, index, imageUrls);
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
              return null;
            },
          ),
        ),
      ],
    );
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

  Widget _buildOrderItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Đơn giá"), // Customize the section title
        // Add order item details here

        FutureBuilder<List<Service>>(
          future: _loadServicesOfCustomer(widget.orderId),
          builder: (context, serviceSnapshot) {
            if (serviceSnapshot.connectionState == ConnectionState.waiting) {
              // Trạng thái đợi khi tải dữ liệu
              return CircularProgressIndicator();
            } else if (serviceSnapshot.hasError) {
              // Xử lý lỗi nếu có
              return Text('Error: ${serviceSnapshot.error}');
            } else {
              // Hiển thị dữ liệu khi đã có kết quả
              final List<Service> serviceList = serviceSnapshot.data!;

              if (serviceList.isEmpty) {
                // Xử lý trường hợp danh sách dịch vụ rỗng
                return Text('Không có dịch vụ.');
              }

              // Sử dụng ListView.builder ở đây để danh sách dịch vụ có thể cuộn một cách linh hoạt
              return ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(), // Tắt tính năng cuộn của ListView này
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final service = serviceList[index];
                  return _buildInfoRow(
                    "${service.name}",
                    Text(
                      "${service.price} vnd", // Sử dụng giá từ đối tượng Service
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
