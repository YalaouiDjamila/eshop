class Product {
  final int id;
  final int storeId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String size;
  final String imageUrl;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.size,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      storeId: int.parse(json['store_id'].toString()),
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      size: json['size'],
      imageUrl: json['image_url'],
    );
  }
}
