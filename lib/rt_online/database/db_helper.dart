import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:rt_online/rt_online/model/payment_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbHelper {
  static const tableCitizen = 'citizen';
  static const tablePayment = 'payment';
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'rtdigital.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $tableCitizen(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, email TEXT, password TEXT, age INTEGER, domisili TEXT)",
        );
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute(
            "CREATE TABLE $tablePayment(id INTEGER PRIMARY KEY AUTOINCREMENT, citizen_id INTEGER, period TEXT, amount INTEGER, status TEXT, FOREIGN KEY (citizen_id) REFERENCES $tableCitizen(id))",
          );
        }
      },
      version: 2,
    );
  }

  static Future<void> registerUser(CitizenModel user) async {
    final dbs = await db();
    //cat: insert fungsi menambahkan data (create)
    await dbs.insert(
      tableCitizen,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(user.toMap());
  }

  static Future<CitizenModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final dbs = await db();
    //cat query adalah fungsi untuk meanmpilkan data (READ)
    final List<Map<String, dynamic>> results = await dbs.query(
      tableCitizen,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    final List<Map<String, dynamic>> cek = await dbs.query(tableCitizen);
    print(cek);
    if (results.isNotEmpty) {
      return CitizenModel.fromMap(results.first);
    }
    return null;
  }

  // tambahin warga
  static Future<void> createCitizen(CitizenModel citizen) async {
    final dbs = await db();
    //insert fungsi untuk menambahkan data (CREATE)
    await dbs.insert(
      tableCitizen,
      citizen.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(citizen.toMap());
  }

  // get citizen
  static Future<List<CitizenModel>> getAllCitizen() async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(tableCitizen);
    print(results.map((e) => CitizenModel.fromMap(e)).toList());
    return results.map((e) => CitizenModel.fromMap(e)).toList();
  }

  // ambil data warga via email
  static Future<CitizenModel?> getCitizenByEmail(String email) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      tableCitizen,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return CitizenModel.fromMap(results.first);
    }
    return null;
  }

  // update warga
  static Future<void> updateCitizen(CitizenModel citizen) async {
    final dbs = await db();
    await dbs.update(
      tableCitizen,
      citizen.toMap(),
      where: "id = ?",
      whereArgs: [citizen.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(citizen.toMap());
  }

  // delete citizen
  static Future<void> deleteCitizen(int id) async {
    final dbs = await db();
    await dbs.delete(tableCitizen, where: "id = ?", whereArgs: [id]);
  }

  // buat pembayaran
  static Future<void> addPayment(PaymentModel payment) async {
    final dbs = await db();
    await dbs.insert(
      tablePayment,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Payment added: ${payment.toMap()}");
  }

  // baca semua pembaayran
  static Future<List<PaymentModel>> getAllPayments() async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(tablePayment);
    return results.map((e) => PaymentModel.fromMap(e)).toList();
  }

  //baca pembayaran dari id warga
  static Future<List<PaymentModel>> getPaymentsByCitizen(int citizenid) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      tablePayment,
      where: 'citizen_id = ?',
      whereArgs: [citizenid],
    );
    return results.map((e) => PaymentModel.fromMap(e)).toList();
  }

  // update pembayaran
  static Future<void> updatePayment(PaymentModel payment) async {
    final dbs = await db();
    await dbs.update(
      tablePayment,
      payment.toMap(),
      where: "id = ?",
      whereArgs: [payment.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Payment updated: ${payment.toMap()}");
  }

  // hapus pembayaran
  static Future<void> deletePayment(int id) async {
    final dbs = await db();
    await dbs.delete(tablePayment, where: "id = ?", whereArgs: [id]);
    print("Payment deleted: $id");
  }
}
