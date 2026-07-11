import 'category.dart';
import 'brand.dart';
import 'unit.dart';
import 'product_variant.dart';

class Product {
  final int productId;
  final int categoryId;
  final int brandId;
  final int baseUnitId;
  final String imageUrl;
  final String productName;
  final int trackingMethod; // 0 = NONE, 1 = BATCH, 2 = SERIAL, 3 = BATCH_AND_SERIAL
  final String description;
  final int status; // 0 = DRAFT, 1 = ACTIVE, 2 = INACTIVE, 3 = DISCONTINUED

  final Category? category;
  final Brand? brand;
  final Unit? baseUnit;
  final List<ProductVariant> productVariants;

  Product({
    required this.productId,
    required this.categoryId,
    required this.brandId,
    required this.baseUnitId,
    required this.imageUrl,
    required this.productName,
    required this.trackingMethod,
    required this.description,
    required this.status,
    this.category,
    this.brand,
    this.baseUnit,
    this.productVariants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var variantsList = json['productVariants'] as List? ?? [];
    List<ProductVariant> variants = variantsList.map((v) => ProductVariant.fromJson(v)).toList();

    return Product(
      productId: json['productID'] ?? json['productId'] ?? 0,
      categoryId: json['categoryID'] ?? json['categoryId'] ?? 0,
      brandId: json['brandID'] ?? json['brandId'] ?? 0,
      baseUnitId: json['baseUnitID'] ?? json['baseUnitId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      productName: json['productName'] ?? '',
      trackingMethod: json['trackingMethod'] ?? json['TrackingMethod'] ?? 0,
      description: json['description'] ?? '',
      status: json['status'] ?? 1,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : (json['categoryName'] != null || json['categoryID'] != null || json['categoryId'] != null)
              ? Category(
                  categoryId: json['categoryID'] ?? json['categoryId'] ?? 0,
                  categoryName: json['categoryName'] ?? '',
                  description: '',
                )
              : null,
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : (json['brandName'] != null || json['brandID'] != null || json['brandId'] != null)
              ? Brand(
                  brandId: json['brandID'] ?? json['brandId'] ?? 0,
                  brandName: json['brandName'] ?? '',
                  country: '',
                )
              : null,
      baseUnit: json['baseUnit'] != null
          ? Unit.fromJson(json['baseUnit'])
          : (json['baseUnitName'] != null || json['baseUnitSymbol'] != null || json['baseUnitID'] != null || json['baseUnitId'] != null)
              ? Unit(
                  unitId: json['baseUnitID'] ?? json['baseUnitId'] ?? 0,
                  unitName: json['baseUnitName'] ?? '',
                  symbol: json['baseUnitSymbol'] ?? '',
                )
              : null,
      productVariants: variants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productId,
      'categoryID': categoryId,
      'brandID': brandId,
      'baseUnitID': baseUnitId,
      'imageUrl': imageUrl,
      'productName': productName,
      'trackingMethod': trackingMethod,
      'description': description,
      'status': status,
    };
  }
}
