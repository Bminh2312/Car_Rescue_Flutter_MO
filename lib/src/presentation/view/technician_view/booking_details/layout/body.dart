import 'dart:io';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customerInfo.dart';
import 'package:CarRescue/src/models/service.dart';
import 'package:CarRescue/src/models/technician.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/booking_status.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/booking_list/booking_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/presentation/view/technician_view/home/home_view.dart';
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
import 'package:intl/intl.dart';

class BookingDetailsBody extends StatefulWidget {
  final Booking booking;
  final Map<String, String> addressesDepart;
  final Map<String, String> subAddressesDepart;
  final Map<String, String> addressesDesti;
  final Map<String, String> subAddressesDesti;
  BookingDetailsBody(this.booking, this.addressesDepart,
      this.subAddressesDepart, this.addressesDesti, this.subAddressesDesti);

  @override
  State<BookingDetailsBody> createState() => _BookingDetailsBodyState();
}

class _BookingDetailsBodyState extends State<BookingDetailsBody> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController techNoteController = TextEditingController();
  bool _isLoading = true;
  int total = 0;
  AuthService authService = AuthService();
  CustomerInfo? customerInfo;
  Technician? technicianInfo;
  List<String> _imageUrls = [];
  List<String> pickedImages = [];
  bool checkUpdate = false;
  @override
  void initState() {
    super.initState();
    _loadCustomerInfo(widget.booking.customerId);
    _loadImageOrders(widget.booking.id);
    _loadTechInfo(widget.booking.technicianId);
    _calculateTotal(widget.booking.id);
    // _imageUrls.clear();
  }

  Future<void> _loadCustomerInfo(String customerId) async {
    Map<String, dynamic>? userProfile =
        await authService.fetchCustomerInfo(customerId);
    print('day la ${userProfile}');
    if (userProfile != null) {
      setState(() {
        customerInfo = CustomerInfo.fromJson(userProfile);
      });
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

  Future<void> _loadImageOrders(String id) async {
    final orderProvider = OrderProvider();
    List<String> imgData = await orderProvider.getUrlImages(id);
    setState(() {
      _imageUrls = imgData;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _showImageDialog(BuildContext context, String imageUrl) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: 400, // Set the width of the dialog as needed
              height: 400, // Set the height of the dialog as needed
              child: Image.network(
                imageUrl, // Display the tapped image
                fit: BoxFit.contain, // Fit the image to the dialog
              ),
            ),
          );
        },
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
        _imageUrls.clear();
        for (int index = 0; index < pickedImages.length; index++) {
          String? imageUrl =
              await upload.uploadImageToFirebaseStorage(pickedImages[index]);
          print(imageUrl);
          if (imageUrl != null) {
            setState(() {
              _imageUrls.add(imageUrl);
            });
            print('Image uploaded successfully. URL: $imageUrl');
          } else {
            print('Failed to upload image.');
          }
        }
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
        ;
      } catch (error) {
        print('Lỗi khi cập nhật đơn hàng: $error');
        setState(() {
          checkUpdate = false;
        }); // Trả về false nếu có lỗi
      }
    }
    

    Widget _slider(bool type) {
      return Container(
        width: double.infinity,
        child: SliderButton(
          alignLabel: Alignment.center,
          shimmer: true,
          baseColor: Colors.white,
          buttonSize: 45,
          height: 60,
          backgroundColor: FrontendConfigs.kActiveColor,
          action: () {
            if (type) {
              final orderProvider = OrderProvider();
              print("Id: ${widget.booking.id}");
              orderProvider.startOrder(widget.booking.id);
              Navigator.pushReplacement(context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarView(
                          accountId: technicianInfo!.accountId,
                          userId: technicianInfo!.id,
                          fullname: technicianInfo!.fullname!,
                        ),
                      ),
                    );
              // Navigator.push(context,
              //       MaterialPageRoute(
              //         builder: (context) => BookingListView(userId:technicianInfo!.id , accountId:technicianInfo!.accountId ,
              //             ),
              //       ),);
            }else{
              final orderProvider = OrderProvider();
              print("Id: ${widget.booking.id}");
              orderProvider.endOrder(widget.booking.id);
              Navigator.pushReplacement(context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBarView(
                          accountId: technicianInfo!.accountId,
                          userId: technicianInfo!.id,
                          fullname: technicianInfo!.fullname!,
                        ),
                      ),
                    );
            }
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Hình ảnh"),
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
                else if (widget.booking.status.toUpperCase() == 'ASSIGNED') {
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Center(
            child: CustomText(
              text: "Mã đơn hàng: ${widget.booking.id}",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(thickness: 3),
          // Increased spacing

          // Booking Information

          _buildSectionTitle("Thông tin khách hàng"),
          CustomerInfoRow(
            name: customerInfo?.fullname ?? '',
            phone: customerInfo?.phone ?? '',
          ),
          Divider(thickness: 3),
          _buildSectionTitle("Thông tin đơn hàng"),
          _buildInfoRow(
              "Trạng thái",
              BookingStatus(
                status: widget.booking.status,
              )),
          _buildInfoRow(
              "Điểm đi",
              Text(' ${widget.addressesDepart[widget.booking.id]}',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          if (widget.booking.rescueType == "Towing")
            _buildInfoRow(
                "Điểm đến",
                Text('${widget.addressesDesti[widget.booking.id]}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          _buildInfoRow(
              "Loại dịch vụ",
              Text(widget.booking.rescueType,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          _buildInfoRow(
              "Ghi chú",
              Text(widget.booking.customerNote,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Divider(thickness: 3),
          SizedBox(height: 15.0),

          // Image
          // if (_imageUrls.isNotEmpty)
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildImageSection(_imageUrls),
                  SizedBox(height: 15.0),
                  Divider(thickness: 1),
                ],
              ),
            ),
          ),
          // _buildImageSection(imageUrls!),

          // Additional Details
          // You can replace this with the actual payment details

          // Notes
          _buildSectionTitle("Ghi chú của kĩ thuật viên"),
          if (widget.booking.status == "ASSIGNED")
            _buildNoteRow("Ghi chú", _formKey),
          _buildInfoRow(
              "-",
              Text('${widget.booking.staffNote ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Divider(thickness: 3),
          SizedBox(height: 8.0),
          if (widget.booking.status != "ASSIGNED")
            _buildInfoRow(
                "-",
                Text('${widget.booking.staffNote ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          // Timing

          _buildSectionTitle("Thời gian"),
          if (widget.booking.status != "ASSIGNED")
            _buildInfoRow(
              "Bắt đầu",
              Text(
                DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(widget.booking.startTime ?? DateTime.now()),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          if (widget.booking.status != "ASSIGNED")
            _buildInfoRow(
              "Kết thúc ",
              Text(
                DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(widget.booking.endTime ?? DateTime.now()),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          _buildInfoRow(
            "Được tạo lúc",
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(widget.booking.createdAt ?? DateTime.now()),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 24.0),
          Divider(thickness: 3),
          SizedBox(height: 8.0),
          _buildOrderItemSection(),
          SizedBox(height: 24.0),
          Divider(thickness: 3),

          // Conditionally display the order item section
          _buildSectionTitle("Thanh toán"),
          _buildInfoRow(
              "Người trả",
              Text('${customerInfo?.fullname ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          _buildInfoRow(
              "Người nhận",
              Text('${technicianInfo?.fullname ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          _buildInfoRow(
              "Tổng tiền",
              Text('${total} vnd',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(height: 24.0),
          
          Divider(thickness: 3),
          // Action Buttons
          if (widget.booking.status == "ASSIGNED") _slider(true),
          if (widget.booking.status == "INPROGRESS") _slider(false),
          Divider(thickness: 3),
          if (widget.booking.status == "ASSIGNED")
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 24.0),
                  AppButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            pickedImages.isNotEmpty) {
                          await uploadImage();
                          if (_imageUrls.isNotEmpty) {
                            await updateOrder(widget.booking.id,
                                techNoteController.text, _imageUrls);
                            techNoteController.clear();
                            if (checkUpdate) {
                              setState(() {
                                _loadCustomerInfo(widget.booking.customerId);
                                _loadImageOrders(widget.booking.id);
                                _loadTechInfo(widget.booking.technicianId);
                                _calculateTotal(widget.booking.id);
                              });
                            }
                          } else {
                            print("Image empty");
                          }
                        } else {
                          print("Image empty");
                        }
                      },
                      btnLabel: checkUpdate
                          ? "Đang gửi về hệ thống"
                          : "Hoàn thiện đơn hàng"),
                ],
              ),
            ),
          SizedBox(height: 24.0), // Additional spacing at the bottom
        ],
      ),
    );
  }

  Widget buildBookingStatus(String status) {
    return BookingStatus(status: status);
  }

  Widget _buildOrderItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Đơn giá"), // Customize the section title
        // Add order item details here

        FutureBuilder<List<Service>>(
          future: _loadServicesOfCustomer(widget.booking.id),
          builder: (context, serviceSnapshot) {
            if (serviceSnapshot.connectionState == ConnectionState.waiting) {
              // Trạng thái đợi khi tải dữ liệu
              return CircularProgressIndicator();
            } else if (serviceSnapshot.hasError) {
              // Xử lý lỗi nếu có
              return Text('Error: ${serviceSnapshot.error}');
            } else {
              // Hiển thị dữ liệu khi đã có kết quả
              final List<Service> serviceList = serviceSnapshot.data!;

              if (serviceList.isEmpty) {
                // Xử lý trường hợp danh sách dịch vụ rỗng
                return Text('No services found.');
              }

              // Sử dụng ListView.builder ở đây để danh sách dịch vụ có thể cuộn một cách linh hoạt
              return ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(), // Tắt tính năng cuộn của ListView này
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final service = serviceList[index];
                  return _buildInfoRow(
                    "${service.name}",
                    Text(
                      "${service.price} vnd", // Sử dụng giá từ đối tượng Service
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
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

  Widget _buildNoteRow(String label, GlobalKey key) {
    return Form(
        key: key,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: TextFormField(
                controller: techNoteController,
                decoration: InputDecoration(
                  labelText: label,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Hãy ghi chú';
                  }
                  return null;
                },
              )),
              SizedBox(width: 8.0), // Add spacing between label and value
            ],
          ),
        ));
  }
}
