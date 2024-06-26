import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfileItem {
  final int id;
  final String fullName;
  final String phone;
  final String address;
  final DateTime birthdate;

  ProfileItem({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.birthdate,
  });
}

class EditProfileBody extends StatefulWidget {
  final String userId;
  final String accountId;

  EditProfileBody({Key? key, required this.userId, required this.accountId})
      : super(key: key);

  @override
  _EditProfileBodyState createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<EditProfileBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  NotifyMessage notify = NotifyMessage();
  String phoneError = ''; // New
  String? accountId;
  String? _selectedGenderString;
  String? _profileImage;
  String? _downloadURL;
  String? downloadURL;
  int? _area;
  String? _status;
// Chuyển đổi sang đối tượng DateTime
  String updatedAtString = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final ImagePicker imagePicker = ImagePicker();
  AuthService authService = AuthService();
  DateTime? _birthday;
  bool _profileImageChanged = false;
  bool _isUpdating = false;
  bool checkImage = false;
  bool _isLoading = false;
  String? accessToken = GetStorage().read<String>("accessToken");
  @override
  void initState() {
    super.initState();
    _loadUserProfileData(widget.userId);
  }

  Future<void> _loadUserProfileData(String userId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic>? userProfile =
        await authService.fetchTechProfile(userId);

    if (userProfile != null) {
      final Map<String, dynamic> data = userProfile['data'];
      setState(() {
        _nameController.text = data['fullname'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        downloadURL = data['avatar'];
        _status = data['status'];
        _area = data['area'];
        // Retrieve and set the gender from the profile data
        final String? genderString = data['sex'];
        if (genderString != null) {
          _selectedGenderString = genderString;
        }
        String? birthdateString = data['birthdate'];
        if (birthdateString != null) {
          _birthday = DateTime.parse(birthdateString);
          _birthdayController.text =
              DateFormat('dd/MM/yyyy').format(_birthday!);
        } else {
          _birthday = null;
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> updateProfile({
    required String userId,
    required String accountId,
    required String name,
    required String phone,
    required String address,
    required String birthdate,
    required String sex,
    required String updateAt,
    required int area,
    required String status,
  }) async {
    final Map<String, dynamic> requestBody = {
      'id': userId,
      'accountId': accountId,
      'fullname': name,
      'phone': phone,
      'address': address,
      'sex': sex,
      'birthdate': birthdate,
      'avatar': _downloadURL,
      'updateAt': updateAt,
      'status': status,
      'area': area
    };

    final response = await http.put(
      Uri.parse(
          'https://rescuecapstoneapi.azurewebsites.net/api/Technician/Update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(requestBody),
    );

    print(response.statusCode);
    final List userData = [
      userId,
      accountId,
      name,
      phone,
      address,
      sex,
      _downloadURL
    ];
    print(userData);

    if (response.statusCode == 200) {
      // Update the state with the updated profile data
      setState(() {
        _nameController.text = name;
        _phoneController.text = phone;
        _addressController.text = address;
        _selectedGenderString = sex;
        _profileImageChanged = false;
        // _downloadURL = _downloadURL;
        _isUpdating = false;
        updatedAtString = updateAt;
        _status = status;
        _area = area;
      });

      print(_downloadURL);
      // Display a success message to the user
      notify.showToast('Cập nhật thông tin thành công');
      return true;
    } else {
      _isUpdating = false;
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    return false;
  }

  // Future<void> _pickImage() async {
  //   XFile? pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     File file = File(pickedFile.path);
  //     int sizeInBytes = file.lengthSync();
  //     double sizeInMB = sizeInBytes / (1024 * 1024);

  //     if (sizeInMB > 3) {
  //       // File quá lớn, hiển thị lỗi
  //       notify.showErrorToast('Kích thước hình ảnh phải nhỏ hơn 3MB');
  //       return;
  //     }

  //     // File hợp lệ, tiếp tục
  //     imageCache.clear();

  //     setState(() {
  //       _profileImage = file;
  //       _profileImageChanged = true;
  //     });
  //   }
  // }

  Future<void> uploadImage() async {
    final upload = FirBaseStorageProvider();

    if (_downloadURL != null) {
      print(_downloadURL);
      String? imageUrl =
          await upload.uploadImageToFirebaseStorage(_downloadURL!);
      print(imageUrl);
      if (imageUrl != null) {
        setState(() {
          _downloadURL = imageUrl;
          checkImage = false;
        });
        print('Image uploaded successfully. URL: $imageUrl');
      } else {
        print('Failed to upload image.');
        setState(() {
          checkImage = true;
        });
      }
    } else {
      print('No image selected.');
      setState(() {
        _downloadURL = downloadURL;
        checkImage = false;
      });
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

  void _addImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Add the file path to your imageUrls list
      setState(() {
        _downloadURL = pickedFile.path;
        checkImage = true;
      });
    } else {
      print('No image selected.');
      checkImage = false;
    }
  }

  void _addImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Add the file path to your imageUrls list
      setState(() {
        _downloadURL = pickedFile.path;
        checkImage = true;
      });
    } else {
      print('No image selected.');
      checkImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingState()
        : SafeArea(
      child: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE0AC69),
                                Color(0xFF8D5524),
                              ],
                            ),
                          ),
                          height: 120,
                        ),
                      ),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: checkImage
                            ? _downloadURL != ''
                                ? Image.file(File(_downloadURL!)).image
                                : Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431')
                                    .image
                            : downloadURL != null
                                ? Image.network(downloadURL!).image
                                : Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/car-rescue-399511.appspot.com/o/profile_images%2Fdefaultava.jpg?alt=media&token=72b870e8-a42d-418c-af41-9ff4acd41431')
                                    .image,
                      ),
                      Positioned(
                        bottom: 60,
                        right: 120,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            color: Colors.white,
                            onPressed: () {
                              showCancelOrderDialog(context);
                            }, // Open image picker
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên đầy đủ',
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: TextStyle(fontFamily: 'Montserrat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy nhập họ tên đầy đủ';
                      }

                      // Check if the input contains any numeric characters
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Tên không được chứa số';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    style: TextStyle(fontFamily: 'Montserrat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy nhập số điện thoại.';
                      }
                      if (value.length != 10) {
                        return 'Số điện thoại phải bao gồm 10 số.';
                      }

                      // Check if the input contains any alphabetic characters
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Số điện thoại chỉ được chứa các chữ số.';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    style: TextStyle(fontFamily: 'Montserrat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Giới tính',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Row(
                    children: [
                      Radio(
                        activeColor: FrontendConfigs.kIconColor,
                        value: 'Nam',
                        groupValue: _selectedGenderString,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedGenderString = value;
                          });
                        },
                      ),
                      Text('Nam', style: TextStyle(fontFamily: 'Montserrat')),
                      Radio(
                        activeColor: FrontendConfigs.kIconColor,
                        value: 'Nữ',
                        groupValue: _selectedGenderString,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedGenderString = value;
                          });
                        },
                      ),
                      Text('Nữ', style: TextStyle(fontFamily: 'Montserrat')),
                    ],
                  ),
                  Text(
                    'Ngày sinh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                      onTap: () async {
                        DateTime currentDate = DateTime.now();
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _birthday ?? currentDate,
                          firstDate: DateTime(1900),
                          lastDate: currentDate,
                        );

                        if (selectedDate != null) {
                          // Kiểm tra xem ngày sinh đã đủ 18 tuổi chưa
                          if (currentDate.difference(selectedDate).inDays <
                              365 * 18) {
                            // Hiển thị thông báo hoặc thực hiện các xử lý khác nếu ngày sinh không đủ 18 tuổi
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text(
                                      'Bạn phải đủ 18 tuổi để sử dụng ứng dụng.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              _birthday = selectedDate;
                              _birthdayController.text =
                                  DateFormat('yyyy-MM-dd').format(_birthday!);
                            });
                            print("Ngày sinh: ${_birthdayController.text}");
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _birthday != null
                                ? Text(
                                    DateFormat('dd-MM-yyyy').format(_birthday!),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    "Chưa có ngày sinh",
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Montserrat')),
                          backgroundColor: MaterialStatePropertyAll(
                              FrontendConfigs.kPrimaryColor),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isUpdating = true;
                          });
                          // String? downloadURL;
                          // if (_profileImage != null && _profileImageChanged) {
                          //   downloadURL =
                          //       await authService.uploadImageToFirebase(
                          //           _profileImage!, 'RVOprofile_images/');
                          //   if (downloadURL == null) {
                          //     notify.showErrorToast('Có lỗi xảy ra');
                          //     return; // Exit the function, don't proceed to updateProfile
                          //   }
                          // }

                          String selectedGender = _selectedGenderString ?? '';
                          String formattedBirthdate =
                              DateFormat('yyyy-MM-dd').format(_birthday!);
                          await uploadImage();
                          bool isSuccess = await updateProfile(
                              area: _area ?? 0,
                              status: _status!,
                              userId: widget.userId,
                              accountId: widget.accountId,
                              name: _nameController.text,
                              phone: _phoneController.text,
                              address: _addressController.text,
                              birthdate: formattedBirthdate,
                              sex: selectedGender,
                              updateAt: updatedAtString);
                          if (isSuccess) {
                            setState(() {
                              _isUpdating = false;
                            });
                          }
                          Navigator.pop(context, true);
                        }
                        setState(() {
                          _isUpdating = false;
                        });
                      },
                      child: Text('Lưu thông tin'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isUpdating)
          Opacity(
            opacity: 0.5,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ),
        if (_isUpdating) LoadingState()
      ]),
    );
  }
}
