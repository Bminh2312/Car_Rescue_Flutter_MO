import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/feedback_customer.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/chat_with_driver/chat_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/order_detail_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/orders/layout/widgets/selection_location_widget.dart';
import 'package:CarRescue/src/providers/feedback_order.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  String selectedStatus = "ASSIGNING";
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  FeedBackProvider feedBackProvider = FeedBackProvider();
  FeedbackCustomer? feedbackCustomer ;
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

  Future<FeedbackCustomer?> fetchFeedback(String idOrder) async {
    try {
      FeedbackCustomer feedback =
          await feedBackProvider.getFeedbackOfOrder(idOrder);
      // Do something with the feedbackList
      print(feedback);
      return feedback;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              child: TabBar(
                indicatorColor: FrontendConfigs.kPrimaryColor,
                tabs: [
                  Tab(
                    child: Center(
                      child: Text(
                        'Sữa chữa tại chỗ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Center(
                      child: Text(
                        'Kéo xe',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: FrontendConfigs.kBackgrColor,
                child: TabBarView(
                  children: [
                    _buildTabView('Fixing'),
                    _buildTabView('Towing'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView(String type) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: true, // Để cố định SliverAppBar
          expandedHeight: 50,
          backgroundColor:
              FrontendConfigs.kBackgrColor, // Điều chỉnh độ cao tùy ý
          flexibleSpace: FlexibleSpaceBar(
            background: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('ASSIGNING', Colors.blue),
                _buildFilterButton('COMPLETED', Colors.green),
                _buildFilterButton('CANCELLED', Colors.red),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return FutureBuilder<List<Order>>(
                future: getAllOrders(selectedStatus, type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final orders = snapshot.data ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: orders.map((order) {
                          String formattedStartTime =
                              DateFormat('dd/MM/yyyy | HH:mm')
                                  .format(order.createdAt ?? DateTime.now());
                          return Card(
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              Color.fromARGB(86, 115, 115, 115),
                                          width: 2.0,
                                        ),
                                        color: Color.fromARGB(0, 255, 255, 255),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(115, 47, 47, 47),
                                        backgroundImage: AssetImage(
                                            'assets/images/logocarescue.png'),
                                        radius: 20,
                                      ),
                                    ),
                                    title: CustomText(
                                      text: formattedStartTime,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    subtitle: Text(order.rescueType!),

                                    trailing: Column(
                                      children: [
                                        BookingStatus(
                                          status: order.status,
                                        ),
                                        Expanded(
                                          child:
                                              FutureBuilder<FeedbackCustomer?>(
                                            future: fetchFeedback(order.id),
                                            builder:
                                                (context, feedbackSnapshot) {
                                              if (feedbackSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                // Display loading indicator or placeholder text
                                                return CircularProgressIndicator(
                                                  value:
                                                      null, // Set to null for an indeterminate (spinning) indicator
                                                  strokeWidth:
                                                      2, // Adjust the value to make the indicator smaller
                                                );
                                              } else if (feedbackSnapshot
                                                  .hasError) {
                                                return Text(
                                                    'Error: ${feedbackSnapshot.error}');
                                              } else {
                                                // Assuming your FeedbackCustomer class has a 'rating' field
                                                
                                                int rating = feedbackSnapshot
                                                        .data?.rating ??
                                                    0;
                                                double ratingParse =
                                                    rating.toDouble();

                                                String status = feedbackSnapshot
                                                        .data?.status ??
                                                    '';

                                                return status == 'COMPLETED' ? RatingBar.builder(
                                                  initialRating: ratingParse,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: false,
                                                  itemCount: 5,
                                                  itemSize: 20,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 2.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (newRating) {
                                                    // Handle the updated rating if needed
                                                  },
                                                  ignoreGestures: true,
                                                ): Text("Chưa đánh giá");
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Use the BookingStatusWidget here
                                  ),
                                  Divider(
                                    color: FrontendConfigs.kIconColor,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/svg/location_icon.svg",
                                                    color: FrontendConfigs
                                                        .kPrimaryColor),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                CustomText(
                                                  text: "6.5 km",
                                                  fontWeight: FontWeight.w600,
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/svg/watch_icon.svg"),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                CustomText(
                                                  text: "15 mins",
                                                  fontWeight: FontWeight.w600,
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/svg/wallet_icon.svg",
                                                  color: FrontendConfigs
                                                      .kPrimaryColor,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                CustomText(
                                                  text: "\$56.00",
                                                  fontWeight: FontWeight.w600,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: FrontendConfigs.kIconColor,
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      FutureBuilder<String>(
                                        future:
                                            getPlaceDetails(order.departure!),
                                        builder: (context, addressSnapshot) {
                                          if (addressSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // Display loading indicator or placeholder text
                                            return CircularProgressIndicator();
                                          } else if (addressSnapshot.hasError) {
                                            // Handle error
                                            return Text(
                                                'Error: ${addressSnapshot.error}');
                                          } else {
                                            String departureAddress =
                                                addressSnapshot.data ?? '';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: RideSelectionWidget(
                                                icon:
                                                    'assets/svg/pickup_icon.svg',
                                                title:
                                                    "Địa điểm hiện tại", // Add your title here
                                                body: departureAddress,
                                                onPressed: () {},
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      if (type == "Towing")
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
                                      if (type == "Towing")
                                        FutureBuilder<String>(
                                          future: getPlaceDetails(
                                              order.destination!),
                                          builder: (context, addressSnapshot) {
                                            if (addressSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              // Display loading indicator or placeholder text
                                              return CircularProgressIndicator();
                                            } else if (addressSnapshot
                                                .hasError) {
                                              // Handle error
                                              return Text(
                                                  'Error: ${addressSnapshot.error}');
                                            } else {
                                              String destinationAddress =
                                                  addressSnapshot.data ?? '';
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0),
                                                child: RideSelectionWidget(
                                                  icon:
                                                      'assets/svg/location_icon.svg',
                                                  title: "Địa điểm muốn đến",
                                                  body: destinationAddress,
                                                  onPressed: () {},
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ButtonBar(
                                        children: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              if (order.technicianId == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetail(
                                                            orderId: order.id,
                                                            techId: null),
                                                  ),
                                                );
                                              } else if (order.technicianId ==
                                                  '') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetail(
                                                            orderId: order.id,
                                                            techId: ''),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetail(
                                                            orderId: order.id,
                                                            techId: order
                                                                .technicianId),
                                                  ),
                                                );
                                              }
                                            },
                                            child: CustomText(
                                              text: 'Chi tiết',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ]),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              );
            },
            childCount: 1, // Chỉ có một phần SliverList nên set là 1
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String type, Color textColor) {
    String translatedText = type;

    if (type == 'ASSIGNING') {
      translatedText = 'Đã duyệt';
    } else if (type == 'COMPLETED') {
      translatedText = 'Hoàn Thành';
    } else if (type == 'CANCELLED') {
      translatedText = 'Đã hủy';
    }
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(textColor),
      ),
      onPressed: () {
        setState(() {
          selectedStatus = type;
        });
      },
      child: Text(
        translatedText,
      ),
    );
  }

  Future<List<Order>> getAllOrders(String status, String type) async {
    final orderProvider = OrderProvider();
    print("Status: $status");
    try {
      final orders = await orderProvider.getAllOrders(customer.id);
      final filteredOrders = orders
          .where((order) => order.status == status && order.rescueType == type)
          .toList();
      return filteredOrders;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
