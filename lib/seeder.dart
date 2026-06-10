import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseSeeder {
  /// Seed data admin ke Firestore
  /// Admin disesuaikan dengan seluruh dokter yang ada:
  ///   - dr. Bambang S.       → Poli Umum
  ///   - dr. Siti Aminah      → Poli KIA
  ///   - drg. Rahmat H.       → Poli Gigi
  ///   - dr. Andi Setiawan    → Poli Jantung
  ///   - dr. Laras W.         → Poli Mata
  ///   - dr. Kevin L.         → Lab Utama (Staff Lab)
  static Future<void> seedAdminData() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection("admins");

    // Hapus semua data admin lama
    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Data admin: 1 super admin + 5 admin dokter + 1 admin lab
    final Map<String, Map<String, dynamic>> dummyAdmins = {
      // ===== Super Admin =====
      "admin_1": {
        "nip": "199001012020011001",
        "name": "dr. Ahmad Fauzi",
        "password": "superadmin123",
        "role": "super admin",
      },
      // ===== Admin Dokter =====
      "admin_2": {
        "nip": "198505102019011002",
        "name": "dr. Bambang S.",
        "password": "bambang123",
        "role": "admin dokter",
      },
      "admin_3": {
        "nip": "199003202020022003",
        "name": "dr. Siti Aminah",
        "password": "sitiaminah123",
        "role": "admin dokter",
      },
      "admin_4": {
        "nip": "198807152018031004",
        "name": "drg. Rahmat H.",
        "password": "rahmat123",
        "role": "admin dokter",
      },
      "admin_5": {
        "nip": "197712082015031005",
        "name": "dr. Andi Setiawan, Sp.JP",
        "password": "andi123",
        "role": "admin dokter",
      },
      "admin_6": {
        "nip": "198903252018042006",
        "name": "dr. Laras W., Sp.M",
        "password": "laras123",
        "role": "admin dokter",
      },
      // ===== Staff Lab =====
      "admin_7": {
        "nip": "199206102021011007",
        "name": "dr. Kevin L.",
        "password": "kevin123",
        "role": "admin lab",
      },
    };

    // Menulis data ke Cloud Firestore
    for (var entry in dummyAdmins.entries) {
      await ref.doc(entry.key).set(entry.value);
    }
  }

  /// Seed data poliklinik ke Firestore (5 poliklinik, tanpa poli_anak)
  /// Seluruh dokter sudah terisi di setiap poliklinik
  static Future<void> seedPoliklinikData() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection("poliklinik");

    // Hapus semua data poliklinik lama (termasuk poli_anak)
    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // 5 Poliklinik — semua poli sudah memiliki dokter
    final Map<String, Map<String, dynamic>> poliklinikData = {
      "poli_umum": {
        "name": "Poli Umum",
        "icon": "medical_services_outlined",
        "doctors": [
          {
            "name": "dr. Bambang S.",
            "specialty": "Dokter Umum",
            "time": "08:00 - 14:00",
          },
        ],
      },
      "poli_gigi": {
        "name": "Poli Gigi",
        "icon": "medical_services_outlined",
        "doctors": [
          {
            "name": "drg. Rahmat H.",
            "specialty": "Dokter Gigi",
            "time": "08:00 - 12:00",
          },
        ],
      },
      "poli_jantung": {
        "name": "Poli Jantung",
        "icon": "favorite_outlined",
        "doctors": [
          {
            "name": "dr. Andi Setiawan, Sp.JP",
            "specialty": "Dokter Spesialis Jantung",
            "time": "09:00 - 13:00",
          },
        ],
      },
      "poli_kia": {
        "name": "Poli KIA",
        "icon": "child_care_rounded",
        "doctors": [
          {
            "name": "dr. Siti Aminah",
            "specialty": "Dokter KIA",
            "time": "08:00 - 14:00",
          },
        ],
      },
      "poli_mata": {
        "name": "Poli Mata",
        "icon": "visibility_outlined",
        "doctors": [
          {
            "name": "dr. Laras W., Sp.M",
            "specialty": "Dokter Spesialis Mata",
            "time": "10:00 - 14:00",
          },
        ],
      },
    };

    // Menulis data ke Cloud Firestore
    for (var entry in poliklinikData.entries) {
      await ref.doc(entry.key).set(entry.value);
    }
  }

  /// Seed data dokter ke Realtime Database
  /// 5 dokter (semua poli terisi) + 1 staff lab
  static Future<void> seedDoctorData() async {
    final DatabaseReference doctorRef = FirebaseDatabase.instance.ref("dokter");
    await doctorRef.remove();

    final List<Map<String, dynamic>> dummyDoctors = [
      {
        "name": "dr. Bambang S.",
        "poli": "Poli Umum",
        "isActive": true,
        "avatarUrl": "",
      },
      {
        "name": "dr. Siti Aminah",
        "poli": "Poli KIA",
        "isActive": true,
        "avatarUrl": "",
      },
      {
        "name": "drg. Rahmat H.",
        "poli": "Poli Gigi",
        "isActive": true,
        "avatarUrl": "",
      },
      {
        "name": "dr. Andi Setiawan, Sp.JP",
        "poli": "Poli Jantung",
        "isActive": true,
        "avatarUrl": "",
      },
      {
        "name": "dr. Laras W., Sp.M",
        "poli": "Poli Mata",
        "isActive": true,
        "avatarUrl": "",
      },
      {
        "name": "dr. Kevin L.",
        "poli": "Lab Utama",
        "isActive": true,
        "avatarUrl": "",
      },
    ];

    for (int i = 0; i < dummyDoctors.length; i++) {
      await doctorRef.child('doc_${i + 1}').set(dummyDoctors[i]);
    }
  }

  /// Seed data riwayat medis ke Firestore untuk testing
  static Future<void> seedMedicalRecords() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection("medical_records");

    // Hapus data lama
    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    final now = DateTime.now();
    final List<Map<String, dynamic>> dummyRecords = [
      {
        "patientId": "queue_1",
        "noRekamMedis": "P-00981",
        "namaPasien": "Ratna Sari",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        "dokterName": "dr. Bambang S.",
        "keluhan": "Kontrol rutin, pusing dan tensi tinggi",
        "tensiDarah": "140/90 mmHg",
        "beratBadan": 61.0,
        "tinggiBadan": 158.0,
        "suhuTubuh": 36.5,
        "diagnosa": "Hipertensi Stage 1",
        "resepObat": "Amlodipine 5mg 1x1 pagi",
        "catatanDokter": "Diet rendah garam dan lemak, kontrol kembali bulan depan.",
      },
      {
        "patientId": "queue_1",
        "noRekamMedis": "P-00981",
        "namaPasien": "Ratna Sari",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(minutes: 60))),
        "dokterName": "dr. Bambang S.",
        "keluhan": "Sakit kepala berdenyut-denyut",
        "tensiDarah": "130/80 mmHg",
        "beratBadan": 60.5,
        "tinggiBadan": 158.0,
        "suhuTubuh": 36.8,
        "diagnosa": "Cephalgia (Sakit Kepala Tegangan)",
        "resepObat": "Paracetamol 500mg 3x1 (jika sakit), Vitamin B Kompleks 1x1",
        "catatanDokter": "Kurangi kafein, istirahat cukup, hindari stres berlebih.",
      },
      {
        "patientId": "queue_2",
        "noRekamMedis": "P-00982",
        "namaPasien": "Ananda Rizky Pratama",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(days: 15))),
        "dokterName": "dr. Siti Aminah",
        "keluhan": "Batuk pilek dan radang tenggorokan",
        "tensiDarah": "110/70 mmHg",
        "beratBadan": 65.0,
        "tinggiBadan": 172.0,
        "suhuTubuh": 37.5,
        "diagnosa": "Faringitis Akut",
        "resepObat": "Amoxicillin 500mg 3x1 (habiskan), Paracetamol 500mg 3x1 (jika demam)",
        "catatanDokter": "Hindari es dan makanan pedas/gorengan selama 5 hari.",
      },
      {
        "patientId": "queue_3",
        "noRekamMedis": "P-00983",
        "namaPasien": "Budi Hartono",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(days: 7))),
        "dokterName": "drg. Rahmat H.",
        "keluhan": "Sakit gigi dan bengkak pada gusi",
        "tensiDarah": "120/80 mmHg",
        "beratBadan": 70.0,
        "tinggiBadan": 168.0,
        "suhuTubuh": 37.0,
        "diagnosa": "Periodontitis",
        "resepObat": "Amoxicillin 500mg 3x1 (5 hari), Asam Mefenamat 500mg 3x1 (jika nyeri)",
        "catatanDokter": "Jaga kebersihan gigi, sikat gigi 2x sehari, kontrol 1 minggu lagi.",
      },
      {
        "patientId": "queue_4",
        "noRekamMedis": "P-00984",
        "namaPasien": "Hendra Kusuma",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        "dokterName": "dr. Andi Setiawan, Sp.JP",
        "keluhan": "Nyeri dada dan sesak napas saat beraktivitas",
        "tensiDarah": "150/95 mmHg",
        "beratBadan": 78.0,
        "tinggiBadan": 170.0,
        "suhuTubuh": 36.7,
        "diagnosa": "Angina Pectoris",
        "resepObat": "Nitrat sublingual (jika nyeri), Aspirin 80mg 1x1, Atorvastatin 20mg 1x1 malam",
        "catatanDokter": "Hindari aktivitas berat, diet rendah lemak, jadwalkan EKG bulan depan.",
      },
      {
        "patientId": "queue_5",
        "noRekamMedis": "P-00985",
        "namaPasien": "Dewi Lestari",
        "tanggalPengecekan": Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        "dokterName": "dr. Laras W., Sp.M",
        "keluhan": "Pandangan kabur dan mata sering berair",
        "tensiDarah": "115/75 mmHg",
        "beratBadan": 55.0,
        "tinggiBadan": 160.0,
        "suhuTubuh": 36.6,
        "diagnosa": "Miopia & Konjungtivitis Ringan",
        "resepObat": "Tetes mata Cendol 3x1 tetes, Vitamin A 5000 IU 1x1",
        "catatanDokter": "Disarankan penggunaan kacamata, kurangi paparan layar berlebihan.",
      },
    ];

    for (var record in dummyRecords) {
      await ref.add(record);
    }
  }
}
