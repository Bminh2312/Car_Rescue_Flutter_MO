import 'dart:io';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/incident.dart';
import 'package:CarRescue/src/models/order_booking.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/symptom.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/home/layout/home_selection_widget.dart';
import 'package:CarRescue/src/presentation/view/customer_view/order_status/order_processing.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/widgets/service_select.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/widgets/symptom_selector.dart';
import 'package:CarRescue/src/providers/car_customer_profile_provider.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/incident_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:CarRescue/src/providers/symptom_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  Symptom? selectedSymptom;
  List<String> pickedImages = [];
  List<String> _updateImage = [];
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
  List<Symptom> _symptoms = [];
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
    selectedPaymentOption = 'Cash';
    urlImages = [];
    selectedServices = [];
    availableServices = loadService();
    getCustomerCar();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _updateImage.clear();
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
            _updateImage.add(imageUrl);
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

  Future<List<Symptom>> loadSymptom() async {
    final _symptomProvider = SymptomProvider();
    try {
      return _symptomProvider.getAllSymptoms();
    } catch (e) {
      print(e);
      return [];
    }
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
          urlImages.add(urlImage);
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

  Future<void> createOrder() async {
    if (selectedSymptom == null) {
      notify.showToast("Hãy chọn vấn đề bạn đang gặp phải.");
    } else {
      setState(() {
        isLoading = true; // Bắt đầu hiển thị vòng quay khi bắt đầu gửi yêu cầu
      });
      await uploadImage();
      print("Hình lên : ${_updateImage.length}");
      // Bước 1: Xác định thông tin cho đơn hàng
      String departure =
          "lat: ${widget.latLng.latitude}, long: ${widget.latLng.longitude}";
      String destination =
          "lat: ${widget.latLng.latitude}, long: ${widget.latLng.longitude}"; // Không có thông tin đích đến
      String rescueType = "Fixing"; // Loại cứu hộ (ở đây là "repair")
      selectedServices =
          selectedServiceCards.map((service) => service.name).toList();

      // Bước 2: Tạo đối tượng Order
      Incident incident = Incident(
        carId: widget.carId,
        paymentMethod: selectedPaymentOption!,
        departure: departure,
        destination: destination,
        rescueType: rescueType,
        customerId: customer.id,
        url: _updateImage,
        area: selectedDropdownItem['value'],
        symptomId: selectedSymptom!.id,
        distance: null,
      );

      // Bước 3: Gọi phương thức createOrder từ ServiceProvider
      final incidentProvider = IncidentProvider();
      try {
        // Gửi đơn hàng lên máy chủ
        final status = await incidentProvider.createIncident(incident);

        // Xử lý khi đơn hàng được tạo thành công
        // Ví dụ: Chuyển người dùng đến màn hình khác hoặc hiển thị thông báo

        // Dưới đây là một ví dụ chuyển người dùng đến màn hình BottomNavBarView
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
              body: 'Có một đơn hàng sửa chữa tại chỗ đã được gởi đến hệ thống',
              target: '4a30e2d2-149a-4442-817c-9e73ee4e4477',
              orderId: '');
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
        setState(() {
          _updateImage.clear();
        });
        // Ví dụ: Hiển thị thông báo lỗi cho người dùng
      } finally {
        // Kết thúc quá trình gửi đơn hàng (thành công hoặc thất bại), tắt vòng quay
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onSymptomSelected(Symptom? symptom) {
    setState(() {
      selectedSymptom = symptom;
      if (selectedSymptom != null) {
        print('Selected Symptom ID: ${selectedSymptom!.id}');
      }
    });
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
                      ],
                    ),
                  ),
                ),
              Container(
                height: 10,
              ),
              _buildSectionTitle('Khu vực hỗ trợ gần bạn'),
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
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  children: [
                    _buildImageSection(pickedImages),
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
              _buildSectionTitle('Vấn đề đang gặp'),
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: SymptomSelector(onSymptomSelected: onSymptomSelected)),
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
              _buildSectionTitle('Phương thức thanh toán'),
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
                    SizedBox(
                      width:
                          double.infinity, // Đặt chiều rộng bằng với Container
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
                            borderRadius:
                                BorderRadius.circular(8), // Góc bo tròn cho nút
                          ),
                        ),
                        onPressed: () async {
                          await createOrder();
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

  Widget _buildImageSection(List<String> imageUrls) {
    final allImages = [..._updateImage, ...pickedImages];
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
