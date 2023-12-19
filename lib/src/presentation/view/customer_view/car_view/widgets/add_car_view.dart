import 'dart:convert';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/configuration/show_toast_notify.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/notification.dart';
import 'package:CarRescue/src/presentation/elements/car_brand.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/car_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddCarScreen extends StatefulWidget {
  final String userId;

  const AddCarScreen({super.key, required this.userId});
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  // ... All your variables ...
  List<int> yearList =
      List.generate(DateTime.now().year - 2010 + 1, (index) => index + 2010)
          .reversed
          .toList();
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  NotifyMessage _notify = NotifyMessage();

  File? vehicleImage;
  String _manufacturer = '';
  String _licensePlate = '';
  String _status = 'ACTIVE';
  String _vinNumber = '';

  String _color = '';
  int _manufacturingYear = 0;
  bool _isLoading = false;
  bool _isValidate = false;
  List<CarModel> carModelList = [];
  Map<String, String> modelNameToId = {};
  String _selectedModelId = '';
  List<CarBrand> _brands = [];
  String? _selectedBrand;
  String? _selectedType;
  bool _isFormConfirmed = false;
  String? accessToken = GetStorage().read<String>("accessToken");
  final titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  );
  void _submitForm() async {
    var uuid = Uuid();
    String randomId = uuid.v4();

    if (_formKey.currentState!.validate()) {
      await _showAlertDialog(context);
      if (_isFormConfirmed) {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });

        try {
          bool isSuccess = await authService.createCarforCustomer(randomId,
              customerId: widget.userId,
              licensePlate: _licensePlate,
              manufacturer: _manufacturer,
              status: _status,
              vinNumber: _vinNumber,
              modelId: _selectedModelId,
              color: _color,
              manufacturingYear: _manufacturingYear,
              vehicleImage: vehicleImage!);

          if (isSuccess) {
            setState(() {
              _isLoading = false;
              Navigator.pop(context, true);
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Thành công',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text(
                    'Đã lưu thông tin thành công',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Đóng'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Handle unsuccessful API response, e.g., show a snackbar with an error message.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to create car approval. Please try again.')),
            );
          }
        } catch (error) {
          Navigator.pop(context, false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred. Please try again.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<List<CarModel>> fetchModel() async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Model/GetAll';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        var dataField = data['data'];

        // Check if 'dataField' is a list before parsing
        if (dataField is List) {
          List<CarModel> carModelListAPI = dataField
              .map((modelData) => CarModel(
                    id: modelData['id'],
                    model1: modelData['model1'],
                    status: modelData['status'],
                  ))
              .toList();
          setState(() {
            carModelList = carModelListAPI;
          });

// After fetching car models
          for (var model in carModelListAPI) {
            modelNameToId[model.model1!] = model.id!;
          }

          print('ab:$carModelList');
          return carModelListAPI;
        } else {
          // Handle the case where 'dataField' is not a list
          throw Exception('Data is not in the expected format');
        }
      } else {
        // Handle the case where the response status code is not 200
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      // Handle any errors that occur during parsing or HTTP request
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchModel();
    fetchVehicleBrands().then((brands) {
      setState(() {
        _brands = brands;
      });
    });
  }

  Future<List<CarBrand>> fetchVehicleBrands() async {
    const String apiUrl =
        'https://carapi.app/api/makes'; // Replace with actual API URL
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> brandsJson =
          responseBody['data']; // Access the 'data' field

      return brandsJson.map((json) => CarBrand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicle brands');
    }
  }

  @override
  Widget build(BuildContext context) {
    // String? _selectedType =
    //     carModelList.isNotEmpty ? carModelList[0].model1 : '';

    return Stack(children: [
      Scaffold(
        appBar: customAppBar(context, text: 'Đăng kí xe mới', showText: true),
        body:
            _isLoading // If loading, show loading indicator, else show content
                ? LoadingState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thông tin chung', style: titleStyle),
                          Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: inputDecoration.copyWith(
                                        icon: Icon(Icons.drive_eta),
                                        labelText: 'Biển số xe',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          print(value);
                                          return 'Vui lòng nhập biển số xe';
                                        }
                                        RegExp regex = RegExp(
                                            r'^([1-9][1-9][A-Z]-\d{4,5})$');

                                        if (!regex
                                            .hasMatch(value.toUpperCase())) {
                                          return 'Biển số xe không hợp lệ';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _licensePlate = value!;
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _selectedBrand,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          print(value);
                                          return 'Vui lòng chọn hãng xe';
                                        }
                                        return null;
                                      },
                                      onChanged: (newValue) {
                                        setState(() {
                                          _manufacturer = newValue!;
                                        });
                                      },
                                      items: _brands
                                          .map<DropdownMenuItem<String>>(
                                              (CarBrand brand) {
                                        return DropdownMenuItem<String>(
                                          value: brand.name,
                                          child: Text(brand.name),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Chọn hãng xe',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width:
                                      12), // Some spacing between the fields and the image button
                              _buildAvatarField(
                                imageFile: vehicleImage,
                                onImageChange: (file) {
                                  if (file!.lengthSync() > 3 * 1024 * 1024) {
                                    // 3MB in bytes
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Ảnh quá lớn. Vui lòng tải lên ảnh dưới 3MB.')),
                                    );
                                  } else {
                                    setState(() {
                                      vehicleImage = file;
                                    });
                                  }
                                },
                                key: Key('avatar'),
                              ),
                            ],
                          ),
                          Text('Chi tiết kỹ thuật', style: titleStyle),
                          Divider(),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Số khung',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số khung';
                              } else if (value.length != 17) {
                                return 'Số khung phải chứa đúng 17 ký tự';
                              } else if (value.contains(RegExp(r'[^\w]'))) {
                                return 'Số khung chỉ có thể chứa số và chữ cái';
                              } else if (value.contains(RegExp(r'[IQO]'))) {
                                return 'Số khung không được chứa các ký tự I, Q, O';
                              }
                              _isValidate = true;
                              return null;
                            },
                            onSaved: (value) {
                              _vinNumber = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Loại xe',
                              labelStyle: TextStyle(fontSize: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn loại xe';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value ?? '';
                                _selectedModelId =
                                    modelNameToId[_selectedType] ?? '';
                              });
                            },
                            onSaved: (value) {
                              _selectedType = value ?? '';
                              _selectedModelId =
                                  modelNameToId[_selectedType] ?? '';
                            },
                            value: _selectedType != null ? _selectedType : null,
                            items: carModelList.map<DropdownMenuItem<String>>(
                                (CarModel model) {
                              return DropdownMenuItem<String>(
                                value: model.model1,
                                child: Text('${model.model1}'),
                              );
                            }).toList(),
                            hint: Text('Chọn loại xe'),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2 -
                                    20, // Giving it half of the screen width minus a small margin
                                padding: EdgeInsets.only(
                                    right:
                                        10), // Padding to add spacing between the two widgets
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Màu sắc',
                                    labelStyle: TextStyle(fontSize: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      print(value);
                                      return 'Vui lòng nhập màu sắc';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _color = value!;
                                  },
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2 -
                                    20, // Giving it half of the screen width minus a small margin
                                padding: EdgeInsets.only(
                                    left:
                                        10), // Padding to add spacing between the two widgets
                                child: DropdownButtonFormField<int>(
                                  decoration: inputDecoration.copyWith(
                                    labelText: 'Năm sản xuất',
                                    labelStyle: TextStyle(fontSize: 16),
                                  ),
                                  dropdownColor: Colors.grey[200],
                                  items: yearList.map((year) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: SizedBox(
                                        width: 60,
                                        child: Center(
                                          child: Text(year.toString()),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _manufacturingYear =
                                          value ?? DateTime.now().year;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Vui lòng chọn năm sản xuất';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _manufacturingYear =
                                        value ?? DateTime.now().year;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 170,
                          ),
                          Container(
                            alignment: Alignment
                                .bottomCenter, // Set the alignment to bottom center
                            child: ElevatedButton(
                              onPressed: () async {
                                _submitForm();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        FrontendConfigs.kActiveColor),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                minimumSize: MaterialStateProperty.all<Size>(
                                    Size(double.infinity, 50)),
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(vertical: 12)),
                              ),
                              child: Text('Lưu thông tin'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    ]);
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Xác nhận'),
              content: Text('Bạn đã chắc chắc điền đúng thông tin?'),
              actions: [
                TextButton(
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the AlertDialog
                  },
                ),
                TextButton(
                  child: Text(
                    'Chắc chắn',
                    style: TextStyle(color: FrontendConfigs.kActiveColor),
                  ),
                  onPressed: () {
                    // Use the provided setState from StatefulBuilder
                    setState(() {
                      _isFormConfirmed = true;
                    });

                    // Close the AlertDialog
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isEmpty(File? imageFile) {
    return imageFile == null;
  }

  Widget _buildImageField({
    required String label,
    required File? imageFile,
    required ValueChanged<File?> onImageChange,
    required Key key,
    //
    String validationMessage = 'Ảnh bắt buộc',
  }) {
    bool isValid = !_isEmpty(imageFile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              onImageChange(File(pickedFile.path));
            }
          },
          child: _getImageWidget(imageFile, key),
        ),
        if (!isValid)
          Transform.translate(
            offset: Offset(
                40, -40), // Set the offset to move the text up by 10 pixels
            child: imageFile == null
                ? Text(
                    validationMessage,
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox.shrink(),
          ) // Displaying a mandatory text in red when image is not uploaded
      ],
    );
  }

  Widget _buildAvatarField(
      {required File? imageFile,
      required ValueChanged<File?> onImageChange,
      required Key key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              onImageChange(File(pickedFile.path));
            }
          },
          child: _getImageWidget(imageFile, key),
        ),
        if (imageFile == null)
          Transform.translate(
            offset: Offset(
                40, -40), // Set the offset to move the text up by 10 pixels
            child: imageFile == null
                ? Text(
                    'Hình ảnh xe',
                  )
                : SizedBox.shrink(),
          ) // Displaying a mandatory text in red when image is not uploaded
      ],
    );
  }

  Widget _getImageWidget(File? imageFile, Key key) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 108,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: imageFile != null
              ? Image.file(imageFile, fit: BoxFit.cover)
              : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
        ),
        Visibility(
          visible: imageFile != null,
          child: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                if (key == Key('avatar')) {
                  vehicleImage = null;
                }
              });
            },
          ),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
        ),
      ],
    );
  }
}
