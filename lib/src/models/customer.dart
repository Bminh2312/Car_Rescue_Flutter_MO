class Customer {
  late String id;
  late String accountId;
  late String fullname;
  late String sex;
  late String phone;
  late String licensePlate;
  late String avatar;
  late String address;
  late String status;
  late String createAt;
  late String updateAt;
  late String birthdate;

  Customer({
    required this.id,
    required this.accountId,
    required this.fullname,
    required this.sex,
    required this.phone,
    required this.licensePlate,
    required this.avatar,
    required this.address,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.birthdate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? "",
      accountId: json['accountId'] ?? "",
      fullname: json['fullname'] ?? "",
      sex: json['sex'] ?? "",
      phone: json['phone'] ?? "",
      licensePlate: json['licensePlate'] ?? "",
      avatar: json['avatar'] ?? "",
      address: json['address'] ?? "",
      status: json['status'] ?? "",
      createAt: json['createAt'] ?? "",
      updateAt: json['updateAt'] ?? "",
      birthdate: json['birthdate'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'fullname': fullname,
        'sex': sex,
        'phone': phone,
        'licensePlate': licensePlate,
        'avatar': avatar,
        'address': address,
        'status': status,
        'createAt': createAt,
        'updateAt': updateAt,
        'birthdate': birthdate,
      };
}
