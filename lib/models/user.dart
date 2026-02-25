class User {
  final String id;
  final String name;
  final String email;
  final String img;
  final String createdAt;
  final String? lastBackup;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.img,
    required this.createdAt,
    this.lastBackup,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'img': img,
    'createdAt': createdAt,
    'lastBackup': lastBackup,
  };

  factory User.fromJson( json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      img: json['img'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastBackup: json['lastBackup'],
    );
  }
}