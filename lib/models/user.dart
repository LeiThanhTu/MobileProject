class User {
  final int? id;
  final String username;
  final String email;
  final String password;

  String get name => username;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
// tạo bản sao của đối tượng User
  User copyWith({int? id, String? username, String? email, String? password}) {
    return User(
      // nếu id không null thì sử dụng id của đối tượng hiện tại, nếu null thì sử dụng id của đối tượng mới
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
