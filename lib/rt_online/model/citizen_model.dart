import 'dart:convert';

class CitizenModel {
  int? id;
  String username;
  String email;
  int age;
  String password;
  String domisili;
  CitizenModel({
    this.id,
    required this.username,
    required this.email,
    required this.age,
    required this.password,
    required this.domisili,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'age': age,
      'password': password,
      'domisili': domisili,
    };
  }

  factory CitizenModel.fromMap(Map<String, dynamic> map) {
    return CitizenModel(
      id: map['id'] != null ? map['id'] as int : null,
      username: map['username'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      password: map['password'] as String,
      domisili: map['domisili'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CitizenModel.fromJson(String source) =>
      CitizenModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
