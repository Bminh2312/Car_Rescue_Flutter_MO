class Manager {
  final String id;
  final String accountId;
  final String? fullname;
  final String sex;
  final String phone;
  final String? licensePlate;
  final String? address;
  final String? status;
  final String? avatar;
  final String? createAt;
  final String? updateAt;
  final String? birthdate;
  final int? area;
  String? deviceToken;
  Manager({
    required this.deviceToken,
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
    required this.area,
    required this.avatar,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? Map<String, dynamic>();

    return Manager(
      deviceToken: json['data']['account']['deviceToken'],
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
      area: data['area'] ?? 0,
      avatar: data['avatar'] ?? '',
    );
  }
}
