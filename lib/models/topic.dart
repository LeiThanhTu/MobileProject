class Topic {
  final int id;
  final String name;
  final String? description;

  Topic({required this.id, required this.name, this.description});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
