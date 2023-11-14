import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/widget/customer_info.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/widget/selection_location_widget.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class OrderDetailBody extends StatefulWidget {
  final String orderId;
  String? techId;
  OrderDetailBody({Key? key, required this.orderId, this.techId});

  @override
  State<OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<OrderDetailBody> {
  Technician? technicianInfo;
  AuthService authService = AuthService();
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  int total = 0;
  @override
  void initState() {
    print(widget.orderId);
    print(widget.techId);
    if (widget.techId != '' || widget.techId != null) {
      _loadTechInfo(widget.techId!);
    }
    super.initState();
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Center(
                  child: CustomText(
                    text: "Mã đơn hàng: ${widget.orderId}",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.techId != null && widget.techId != '')
                  Divider(thickness: 3),
                // Use the 'order' object as needed
                // Example: Text(order.id),
                if (widget.techId != null && widget.techId != '')
                  _buildSectionTitle("Thông tin kĩ thuật viên"),
                if (widget.techId != null && widget.techId != '')
                  CustomerInfoRow(
                    name: technicianInfo!.fullname!,
                    phone: technicianInfo!.phone,
                    avt: technicianInfo!.avatar!,
                  ),
                Divider(thickness: 3),
                SizedBox(height: 15.0),
                _buildSectionTitle("Thông tin đơn hàng"),
                _buildInfoRow(
                    "Trạng thái",
                    BookingStatus(
                      status: order.status,
                    )),
                _buildInfoRow(
                    "Loại dịch vụ",
                    Text(order.rescueType!,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                FutureBuilder<String>(
                  future: getPlaceDetails(order.departure!),
                  builder: (context, addressSnapshot) {
                    if (addressSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // Display loading indicator or placeholder text
                      return CircularProgressIndicator();
                    } else if (addressSnapshot.hasError) {
                      // Handle error
                      return Text('Error: ${addressSnapshot.error}');
                    } else {
                      String departureAddress = addressSnapshot.data ?? '';
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
                  const Padding(
                    padding: EdgeInsets.only(left: 31),
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: 30,
                      lineThickness: 1.0,
                      dashLength: 4.0,
                      dashColor: Colors.black,
                      dashRadius: 2.0,
                      dashGapLength: 4.0,
                      dashGapRadius: 0.0,
                    ),
                  ),
                if (order.rescueType == "Towing")
                  FutureBuilder<String>(
                    future: getPlaceDetails(order.destination!),
                    builder: (context, addressSnapshot) {
                      if (addressSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        // Display loading indicator or placeholder text
                        return CircularProgressIndicator();
                      } else if (addressSnapshot.hasError) {
                        // Handle error
                        return Text('Error: ${addressSnapshot.error}');
                      } else {
                        String destinationAddress = addressSnapshot.data ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: RideSelectionWidget(
                            icon: 'assets/svg/location_icon.svg',
                            title: "Địa điểm muốn đến",
                            body: destinationAddress,
                            onPressed: () {},
                          ),
                        );
                      }
                    },
                  ),
                  _buildInfoRow(
                    "Ghi chú",
                    Text(order.customerNote!,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Divider(thickness: 3),
                SizedBox(height: 15.0),
                _buildSectionTitle("Ghi chú của kĩ thuật viên"),
                _buildInfoRow(
                    "Ghi chú",
                    Text(order.staffNote!,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Divider(thickness: 3),
                SizedBox(height: 15.0),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: CustomText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ));
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: Text(
            label,
          )),
          SizedBox(width: 8.0), // Add spacing between label and value
          value
        ],
      ),
    );
  }
}
