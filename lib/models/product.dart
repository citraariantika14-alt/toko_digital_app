class Product {
  final int id;
  final String name;
  final String subtitle;
  final int price;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'category': category,
      'image': image,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: map['price'] ?? 0,
      category: map['category'] ?? '',
      image: map['image'] ?? '',
    );
  }
}