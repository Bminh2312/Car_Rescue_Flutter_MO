import 'package:CarRescue/src/models/order.dart';
import 'package:CarRescue/src/models/order_detail.dart';
import 'package:CarRescue/src/models/vehicle_item.dart';

class Booking {
  final String? carId;
  final String id;
  final String customerId;
  final String technicianId;
  final String? managerId;
  final String? vehicleId;
  final String? paymentId;
  final String rescueType;
  final String? staffNote;
  final String customerNote;
  final String? cancellationReason;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? createdAt;
  final String status;
  final String departure;
  final String? destination;
  final int? area;
  final String? indicentId;
  double? rating;
  String? note;
  OrderDetail? orderDetail;
  Vehicle? vehicleInfo;
  bool isShowDetails = false;
  int? quantity;
  int? total;
  Booking({
    required this.carId,
    required this.id,
    required this.customerId,
    required this.technicianId,
    required this.managerId,
    required this.vehicleId,
    required this.paymentId,
    required this.rescueType,
    required this.staffNote,
    required this.customerNote,
    required this.cancellationReason,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.status,
    required this.departure,
    required this.destination,
    required this.area,
    this.quantity,
    this.total, required this.indicentId,
  });
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      indicentId: json['indicentId'] != null ? json['indicentId'] : null,
      carId: json['carId'] as String?,
      id: json['id'],
      customerId: json['customerId'],
      technicianId: json['technicianId'] ?? '',
      managerId: json['managerId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      paymentId: json['paymentId'] as String?,
      customerNote: json['customerNote'],
      departure: json['departure'],
      destination: json['destination'] as String?,
      rescueType: json['rescueType'],
      staffNote: json['staffNote'] != null ? json['staffNote'] : null,
      cancellationReason: json['cancellationReason'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null, // Check for null before parsing
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null, // Check for null before parsing
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null, // Check for null before parsing
      status: json['status'],
      area: json['area'],
    );
  }
}





// final List<Booking> bookings = [
//   Booking(
//       id: '1',
//       type: 'Kéo xe',
//       staffNote: 'Please prepare presentation materials.',
//       cancellationReason: '',
//       startTime: DateTime.now().add(Duration(hours: 1)),
//       endTime: DateTime.now().add(Duration(hours: 2)),
//       status: 'Hoàn thành',
//       departure: 'Nhà Văn hóa Sinh viên ĐHQG TPHCM',
//       destination: 'FPT University',
//       customerName: 'Hieu Phan',
//       customerNote: 'abc',
//       avatar: 'assets/images/profile_one.png',
//       phone: '0123456788'),
//   Booking(
//       id: '2',
//       type: 'Sửa chữa',
//       staffNote: 'Follow-up checkup.',
//       cancellationReason: 'Patient rescheduled.',
//       startTime: DateTime.now().add(Duration(days: 1)),
//       endTime: DateTime.now().add(Duration(days: 1, hours: 2)),
//       status: 'Đã phân công',
//       departure: 'FPT Campus',
//       destination: 'Crescent Mall Quan 7',
//       customerName: 'Tom',
//       customerNote: 'abc',
//       avatar: 'assets/images/avatars-2.png',
//       phone: '0123456788'),
//   Booking(
//       id: '3',
//       type: 'Kéo xe',
//       staffNote: 'Agenda and materials ready.',
//       cancellationReason: 'Change in schedule.',
//       startTime: DateTime.now().add(Duration(days: 2)),
//       endTime: DateTime.now().add(Duration(days: 2, hours: 3)),
//       status: 'Đã hủy',
//       departure: 'Nha sach Fahasa',
//       destination: 'CGV Ho Chi Minh',
//       customerName: 'Jerry',
//       customerNote: 'abc',
//       avatar: 'assets/images/profile.png',
//       phone: '0123456788'),

//   // Add more bookings here
// ];
