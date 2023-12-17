import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:CarRescue/src/models/manager.dart';
import 'package:CarRescue/src/models/symptom.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/change_rescue_type.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/map_tech_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/service_select.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_details/widgets/select_service.dart';
import 'package:CarRescue/src/presentation/view/technician_view/booking_list/widgets/selection_location_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/waiting_payment/waiting_payment.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/providers/order_provider.dart';
import 'package:CarRescue/src/providers/service_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:slider_button/slider_button.dart';
import '../widgets/customer_info.dart';
import '../../../../../models/booking.dart';
import '../../../../../models/payment.dart';
import 'package:intl/intl.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_details/widgets/customer_car_info.dart';
import 'dart:ui';

class BookingDetailsBody extends StatefulWidget {
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  final String userId;
  final String accountId;
  BookingDetailsBody(
      this.booking,
      this.addressesDepart,
      this.subAddressesDepart,
      this.addressesDesti,
      this.subAddressesDesti,
      this.userId,
      this.accountId);

  @override
  State<BookingDetailsBody> createState() => _BookingDetailsBodyState();
}

class _BookingDetailsBodyState extends State<BookingDetailsBody> {
  String? accessToken = GetStorage().read<String>("accessToken");
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController techNoteController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  bool _isLoading = false;
  int total = 0;
  AuthService authService = AuthService();
  OrderProvider orderProvider = OrderProvider();
  CustomerInfo? customerInfo;
  Technician? technicianInfo;
  Booking? _currentBooking;
  Payment? _payment;
  CustomerCar? _car;
  CarModel? _carModel;
  Symptom? selectedSymptom;
  List<String> _imageUrls = [];
  List<String> pickedImages = [];
  List<String> _updateImage = [];
  Future<List<Service>>? availableServices;
  List<Map<String, dynamic>> orderDetails = [];
  bool checkUpdate = false;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  NotifyMessage notifyMessage = NotifyMessage();
  List<Service> selectedServiceCards = [];
  late List<String> selectedServices;
  int totalPrice = 0;
  int totalQuantity = 0;
  int totalAmount = 0;
  final ScrollController _scrollController = ScrollController();
  double _savedScrollPosition = 0.0;
  Timer? myTimer;
  String? _orderId;
  String? _managerToken;
  String? _managerAccountId;
  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _loadCustomerInfo(widget.booking.customerId);
    _loadImageOrders(widget.booking.id);
    _loadTechInfo(widget.booking.technicianId);
    _calculateTotal(widget.booking.id);
    _loadPayment(widget.booking.id);
    _loadBooking(widget.booking.id);
    getCarData(widget.booking.carId ?? '');
    fetchServiceData(widget.booking.id);
    selectedServices = [];
    availableServices = loadService();
    _loadCreateLocation();
    // _loadLocation();
    print(widget.booking.status);
    _loadManagerId(widget.booking.managerId ?? '');
  }

  Future<void> _loadManagerId(String managerId) async {
    try {
      Manager? manager = await AuthService().fetchManagerProfile(managerId);
      print(manager!.deviceToken);
      setState(() {
        _managerToken = manager.deviceToken;
        _managerAccountId = manager.accountId;
      });
    } catch (e) {
      print('Error loading manager: $e');
      // Handle the error appropriately
    }
  }

  Future<void> _loadCreateLocation() async {
    try {
      Position? currentPosition = await getCurrentLocation();
      if (currentPosition != null) {
        await AuthService().createLocation(
          id: technicianInfo!.id,
          lat: '${currentPosition.latitude}',
          long: '${currentPosition.longitude}',
        );
      }
    } catch (e) {
      print('Error in _loadcreateLocation: $e');
    }
  }

  void loadUpdateLocation() async {
    try {
      Position? currentPosition = await getCurrentLocation();
      if (currentPosition != null) {
        await AuthService().updateLocation(
          id: widget.booking.technicianId,
          lat: '${currentPosition.latitude}',
          long: '${currentPosition.longitude}',
        );
        print(currentPosition);
      }
    } catch (error) {
      print('Error loading updateLocation: $error');
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request location permission from the user
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Handle the case where the user denied location permission
          print("User denied location permission");
          return null;
        }
      }

      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print("Error getting current location: $e");
      return null;
    }
  }

  Future<void> deleteServiceInOrder(String id) async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Order/DeleteOrderDetail?id=$id';

    final response =
        await http.put(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });
    print(response.statusCode);
    try {
      if (response.statusCode == 201) {
        print('Change status successfuly');
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Delete not ok: $e');
      // Handle the error appropriately
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

  Future<void> _loadBooking(String orderId) async {
    try {
      Booking updatedBooking = await authService.fetchBookingById(orderId);
      setState(() {
        _currentBooking = updatedBooking;
        _isLoading = false;
      });
      if (_currentBooking != null) {
        print('Booking ID: ${_currentBooking!.id}');
        print('Booking Status: ${_currentBooking?.status ?? 'N/A'}');
        // Access other properties in a similar way
      } else {
        print('The fetched booking is null.');
      }
    } catch (e) {
      print('Error loading payment: $e');
    }
  }

  Future<void> _updateService(
      String orderDetailId, int quantity, String service) async {
    setState(() {
      _isLoading = true;
    });
    final String apiUrl =
        "https://rescuecapstoneapi.azurewebsites.net/api/Order/ManagerUpdateService"; // Replace with your endpoint URL

    final response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode({
          'orderDetailId': orderDetailId,
          'quantity': quantity,
          'service': service
        }));
    final Map<String, dynamic> requestBody = {
      'orderDetailId': orderDetailId,
      'quantity': quantity,
      'service': service
    };
    print(requestBody);
    if (response.statusCode == 200) {
      print('Successfully update the car ${response.body}');
      setState(() {
        _isLoading = false;
      });
      onLoadingComplete();
    } else {
      print('Failed to update the car: ${response.body}');
    }
  }

  //

  Future<void> _loadPayment(String orderId) async {
    try {
      Map<String, dynamic>? paymentInfo =
          await authService.fetchPayment(widget.booking.id);
      print(paymentInfo);
      // Assuming Payment.fromJson is a constructor that returns a Payment object
      Payment payment = Payment.fromJson(paymentInfo);
      print(payment);
      setState(() {
        _payment = payment;

        _isLoading = false;
      });
    } catch (e) {
      // Handle any potential errors, such as network issues
      print('Error loading payment: $e');
      // Optionally, set some state to show an error message in the UI
    }
  }

  Future<void> _loadCustomerInfo(String customerId) async {
    Map<String, dynamic>? userProfile =
        await authService.fetchCustomerInfo(customerId);
    print('day la $userProfile');
    if (userProfile != null) {
      setState(() {
        customerInfo = CustomerInfo.fromJson(userProfile);
      });
    }
  }

  Future<void> _loadTechInfo(String techId) async {
    Map<String, dynamic>? techProfile =
        await authService.fetchTechProfile(techId);
    print('day la $techProfile');
    if (techProfile != null) {
      setState(() {
        technicianInfo = Technician.fromJson(techProfile);
      });
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
    setState(() {
      total = 0;
    });
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
    print("Loaded: ${imgData.length}");
    setState(() {
      _imageUrls.clear();
      _imageUrls = imgData;
    });
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

  void onSymptomSelected(Symptom? symptom) {
    setState(() {
      selectedSymptom = symptom;
      if (selectedSymptom != null) {
        print('Selected Symptom ID: ${selectedSymptom!.id}');
      }
    });
  }

  Future<void> fetchServiceData(String orderId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/OrderDetail/GetDetailsOfOrder?id=$orderId';

    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        setState(() {
          orderDetails = List<Map<String, dynamic>>.from(responseData['data']);
          print(orderDetails);
        });
        fetchServiceNameAndQuantity(
            orderDetails[0]['serviceId']); // Get the first serviceId
      } else {
        throw Exception('API response does not contain a valid list of data.');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<Map<String, dynamic>> fetchServiceNameAndQuantity(
      String serviceId) async {
    final apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Service/Get?id=$serviceId';

    final response =
        await http.get(Uri.parse(apiUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = data['data'];
        final String name = responseData['name'];
        final int price = responseData['price'];
        final int quantity = orderDetails
            .firstWhere((order) => order['serviceId'] == serviceId)['quantity'];

        return {'name': name, 'quantity': quantity, 'price': price};
      }
    }
    throw Exception('Failed to load service name and quantity from API');
  }

  Future<CustomerCar> getCarData(String carId) async {
    final String fetchCarUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Car/Get?id=$carId'; // Replace with your actual API endpoint for fetching car data

    final response =
        await http.get(Uri.parse(fetchCarUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    });
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];
        final carFromAPI = CustomerCar.fromJson(dataField);
        print(carFromAPI);
        setState(() {
          _car = carFromAPI;
        });
        _loadCarModel(_car?.modelId ?? '');
        // Assuming the response data is in the format you need
        return CustomerCar.fromJson(
            dataField); // Convert the data to a CustomerCar object
      } else {
        throw Exception('Failed to get car data from API');
      }
    } catch (e) {
      print('Error fetching CarModel: $e');
      throw Exception('Error fetching CarModel: $e');
    }
  }

  Future<void> _loadCarModel(String modelId) async {
    try {
      CarModel carModelAPI = await authService.fetchCarModel(modelId);
      // Use carModelAPI as needed
      setState(() {
        _carModel = carModelAPI;
      });
    } catch (e) {
      // Handle the exception
      print('Error loading CarModel: $e');
      // Optionally, implement additional error handling logic here
    }
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

  Future<void> updateOrder(
    String orderId,
    String staffNote,
    List<String> imageUrls,
  ) async {
    Future<bool> checkUpdateFuture = Future.value(false);
    print("UpdateOrder img: ${imageUrls.length}");
    try {
      final update = OrderProvider();
      checkUpdateFuture =
          update.updateOrderForTechnician(orderId, staffNote, imageUrls);
      if (checkUpdateFuture == Future.value(true)) {
        setState(() {
          checkUpdate = true;
        }); // Trả về true nếu cập nhật thành công
      } else {
        setState(() {
          checkUpdate = false;
        });
      }
      notifyMessage.showToast("Đã cập nhật.");
    } catch (error) {
      print('Lỗi khi cập nhật đơn hàng: $error');
      setState(() {
        checkUpdate = false;
      }); // Trả về false nếu có lỗi
    }
  }

  Widget _slider(bool type) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: double.infinity,
      child: SliderButton(
        alignLabel: Alignment.center,
        shimmer: true,
        baseColor: Colors.white,
        buttonSize: 45,
        height: 60,
        backgroundColor: FrontendConfigs.kActiveColor,
        action: () async {
          if (type) {
            final orderProvider = OrderProvider();
            print("Id: ${widget.booking.id}");
            await orderProvider.startOrder(widget.booking.id);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBarTechView(
                  accountId: technicianInfo?.accountId ?? '',
                  userId: technicianInfo?.id ?? '',
                ),
              ),
            );
          } else {
            final orderProvider = OrderProvider();
            print("Id: ${widget.booking.id}");
            dynamic data = await orderProvider.endOrder(widget.booking.id);
            AuthService().sendNotification(
                deviceId: _managerToken ?? '',
                isAndroidDevice: true,
                title: 'Thông báo từ kĩ thuật viên',
                body: 'Đơn hàng ${widget.booking.id} đã kết thúc',
                target: _managerAccountId ?? '',
                orderId: widget.booking.id);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingForPaymentScreen(
                  tech: technicianInfo!,
                  deviceToken: _managerToken ?? '',
                  managerId: _managerAccountId ?? '',
                  accountId: technicianInfo?.accountId ?? '',
                  addressesDepart: widget.addressesDepart,
                  subAddressesDepart: widget.subAddressesDepart,
                  addressesDesti: widget.addressesDesti,
                  subAddressesDesti: widget.subAddressesDesti,
                  booking: widget.booking,
                  payment: _payment!,
                  userId: technicianInfo?.id ?? '',
                  data:
                      data, // Pass the retrieved data to WaitingForPaymentScreen
                ),
              ),
            );
          }

          // @override
          // Widget build(BuildContext context) {
          //   // TODO: implement build
          //   throw UnimplementedError();
          // }
        },
        label: type
            ? const Text(
                "Bắt đầu",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )
            : const Text(
                "Kết thúc",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
        icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
      ),
    );
  }

  Widget _buildImageSection(List<String> imageUrls) {
    final allImages = [...imageUrls, ...pickedImages];
    print("Tong so anh:  ${allImages.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hình ảnh hiện trường'),
        Container(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10, // fixed to 5 slots for images
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
              else if (widget.booking.status.toUpperCase() == 'ASSIGNED' ||
                  widget.booking.status.toUpperCase() == 'INPROGRESS') {
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
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget buildBookingStatus(String status) {
    return BookingStatus(
      status: status,
      fontSize: 14,
    );
  }

  // Widget _buildOrderItemSection() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 4),
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomText(
  //           text: 'Tạm tính',
  //           fontWeight: FontWeight.bold,
  //           fontSize: 20,
  //         ),
  //         FutureBuilder<List<Service>>(
  //           future: _loadServicesOfCustomer(widget.booking.id),
  //           builder: (context, serviceSnapshot) {
  //             if (serviceSnapshot.connectionState == ConnectionState.waiting) {
  //               // Trạng thái đợi khi tải dữ liệu

  //               return CircularProgressIndicator();
  //             } else if (serviceSnapshot.hasError) {
  //               // Xử lý lỗi nếu có
  //               return Text('Error: ${serviceSnapshot.error}');
  //             } else {
  //               final List<Service> serviceList = serviceSnapshot.data!;

  //               if (serviceList.isEmpty) {
  //                 // Xử lý trường hợp danh sách dịch vụ rỗng
  //                 return Text('No services found.');
  //               }

  //               // Sử dụng ListView.builder ở đây để danh sách dịch vụ có thể cuộn một cách linh hoạt
  //               return ListView.builder(
  //                 shrinkWrap: true,
  //                 physics:
  //                     ScrollPhysics(), // Tắt tính năng cuộn của ListView này
  //                 itemCount: serviceList.length,
  //                 itemBuilder: (context, index) {
  //                   final service = serviceList[index];
  //                   final formattedPrice =
  //                       NumberFormat('#,##0₫', 'vi_VN').format(service.price);

  //                   return _buildInfoRow(
  //                     "${service.name}",
  //                     Text(
  //                       formattedPrice, // Sử dụng giá đã được định dạng
  //                       style: TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildPaymentMethod(String title, String total) {
    String displayTitle;
    if (title == 'Banking') {
      displayTitle = 'Trả bằng chuyển khoản';
    } else if (title == 'Cash') {
      displayTitle = 'Trả bằng tiền mặt';
    } else {
      displayTitle = 'Tổng cộng';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomText(
                text: displayTitle,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              SizedBox(width: 10.0),
              if (displayTitle == 'Trả bằng chuyển khoản')
                Image.asset(
                  'assets/images/banking.png',
                  height: 20,
                  width: 20,
                )
              else if (displayTitle == 'Trả bằng tiền mặt')
                Image.asset(
                  'assets/images/money.png', // Replace with your cash image asset
                  height: 20,
                  width: 20,
                )
            ],
          ),
          CustomText(
            text: total,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  // Widget _buildOrderItemSection() {
  //   int totalQuantity = 0; // Initialize total quantity
  //   int totalAmount = 0; // Initialize total amount
  //   return Column(
  //     children: [
  //       // Column(
  //       //   children: [
  //       //     Row(
  //       //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       //       children: [
  //       //         Row(
  //       //           children: [
  //       //             CustomText(
  //       //               text: 'Phí dịch vụ',
  //       //               fontSize: 16,
  //       //             ),
  //       //             SizedBox(
  //       //               width: 7,
  //       //             ),
  //       //             Tooltip(
  //       //               triggerMode: TooltipTriggerMode.tap,
  //       //               message:
  //       //                   'Phí dịch vụ mặc định được tính 300.000đ mỗi đơn hàng\n\nTổng cộng = Phí dịch vụ + (Đơn giá x Khoảng cách) ',
  //       //               textStyle: TextStyle(color: Colors.white),
  //       //               padding: EdgeInsets.all(8),
  //       //               margin: EdgeInsets.all(5),
  //       //               waitDuration: Duration(seconds: 1),
  //       //               showDuration: Duration(seconds: 7),
  //       //               child: Icon(Icons.info),
  //       //             ),
  //       //           ],
  //       //         ),
  //       //         CustomText(
  //       //           text: '300.000đ',
  //       //           fontWeight: FontWeight.bold,
  //       //           fontSize: 14,
  //       //         ),
  //       //       ],
  //       //     ),
  //       //   ],
  //       // ),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: orderDetails.map((orderDetail) {
  //           return FutureBuilder<Map<String, dynamic>>(
  //             // Key for FutureBuilder
  //             future: fetchServiceNameAndQuantity(
  //                 orderDetail['serviceId']), // Fetch service name and quantity
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.done) {
  //                 final name = snapshot.data?['name'] ?? 'Name not available';
  //                 final quantity = orderDetail['quantity'] ?? 0;
  //                 final price = snapshot.data?['price'] ?? 0;
  //                 int total = orderDetail['tOtal'] ??
  //                     1.0; // Updated to 'total' instead of 'tOtal'
  //                 final orderId = orderDetail['id'];
  //                 final formatter =
  //                     NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
  //                 final formattedTotal = formatter.format(total);

  //                 return Column(
  //                   children: [
  //                     _buildInfoRow(
  //                       '$name (Số lượng: $quantity) ',
  //                       Text(
  //                         '$formattedTotal',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       // Include quantity selection here
  //                     ),
  //                     Row(
  //                       children: [
  //                         IconButton(
  //                           icon: Icon(Icons.remove),
  //                           onPressed: () async {
  //                             if (quantity > 1) {
  //                               setState(() {
  //                                 _updateService(
  //                                   orderId,
  //                                   quantity - 1,
  //                                   name,
  //                                 );
  //                                 orderDetail['quantity'] = quantity - 1;

  //                                 // Recalculate total
  //                                 orderDetail['tOtal'] = (quantity - 1) * price;

  //                                 // Trigger refresh by changing the key
  //                               });

  //                               // Introduce a small delay before calling _loadPayment
  //                               await Future.delayed(
  //                                   Duration(milliseconds: 100));

  //                               // Now, call _loadPayment after a short delay
  //                               await _loadPayment(widget.booking.id);
  //                             }
  //                           },
  //                         ),
  //                         SizedBox(
  //                           width: 50,
  //                           height: 32,
  //                           child: TextFormField(
  //                             readOnly: true,
  //                             textAlign: TextAlign.center,
  //                             decoration: InputDecoration(
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             controller: TextEditingController(
  //                               text: quantity.toString(),
  //                             ),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: Icon(Icons.add),
  //                           onPressed: () async {
  //                             setState(() {
  //                               _updateService(
  //                                 orderId,
  //                                 quantity + 1,
  //                                 name,
  //                               );
  //                               orderDetail['quantity'] = quantity + 1;

  //                               // Recalculate total
  //                               orderDetail['tOtal'] = (quantity + 1) * price;

  //                               // Trigger refresh by changing the key
  //                             });

  //                             // Introduce a small delay before calling _loadPayment
  //                             await Future.delayed(Duration(milliseconds: 100));

  //                             // Now, call _loadPayment after a short delay
  //                             await _loadPayment(widget.booking.id);
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 );
  //               } else if (snapshot.hasError) {
  //                 return Text('Error fetching service name and quantity');
  //               } else {
  //                 return SizedBox.shrink(); // Show a loading indicator
  //               }
  //             },
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildOrderItemSection() {
    return Column(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              key: PageStorageKey<String>('page'),
              physics: ClampingScrollPhysics(),
              itemCount: orderDetails.length,
              itemBuilder: (context, index) {
                return _buildOrderDetail(orderDetails[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetail(Map<String, dynamic> orderDetail) {
    final quantityController = TextEditingController();
    quantityController.text = orderDetail['quantity'].toString();
    bool localIsLoading = false;

    // Generate a unique key for each Dismissible widget based on the orderDetail's id
    Key dismissibleKey = Key(orderDetail['id'].toString());

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchServiceNameAndQuantity(orderDetail['serviceId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data is Map<String, dynamic>) {
            final name = snapshot.data?['name'] ?? 'Name not available';
            var quantity = orderDetail['quantity'] ?? 0;
            final price = snapshot.data?['price'] ?? 0;
            int total = orderDetail['tOtal'] ?? 1;
            final orderId = orderDetail['id'];

            final formatter =
                NumberFormat.currency(symbol: '₫', locale: 'vi_VN');
            final formattedTotal = formatter.format(total);
            _orderId = orderId;
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isWideScreen = constraints.maxWidth > 600;
                return Stack(
                  children: [
                    widget.booking.status != "COMPLETED" &&
                            widget.booking.status != "CANCELLED"
                        ? Dismissible(
                            key: dismissibleKey, // Use a unique key
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _showConfirmationDialog(context);
                            },
                            onDismissed: (direction) async {
                              await _deleteOrderDetail(orderId);
                              // Optionally, you can add a snackbar or handle UI updates after deletion
                            },
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: Colors.red,
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),

                            child: Column(
                              children: [
                                _buildItemRow(
                                  '$name (Số lượng: $quantity) ',
                                  Text(
                                    '$formattedTotal',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  isLoading: localIsLoading,
                                ),
                                widget.booking.status.toUpperCase() !=
                                            'COMPLETED' &&
                                        widget.booking.status.toUpperCase() !=
                                            'CANCELLED' &&
                                        widget.booking.status.toUpperCase() !=
                                            'WAITING'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () async {
                                                  if (quantity > 1) {
                                                    setState(() {
                                                      localIsLoading = true;
                                                    });
                                                    await _updateOrderDetails(
                                                      orderDetail,
                                                      quantity - 1,
                                                      price,
                                                      (loading) {
                                                        setState(() {
                                                          localIsLoading =
                                                              loading;
                                                        });
                                                      },
                                                    );
                                                    await _delayedLoadPayment();
                                                  }
                                                },
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 50,
                                                height: 32,
                                                child: TextFormField(
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  controller:
                                                      quantityController,
                                                  onChanged: (value) {
                                                    quantity =
                                                        int.tryParse(value) ??
                                                            0;
                                                  },
                                                  onEditingComplete: () async {
                                                    setState(() {
                                                      localIsLoading = true;
                                                    });
                                                    await _updateOrderDetails(
                                                      orderDetail,
                                                      quantity,
                                                      price,
                                                      (loading) {
                                                        setState(() {
                                                          localIsLoading =
                                                              loading;
                                                        });
                                                      },
                                                    );
                                                    await _delayedLoadPayment();
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () async {
                                                  setState(() {
                                                    localIsLoading = true;
                                                  });
                                                  await _updateOrderDetails(
                                                    orderDetail,
                                                    quantity + 1,
                                                    price,
                                                    (loading) {
                                                      setState(() {
                                                        localIsLoading =
                                                            loading;
                                                      });
                                                    },
                                                  );
                                                  await _delayedLoadPayment();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              _buildItemRow(
                                '$name (Số lượng: $quantity) ',
                                Text(
                                  '$formattedTotal',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                isLoading: localIsLoading,
                              ),
                              widget.booking.status.toUpperCase() !=
                                          'COMPLETED' &&
                                      widget.booking.status.toUpperCase() !=
                                          'CANCELLED'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () async {
                                                if (quantity > 1) {
                                                  setState(() {
                                                    localIsLoading = true;
                                                  });
                                                  await _updateOrderDetails(
                                                    orderDetail,
                                                    quantity - 1,
                                                    price,
                                                    (loading) {
                                                      setState(() {
                                                        localIsLoading =
                                                            loading;
                                                      });
                                                    },
                                                  );
                                                  await _delayedLoadPayment();
                                                }
                                              },
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 50,
                                              height: 32,
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                controller: quantityController,
                                                onChanged: (value) {
                                                  quantity =
                                                      int.tryParse(value) ?? 0;
                                                },
                                                onEditingComplete: () async {
                                                  setState(() {
                                                    localIsLoading = true;
                                                  });
                                                  await _updateOrderDetails(
                                                    orderDetail,
                                                    quantity,
                                                    price,
                                                    (loading) {
                                                      setState(() {
                                                        localIsLoading =
                                                            loading;
                                                      });
                                                    },
                                                  );
                                                  await _delayedLoadPayment();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () async {
                                                setState(() {
                                                  localIsLoading = true;
                                                });
                                                await _updateOrderDetails(
                                                  orderDetail,
                                                  quantity + 1,
                                                  price,
                                                  (loading) {
                                                    setState(() {
                                                      localIsLoading = loading;
                                                    });
                                                  },
                                                );
                                                await _delayedLoadPayment();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink()
                            ],
                          ),
                    if (localIsLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          } else {
            return Text('Invalid data format');
          }
        } else if (snapshot.hasError) {
          return Text('Error fetching service name and quantity');
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn xóa dịch vụ này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOrderDetail(String id) async {
    setState(() {
      _isLoading = true; // Set loading to true before starting deletion
    });

    try {
      await deleteServiceInOrder(id);

      // Assuming you have a list of order details in your state
      // Update the list by removing the deleted item
      setState(() {
        orderDetails.removeWhere((detail) => detail['id'] == id);
        _delayedLoadPayment();
        _isLoading = false; // Set loading to false after deletion
      });
    } catch (error) {
      print('Error deleting order detail: $error');
      setState(() {
        _isLoading = false; // Set loading to false in case of an error
      });
    }
  }

  Future<void> _updateOrderDetails(Map<String, dynamic> orderDetail,
      int newQuantity, int price, Function(bool) setLoading) async {
    try {
      setLoading(true);

      // Perform your actual asynchronous operation here
      final snapshot =
          await fetchServiceNameAndQuantity(orderDetail['serviceId']);
      final name = snapshot['name'] ?? 'Name not available';
      await _updateService(orderDetail['id'], newQuantity, name);
      // Update the UI state
      setState(() {
        orderDetail['quantity'] = newQuantity;

        if (orderDetail['tOtal'] != null && orderDetail['tOtal'] is num) {
          orderDetail['tOtal'] = newQuantity * price;
        } else {
          orderDetail['tOtal'] = 0;
        }
      });
    } catch (e) {
      print('Exception in _updateOrderDetails: $e');
    } finally {
      // Ensure that setLoading(false) is always called, even if an exception occurs
      setLoading(false);
    }
  }

  Future<void> _delayedLoadPayment() async {
    await Future.delayed(Duration(milliseconds: 300));
    await _loadPayment(widget.booking.id);
  }

  Widget _buildInfoRow(String title, Widget value) {
    return ListTile(
      title: Text(title),
      subtitle: value,
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

  Widget _buildNoteRow(String label, GlobalKey key) {
    return Form(
      key: key,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: TextFormField(
              controller: techNoteController,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung ghi chú',
                border: OutlineInputBorder(),
              ),
              onTap: () {
                // Clear the hint text when the user taps on the text field
                setState(() {
                  techNoteController.text = '';
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? '' == value) {
                  return 'Hãy ghi chú';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void onLoadingComplete() {
    _scrollController.jumpTo(_savedScrollPosition);
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    return Stack(children: [
      Scaffold(
        backgroundColor: FrontendConfigs.kBackgrColor,
        body: ListView(key: PageStorageKey<String>('page'), children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        text: " ${widget.booking.id}",
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
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Khách hàng"),
                          widget.booking.status == 'ASSIGNED' &&
                                  widget.booking.status == 'INPROGRESS'
                              ? InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapTechScreen(
                                            car: _car!,
                                            model: _carModel!,
                                            cus: customerInfo!,
                                            booking: widget.booking,
                                            techImg:
                                                technicianInfo?.avatar ?? '',
                                            techId: technicianInfo?.id ?? '',
                                            techPhone:
                                                customerInfo?.phone ?? ''),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      // Add your section title
                                      Image.asset('assets/icons/location.png')
                                    ],
                                  ),
                                )
                              : Container()
                        ]),
                    CustomerInfoRow(
                      name: customerInfo?.fullname ?? '',
                      phone: customerInfo?.phone ?? '',
                      avatar: customerInfo?.avatar ??
                          'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431',
                    ),
                    if (customerInfo?.fullname != 'Khách Hàng Offline')
                      CustomerCarInfoRow(
                        manufacturer: _car?.manufacturer ?? 'Không có',
                        type: _carModel?.model1 ?? 'Không có',
                        licensePlate: _car?.licensePlate ?? 'Không có',
                        image: _car?.image ??
                            'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fcardefault.png?alt=media&token=8344e522-0e82-426f-93c9-6204a7e3a760',
                      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Đơn hàng'),
                        Flexible(
                          child: BookingStatus(
                            status: _currentBooking!.status,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: RideSelectionWidget(
                        icon: 'assets/svg/pickup_icon.svg',
                        title: widget.subAddressesDepart[widget.booking.id] ??
                            '', // Use addresses parameter

                        onPressed: () {},
                      ),
                    ),
                    _buildInfoRow(
                      "Loại dịch vụ",
                      Text(
                        widget.booking.rescueType == "Towing"
                            ? "Keo xe cứu hộ"
                            : (widget.booking.rescueType == "Fixing"
                                ? "Sửa chữa tại chỗ"
                                : widget.booking.rescueType),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: FrontendConfigs.kAuthColor,
                        ),
                      ),
                    ),
                    _buildInfoRow(
                        "Ghi chú của khách hàng",
                        Text(widget.booking.customerNote,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: FrontendConfigs.kAuthColor,
                                fontSize: 15))),
                    if (widget.booking.status.toUpperCase() == 'COMPLETED')
                      _buildInfoRow(
                        'Đánh giá',
                        Container(
                          child: RatingBar.builder(
                            itemSize: 19,
                            initialRating: widget.booking.rating ?? 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                      ),
                    if (widget.booking.status.toUpperCase() == 'COMPLETED')
                      _buildInfoRow(
                          'Nội dung đánh giá',
                          Text(
                            widget.booking.note ?? 'Không có',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    if (widget.booking.status == 'CANCELLED')
                      _buildInfoRow(
                          "Lí do hủy đơn",
                          Text(widget.booking.cancellationReason ?? 'Không có',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: FrontendConfigs.kAuthColor,
                                  fontSize: 15))),
                  ],
                ),
              ),

              // Image

              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  children: [
                    _buildImageSection(_imageUrls),
                  ],
                ),
              ),

              // _buildImageSection(imageUrls!),

              // Additional Details
              // You can replace this with the actual payment details
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    _buildSectionTitle("Ghi chú của kĩ thuật viên"),
                    if (widget.booking.status == "ASSIGNED" ||
                        widget.booking.status == "INPROGRESS")
                      _buildNoteRow("Nhập nội dung ghi chú", _formKey),
                    _buildInfoRow(
                        "Nội dung ghi chú",
                        Text('${_currentBooking?.staffNote ?? 'Không có'}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: FrontendConfigs.kAuthColor,
                                fontSize: 15))),
                  ],
                ),
              ),
              // Notes

              // Timing
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Thời gian"),
                    if (widget.booking.status != "ASSIGNED" &&
                        widget.booking.startTime != null)
                      _buildItemRow(
                        "Bắt đầu",
                        Text(
                          DateFormat('dd-MM-yyyy | HH:mm').format(widget
                              .booking.startTime!
                              .toUtc()
                              .add(Duration(hours: 14))),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: FrontendConfigs.kAuthColor,
                              fontSize: 15),
                        ),
                      ),
                    if (widget.booking.status != "ASSIGNED" &&
                        widget.booking.endTime != null)
                      _buildItemRow(
                        "Kết thúc ",
                        Text(
                          DateFormat('dd-MM-yyyy | HH:mm').format(widget
                              .booking.endTime!
                              .toUtc()
                              .add(Duration(hours: 14))),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: FrontendConfigs.kAuthColor,
                              fontSize: 15),
                        ),
                      ),
                    _buildItemRow(
                      "Được tạo lúc",
                      Text(
                        DateFormat('dd-MM-yyyy | HH:mm').format(widget
                            .booking.createdAt!
                            .toUtc()
                            .add(Duration(hours: 14))),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: FrontendConfigs.kAuthColor,
                            fontSize: 15),
                      ),
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle("Đơn giá"),
                        _buildSectionTitle(""),
                      ],
                    ),
                    Column(
                      children: [],
                    ),
                    Container(child: _buildOrderItemSection()),
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
                    _buildSectionTitle("Thanh toán"),
                    _buildInfoRow(
                        "Người trả",
                        Text('${customerInfo?.fullname ?? ''}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: FrontendConfigs.kAuthColor,
                                fontSize: 15))),
                    _buildInfoRow(
                        "Người nhận",
                        Text('${technicianInfo?.fullname ?? ''}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: FrontendConfigs.kAuthColor,
                                fontSize: 15))),
                  ],
                ),
              ),

              // Action Buttons

              SizedBox(height: 24.0), // Additional spacing at the bottom
            ],
          ),
        ]),
        bottomNavigationBar: Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (widget.booking.status != "COMPLETED" &&
                widget.booking.status != "CANCELLED" &&
                widget.booking.status != "WAITING")
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: widget.booking.status == "INPROGRESS"
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () async {
                          List<Service> selectedServices = selectedServiceCards
                              .where((service) =>
                                  selectedServiceCards.contains(service))
                              .toList();
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceSelectionScreen(
                                      userId: widget.userId,
                                      accountId: widget.accountId,
                                      selectedServices: selectedServices,
                                      booking: widget.booking,
                                      addressesDepart: widget.addressesDepart,
                                      subAddressesDepart:
                                          widget.subAddressesDepart,
                                      addressesDesti: widget.addressesDesti,
                                      subAddressesDesti:
                                          widget.subAddressesDesti,
                                    ),
                                  ))
                              .then(
                                  (value) => {_loadBooking(widget.booking.id)});
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildServiceList(context, "Chọn dịch vụ",
                                      Icon(Icons.add_box)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    widget.booking.status == "INPROGRESS"
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: GestureDetector(
                              onTap: () {
                                print(
                                    "IncidentID: ${widget.booking.indicentId}");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeRescueScreen(
                                        paymentMethod: _payment?.method ?? '',
                                        accountId: widget.accountId,
                                        userId: widget.userId,
                                        addressesDepart: widget.addressesDepart,
                                        addressesDesti: widget.addressesDesti,
                                        booking: widget.booking,
                                        subAddressesDepart:
                                            widget.subAddressesDepart,
                                        subAddressesDesti:
                                            widget.subAddressesDesti,
                                      ),
                                    ));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [SizedBox()],
                                    ),
                                    buildServiceList(context, "Chuyển đơn",
                                        Icon(Icons.next_plan)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPaymentMethod(
                        _payment?.method ?? '',
                        currencyFormat.format(_payment?.amount ?? 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.booking.status == "INPROGRESS") _slider(false),
            if (widget.booking.status == "ASSIGNED" ||
                widget.booking.status == "INPROGRESS")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 24.0),
                    AppButton(
                        width: double.infinity,
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          if (_formKey.currentState!.validate() &&
                              pickedImages.isNotEmpty) {
                            await uploadImage();
                            await updateOrder(widget.booking.id,
                                techNoteController.text, _updateImage);
                            // await _loadImageOrders(widget.booking.id);
                            await _loadTechInfo(widget.booking.technicianId);
                            await _loadBooking(widget.booking.id);

                            await _loadImageOrders(widget.booking.id);

                            setState(() {
                              techNoteController.clear();
                              _loadCustomerInfo(widget.booking.customerId);
                              _calculateTotal(widget.booking.id);
                            });
                          } else {
                            print("Note or pickedImages empty");
                            notifyMessage.showToast("Cần chụp ảnh hiện trường");
                            notifyMessage.showToast("Cần ghi chú");
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        btnLabel: checkUpdate
                            ? "Đang gửi về hệ thống"
                            : "Hoàn thiện đơn hàng"),
                  ],
                ),
              ),
          ]),
        ),

        // Conditionally display the order item section
      ),
      if (_isLoading)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: Center(
              child: LoadingState(),
            ),
          ),
        ),
    ]);
  }

  Widget buildServiceList(BuildContext context, String content, Icon icon) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon, // Biểu tượng dấu '+'
              SizedBox(width: 8.0), // Khoảng cách giữa biểu tượng và văn bản
              Text(
                content, // Văn bản bên cạnh biểu tượng
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Kích thước văn bản
                ),
              ),
            ],
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
                        rescueType: '',
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

  Widget _buildItemRow(String label, Widget value, {bool isLoading = false}) {
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
          value,
          isLoading ? LoadingState() : SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _imageUrls.clear();
    techNoteController.dispose();
    quantityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// // Usage:

// Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: orderDetails.map((orderDetail) {
//     return OrderDetailWidget(orderDetail: orderDetail);
//   }).toList(),
// ),
