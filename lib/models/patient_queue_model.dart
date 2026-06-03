import 'package:cloud_firestore/cloud_firestore.dart';

class PatientQueue {
  final String id;
  final String nomorAntrean;
  final String namaPasien;
  final String noRekamMedis;
  final String keluhanAwal;
  final DateTime waktuDaftar;
  final String status; // "menunggu" / "dipanggil" / "selesai"
  final String poliTujuan;
  final int estimasiMenit;

  PatientQueue({
    required this.id,
    required this.nomorAntrean,
    required this.namaPasien,
    required this.noRekamMedis,
    required this.keluhanAwal,
    required this.waktuDaftar,
    required this.status,
    required this.poliTujuan,
    required this.estimasiMenit,
  });

  factory PatientQueue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientQueue(
      id: doc.id,
      nomorAntrean: data['nomorAntrean'] ?? '',
      namaPasien: data['namaPasien'] ?? '',
      noRekamMedis: data['noRekamMedis'] ?? '',
      keluhanAwal: data['keluhanAwal'] ?? '',
      waktuDaftar: (data['waktuDaftar'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'menunggu',
      poliTujuan: data['poliTujuan'] ?? '',
      estimasiMenit: data['estimasiMenit'] ?? 5,
    );
  }

  factory PatientQueue.fromRealtime(String id, Map<dynamic, dynamic> data) {
    DateTime parseWaktu(dynamic val) {
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return PatientQueue(
      id: id,
      nomorAntrean: data['nomorAntrean'] ?? '',
      namaPasien: data['namaPasien'] ?? '',
      noRekamMedis: data['noRekamMedis'] ?? '',
      keluhanAwal: data['keluhanAwal'] ?? '',
      waktuDaftar: parseWaktu(data['waktuDaftar']),
      status: data['status'] ?? 'menunggu',
      poliTujuan: data['poliTujuan'] ?? '',
      estimasiMenit: data['estimasiMenit'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomorAntrean': nomorAntrean,
      'namaPasien': namaPasien,
      'noRekamMedis': noRekamMedis,
      'keluhanAwal': keluhanAwal,
      'waktuDaftar': Timestamp.fromDate(waktuDaftar),
      'status': status,
      'poliTujuan': poliTujuan,
      'estimasiMenit': estimasiMenit,
    };
  }

  Map<String, dynamic> toRealtimeMap() {
    return {
      'nomorAntrean': nomorAntrean,
      'namaPasien': namaPasien,
      'noRekamMedis': noRekamMedis,
      'keluhanAwal': keluhanAwal,
      'waktuDaftar': waktuDaftar.millisecondsSinceEpoch,
      'status': status,
      'poliTujuan': poliTujuan,
      'estimasiMenit': estimasiMenit,
    };
  }

  PatientQueue copyWith({
    String? id,
    String? nomorAntrean,
    String? namaPasien,
    String? noRekamMedis,
    String? keluhanAwal,
    DateTime? waktuDaftar,
    String? status,
    String? poliTujuan,
    int? estimasiMenit,
  }) {
    return PatientQueue(
      id: id ?? this.id,
      nomorAntrean: nomorAntrean ?? this.nomorAntrean,
      namaPasien: namaPasien ?? this.namaPasien,
      noRekamMedis: noRekamMedis ?? this.noRekamMedis,
      keluhanAwal: keluhanAwal ?? this.keluhanAwal,
      waktuDaftar: waktuDaftar ?? this.waktuDaftar,
      status: status ?? this.status,
      poliTujuan: poliTujuan ?? this.poliTujuan,
      estimasiMenit: estimasiMenit ?? this.estimasiMenit,
    );
  }
}
