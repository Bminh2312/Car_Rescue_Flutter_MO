import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/order_booking.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/layout/home_selection_widget.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_status/order_processing.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/widgets/service_select.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TowBody extends StatefulWidget {
  final LatLng latLng;
  final String address;
  final LatLng latLngDrop;
  final String addressDrop;
  final String distance;

  const TowBody(
      {super.key,
      required this.latLng,
      required this.address,
      required this.latLngDrop,
      required this.addressDrop,
      required this.distance});

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
  final List<Map<String, dynamic>> dropdownItems = [
    {"name": "Quận 1", "value": 1},
    {"name": "Quận 2", "value": 2},
    {"name": "Quận 3", "value": 3},
    // Thêm các quận khác nếu cần
  ];
  bool isImageLoading = false;
  // Future<List<Service>>? availableServices;
  List<String>? selectedServices;
  List<String>? urlImages;
  Future<List<Service>>? availableServices;
  late String urlImage;
  late Map<String, dynamic> selectedDropdownItem;
  late String selectedPaymentOption;
  int totalPrice = 0;
  bool isLoading = false;
  bool isMomoSelected = false;
  bool isCashSelected = false;
  String? selectedPaymentMethod;
  @override
  void initState() {
    selectedDropdownItem = dropdownItems[0];
    selectedPaymentOption = "";
    urlImages = [];
    selectedServices = [];
    availableServices = loadService();
    selectedPaymentMethod = 'Tiền mặt';
    super.initState();
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Bắt đầu hiển thị vòng quay khi bắt đầu gửi yêu cầu
      });

      // Bước 1: Xác định thông tin cho đơn hàng
      String paymentMethod = paymentMethodController.text;
      String customerNote = customerNoteController.text;
      String departure =
          "lat:${widget.latLng.latitude},long:${widget.latLng.longitude}";
      String destination =
          "lat:${widget.latLngDrop.latitude},long:${widget.latLngDrop.longitude}"; // Không có thông tin đích đến
      String rescueType = "Towing"; // Loại cứu hộ (ở đây là "repair")
      String customerId = customer.id; // ID của khách hàng
      List<String> url = urlImages ?? [];
      List<String> service = selectedServices ?? [];
      int area = selectedDropdownItem['value'] ?? 0;
      double distance = double.parse(widget.distance);

      // Bước 2: Tạo đối tượng Order
      OrderBookServiceTowing order = OrderBookServiceTowing(
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
                CustomText(
                    text: 'Khu vực hỗ trợ gần bạn',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                Column(
                  children: [
                    Wrap(
                      spacing: 32.0, // Horizontal space between chips.
                      runSpacing: 8.0, // Vertical space between lines.
                      children: dropdownItems.map((item) {
                        return ChoiceChip(
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ), // Add padding inside the chip.
                          label: Text(
                            item["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Increase the font size.
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
                          selectedColor: FrontendConfigs
                              .kActiveColor, // Optional: Changes the color when selected.
                          backgroundColor: FrontendConfigs.kIconColor,
                          shape:
                              StadiumBorder(), // Optional: Creates a stadium-shaped border.
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 16.0),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomText(
                    text: 'Hình ảnh hiện trường (nếu có)',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                ElevatedButton(
                  onPressed: () async {
                    if (!isImageLoading) {
                      setState(() {
                        isImageLoading = true;
                      });
                    }
                    // Xử lý khi người dùng nhấp vào biểu tượng '+'
                    // Chuyển qua camera ở đây
                    captureImage();
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      FrontendConfigs.kIconColor, // Màu nền của nút
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_box), // Biểu tượng dấu '+'
                      SizedBox(
                          width: 8.0), // Khoảng cách giữa biểu tượng và văn bản
                      Text(
                        'Thêm', // Văn bản bên cạnh biểu tượng
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Kích thước văn bản
                        ),
                      ),
                    ],
                  ),
                ),
                if (urlImages!.isNotEmpty)
                  Container(
                    height: 100, // Điều chỉnh chiều cao tùy ý
                    child: ListView.builder(
                      scrollDirection:
                          Axis.horizontal, // Đặt hướng cuộn là ngang
                      itemCount: urlImages!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(
                              8.0), // Thêm khoảng cách giữa các hình ảnh
                          child: Image.network(
                            urlImages![index],
                            width:
                                100, // Điều chỉnh kích thước của hình ảnh tùy ý
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                buildServiceList(),
                // Tôi cần 1 cái drop dow các dịch vụ và chọn được nhìu lần
                // FutureBuilder<List<Service>>(
                //   future:
                //       availableServices, // Thay bằng hàm lấy dữ liệu thích hợp
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator();
                //     } else if (snapshot.hasError) {
                //       return Text('Error: ${snapshot.error}');
                //     } else {
                //       if (snapshot.hasData) {
                //         List<Service> availableServices = snapshot.data!;
                //         return buildServiceList(availableServices);
                //       } else {
                //         return Text('Không có dữ liệu.');
                //       }
                //     }
                //   },
                // ),

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
                        isExpanded: true, // Set this property to true
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
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  getImageAsset(value),
                                  width: value == 'Chuyển khoản'
                                      ? 25
                                      : 24, // Larger width for banking.png
                                  height: value == 'Chuyển khoản'
                                      ? 25
                                      : 24, // Larger height for banking.png
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
                            '0₫', // Số tiền tổng cộng, cần được tính toán hoặc lấy từ state
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

  Widget buildServiceList() {
    // A map of icons for each service, for example purposes

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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceSelectionPage(),
                )),
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
          // if (selectedServices?.isEmpty ?? true)
          //   Padding(
          //     padding: EdgeInsets.only(bottom: 10),
          //     child: Text(
          //       "Hãy chọn ít nhất 1 dịch vụ",
          //       style: TextStyle(
          //         color: Colors.red,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //       ),
          //     ),
          //   ),
          // Wrap(
          //   spacing: 10, // Horizontal space between chips
          //   runSpacing: 10, // Vertical space between chips
          //   children: availableServices.map((service) {
          //     bool isSelected =
          //         selectedServices?.contains(service.name) ?? false;
          //     return ChoiceChip(
          //       label: Text('${service.name} (${service.price}vnd)'),
          //       avatar: Icon(
          //         serviceIcons[service
          //             .name], // Use the corresponding icon for each service
          //         color: isSelected ? Colors.white : Colors.black54,
          //       ),
          //       selected: isSelected,
          //       onSelected: (value) {
          //         setState(() {
          //           if (value) {
          //             selectedServices?.add(service.name);
          //             totalPrice += service.price;
          //           } else {
          //             selectedServices?.remove(service.name);
          //             totalPrice -= service.price;
          //           }
          //         });
          //       },
          //       backgroundColor: Colors.grey[200],
          //       selectedColor: Theme.of(context).primaryColor,
          //       labelStyle: TextStyle(
          //         color: isSelected ? Colors.white : Colors.black,
          //       ),
          //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     );
          //   }).toList(),
          // ),
        ],
      ),
    );
  }
}
