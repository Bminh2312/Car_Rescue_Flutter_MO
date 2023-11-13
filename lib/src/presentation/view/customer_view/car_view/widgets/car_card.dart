import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/car_view/widgets/car_status.dart';
import 'package:CarRescue/src/presentation/view/customer_view/car_view/widgets/update_car_view.dart';
import 'package:flutter/material.dart';
import '../../../../../models/vehicle_item.dart';

class CarCard extends StatelessWidget {
  final Vehicle vehicle;

  CarCard({required this.vehicle});

  void _showCarDetails(BuildContext context, String id) {
    // Assuming that you have properly initialized the 'car' object

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            color: FrontendConfigs.kBackgrColor,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Image(image: NetworkImage(vehicle.image ?? '')),
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'Trạng thái',
                            style: TextStyle(
                              fontSize: 16.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CarStatus(status: vehicle.status),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    _buildDetailItem('Nhà sản xuất', vehicle.manufacturer),
                    _buildDetailItem('Số khung', vehicle.vinNumber),
                    _buildDetailItem('Biển số xe', vehicle.licensePlate),
                    _buildDetailItem('Màu sắc', vehicle.color),
                    _buildDetailItem(
                        'Năm sản xuất', vehicle.manufacturingYear.toString()),
                    _buildDetailItem('Loại xe', vehicle.type),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: vehicle.status.toUpperCase() == 'ACTIVE'
                      ? TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => HomeView(
                            //       vehicle: vehicle,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Text(
                            'Chọn',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: FrontendConfigs.kIconColor,
                            minimumSize: Size(double.infinity, 48),
                          ),
                        )
                      : vehicle.status.toUpperCase() == 'WAITING_APPROVAL'
                          ? TextButton(
                              onPressed: () {},
                              child: Text(
                                'Cập nhật',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: FrontendConfigs.kIconColor,
                                minimumSize: Size(double.infinity, 48),
                              ),
                            )
                          : IgnorePointer(
                              ignoring: true,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Chọn',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  minimumSize: Size(double.infinity, 48),
                                ),
                              ),
                            ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          _showCarDetails(context, vehicle.id);
        },
        child: Card(
          margin: EdgeInsets.all(20),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(vehicle.image ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              vehicle.manufacturer,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color.fromARGB(134, 154, 154, 154),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      vehicle.licensePlate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FrontendConfigs.kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                CarStatus(status: vehicle.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
