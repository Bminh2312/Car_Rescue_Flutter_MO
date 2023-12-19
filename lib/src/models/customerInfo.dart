class CustomerInfo {
  final String id;
  final String accountId;
  final String fullname;
  final String sex;
  final String phone;
  final String licensePlate;
  final String address;
  final String status;
  final String createAt;
  final String updateAt;
  final String birthdate;
  final String avatar;
  final String deviceToken;
  CustomerInfo({
    required this.id,
    required this.accountId,
    required this.fullname,
    required this.sex,
    required this.phone,
    required this.licensePlate,
    required this.address,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.birthdate,
    required this.avatar,
    required this.deviceToken,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? Map<String, dynamic>();

    return CustomerInfo(
      id: data['id'] ?? '',
      accountId: data['accountId'] ?? '',
      fullname: data['fullname'] ?? '',
      sex: data['sex'] ?? '',
      phone: data['phone'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? '',
      createAt: data['createAt'] ?? '',
      updateAt: data['updateAt'] ?? '',
      birthdate: data['birthdate'] ?? '',
      avatar: data['avatar'] ?? '',
      deviceToken: data['account']['deviceToken'],
    );
  }
}
