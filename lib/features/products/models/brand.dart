class Brand {
  final int brandId;
  final String brandName;
  final String country;

  Brand({
    required this.brandId,
    required this.brandName,
    required this.country,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['brandID'] ?? json['brandId'] ?? 0,
      brandName: json['brandName'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandID': brandId,
      'brandName': brandName,
      'country': country,
    };
  }
}
