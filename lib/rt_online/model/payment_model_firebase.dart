class PaymentModelFirebase {
  final String? id; // firestore doc.id
  final String ownerUid; // UID pemilik pembayaran
  final String citizen; // Nama/email warga yang melakukan pembayaran
  final String period; // Bulan / periode
  final int amount; // Nominal
  final String status; // paid, pending, overdue

  PaymentModelFirebase({
    this.id,
    required this.ownerUid,
    required this.citizen,
    required this.period,
    required this.amount,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'citizen': citizen,
      'period': period,
      'amount': amount,
      'status': status,
      // id tidak disimpan di firestore!
    };
  }

  factory PaymentModelFirebase.fromMap(Map<String, dynamic> map) {
    return PaymentModelFirebase(
      id: map['id']?.toString(),
      ownerUid: map['ownerUid'] ?? '',
      citizen: map['citizen'] ?? '',
      period: map['period'] ?? '',
      amount: map['amount'] is int
          ? map['amount']
          : int.tryParse(map['amount'].toString()) ?? 0,
      status: map['status'] ?? 'pending',
    );
  }
}
