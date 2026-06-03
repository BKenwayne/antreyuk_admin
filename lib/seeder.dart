import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseSeeder {
  static Future<void> seedAdminData() async {
    final CollectionReference ref = FirebaseFirestore.instance.collection("admins");

    // Beberapa data admin dummy untuk testing
    final Map<String, Map<String, dynamic>> dummyAdmins = {
      "admin_1": {
        "nip": "199001012020011001",
        "name": "dr. Ahmad Fauzi (Admin Utama)",
        "password": "password123",
        "role": "super admin",
      },
      "admin_2": {
        "nip": "199203152021022002",
        "name": "Siti Aminah, A.Md.Keb (Bidan)",
        "password": "bidanpassword",
        "role": "admin dokter",
      },
      "admin_3": {
        "nip": "199508202022031003",
        "name": "Budi Santoso, S.Kep (Perawat)",
        "password": "perawatpassword",
        "role": "admin dokter",
      },
    };

    // Menulis data ke Cloud Firestore
    for (var entry in dummyAdmins.entries) {
      await ref.doc(entry.key).set(entry.value);
    }
  }

  /// Seed data antrean pasien dummy untuk testing dashboard
  static Future<void> seedQueueData() async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref("antrean");

    final now = DateTime.now();
    final baseTime = DateTime(now.year, now.month, now.day, 8, 0);

    final List<Map<String, dynamic>> dummyQueue = [
      {
        "nomorAntrean": "A-14",
        "namaPasien": "Ratna Sari",
        "noRekamMedis": "P-00981",
        "keluhanAwal": "Sakit Kepala Berat",
        "waktuDaftar": baseTime.millisecondsSinceEpoch,
        "status": "selesai",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 8,
      },
      {
        "nomorAntrean": "A-15",
        "namaPasien": "Ananda Rizky Pratama",
        "noRekamMedis": "P-00982",
        "keluhanAwal": "Demam Tinggi & Flu",
        "waktuDaftar": baseTime.add(const Duration(minutes: 15)).millisecondsSinceEpoch,
        "status": "dipanggil",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 4,
      },
      {
        "nomorAntrean": "A-16",
        "namaPasien": "Siti Maesaroh",
        "noRekamMedis": "P-00983",
        "keluhanAwal": "Pemeriksaan Rutin Gula Darah",
        "waktuDaftar": baseTime.add(const Duration(minutes: 20)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 6,
      },
      {
        "nomorAntrean": "A-17",
        "namaPasien": "Bambang Wijaya",
        "noRekamMedis": "P-00984",
        "keluhanAwal": "Nyeri Sendi Lutut Kanan",
        "waktuDaftar": baseTime.add(const Duration(minutes: 32)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 10,
      },
      {
        "nomorAntrean": "A-18",
        "namaPasien": "Dewi Lestari",
        "noRekamMedis": "P-00985",
        "keluhanAwal": "Batuk Berdahak 1 Minggu",
        "waktuDaftar": baseTime.add(const Duration(minutes: 40)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 5,
      },
      {
        "nomorAntrean": "A-19",
        "namaPasien": "Agus Purnomo",
        "noRekamMedis": "P-00986",
        "keluhanAwal": "Tekanan Darah Tinggi",
        "waktuDaftar": baseTime.add(const Duration(minutes: 48)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 7,
      },
      {
        "nomorAntrean": "A-20",
        "namaPasien": "Rina Anggraeni",
        "noRekamMedis": "P-00987",
        "keluhanAwal": "Alergi Kulit Gatal-Gatal",
        "waktuDaftar": baseTime.add(const Duration(minutes: 55)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 4,
      },
      {
        "nomorAntrean": "A-21",
        "namaPasien": "Hendra Setiawan",
        "noRekamMedis": "P-00988",
        "keluhanAwal": "Sakit Gigi Berlubang",
        "waktuDaftar": baseTime.add(const Duration(minutes: 62)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 15,
      },
      {
        "nomorAntrean": "A-22",
        "namaPasien": "Fitri Handayani",
        "noRekamMedis": "P-00989",
        "keluhanAwal": "Mual dan Pusing",
        "waktuDaftar": baseTime.add(const Duration(minutes: 70)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 5,
      },
      {
        "nomorAntrean": "A-23",
        "namaPasien": "Wahyu Nugroho",
        "noRekamMedis": "P-00990",
        "keluhanAwal": "Kontrol Pasca Operasi",
        "waktuDaftar": baseTime.add(const Duration(minutes: 78)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 12,
      },
      {
        "nomorAntrean": "A-24",
        "namaPasien": "Sri Mulyani",
        "noRekamMedis": "P-00991",
        "keluhanAwal": "Sesak Napas Ringan",
        "waktuDaftar": baseTime.add(const Duration(minutes: 85)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 8,
      },
      {
        "nomorAntrean": "A-25",
        "namaPasien": "Dian Permata",
        "noRekamMedis": "P-00992",
        "keluhanAwal": "Diare 3 Hari",
        "waktuDaftar": baseTime.add(const Duration(minutes: 92)).millisecondsSinceEpoch,
        "status": "menunggu",
        "poliTujuan": "Poli Umum",
        "estimasiMenit": 6,
      },
    ];

    // Hapus data lama terlebih dahulu
    await ref.remove();

    // Tulis data baru
    for (int i = 0; i < dummyQueue.length; i++) {
      await ref.child('queue_${i + 1}').set(dummyQueue[i]);
    }
  }

  /// Seed data dokter dan janji temu untuk kalender
  static Future<void> seedDoctorAndAppointmentData() async {
    // 1. Seed data dokter
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
        "isActive": false,
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

    // 2. Seed data janji temu (appointments)
    final DatabaseReference appointmentRef = FirebaseDatabase.instance.ref("antrean_janjitemu");
    await appointmentRef.remove();

    final now = DateTime.now();
    // Gunakan tanggal hari ini (atau tgl 23 Mei 2024 untuk mencocokkan screenshot, tapi gunakan hari ini agar dinamis)
    final today = DateTime(now.year, now.month, now.day);

    final List<Map<String, dynamic>> dummyAppointments = [
      {
        "namaPasien": "Budi Santoso",
        "nikOrKeluhan": "NIK: 32750...4401",
        "poli": "Poli Umum",
        "waktu": "08:30",
        "estimasiMenit": 30,
        "isEmergency": false,
        "status": "menunggu",
        "tanggal": today.millisecondsSinceEpoch,
      },
      {
        "namaPasien": "Ani Yuliana",
        "nikOrKeluhan": "NIK: 32750...8902",
        "poli": "Poli KIA",
        "waktu": "09:15",
        "estimasiMenit": 15,
        "isEmergency": false,
        "status": "menunggu",
        "tanggal": today.millisecondsSinceEpoch,
      },
      {
        "namaPasien": "Lukas Pratama",
        "nikOrKeluhan": "Sesak Napas Akut",
        "poli": "IGD / Umum",
        "waktu": "09:45",
        "estimasiMenit": 0, // Darurat
        "isEmergency": true,
        "status": "menunggu",
        "tanggal": today.millisecondsSinceEpoch,
      },
      {
        "namaPasien": "Maya Indah",
        "nikOrKeluhan": "NIK: 32750...1109",
        "poli": "Poli Gigi",
        "waktu": "10:30",
        "estimasiMenit": 45,
        "isEmergency": false,
        "status": "menunggu",
        "tanggal": today.millisecondsSinceEpoch,
      },
    ];

    for (int i = 0; i < dummyAppointments.length; i++) {
      await appointmentRef.child('apt_${i + 1}').set(dummyAppointments[i]);
    }
  }
}

