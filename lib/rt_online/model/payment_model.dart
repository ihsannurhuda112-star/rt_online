// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PaymentModel {
  final int? id;
  final String citizen;
  final String period;
  final int amount;
  final String status; // 'paid', 'pending', 'overdue'

  PaymentModel({
    this.id,
    required this.citizen,
    required this.period,
    required this.amount,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'citizen': citizen,
      'period': period,
      'amount': amount,
      'status': status,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] != null ? map['id'] as int : null,
      citizen: map['citizen'] as String,
      period: map['period'] as String,
      amount: map['amount'] as int,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentModel.fromJson(String source) =>
      PaymentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
