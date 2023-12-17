import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/customer.dart';
import 'package:CarRescue/src/presentation/view/customer_view/bottom_nav_bar/bottom_nav_bar_view.dart';
import 'package:CarRescue/src/providers/firebase_storage_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:CarRescue/src/providers/customer_profile_provider.dart';
import 'package:flutter/material.dart';

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

  FirBaseStorageProvider fb = FirBaseStorageProvider();
  CustomerProfileProvider _profileProvider = CustomerProfileProvider();
  String phoneError = ''; // New
  String? accountId;
  String? _selectedGenderString;
  String? _profileImage;
  bool isImageLoading = false;
  DateTime? _selectedBirthday; // New
  String? _createdAt;
  DateTime _updateAt = DateTime.now();
  String? status = 'ACTIVE';
  late Future<Customer> customerFuture;
  late Customer customer;
  DateTime _birthday = DateTime(0000, 0, 0);
  @override
  void initState() {
    super.initState();
    customerFuture = _loadUserProfileData(widget.userId);
  }

  Future<Customer> _loadUserProfileData(String userId) async {
    // Map<String, dynamic>? userProfile =
    //     await authService.fetchTechProfile(userId);
    Customer userProfile = await _profileProvider.getCustomerById(userId);
    setState(() {
      customer = userProfile;
    });
    if (userProfile != null) {
      GetStorage().write('customer', userProfile.toJson());
      setState(() {
        _nameController.text = userProfile.fullname;
        _phoneController.text = userProfile.phone;
        _addressController.text = userProfile.address;
        _createdAt = userProfile.createAt;
        _profileImage = userProfile.avatar;
        // Retrieve and set the gender from the profile data
        if (userProfile.sex != '') {
          _selectedGenderString = userProfile.sex;
        }
        if (userProfile.birthdate != '') {
          _birthday = DateTime.parse(userProfile.birthdate);
          _birthdayController.text = DateFormat('dd/MM/yyyy').format(_birthday);
        }
      });
      return userProfile;
    } else {
      return Future.value(null);
    }
  }

  Future<void> updateProfile(Customer customer) async {
    // Cập nhật thông tin khách hàng với dữ liệu mới
    customer.fullname = _nameController.text;
    customer.phone = _phoneController.text;
    customer.address = _addressController.text;
    customer.createAt = _createdAt!;
    customer.updateAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(_updateAt);
    customer.status = status!;
    customer.avatar = _profileImage!;

    if (_selectedGenderString != null) {
      customer.sex = _selectedGenderString!;
    }
    if (_selectedBirthday != null) {
      customer.birthdate = _birthdayController.text;
    } else {
      String defaultDate = DateFormat('yyyy-MM-dd').format(_birthday);
      customer.birthdate = defaultDate;
    }

    // Gọi hàm cập nhật thông tin khách hàng từ _profileProvider
    bool checkUpdate = await _profileProvider.updateCustomer(customer);

    if (checkUpdate) {
      // Cập nhật thành công, bạn có thể thực hiện các thao tác khác (nếu cần)
      GetStorage().write('customer', customer.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      // Lỗi khi cập nhật
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The profile update failed')),
      );
    }
  }

  void captureImage() async {
    try {
      String newUrlImage = await fb.captureImage();
      if (newUrlImage.isNotEmpty) {
        print("Uploaded image URL: $newUrlImage");
        setState(() {
          _profileImage = newUrlImage;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Xử lý lỗi nếu có
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return SafeArea(
              child: SingleChildScrollView(
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
                              backgroundImage: _profileImage != null
                                  ? Image.network(_profileImage!).image
                                  // Sử dụng NetworkImage cho hình ảnh từ mạng
                                  : AssetImage(
                                      'assets/images/profile.png'), // Sử dụng AssetImage cho hình ảnh từ tài nguyên cục bộ
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
                                  onPressed: captureImage, // Open image picker
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

                            // Check if the input contains only numeric characters
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
                            Text('Nam',
                                style: TextStyle(fontFamily: 'Montserrat')),
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
                            Text('Nữ',
                                style: TextStyle(fontFamily: 'Montserrat')),
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
                              // DateTime? selectedDate = await showDatePicker(
                              //   context: context,
                              //   initialDate:
                              //       _selectedBirthday ?? DateTime.now(),
                              //   firstDate: DateTime(1900),
                              //   lastDate: DateTime.now(),
                              // );
                              // if (selectedDate != null &&
                              //     selectedDate != _birthday) {
                              //   setState(() {
                              //     _birthday = selectedDate;
                              //     _birthdayController.text =
                              //         DateFormat('dd-MM-yyyy')
                              //             .format(_birthday);
                              //   });
                              // }
                              _pickDate(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(_birthday),
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
                                backgroundColor: MaterialStatePropertyAll(
                                    FrontendConfigs.kPrimaryColor)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await updateProfile(customer);
                                setState(() {
                                  customerFuture =
                                      _loadUserProfileData(widget.userId);
                                });
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavBarView(page: 2),
                                  ),
                                  (route) =>
                                      false, // Loại bỏ tất cả các màn hình khỏi ngăn xếp
                                );
                              }
                            },
                            child: Text('Lưu thông tin'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null && selectedDate != _birthday) {
      setState(() {
        _birthday = selectedDate;
        _birthdayController.text = DateFormat('dd-MM-yyyy').format(_birthday);
      });
      print("date: ${_birthdayController.text}");
    }
  }
}
