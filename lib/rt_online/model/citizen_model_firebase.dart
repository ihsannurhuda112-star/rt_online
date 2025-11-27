class CitizenModelFirebase {
  final String uid;
  final String username;
  final String email;
  final int age;
  final String domisili;

  CitizenModelFirebase({
    required this.uid,
    required this.username,
    required this.email,
    required this.age,
    required this.domisili,
  });

  factory CitizenModelFirebase.fromMap(Map<String, dynamic> map) {
    return CitizenModelFirebase(
      uid: map['uid']?.toString() ?? "", // wajib
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      domisili: map['domisili'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // field di Firestore
      'username': username,
      'email': email,
      'age': age,
      'domisili': domisili,
    };
  }
}
