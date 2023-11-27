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
import 'package:CarRescue/src/presentation/view/customer_view/service_details/widgets/service_select.dart';
import 'package:CarRescue/src/providers/car_customer_profile_provider.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RepairBody extends StatefulWidget {
  final LatLng latLng;
  final String address;
  final String carId;

  const RepairBody(
      {Key? key,
      required this.latLng,
      required this.address,
      required this.carId})
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
  CarCustomerProvider carCustomerProvider = CarCustomerProvider();
  CustomerCar? _car;
  final List<Map<String, dynamic>> dropdownItems = [
    {"name": "Quận 1", "value": 1},
    {"name": "Quận 2", "value": 2},
    {"name": "Quận 3", "value": 3},
    // Thêm các quận khác nếu cần
  ];
  bool isImageLoading = false;
  Future<List<Service>>? availableServices;
  List<Service> selectedServiceCards = [];
  late List<String> selectedServices;
  late List<String> urlImages;
  late String urlImage;
  late Map<String, dynamic> selectedDropdownItem;
  String? selectedPaymentOption;
  int totalPrice = 0;
  bool isLoading = false;

  @override
  void initState() {
    selectedDropdownItem = dropdownItems[0];
    selectedPaymentOption = 'CASH';
    urlImages = [];
    selectedServices = [];
    availableServices = loadService();
    getCustomerCar();
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

  void updateSelectedServices(Service service, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedServiceCards.add(service);
        caculateTotal();
      } else {
        selectedServiceCards.remove(service);
        caculateTotal();
      }
    });
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

  void caculateTotal() {
    int total = 0;
    for (Service service in selectedServiceCards) {
    total += service.price;
  }

  setState(() {
    totalPrice = total;
  });
  }

  void createOrder() async {
    if (selectedServiceCards.length == 0) {
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
      String destination =
          "lat: ${widget.latLng.latitude}, long: ${widget.latLng.longitude}"; // Không có thông tin đích đến
      String rescueType = "Fixing"; // Loại cứu hộ (ở đây là "repair")
      selectedServices =
          selectedServiceCards.map((service) => service.name).toList();

      // Bước 2: Tạo đối tượng Order
      OrderBookServiceFixing order = OrderBookServiceFixing(
        carId: widget.carId,
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
        } else if (status == 201) {
          notify.showToast("Hết kĩ thuật viên");
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
                        Column(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                    'assets/svg/edit_icon.svg')),
                            Container(
                              height: 10,
                            ),
                            // SizedBox(
                            //   height: 20,
                            //   child: CustomText(
                            //     text: widget.amount,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
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
              if (urlImages.isNotEmpty)
                Container(
                  height: 100, // Điều chỉnh chiều cao tùy ý
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Đặt hướng cuộn là ngang
                    itemCount: urlImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(
                            8.0), // Thêm khoảng cách giữa các hình ảnh
                        child: Image.network(
                          urlImages[index],
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
                              'Giá: ${selectedServiceCards[index].price}₫'),
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
                  SizedBox(height: 8.0), // Khoảng cách giữa nhãn và ô nhập liệu
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
                      hintText: 'Nhập ghi chú của bạn', // Gợi ý cho ô nhập liệu
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedPaymentOption,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedPaymentOption = newValue;
                          });
                        }
                      },
                      items: <String>['Chuyển khoản', 'Tiền mặt']
                          .map<DropdownMenuItem<String>>((String value) {
                        String mappedValue =
                            value == 'Chuyển khoản' ? 'BANKING' : 'CASH';

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
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final service = snapshot.data![index];
                      final isSelected = selectedServiceCards.contains(service);
                      return ServiceCard(
                        service: service,
                        onSelected: (isSelected) {
                          updateSelectedServices(service, isSelected);
                        },
                        isSelected: isSelected,
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Đặt cột để không chiếm quá nhiều không gian
              children: [
                SizedBox(height: 20), // Khoảng cách giữa tổng cộng tiền và nút
                SizedBox(
                  width: double.infinity, // Đặt chiều rộng bằng với Container
                  height: 50, // Đặt chiều cao cố định cho nút
                  child: ElevatedButton(
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrontendConfigs
                          .kIconColor, // Đảm bảo rằng màu này được định nghĩa trong FrontendConfigs
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Góc bo tròn cho nút
                      ),
                    ),
                    onPressed: () {
                      print(selectedServiceCards.length);
                      Navigator.pop(context);
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
}
