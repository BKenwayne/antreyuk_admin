import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  static Future<void> seedAdminData() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection("admins");

    // Beberapa data admin dummy untuk testing
    final Map<String, Map<String, dynamic>> dummyAdmins = {
      "admin_1": {
        "nip": "199001012020011001",
        "name": "dr. Ahmad Fauzi (Admin Utama)",
        "password": "password123",
        "role": "Super Admin",
      },
      "admin_2": {
        "nip": "199203152021022002",
        "name": "Siti Aminah, A.Md.Keb (Bidan)",
        "password": "bidanpassword",
        "role": "Admin Layanan",
      },
      "admin_3": {
        "nip": "199508202022031003",
        "name": "Budi Santoso, S.Kep (Perawat)",
        "password": "perawatpassword",
        "role": "Admin Pendaftaran",
      },
    };

    // Menulis data ke Cloud Firestore
    for (var entry in dummyAdmins.entries) {
      await ref.doc(entry.key).set(entry.value);
    }
  }
}
