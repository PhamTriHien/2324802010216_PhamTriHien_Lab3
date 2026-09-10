import 'package:flutter/material.dart';

/// Model đại diện cho một sản phẩm trong ứng dụng TechStore
class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String description;
  final Map<String, String> specifications;
  final IconData icon;
  final Color themeColor;
  final int stock;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.specifications,
    required this.icon,
    required this.themeColor,
    required this.stock,
    this.isFavorite = false,
  });

  /// Tính phần trăm giảm giá nếu có
  int get discountPercent {
    if (originalPrice <= price) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  /// Tạo bản sao với các thuộc tính cập nhật (ví dụ: đổi trạng thái yêu thích)
  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? description,
    Map<String, String>? specifications,
    IconData? icon,
    Color? themeColor,
    int? stock,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Model đại diện cho một mục trong giỏ hàng
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Tính tổng tiền của món hàng này
  double get totalPrice => product.price * quantity;
}
