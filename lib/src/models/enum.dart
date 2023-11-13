enum ServiceType {
  repair, // Sữa chữa tại chỗ
  tow,   // Kéo xe
 } 

 ServiceType getServiceTypeFromString(String value) {
  switch (value) {
    case 'repair':
      return ServiceType.repair;
    case 'tow':
      return ServiceType.tow;
    default:
      throw Exception('Invalid service type string: $value');
  }
}