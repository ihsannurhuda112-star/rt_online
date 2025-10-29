import 'package:rt_online/rt_online/model/citizen_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbHelper {
  static const tableCitizen = 'citizen';
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'rtdigital.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $tableCitizen(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, email TEXT, password TEXT, age INTEGER, domisili TEXT)",
        );
      },

      //onUpgrade: (db, oldVersion, newVersion) async {
      //  if (oldVersion < newVersion) {
      // await db.execute(
      //   "CREATE TABLE $tableCitizen(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, email TEXT, password TEXT, age INTEGER, domisili TEXT)",
      //  );
      // }
      // },
      version: 1,
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
    final List<Map<String, dynamic>> resluts = await dbs.query(
      tableCitizen,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (resluts.isNotEmpty) {
      return CitizenModel.fromMap(resluts.first);
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
}
