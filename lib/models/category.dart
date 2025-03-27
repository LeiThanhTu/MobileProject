class Category {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;

  Category({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  Map toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Category.fromMap(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}