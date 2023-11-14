import 'dart:async';

import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/quick_access_buttons.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/car_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_status/order_processing.dart';
import 'package:CarRescue/src/presentation/view/customer_view/orders/orders_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/animated_indicator.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/popup_service_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/service_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/home_view.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';

class ServiceBody extends StatefulWidget {
  const ServiceBody({super.key});

  @override
  State<ServiceBody> createState() => _ServiceBodyState();
}

class _ServiceBodyState extends State<ServiceBody> {
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  NotifyMessage notifyMessage = NotifyMessage();
  TextEditingController _reasonCacelController = TextEditingController();

  bool isConfirmed = false;
  final _formKey = GlobalKey<FormState>();

  late PageController _pageController;
  late Timer _timer;
  final List<String> _advertisements = [
    'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/images%2Fstep1.png?alt=media&token=fafca03d-ed24-4b10-b928-07d37410bcd7',
    'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/images%2Fstep2.png?alt=media&token=c1396b52-f0cc-4acb-85fe-9cacbe5dae0d',
    'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/images%2Fstep2.png?alt=media&token=c1396b52-f0cc-4acb-85fe-9cacbe5dae0d',
  ]; // Placeholder for advertisement images
  int _currentPage = 0;
  int _selectedIndex = 0;
  bool hasInProgressBooking = true;
  int selectedOption = -1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllOrders("NEW");
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);

    // Set the timer to change the advertisement every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _advertisements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<List<Order>> getAllOrders(String status) async {
    final orderProvider = OrderProvider();
    print("Status: $status");
    try {
      final orders = await orderProvider.getAllOrders(customer.id);
      final filteredOrders =
          orders.where((order) => order.status == status).toList();
      return filteredOrders;
    } catch (e) {
      print('Error: $e');
      return [];
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

  Widget buildQuickAccessButtons() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5), bottomRight: Radius.circular(10)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickAccessButton(
                label: 'Xe của tôi',
                icon: CupertinoIcons.car_detailed,
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CarListView(
                  //       userId: customer.id,
                  //     ),
                  //   ),
                  // );
                },
              ),
              // QuickAccessButton(
              //   label: 'Cứu hộ',
              //   icon: CupertinoIcons.book_solid,
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => OrderView(),
              //       ),
              //     ).then((value) => {});
              //   },
              // ),
              QuickAccessButton(
                label: 'Thông báo',
                icon: Icons.notifications,
                onPressed: () {
                  //  Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const NotificationView(),
                  //   ),
                  // );
                },
              ),
              QuickAccessButton(
                  icon: CupertinoIcons.phone_fill_arrow_down_left,
                  label: 'CSKH',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderProcessingScreen(),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildQuickRegister() {
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return PopupButton(
                  onOptionSelected: (selectedOption) {
                    // Handle navigation logic here
                    if (selectedOption.title == 'Kéo xe cứu hộ') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeView(services: "Towing")));
                    } else if (selectedOption.title == 'Cứu hộ tại chỗ') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              HomeView(services: "OnSiteRescue")));
                    } else if (selectedOption.title == 'Dịch vụ khác') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              HomeView(services: "OtherServices")));
                    }
                    // Add more conditions as necessary
                  },
                  onConfirm: (selectedOption) {
                    Navigator.pop(context);
                    try {
                      print(
                          "Handling confirmation for: ${selectedOption.title}");
                      if (selectedOption.title == 'Kéo xe cứu hộ') {
                        // Navigate to a specific page or with specific parameters
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeView(services: "Towing")),
                        );
                      } else if (selectedOption.title == 'Cứu hộ tại chỗ') {
                        // Navigate differently based on the option
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeView(services: "Fixing")),
                        );
                      } else if (selectedOption.title == 'Dịch vụ khác') {
                        // Another navigation logic
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeView(services: "Towing")),
                        );
                      }
                      // Add more conditions as necessary
                    } catch (e) {
                      print("Error during navigation: $e");
                    }
                  },
                );
              });
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color.fromARGB(86, 0, 0, 0),
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Loại dịch vụ 1

                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                            height: 25, width: 25, 'assets/icons/rescue.png'),
                        SizedBox(
                          width: 10,
                        ),
                        CustomText(
                          text: 'Cứu hộ ngay',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Màu văn bản
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget buildSliderBanner() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 400, // Adjust the height as needed
          child: PageView.builder(
            controller: _pageController,
            itemCount: _advertisements.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: FrontendConfigs.kActiveColor,
                ),
                margin: EdgeInsets.symmetric(horizontal: 3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      16), // Clip the image to the border radius
                  child: Image.network(
                    _advertisements[
                        index], // Placeholder for an advertisement image
                    fit:
                        BoxFit.cover, // Cover the entire space of the container
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 7),
        AnimatedIndicator(
          pageController: _pageController,
          itemCount: _advertisements.length,
          activeColor: FrontendConfigs.kPrimaryColor, // Active indicator color
          inactiveColor: Colors.grey, // Inactive indicator color
        ),
        SizedBox(height: 7),
      ],
    );
  }

  Widget buildService() {
    final List<String> categories = [
      'Đổ xăng',
      'Thay bánh xe',
      'Bơm bánh xe',
      'Sạc ắc quy',
      'Kích bình',
      'Thay bình',
      // Add more categories if needed
    ];
    final size = MediaQuery.of(context).size;

    // Ensure the GridView is returned within a widget that provides enough space,
    // like Expanded if in a Column or Row, or directly in the body of a Scaffold.

    return Container(
      height: size.height *
          0.35, // Specify the height to ensure it takes the available space
      width: size.width,
      child: GridView.builder(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              3, // Increase the number of columns to make each item smaller
          crossAxisSpacing: 10, // Horizontal space between items
          mainAxisSpacing: 10, // Vertical space between items
          childAspectRatio:
              1, // Adjust the aspect ratio to change the size of the items
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ServiceCategoryWidget(category: categories[index]);
        },
      ),
    );
  }

  Widget buildOrders() {
    return Container(
      height: 300, // Reduced height
      child: FutureBuilder<List<Order>>(
        future: getAllOrders("NEW"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orders = snapshot.data ?? [];

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Order order = orders[index];
                String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
                    .format(order.createdAt ?? DateTime.now());

                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color.fromARGB(115, 47, 47, 47),
                          backgroundImage:
                              AssetImage('assets/images/logocarescue.png'),
                          radius: 20,
                        ), // Simplified icon
                        title: Text(formattedStartTime), // Order creation date
                        // Rescue type
                        trailing: Text(order.status), // Order status
                        onTap: () {
                          // Action to view details or cancel the order
                        },
                      ),
                      margin: EdgeInsets.all(8.0),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget buildQuickBooking() {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Loại dịch vụ 1
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => HomeView(
                              services: "Towing",
                            )),
                  );
                },
                child: Container(
                  // Độ cao của loại dịch vụ

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 24,
                        color: Colors.white, // Màu biểu tượng
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomText(
                        text: 'Kéo xe',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Màu văn bản
                      ),
                    ],
                  ),
                ),
              ),
              // Loại dịch vụ 2

              GestureDetector(
                onTap: () {
                  //  Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //       builder: (context) => HomeView(services: "repair",)),
                  // );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => HomeView(
                              services: "Fixing",
                            )),
                  );
                },
                child: Container(
                  // Độ cao của loại dịch vụ
                  decoration: BoxDecoration(
                    // Màu nền trắng
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build,
                        size: 24,
                        color: FrontendConfigs.kIconColor, // Màu biểu tượng
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomText(
                        text: 'Sửa chữa',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Màu văn bản
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: FrontendConfigs.kBackgrColor),
        child: Stack(
          children: <Widget>[
            // Image container
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffffa585), Color(0xffffeda0)],
                ),
              ),
            ),
            // Content with Padding instead of Transform
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 110), // Pushes content up by 150 pixels
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ), // Set the border radius to 10
                      ),
                      child: Column(
                        children: [
                          buildSliderBanner(),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          buildQuickRegister(),
                          buildQuickAccessButtons(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                CustomText(
                                  text: 'Dịch vụ phổ biến',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // buildService(),

                    // ... Add more widgets as needed
                  ],
                ),
              ),
            ),
            // Icon overlay
            Positioned(
                top: 65,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => BottomNavBarView(
                    //                 userId: widget.userId,
                    //                 accountId: widget.accountId,
                    //                 initialIndex: 2,
                    //               )));
                  },
                  child: CircleAvatar(
                    backgroundColor: FrontendConfigs.kIconColor,
                    radius: 25,
                    child: ClipOval(
                      child: Image(
                        image: NetworkImage(
                          customer.avatar,
                        ),
                        width: 64, // double the radius
                        height: 64, // double the radius
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
            // Welcome text on top left
            Positioned(
              top: 70,
              left: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    customer.fullname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      color: FrontendConfigs.kAuthColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(int index) {
    bool isSelected = index == selectedOption;
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = index;
        });
      },
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/towtruck-service2.png',
                height: 120,
                width: 120,
              ),
              Text(
                'Kéo xe cứu hộ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Trường hợp khẩn cấp. Hệ thống của chúng tôi sẽ kết nối với những chủ xe cứu hộ để kéo xe của bạn về địa điểm tiếp nhận xe',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  
//   void showCancelOrderDialog(BuildContext context, String id) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Hủy đơn"),
//           content: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Text("Bạn có chắc muốn hủy đơn không?"),
//                 TextFormField(
//                   controller: _reasonCacelController,
//                   decoration: InputDecoration(labelText: "Lý do hủy đơn"),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'Lý do hủy đơn không được để trống';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Hủy"),
//               onPressed: () {
//                 setState(() {
//                   _reasonCacelController.clear();
//                   getAllOrders("NEW");
//                 });
//                 Navigator.of(context).pop(); // Đóng hộp thoại
//               },
//             ),
//             TextButton(
//               child: Text("Xác nhận"),
//               onPressed: () {
//                 // Kiểm tra hợp lệ của form
//                 if (_formKey.currentState!.validate()) {
//                   // Ở đây bạn có thể xử lý hành động hủy đơn
//                   cancelOrder(id, _reasonCacelController.text).then((success) {
//                     if (success) {
//                       notifyMessage.showToast("Đã hủy đơn");
//                       // Sau khi hủy đơn, cập nhật lại danh sách đơn
//                       setState(() {
//                         getAllOrders("NEW");
//                       });
//                     } else {
//                       notifyMessage.showToast("Hủy đơn lỗi");
//                     }
//                   });
//                   _reasonCacelController.clear();
//                   Navigator.of(context).pop(); // Đóng hộp thoại
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<bool> cancelOrder(String orderID, String cancellationReason) async {
//     try {
//       final orderProvider =
//           await OrderProvider().cancelOrder(orderID, cancellationReason);
//       if (orderProvider) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       notifyMessage.showToast("Huỷ đơn lỗi.");
//       return false;
//     }
//   }

//   Future<List<Order>> getAllOrders(String status) async {
//     final orderProvider = OrderProvider();
//     print("Status: $status");
//     try {
//       final orders = await orderProvider.getAllOrders(customer.id);
//       final filteredOrders =
//           orders.where((order) => order.status == status).toList();
//       return filteredOrders;
//     } catch (e) {
//       print('Error: $e');
//       return [];
//     }
//   }
// }
