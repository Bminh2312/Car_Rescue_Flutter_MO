import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/order_booking.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';

import 'package:CarRescue/src/presentation/view/customer_view/home/layout/home_selection_widget.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RepairBody extends StatefulWidget {
  final LatLng latLng;
  final String address;

  const RepairBody({Key? key, required this.latLng, required this.address})
      : super(key: key);

  @override
  State<RepairBody> createState() => _RepairBodyState();
}

class _RepairBodyState extends State<RepairBody> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController paymentMethodController = TextEditingController();
  TextEditingController customerNoteController = TextEditingController();
  FirBaseStorageProvider fb = FirBaseStorageProvider();
  NotifyMessage notify = NotifyMessage();
  Customer customer = Customer.fromJson(GetStorage().read('customer') ?? {});
  final List<Map<String, dynamic>> dropdownItems = [
    {"name": "Quận 1", "value": 1},
    {"name": "Quận 2", "value": 2},
    {"name": "Quận 3", "value": 3},
    // Thêm các quận khác nếu cần
  ];
  bool isImageLoading = false;
  Future<List<Service>>? availableServices;
  late List<String> selectedServices;
  late List<String> urlImages;
  late String urlImage;
  late Map<String, dynamic> selectedDropdownItem;
  late String selectedPaymentOption;
  int totalPrice = 0;
  bool isLoading = false;

  @override
  void initState() {
    selectedDropdownItem = dropdownItems[0];
    selectedPaymentOption = '';
    urlImages = [];
    selectedServices = [];
    availableServices = loadService();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Service>> loadService() async {
    final serviceProvider = ServiceProvider();
    try {
      return serviceProvider.getAllServicesFixing();
    } catch (e) {
      // Xử lý lỗi khi tải dịch vụ
      print('Lỗi khi tải danh sách dịch vụ: $e');
      return [];
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

  void createOrder() async {
    if (selectedServices.length == 0) {
      notify.showToast("Hãy chọn ít nhất 1 dịch vụ.");
    } else if (selectedPaymentOption == '') {
      notify.showToast("Hãy chọn loại thanh toán.");
    } else if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Bắt đầu hiển thị vòng quay khi bắt đầu gửi yêu cầu
      });

      // Bước 1: Xác định thông tin cho đơn hàng
      String departure =
          "lat: ${widget.latLng.latitude}, long: ${widget.latLng.longitude}";
      String destination = ""; // Không có thông tin đích đến
      String rescueType = "Fixing"; // Loại cứu hộ (ở đây là "repair")

      // Bước 2: Tạo đối tượng Order
      OrderBookServiceFixing order = OrderBookServiceFixing(
        paymentMethod: paymentMethodController.text,
        customerNote: customerNoteController.text,
        departure: departure,
        destination: destination,
        rescueType: rescueType,
        customerId: customer.id,
        url: urlImages,
        service: selectedServices,
        area: selectedDropdownItem['value'],
      );

      // Bước 3: Gọi phương thức createOrder từ ServiceProvider
      final orderProvider = OrderProvider();
      try {
        // Gửi đơn hàng lên máy chủ
        final status = await orderProvider.createOrderFixing(order);

        // Xử lý khi đơn hàng được tạo thành công
        // Ví dụ: Chuyển người dùng đến màn hình khác hoặc hiển thị thông báo

        // Dưới đây là một ví dụ chuyển người dùng đến màn hình BottomNavBarView
        if (status == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBarView(page: 0),
            ),
            (route) => false, // Loại bỏ tất cả các màn hình khỏi ngăn xếp
          );
          notify.showToast("Tạo đơn thành công");
        } else if (status == 500) {
          notify.showToast("External error");
        } else {
          notify.showToast("Lỗi đơn hàng");
        }
      } catch (e) {
        // Xử lý khi có lỗi khi gửi đơn hàng
        print('Lỗi khi tạo đơn hàng: $e');
        // Ví dụ: Hiển thị thông báo lỗi cho người dùng
      } finally {
        // Kết thúc quá trình gửi đơn hàng (thành công hoặc thất bại), tắt vòng quay
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 10,
              ),
              HomeSelectionWidget(
                  icon: 'assets/svg/pickup_icon.svg',
                  title: 'Pick up Location',
                  body: widget.address,
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //       builder: (context) => HomeView(services: "repair")),
                    // );
                    Navigator.of(context).pop();
                  }),

              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedDropdownItem,
                onChanged: (newValue) {
                  setState(() {
                    selectedDropdownItem = newValue!;
                  });
                },
                items: dropdownItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(item["name"]),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Khu vực hỗ trợ',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Hãy chọn một mục trong dropdown';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  if (!isImageLoading) {
                    setState(() {
                      isImageLoading = true;
                    });
                  }
                  // Xử lý khi người dùng nhấp vào biểu tượng '+'
                  // Chuyển qua camera ở đây
                  captureImage();
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hình ảnh chứng thực (nếu có)',
                    prefixIcon: isImageLoading
                        ? CircularProgressIndicator() // Hiển thị biểu tượng xoay khi đang tải
                        : Icon(Icons.add_box), // Biểu tượng dấu '+'
                  ),
                ),
              ),
              if (urlImages!.isNotEmpty)
                Container(
                  height: 100, // Điều chỉnh chiều cao tùy ý
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Đặt hướng cuộn là ngang
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
              // Tôi cần 1 cái drop dow các dịch vụ và chọn được nhìu lần
              FutureBuilder<List<Service>>(
                future:
                    availableServices, // Thay bằng hàm lấy dữ liệu thích hợp
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.hasData) {
                      List<Service> availableServices = snapshot.data!;
                      return buildServiceList(availableServices);
                    } else {
                      return Text('Không có dữ liệu.');
                    }
                  }
                },
              ),

              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: customerNoteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Hãy ghi chú';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset('assets/images/momo.png'),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("Trả bằng momo"),
                    ],
                  ),
                  value: "BANKING",
                  groupValue: selectedPaymentOption,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentOption = value!;
                    });
                  },
                  activeColor: Color(0xFF5BB85D)),
              RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset('assets/images/money.png'),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("Trả bằng tiền mặt"),
                    ],
                  ),
                  value: "CASH",
                  groupValue: selectedPaymentOption,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentOption = value!;
                    });
                  },
                  activeColor: Color(0xFF5BB85D)),
              const SizedBox(
                height: 10,
              ),
              AppButton(
                onPressed: () => createOrder(),
                btnLabel: isLoading
                    ? 'Đang tạo đơn hàng...'
                    : "Đặt cứu hộ (Giá ${totalPrice})",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServiceList(List<Service> availableServices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dịch vụ hiện có", // Tiêu đề
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        if (selectedServices.isNotEmpty != true)
          Text(
            "Hãy chọn ít nhất 1 dịch vụ",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ...availableServices.map((service) {
          return Row(
            children: [
              Checkbox(
                value: selectedServices.contains(service.name),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedServices.add(service.name);
                      setState(() {
                        totalPrice += service.price;
                      });
                    } else {
                      selectedServices.remove(service.name);
                      setState(() {
                        totalPrice -= service.price;
                      });
                    }
                  });
                },
              ),
              Text('${service.name} (Giá: ${service.price}vnd)'),
            ],
          );
        }).toList(),
      ],
    );
  }
}
