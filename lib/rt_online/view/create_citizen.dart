import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rt_online/login_button/login_button.dart';
import 'package:rt_online/rt_online/database/db_helper.dart';
import 'package:rt_online/rt_online/model/citizen_model.dart';

class CreateCitizenWidget extends StatefulWidget {
  const CreateCitizenWidget({super.key});

  @override
  State<CreateCitizenWidget> createState() => _CreateCitizenWidgetDay19State();
}

class _CreateCitizenWidgetDay19State extends State<CreateCitizenWidget> {
  final nameC = TextEditingController();
  final ageC = TextEditingController();
  final emailC = TextEditingController();
  final domisiliC = TextEditingController();
  final passwordC = TextEditingController();
  getData() {
    DbHelper.getAllCitizen();
    setState(() {});
  }

  Future<void> _onEdit(CitizenModel citizen) async {
    final editNameC = TextEditingController(text: citizen.username);
    final editAgeC = TextEditingController(text: citizen.age.toString());
    final editDomisiliC = TextEditingController(text: citizen.domisili);
    final editEmailC = TextEditingController(text: citizen.email);
    final editPasswordC = TextEditingController(text: citizen.password);
    final res = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              buildTextField(hintText: "Name", controller: editNameC),
              buildTextField(hintText: "Email", controller: editEmailC),
              buildTextField(hintText: "Age", controller: editAgeC),
              buildTextField(hintText: "Domisili", controller: domisiliC),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (res == true) {
      final updated = CitizenModel(
        id: citizen.id,
        username: editNameC.text,
        email: editEmailC.text,
        domisili: domisiliC.text,
        age: int.parse(editAgeC.text),
        password: passwordC.text,
      );
      DbHelper.updateCitizen(updated);
      getData();
      Fluttertoast.showToast(msg: "Data berhasil di update");
    }
  }

  Future<void> _onDelete(CitizenModel Citizen) async {
    final res = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                "Apakah anda yakin ingin menghapus data ${Citizen.username}?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Jangan"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Ya, hapus aja"),
            ),
          ],
        );
      },
    );

    if (res == true) {
      DbHelper.deleteCitizen(Citizen.id!);
      getData();
      Fluttertoast.showToast(msg: "Data berhasil di hapus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          children: [
            Text("Pendaftaran Siswa", style: TextStyle(fontSize: 24)),
            buildTextField(hintText: "Name", controller: nameC),
            buildTextField(hintText: "Age", controller: ageC),
            buildTextField(hintText: "Domisili", controller: domisiliC),
            buildTextField(hintText: "Email", controller: emailC),
            LoginButtonWidget(
              text: "Tambahkan",
              onPressed: () {
                if (nameC.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Nama belum diisi");
                } else if (emailC.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Email belum diisi");
                } else if (domisiliC.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Domisili belum diisi");
                } else if (ageC.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Age belum diisi");
                } else {
                  final CitizenModel dataStudent = CitizenModel(
                    username: nameC.text,
                    email: emailC.text,
                    domisili: domisiliC.text,
                    age: int.parse(ageC.text),
                    password: passwordC.text,
                  );
                  DbHelper.createCitizen(dataStudent).then((value) {
                    emailC.clear();
                    ageC.clear();
                    domisiliC.clear();
                    nameC.clear();
                    getData();
                    Fluttertoast.showToast(msg: "Data berhasil ditambahkan");
                  });
                }
              },
            ),
            SizedBox(height: 30),
            FutureBuilder(
              future: DbHelper.getAllCitizen(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.data == null || snapshot.data.isEmpty) {
                  return Column(children: [Text("Data belum ada")]);
                } else {
                  final data = snapshot.data as List<CitizenModel>;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final items = data[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(items.username),
                              subtitle: Text(items.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _onEdit(items);
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _onDelete(items);
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildTextField({
    String? hintText,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
