import 'dart:io';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/order_booking.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/layout/home_selection_widget.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_status/order_processing.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/widgets/service_select.dart';
import 'package:CarRescue/src/providers/car_customer_profile_provider.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class TowBody extends StatefulWidget {
  final LatLng latLng;
  final String address;
  final LatLng latLngDrop;
  final String addressDrop;
  final String distance;
  final String carId;
  const TowBody(
      {super.key,
      required this.latLng,
      required this.address,
      required this.latLngDrop,
      required this.addressDrop,
      required this.distance,
      required this.carId});

  @override
  State<TowBody> createState() => _TowBodyState();
}

class _TowBodyState extends State<TowBody> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController paymentMethodController = TextEditingController();
  TextEditingController customerNoteController = TextEditingController();
  FirBaseStorageProvider fb = FirBaseStorageProvider();
  NotifyMessage notifier = NotifyMessage();
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  CarCustomerProvider carCustomerProvider = CarCustomerProvider();
  CustomerCar? _car;
  Service? selectedService;
  List<String> pickedImages = [];
  final List<Map<String, dynamic>> dropdownItems = [
    {
      "name": "Khu vực 1",
      "value": 1,
      'description':
          'Bao gồm:\nCủ Chi\nGò Vấp\nQuận 12\nHóc Môn\nQuận Tân Bình\nQuận Tân Phú'
    },
    {
      "name": "Khu vực 2",
      "value": 2,
      'description':
          'Bao gồm:\nQuận 1\nQuận 3\nQuận 4\nQuận Bình Thạnh\nThành Phố Thủ Đức'
    },
    {
      "name": "Khu vực 3",
      "value": 3,
      'description':
          'Bao gồm:\nQuận 5\nQuận 6\nQuận 7\nQuận 8\nQuận 10\nQuận 11\nBình Chánh\nNhà Bè\nCần Giờ'
    },
    // Thêm các quận khác nếu cần
  ];
  bool isImageLoading = false;
  // Future<List<Service>>? availableServices;
  List<String>? selectedServices;
  List<String> urlImages = [];
  Future<List<Service>>? availableServices;
  List<Service> selectedServiceCards = [];
  late String urlImage;
  late Map<String, dynamic> selectedDropdownItem;
  late String selectedPaymentOption;
  double totalPrice = 300000;
  bool isLoading = false;
  bool isMomoSelected = false;
  bool isCashSelected = false;
  String? selectedPaymentMethod;

  @override
  void initState() {
    selectedDropdownItem = dropdownItems[0];
    selectedServices = [];
    availableServices = loadService();
    selectedPaymentMethod = 'Cash';
    getCustomerCar();
    super.initState();
  }

  Future<void> uploadImage() async {
    final upload = FirBaseStorageProvider();

    if (pickedImages != []) {
      for (int index = 0; index < pickedImages.length; index++) {
        print(pickedImages.length);
        String? imageUrl =
            await upload.uploadImageToFirebaseStorage(pickedImages[index]);
        print(imageUrl);
        if (imageUrl != null) {
          setState(() {
            urlImages.add(imageUrl);
          });
          print('Image uploaded successfully. URL: $imageUrl');
        } else {
          print('Failed to upload image.');
        }
      }
      setState(() {
        pickedImages.clear();
      });
    } else {
      print('No image selected.');
    }
  }

  void captureImage() async {
    try {
      String newUrlImage = await fb.captureImage();
      if (newUrlImage.isNotEmpty) {
        print("Uploaded image URL: $newUrlImage");
        setState(() {
          urlImage = newUrlImage;
          urlImages!.add(urlImage);
        });
      } else {
        print("Image capture was unsuccessful.");
      }
    } catch (error) {
      print("An error occurred: $error");
    } finally {
      setState(() {
        isImageLoading = false;
      });
    }
  }

  void getCustomerCar() async {
    final carData = await carCustomerProvider.getCar(widget.carId);
    try {
      setState(() {
        _car = carData;
      });
    } catch (e) {
      print(e);
    }
  }

  // void _onServiceCardChanged(Service service, bool isSelected) {
  //   print("Current isSelected: $isSelected");
  //   setState(() {
  //     if (isSelected) {
  //       selectedServiceCards.add(service);
  //     } else {
  //       selectedServiceCards.remove(service);
  //     }
  //   });
  // }

  void caculateTotal() {
    double total = 300000;
    double totalService = 0;
    double distance = double.parse(widget.distance);
    for (Service service in selectedServiceCards) {
      totalService += service.price;
    }

    setState(() {
      totalPrice = totalService * distance + total;
    });
  }

  Future<List<Service>> loadService() async {
    final serviceProvider = ServiceProvider();
    try {
      return serviceProvider.getAllServicesTowing();
    } catch (e) {
      // Xử lý lỗi khi tải dịch vụ
      print('Lỗi khi tải danh sách dịch vụ: $e');
      return [];
    }
  }

  void createOrder() async {
    if (selectedServiceCards.isEmpty) {
      notifier.showToast("Hãy chọn ít nhất một dịch vụ");
    }
    if (_formKey.currentState!.validate() && selectedServiceCards.isNotEmpty) {
      setState(() {
        isLoading = true; // Bắt đầu hiển thị vòng quay khi bắt đầu gửi yêu cầu
      });
      await uploadImage();
      print("Hình lên : ${urlImages.length}");
      // Bước 1: Xác định thông tin cho đơn hàng
      String paymentMethod = selectedPaymentMethod!;
      String customerNote = customerNoteController.text;
      String departure =
          "lat: ${widget.latLng.latitude}, long: ${widget.latLng.longitude}";
      String destination =
          "lat:${widget.latLngDrop.latitude},long:${widget.latLngDrop.longitude}"; // Không có thông tin đích đến
      String rescueType = "Towing"; // Loại cứu hộ (ở đây là "repair")
      String customerId = customer.id; // ID của khách hàng
      List<String> url = urlImages ?? [];
      List<String> service =
          selectedServiceCards.map((service) => service.name).toList();
      ;
      int area = selectedDropdownItem['value'] ?? 0;
      double distance = double.parse(widget.distance);

      // Bước 2: Tạo đối tượng Order
      OrderBookServiceTowing order = OrderBookServiceTowing(
        carID: widget.carId,
        paymentMethod: paymentMethod,
        customerNote: customerNote,
        departure: departure,
        destination: destination,
        rescueType: rescueType,
        customerId: customerId,
        url: url,
        service: service,
        distance: distance,
        area: area,
      );

      // Bước 3: Gọi phương thức createOrder từ ServiceProvider
      final orderProvider = OrderProvider();
      try {
        // Gửi đơn hàng lên máy chủ
        final status = await orderProvider.createOrderTowing(order);
        if (status == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderProcessingScreen(),
            ),
            (route) => false, // Loại bỏ tất cả các màn hình khỏi ngăn xếp
          );

          AuthService().sendNotification(
              deviceId:
                  'eGwrKYghm6vuhnwlMicYsE:APA91bFR9eNQAPggKuJ1S7fweiTyIWHY8WNhnyFB2ZinOHG0euRkJsLghyCLuRTTEs0qER3ss8OkFlNqoIRArs0XqpCtow9q5PFY2-1HeRc8vCmhlZJqmBHhLA1aErqX2kOGKCg2f8AV',
              isAndroidDevice: true,
              title: 'Thông báo từ khách hàng',
              body: 'Có một đơn hàng kéo xe đã được gởi đến hệ thống',
              target: '4a30e2d2-149a-4442-817c-9e73ee4e4477',
              orderId: '');
        } else if (status == 500) {
          notifier.showToast("External error");
        } else if (status == 201) {
          notifier.showToast("Hết xe cứu hộ");
        } else {
          notifier.showToast("Lỗi đơn hàng");
        }
      } catch (e) {
        print('Lỗi khi tạo đơn hàng: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getImageAsset(String value) {
    switch (value) {
      case 'Chuyển khoản':
        return 'assets/images/banking.png';
      case 'Tiền mặt':
        return 'assets/images/money.png';
      default:
        return 'assets/images/money.png'; // Default image
    }
  }

  String? generateTooltipMessage(Map<String, dynamic> item) {
    // Explicitly annotate the return type as String?
    return '${item['description']}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: FrontendConfigs.kBackgrColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 12,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Khoảng cách',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        CustomText(
                          text: '${widget.distance} Km',
                          fontSize: 16,
                        )
                      ],
                    ),
                    Divider(
                      color: FrontendConfigs.kIconColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 12, right: 0, bottom: 12, left: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color.fromARGB(34, 158, 158, 158),
                      ),
                      child: Column(
                        children: [
                          HomeSelectionWidget(
                              icon: 'assets/svg/pickup_icon.svg',
                              title: 'Điểm bắt đầu',
                              body: widget.address,
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          HomeSelectionWidget(
                              icon: 'assets/svg/setting_location.svg',
                              title: 'Điểm kết thúc',
                              body: widget.addressDrop,
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_car != null)
                  Card(
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                _car!.image!,
                                height: 62,
                                width: 62,
                              ),
                              const SizedBox(
                                width: 11,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: _car!.manufacturer,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: _car!.licensePlate,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: FrontendConfigs.kAuthColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                CustomText(
                    text: 'Khu vực hỗ trợ gần bạn ',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),

                const SizedBox(
                  height: 8,
                ),

                CustomText(
                    text: 'Nhấn giữ để xem chi tiết khu vực', fontSize: 14),

                Column(
                  children: [
                    Wrap(
                      spacing: 25.0,
                      runSpacing: 8.0,
                      children: dropdownItems.map((item) {
                        return Tooltip(
                          message: generateTooltipMessage(
                              item), // Set your tooltip message here.
                          child: ChoiceChip(
                            labelPadding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            label: Text(
                              item["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            selected: selectedDropdownItem == item,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedDropdownItem = item;
                                }
                              });
                            },
                            selectedColor: FrontendConfigs.kActiveColor,
                            backgroundColor: FrontendConfigs.kIconColor,
                            shape: StadiumBorder(),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 16.0),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildImageSection(pickedImages),
                // CustomText(
                //     text: 'Hình ảnh hiện trường (nếu có)',
                //     fontWeight: FontWeight.bold,
                //     fontSize: 18),
                // ElevatedButton(
                //   onPressed: () async {
                //     if (!isImageLoading) {
                //       setState(() {
                //         isImageLoading = true;
                //       });
                //     }
                //     // Xử lý khi người dùng nhấp vào biểu tượng '+'
                //     // Chuyển qua camera ở đây
                //     captureImage();
                //   },
                //   style: ButtonStyle(
                //     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                //       EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //     ),
                //     backgroundColor: MaterialStateProperty.all<Color>(
                //       FrontendConfigs.kIconColor, // Màu nền của nút
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(Icons.add_box), // Biểu tượng dấu '+'
                //       SizedBox(
                //           width: 8.0), // Khoảng cách giữa biểu tượng và văn bản
                //       Text(
                //         'Thêm', // Văn bản bên cạnh biểu tượng
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           fontSize: 16, // Kích thước văn bản
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // if (urlImages!.isNotEmpty)
                //   Container(
                //     height: 100, // Điều chỉnh chiều cao tùy ý
                //     child: ListView.builder(
                //       scrollDirection:
                //           Axis.horizontal, // Đặt hướng cuộn là ngang
                //       itemCount: urlImages!.length,
                //       itemBuilder: (context, index) {
                //         return Container(
                //           margin: EdgeInsets.all(
                //               8.0), // Thêm khoảng cách giữa các hình ảnh
                //           child: Image.network(
                //             urlImages![index],
                //             width:
                //                 100, // Điều chỉnh kích thước của hình ảnh tùy ý
                //             height: 100,
                //             fit: BoxFit.cover,
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                const SizedBox(
                  height: 10,
                ),
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
                const SizedBox(
                  height: 10,
                ),
                buildServiceList(context),
                SizedBox(height: 10),
                if (selectedServiceCards.isNotEmpty)
                  SingleChildScrollView(
                    child: Container(
                      height: 200, // Đặt chiều cao tùy ý cho Column
                      child: ListView.builder(
                        itemCount: selectedServiceCards.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(selectedServiceCards[index].name),
                            subtitle: Text(
                                'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(selectedServiceCards[index].price)}₫'),
                            trailing: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                // Create a copy of the list and remove the selected service
                                List<Service> updatedList =
                                    List.from(selectedServiceCards);
                                updatedList.removeAt(index);

                                // Update the state with the new list
                                setState(() {
                                  selectedServiceCards = updatedList;
                                  caculateTotal();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi chú', // Nhãn cho ô nhập liệu
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(
                        height: 8.0), // Khoảng cách giữa nhãn và ô nhập liệu
                    TextFormField(
                      controller: customerNoteController,
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Hãy ghi chú';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Nhập ghi chú của bạn', // Gợi ý cho ô nhập liệu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Định dạng bo tròn viền ô nhập liệu
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomText(
                  text: 'Phương thức thanh toán',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPaymentMethod,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedPaymentMethod = newValue;
                            });
                          }
                        },
                        items: <String>['Chuyển khoản', 'Tiền mặt']
                            .map<DropdownMenuItem<String>>((String value) {
                          String mappedValue =
                              value == 'Chuyển khoản' ? 'Banking' : 'Cash';

                          return DropdownMenuItem<String>(
                            value: mappedValue,
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  getImageAsset(value),
                                  width: value == 'Chuyển khoản' ? 25 : 24,
                                  height: value == 'Chuyển khoản' ? 25 : 24,
                                ),
                                SizedBox(width: 10),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Đặt cột để không chiếm quá nhiều không gian
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng cộng:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(totalPrice)}₫', // Số tiền tổng cộng, cần được tính toán hoặc lấy từ state
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: 20), // Khoảng cách giữa tổng cộng tiền và nút
                      SizedBox(
                        width: double
                            .infinity, // Đặt chiều rộng bằng với Container
                        height: 50, // Đặt chiều cao cố định cho nút
                        child: ElevatedButton(
                          child: Text(
                            isLoading ? 'Đang tạo đơn hàng...' : "Tạo đơn",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FrontendConfigs
                                .kIconColor, // Đảm bảo rằng màu này được định nghĩa trong FrontendConfigs
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Góc bo tròn cho nút
                            ),
                          ),
                          onPressed: () {
                            createOrder();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildServiceList(BuildContext context) {
    return Container(
      color: FrontendConfigs.kBackgrColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Dịch vụ ", // Title
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => buildServiceSelection(context),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_box), // Biểu tượng dấu '+'
                SizedBox(width: 8.0), // Khoảng cách giữa biểu tượng và văn bản
                Text(
                  'Chọn', // Văn bản bên cạnh biểu tượng
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Kích thước văn bản
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildServiceSelection(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0₫', 'vi_VN');

    return Container(
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Service>>(
              future: availableServices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có dữ liệu.'));
                } else {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final service = snapshot.data![index];
                          var isSelected = selectedService == service;
                          return SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? FrontendConfigs.kPrimaryColorCustomer
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(64, 158, 158, 158)
                                        .withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  service.name,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  currencyFormat.format(service.price),
                                  style: TextStyle(
                                    color: FrontendConfigs.kAuthColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    _onServiceCardChanged(service, value ?? false);
                                  });
                                },
                              ),
                            ),
                          );
                        },

                        isSelected: isSelected,
                        rescueType: 'Towing',

                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 25,
              bottom: 10,
            ),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs.kIconColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (selectedService != null) {
                        // Process the selected service
                        print(selectedService!.name);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _onServiceCardChanged(Service service, bool isSelected) {
    print("Current isSelected: $isSelected");
    if (isSelected) {
      setState(() {
        selectedServiceCards.clear();
        selectedServiceCards.add(service);
        selectedService = service;
        caculateTotal();
      });
    } else {
      setState(() {
        selectedService = null;
        caculateTotal();
      });
    }
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
    final allImages = [...urlImages, ...pickedImages];
    print("Tong so anh:  ${allImages.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hình ảnh hiện trường'),
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
              else {
                return Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      showCancelOrderDialog(context);
                    },
                    child: Container(
                      width: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Icon(Icons.add,
                            size: 60.0, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
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

  void showCancelOrderDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Chọn ảnh"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_library),
                    onPressed: () {
                      // Đặt hành động khi chọn ảnh từ thư viện ở đây
                      _addImageFromGallery();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      // Đặt hành động khi chọn ảnh từ máy ảnh ở đây
                      _addImageFromCamera();
                    },
                  ),
                ],
              ));
        });
  }

  void _addImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Add the file path to your imageUrls list
      setState(() {
        pickedImages.add(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _addImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Add the file path to your imageUrls list
      setState(() {
        pickedImages.add(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }
}
