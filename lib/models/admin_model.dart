class AdminModel {
  final String email;
  final String name;
  final String? uid;
  final DateTime? createdAt;

  AdminModel({
    required this.email,
    required this.name,
    this.uid,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'uid': uid,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      email: map['email'],
      name: map['name'],
      uid: map['uid'],
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }
}