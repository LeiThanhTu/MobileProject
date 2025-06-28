class User {
  final int? id;
  final String email;
  final String username;
  final String? displayName;
  final String? photoURL;
  final String provider; // 'email' hoặc 'google'
  final String? password;

  String get name => displayName ?? username;

  User({
    this.id,
    required this.email,
    required this.username,
    this.password,
    this.displayName,
    this.photoURL,
    this.provider = 'email',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      provider: map['provider'] ?? 'email',
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? displayName,
    String? photoURL,
    String? provider,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
    );
  }
}
