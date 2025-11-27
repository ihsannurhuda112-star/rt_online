import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rt_online/rt_online/model/citizen_model_firebase.dart';
import 'package:rt_online/rt_online/model/payment_model_firebase.dart';

class FirebaseDigital {
  static const tableCitizen = 'citizen';
  static const tablePayment = 'payment';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===================== CITIZEN ===================== //

  ///  DIPAKAI SAAT REGISTER:
  /// Simpan profil user ke Firestore.
  static Future<void> createCitizen(CitizenModelFirebase citizen) async {
    final data = citizen.toMap();

    // doc.id = uid
    await _db.collection(tableCitizen).doc(citizen.uid).set(data);

    print('Citizen created with uid: ${citizen.uid}');
  }

  ///  Ambil semua warga
  static Future<List<CitizenModelFirebase>> getAllCitizen() async {
    final snapshot = await _db.collection(tableCitizen).get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      // kalau field 'uid' belum ada, fallback ke doc.id
      data['uid'] ??= doc.id;
      return CitizenModelFirebase.fromMap(data);
    }).toList();

    print(list);
    return list;
  }

  ///  Ambil warga berdasarkan UID
  static Future<CitizenModelFirebase?> getCitizenByUid(String uid) async {
    final doc = await _db
        .collection(tableCitizen)
        .doc(uid)
        .get(); // langsung by id

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['uid'] ??= doc.id;
    return CitizenModelFirebase.fromMap(data);
  }

  ///   Ambil warga berdasarkan email
  static Future<CitizenModelFirebase?> getCitizenByEmail(String email) async {
    final query = await _db
        .collection(tableCitizen)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      data['uid'] ??= doc.id;
      return CitizenModelFirebase.fromMap(data);
    }
    return null;
  }

  ///  Update data warga (by UID)
  static Future<void> updateCitizen(CitizenModelFirebase citizen) async {
    final uid = citizen.uid;

    final data = Map<String, dynamic>.from(citizen.toMap());
    // data.remove('uid');

    await _db.collection(tableCitizen).doc(uid).update(data);

    print('Citizen updated: ${data..['uid'] = uid}');
  }

  ///  Hapus warga (by UID)
  static Future<void> deleteCitizen(String uid) async {
    await _db.collection(tableCitizen).doc(uid).delete();
    print('Citizen deleted: $uid');
  }

  // ===================== PAYMENT ===================== //

  ///  Tambah pembayaran
  /// Pastikan PaymentModelFirebase punya field `ownerUid`
  static Future<void> addPayment(PaymentModelFirebase payment) async {
    final data = Map<String, dynamic>.from(payment.toMap());
    data.remove('id'); // biar Firestore yg bikin doc.id

    final docRef = await _db.collection(tablePayment).add(data);
    await docRef.update({'id': docRef.id});

    print('Payment added: ${data..['id'] = docRef.id}');
  }

  ///  Ambil semua pembayaran (biasanya dipakai admin)
  static Future<List<PaymentModelFirebase>> getAllPayments() async {
    final snapshot = await _db.collection(tablePayment).get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentModelFirebase.fromMap(data);
    }).toList();

    print(list);
    return list;
  }

  ///  Ambil pembayaran berdasarkan pemilik (per user / akun)
  /// ownerUid = FirebaseAuth.currentUser!.uid
  static Future<List<PaymentModelFirebase>> getPaymentsByOwnerUid(
    String ownerUid,
  ) async {
    final snapshot = await _db
        .collection(tablePayment)
        .where('ownerUid', isEqualTo: ownerUid)
        .get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentModelFirebase.fromMap(data);
    }).toList();

    print('Payments for ownerUid $ownerUid: $list');
    return list;
  }

  /// (Opsional) masih bisa ambil berdasarkan nama warga di field `citizen`
  static Future<List<PaymentModelFirebase>> getPaymentsByCitizenName(
    String citizenName,
  ) async {
    final snapshot = await _db
        .collection(tablePayment)
        .where('citizen', isEqualTo: citizenName)
        .get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentModelFirebase.fromMap(data);
    }).toList();

    print('Payments for citizen $citizenName: $list');
    return list;
  }

  ///  Update pembayaran
  static Future<void> updatePayment(PaymentModelFirebase payment) async {
    final id = payment.id;

    if (id == null) {
      throw Exception('Payment id is null. Tidak bisa update tanpa id.');
    }

    final data = Map<String, dynamic>.from(payment.toMap());
    data.remove('id');

    await _db.collection(tablePayment).doc(id).update(data);

    print('Payment updated: ${data..['id'] = id}');
  }

  ///  Hapus pembayaran
  static Future<void> deletePayment(String id) async {
    await _db.collection(tablePayment).doc(id).delete();
    print('Payment deleted: $id');
  }
}
