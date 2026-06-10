import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String id;
  final String patientId;
  final String noRekamMedis;
  final String namaPasien;
  final DateTime tanggalPengecekan;
  final String dokterName;
  final String keluhan;
  final String tensiDarah;
  final double beratBadan;
  final double tinggiBadan;
  final double suhuTubuh;
  final String diagnosa;
  final String resepObat;
  final String catatanDokter;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.noRekamMedis,
    required this.namaPasien,
    required this.tanggalPengecekan,
    required this.dokterName,
    required this.keluhan,
    required this.tensiDarah,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.suhuTubuh,
    required this.diagnosa,
    required this.resepObat,
    required this.catatanDokter,
  });

  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return DateTime.now();
    }

    return MedicalRecord(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      noRekamMedis: data['noRekamMedis'] ?? '',
      namaPasien: data['namaPasien'] ?? '',
      tanggalPengecekan: parseDate(data['tanggalPengecekan']),
      dokterName: data['dokterName'] ?? '',
      keluhan: data['keluhan'] ?? '',
      tensiDarah: data['tensiDarah'] ?? '',
      beratBadan: (data['beratBadan'] as num?)?.toDouble() ?? 0.0,
      tinggiBadan: (data['tinggiBadan'] as num?)?.toDouble() ?? 0.0,
      suhuTubuh: (data['suhuTubuh'] as num?)?.toDouble() ?? 0.0,
      diagnosa: data['diagnosa'] ?? '',
      resepObat: data['resepObat'] ?? '',
      catatanDokter: data['catatanDokter'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'noRekamMedis': noRekamMedis,
      'namaPasien': namaPasien,
      'tanggalPengecekan': Timestamp.fromDate(tanggalPengecekan),
      'dokterName': dokterName,
      'keluhan': keluhan,
      'tensiDarah': tensiDarah,
      'beratBadan': beratBadan,
      'tinggiBadan': tinggiBadan,
      'suhuTubuh': suhuTubuh,
      'diagnosa': diagnosa,
      'resepObat': resepObat,
      'catatanDokter': catatanDokter,
    };
  }
}
