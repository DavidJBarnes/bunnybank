class Parent {
  final String id;
  final String name;
  final String email;

  Parent({required this.id, required this.name, required this.email});

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Child {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String birthday;
  final String? imageUrl;
  final double balance;
  final String createdAt;

  Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.birthday,
    this.imageUrl,
    required this.balance,
    required this.createdAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      parentId: json['parent_id'],
      name: json['name'],
      age: json['age'],
      birthday: json['birthday'],
      imageUrl: json['image_url'],
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class Reason {
  final String id;
  final String parentId;
  final String label;
  final String createdAt;

  Reason({
    required this.id,
    required this.parentId,
    required this.label,
    required this.createdAt,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id'],
      parentId: json['parent_id'],
      label: json['label'],
      createdAt: json['created_at'],
    );
  }
}
