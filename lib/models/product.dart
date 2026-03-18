class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final bool isFavorite;
  final bool isNew;
  final String? badge;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.category,
    this.isFavorite = false,
    this.isNew = false,
    this.badge,
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  Product copyWith({bool? isFavorite}) => Product(
        id: id, name: name, brand: brand, description: description,
        price: price, originalPrice: originalPrice, rating: rating,
        reviewCount: reviewCount, images: images, sizes: sizes,
        colors: colors, category: category, isNew: isNew, badge: badge,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class Order {
  final String id;
  final List<CartItem> items;
  final DateTime date;
  final String status;
  final double total;

  const Order({
    required this.id,
    required this.items,
    required this.date,
    required this.status,
    required this.total,
  });
}
