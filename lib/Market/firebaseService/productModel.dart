import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lindelany/Constants/lists.dart';

class ProductModel {
  final String productId;
  final String sellerId;
  final String sellerName;
  final String productName;
  final int price;
  final String description;
  final String status;
  final String sellerUni;
  final bool isNew;
  final String category;
  final List<String> images;
  final Timestamp createdAt;

  ProductModel({
    required this.productId,
    required this.sellerId,
    required this.sellerName,
    required this.productName,
    required this.price,
    required this.description,
    required this.status,
    required this.sellerUni,
    required this.isNew,
    required this.category,
    required this.images,
    required this.createdAt,
  });

  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      productName: data['productName'] ?? '',
      price: data['price'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      sellerUni: data['sellerUni'] ?? southAfricanUniversities.first,
      isNew: data['isNew'] ?? false,
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? ['assets/broken.png']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'productId': productId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'productName': productName,
      'price': price,
      'description': description,
      'status': status,
      'sellerUni': sellerUni,
      'isNew': isNew,
      'category': category,
      'images': images,
      'createdAt': createdAt,
    };
  }
}
