class BankingInfo {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;
  final bool transferSupported;
  final bool lookupSupported;

  BankingInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
    required this.transferSupported,
    required this.lookupSupported,
  });

  factory BankingInfo.fromJson(Map<String, dynamic> json) {
    return BankingInfo(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      bin: json['bin'],
      shortName: json['shortName'],
      logo: json['logo'],
      transferSupported: json['transferSupported'] == 1,
      lookupSupported: json['lookupSupported'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'bin': bin,
      'shortName': shortName,
      'logo': logo,
      'transferSupported': transferSupported ? 1 : 0,
      'lookupSupported': lookupSupported ? 1 : 0,
    };
  }
}
