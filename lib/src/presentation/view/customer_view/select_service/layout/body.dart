import 'dart:async';

import 'package:CarRescue/main.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/empty_state.dart';
import 'package:CarRescue/src/presentation/elements/quick_access_buttons.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/car_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_detail/order_detail_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_car/select_car_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/popup_service_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/selection_location_widget%20copy.dart';
import 'package:CarRescue/src/presentation/view/customer_view/select_service/widget/slider_banner.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/home_view.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:CarRescue/src/providers/google_map_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceBody extends StatefulWidget {
  const ServiceBody({super.key});

  @override
  State<ServiceBody> createState() => _ServiceBodyState();
}

class _ServiceBodyState extends State<ServiceBody>
    with SingleTickerProviderStateMixin {
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  late TabController _tabController;
  NotifyMessage notifyMessage = NotifyMessage();

  bool isConfirmed = false;
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
    checkInfo(context);
    getAllOrders("NEW");
    _tabController = TabController(length: 3, vsync: this);
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    channelDescription: channel.description,
                    color: Colors.blue,
                    playSound: true,
                    icon: '@drawable/ic_launcher',
                    largeIcon:
                        DrawableResourceAndroidBitmap('@drawable/download'))));
      }

      print('Received message: ${message.notification?.body}');
      // Handle the incoming message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('a new onMessageOpenedApp ok');
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title ?? 'Unknown'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body ?? 'Unknown1')],
                ),
              ),
            );
          });
    });
  }

  void checkInfo(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {

    // Define a list to store missing information messages
    List<String> missingInfoMessages = [];

    // Check each required field
    if (customer.fullname == "" || customer.fullname.isEmpty) {
      missingInfoMessages.add('Họ và tên');
    }

    if (customer.sex == "" || customer.sex.isEmpty) {
      missingInfoMessages.add('Giới tính');
    }

    if (customer.phone == "" || customer.phone.isEmpty) {
      missingInfoMessages.add('Số điện thoại');
    }

    if (customer.address == "" || customer.address.isEmpty) {
      missingInfoMessages.add('Địa chỉ');
    }

    if (customer.birthdate == "" || customer.birthdate.isEmpty) {
      missingInfoMessages.add('Ngày sinh');
    }

    // If there are missing fields, show the dialog
    if (missingInfoMessages.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Thông tin sau đây chưa đầy đủ:'),
                for (String missingInfo in missingInfoMessages)
                  Text('- $missingInfo'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Navigate to the profile screen for updating information
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BottomNavBarView(page: 2),
                    ),
                  );
                },
                child: Text('Cập nhật'),
              ),
            ],
          );
        },
      );
    }
  });
}

  void launchDialPad(String phoneNumber) async {
    String uri = 'tel:$phoneNumber';

    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      print('Error launching dial pad: $e');
      throw 'Could not launch $uri';
    }
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarListView(
                        userId: customer.id,
                        accountId: customer.accountId,
                      ),
                    ),
                  );
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
                    launchDialPad("0983434031");
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
                          builder: (context) => SelectCarView(
                                rescueType: 'Towing',
                              )));
                    } else if (selectedOption.title == 'Cứu hộ tại chỗ') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SelectCarView(
                                rescueType: 'OnSiteRescue',
                              )));
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
                              builder: (context) => SelectCarView(
                                    rescueType: 'Towing',
                                  )),
                        );
                      } else if (selectedOption.title == 'Cứu hộ tại chỗ') {
                        // Navigate differently based on the option
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //       builder: (context) =>
                        //           HomeView(services: "Fixing")),
                        // );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SelectCarView(
                                    rescueType: 'Fixing',
                                  )),
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
    return SliderBanner(advertisements: _advertisements);
  }

  Widget buildOrdersTabView() {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.3, // Set your desired height
      child: TabBarView(
        controller: _tabController,
        children: [
          buildOrders("ASSIGNED"),
          buildOrders("WAITING"),
          buildOrders("INPROGRESS"),
        ],
      ),
    );
  }

  Widget buildOrders(String type) {
    return Container(
      height: 300, // Reduced height
      child: FutureBuilder<List<Order>>(
        future: getAllOrders("$type"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return EmptyState();
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Order order = orders[index];
                String formattedStartTime = DateFormat('dd/MM/yyyy | HH:mm')
                    .format(order.createdAt ?? DateTime.now());

                return Column(
                  children: [
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color.fromARGB(115, 47, 47, 47),
                              backgroundImage:
                                  AssetImage('assets/images/logocarescue.png'),
                              radius: 20,
                            ), // Simplified icon
                            title:
                                Text(formattedStartTime), // Order creation date
                            // Rescue type
                            trailing: BookingStatus(
                              status: order.status,
                              fontSize: 16,
                            ), // Order status
                            onTap: () {
                              // Action to view details or cancel the order
                            },
                          ),
                          Divider(
                            color: FrontendConfigs.kIconColor,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
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
                                String departureAddress =
                                    addressSnapshot.data ?? '';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: RideSelectionWidget(
                                    icon: 'assets/svg/pickup_icon.svg',
                                    title:
                                        "Địa điểm hiện tại", // Add your title here
                                    body: departureAddress,
                                    onPressed: () {},
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
                                  return Text(
                                      'Error: ${addressSnapshot.error}');
                                } else {
                                  String destinationAddress =
                                      addressSnapshot.data ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
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
                          ButtonBar(children: <Widget>[
                            TextButton(
                              onPressed: () {
                                if (order.technicianId == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetail(
                                        orderId: order.id,
                                        techId: null,
                                        hasFailedStatus: false,
                                      ),
                                    ),
                                  );
                                } else if (order.technicianId == '') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetail(
                                        orderId: order.id,
                                        techId: '',
                                        hasFailedStatus: false,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetail(
                                        orderId: order.id,
                                        techId: order.technicianId,
                                        hasFailedStatus: false,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: CustomText(
                                text: 'Chi tiết',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ]),
                        ],
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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CustomText(
                                    text: 'Các đơn chờ duyệt và hoạt động',
                                    fontSize: 20,
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
                              TabBar(
                                controller: _tabController,
                                labelPadding: EdgeInsets.symmetric(horizontal: 0),
                                tabs: [
                                  Tab(
                                    child: BookingStatus(
                                      status: "ASSIGNED",
                                      fontSize: 15,
                                    ),
                                  ),
                                  Tab(
                                    child: BookingStatus(
                                      status: "WAITING",
                                      fontSize: 15,
                                    ),
                                  ),
                                  Tab(
                                    child: BookingStatus(
                                      status: "INPROGRESS",
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              buildOrdersTabView(),
                            ],
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
