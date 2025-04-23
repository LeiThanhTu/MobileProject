class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
// final: không thể thay đổi sau khi gáng giá trị

// hàm khởi tạo 
  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

// Biến một đối tượng Category thành Map (dạng key: value)
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
//  tạo lại một đối tượng Category từ dữ liệu trong Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }
// tạo một bản sao của đối tượng Category với các thuộc tính có thể thay đổi
  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      // nếu description không null thì sử dụng giá trị đó, nếu null thì sử dụng giá trị cũ
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,

    );
  }
}
