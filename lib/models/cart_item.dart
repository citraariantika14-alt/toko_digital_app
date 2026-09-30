class CartItem {
  final int id;
  final int productId;
  final String name;
  final String subtitle;
  final int price;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'] ?? map['productId'] ?? 0,
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
      image: map['image'] ?? '',
    );
  }
}