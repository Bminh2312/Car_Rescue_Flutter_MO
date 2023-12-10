import 'dart:convert';

import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/car_model.dart';
import 'package:CarRescue/src/models/customer_car.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/loading_state.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/car_view.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UpdateCarScreen extends StatefulWidget {
  final String userId;
  final String accountId;
  CustomerCar? car;
  UpdateCarScreen(
      {super.key,
      required this.userId,
      required this.car,
      required this.accountId});
  @override
  _UpdateCarScreenState createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateCarScreen> {
  // ... All your variables ...
  List<int> yearList =
      List.generate(DateTime.now().year - 2010 + 1, (index) => index + 2010)
          .reversed
          .toList();
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();

  File? vehicleImage;
  String _manufacturer = '';
  String _licensePlate = '';
  String _status = '';
  String _vinNumber = '';
  String _selectedType = '';
  String _color = '';
  String id = '';
  int _manufacturingYear = 0;
  bool _isLoading = false;
  bool _isValidate = false;
  List<CarModel> carModelList = [];
  CarModel? carModel;
  // Create a Map to associate car types (model1) with modelIds
  Map<String, String> modelNameToId = {};

  // Initialize _selectedType with an empty string or a default value

  String _selectedModelId = '';
  final titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  );
  Future<bool> updateCarApproval({
    required String id,
    required String customerId,
    required String licensePlate,
    required String manufacturer,
    required String vinNumber,
    required String modelId,
    required String color,
    required String status,
    required int manufacturingYear,
    File? vehicleImage,
    String? vehicleImageUrl,
  }) async {
    // Construct the payload
    Map<String, dynamic> payload = {
      'id': id,
      'customerId': customerId,
      'licensePlate': licensePlate,
      'manufacturer': manufacturer,
      'vinNumber': vinNumber,
      'modelId': modelId,
      'color': color,
      'manufacturingYear': manufacturingYear.toString(),
      'status': status
    };

    payload['image'] = vehicleImage != null
        ? await authService.uploadImageToFirebase(
            vehicleImage, 'RVOvehicle_images/')
        : widget.car?.image;
    print(payload);
    // Make the API call
    var response = await http.put(
      Uri.parse('https://rescuecapstoneapi.azurewebsites.net/api/Car/Update'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    // Handle response
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  void _submitUpdateForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        bool isSuccess = await updateCarApproval(
            id: widget.car?.id ?? '',
            customerId: widget.userId,
            licensePlate: _licensePlate,
            manufacturer: _manufacturer,
            vinNumber: _vinNumber,
            modelId: _selectedModelId,
            color: _color,
            status: _status,
            manufacturingYear: _manufacturingYear,
            vehicleImage: vehicleImage);

        if (isSuccess) {
          setState(() {
            _isLoading = false;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CarListView(
                    userId: widget.userId,
                    accountId: widget.userId,
                  ),
                ));
          });

// Để hiển thị thông báo Toast
          Fluttertoast.showToast(
            msg: 'Hệ thống đã tiếp nhận thông tin.',
            toastLength: Toast.LENGTH_SHORT, // Độ dài hiển thị
            gravity: ToastGravity.CENTER, // Vị trí hiển thị
            timeInSecForIosWeb: 4, // Thời gian hiển thị (tính theo giây)
            backgroundColor: Colors.green, // Màu nền
            textColor: Colors.white, // Màu chữ
            fontSize: 16.0, // Kích thước chữ
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
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
    }
  }

  Future<List<CarModel>> fetchModel() async {
    final String apiUrl =
        'https://rescuecapstoneapi.azurewebsites.net/api/Model/GetAll';

    final response = await http.get(Uri.parse(apiUrl));

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
            modelNameToId[model.model1 ?? ''] = model.id ?? '';
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

  Future<void> _loadCarModel(String modelId) async {
    try {
      CarModel carModelAPI = await authService.fetchCarModel(modelId);
      // Use carModelAPI as needed
      setState(() {
        carModel = carModelAPI;
      });
    } catch (e) {
      // Handle the exception
      print('Error loading CarModel: $e');
      // Optionally, implement additional error handling logic here
    }
  }

  @override
  void initState() {
    super.initState();
    fetchModel();
    _loadCarModel(widget.car!.modelId!);
  }

  @override
  Widget build(BuildContext context) {
    String? _selectedType = carModelList.isNotEmpty ? carModel!.model1! : '';
    if (_isLoading) {
      Center(child: LoadingState());
    }
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
                                      initialValue: widget.car?.licensePlate,
                                      decoration: inputDecoration.copyWith(
                                        icon: Icon(Icons.drive_eta),
                                        labelText: 'Biển số',
                                      ),
                                      onSaved: (value) {
                                        _licensePlate = value!;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          print(value);
                                          return 'Vui lòng nhập biển số xe';
                                        }
                                        RegExp regex = RegExp(r'^([1-9][1-9][A-Z][A-Z1-9]-\d{4,5})$');

                                        if (!regex
                                            .hasMatch(value.toUpperCase())) {
                                          return 'Biển số xe không hợp lệ';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      initialValue: widget.car?.manufacturer,
                                      decoration: inputDecoration.copyWith(
                                        icon: Icon(Icons.drive_eta),
                                        labelText: 'Hãng xe',
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Vui lòng nhập hãng xe';
                                        }
                                        _isValidate = true;
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _manufacturer = value!;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width:
                                      12), // Some spacing between the fields and the image button
                              _buildAvatarField(
                                initialNetworkImageUrl: widget.car?.image,
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
                            initialValue: widget.car?.vinNumber,
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
                            value: _selectedType,
                            items: carModelList.map<DropdownMenuItem<String>>(
                                (CarModel model) {
                              return DropdownMenuItem<String>(
                                value: model.model1,
                                child: Text('${model.model1}'),
                              );
                            }).toList(),
                            hint: Text('Chọn loại xe'),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2 -
                                    20, // Giving it half of the screen width minus a small margin
                                padding: EdgeInsets.only(
                                    right:
                                        10), // Padding to add spacing between the two widgets
                                child: TextFormField(
                                  initialValue: widget.car?.color,
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
                                  value: widget.car!.manufacturingYear,
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
                          SizedBox(height: 16),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 -
                                20, // Half width minus margin
                            padding: EdgeInsets.only(
                                right: 10), // Spacing between widgets
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Trạng thái',
                                labelStyle: TextStyle(fontSize: 16),
                              ),
                              value: widget.car?.status != null &&
                                      ['ACTIVE', 'INACTIVE']
                                          .contains(widget.car?.status)
                                  ? widget.car?.status
                                  : null, // Set initial value
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng chọn trạng thái';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Update the state or handle the change
                                setState(() {
                                  _status = value!;
                                });
                              },
                              onSaved: (value) {
                                _status = value!;
                              },
                              items: <String>[
                                'ACTIVE',
                                'INACTIVE'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 150.0,
                          ),
                          Container(
                            alignment: Alignment
                                .bottomCenter, // Set the alignment to bottom center
                            child: ElevatedButton(
                              onPressed: () async {
                                _submitUpdateForm();
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
                              child: CustomText(
                                text: 'Cập nhật thông tin',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    ]);
  }

  // _showAlertDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Xác nhận'),
  //         content: Text('Bạn đã chắc chắc điền đúng thông tin chưa ? '),
  //         actions: [
  //           TextButton(
  //             child: Text(
  //               'Hủy',
  //               style: TextStyle(
  //                 color: Colors.red,
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the AlertDialog
  //             },
  //           ),
  //           TextButton(
  //             child: Text(
  //               'Chắc chắn',
  //               style: TextStyle(color: FrontendConfigs.kActiveColor),
  //             ),
  //             onPressed: () {
  //               _submitUpdateForm();
  //               Navigator.of(context)
  //                   .pop(); // Close the AlertDialog after submitting
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  bool _isEmpty(File? imageFile) {
    return imageFile == null;
  }

  Widget _buildImageField({
    required String label,
    required File? imageFile,
    required ValueChanged<File?> onImageChange,
    required Key key,
    String? networkImageUrl, // New parameter for network image URL
    String validationMessage = 'Ảnh bắt buộc',
  }) {
    bool isValid = imageFile != null ||
        (networkImageUrl != null && networkImageUrl.isNotEmpty);

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
          child: _getImageWidget(
            networkImageUrl: networkImageUrl,
            imageFile: imageFile,
            onRemove: () {
              setState(() {
                if (key == Key('avatar')) {
                  vehicleImage = null;
                }
              });
            },
          ),
        ),
        if (!isValid)
          Transform.translate(
            offset: Offset(40, -40),
            child: Text(
              validationMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarField({
    required File? imageFile,
    required ValueChanged<File?> onImageChange,
    required Key key,
    String? initialNetworkImageUrl,
  }) {
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
          child: _getImageWidget(
            imageFile: imageFile,
            networkImageUrl: initialNetworkImageUrl,
            onRemove: () {
              setState(() {
                if (key == Key('avatar')) {
                  vehicleImage = null;
                }
              });
            },
          ),
        ),
        if (imageFile == null && initialNetworkImageUrl == null)
          Transform.translate(
            offset: Offset(40, -40), // Adjust the offset as needed
            child: Text(
                'Hình ảnh xe'), // Text to display when no image is selected
          ),
      ],
    );
  }

  Widget _getImageWidget({
    File? imageFile,
    String? networkImageUrl,
    required VoidCallback onRemove,
  }) {
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
              : (networkImageUrl != null && networkImageUrl.isNotEmpty
                  ? Image.network(networkImageUrl, fit: BoxFit.cover)
                  : Icon(Icons.camera_alt, size: 50, color: Colors.grey)),
        ),
        Visibility(
          visible: imageFile != null ||
              (networkImageUrl != null && networkImageUrl.isNotEmpty),
          child: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: onRemove,
          ),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
        ),
      ],
    );
  }
}
