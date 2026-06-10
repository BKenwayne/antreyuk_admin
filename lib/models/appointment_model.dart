import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String namaPasien;
  final String nikOrKeluhan;
  final String poli;
  final String waktu; // e.g. "08:30"
  final int estimasiMenit;
  final bool isEmergency;
  final String status; // e.g. "Menunggu Konfirmasi", "selesai" / "dibatalkan"
  final DateTime tanggal;
  final String userId;
  final String doctorName;

  Appointment({
    required this.id,
    required this.namaPasien,
    required this.nikOrKeluhan,
    required this.poli,
    required this.waktu,
    required this.estimasiMenit,
    required this.isEmergency,
    required this.status,
    required this.tanggal,
    this.userId = '',
    this.doctorName = '',
  });

  factory Appointment.fromRealtime(String id, Map<dynamic, dynamic> data) {
    DateTime parseTanggal(dynamic val) {
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Appointment(
      id: id,
      namaPasien: data['namaPasien'] ?? '',
      nikOrKeluhan: data['nikOrKeluhan'] ?? '',
      poli: data['poli'] ?? '',
      waktu: data['waktu'] ?? '',
      estimasiMenit: data['estimasiMenit'] ?? 15,
      isEmergency: data['isEmergency'] ?? false,
      status: data['status'] ?? 'Menunggu Konfirmasi',
      tanggal: parseTanggal(data['tanggal']),
      userId: data['userId'] ?? '',
      doctorName: data['doctorName'] ?? '',
    );
  }

  factory Appointment.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parseTanggal(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Appointment(
      id: id,
      namaPasien: data['namaPasien'] ?? '',
      nikOrKeluhan: data['nikOrKeluhan'] ?? '',
      poli: data['poli'] ?? '',
      waktu: data['time'] ?? '', // Mobile uses 'time'
      estimasiMenit: data['estimasiMenit'] ?? 15,
      isEmergency: data['isEmergency'] ?? false,
      status: data['status'] ?? 'Menunggu Konfirmasi',
      tanggal: parseTanggal(data['appointment_date']), // Mobile uses 'appointment_date'
      userId: data['userId'] ?? '',
      doctorName: data['doctorName'] ?? '',
    );
  }

  Map<String, dynamic> toRealtimeMap() {
    return {
      'namaPasien': namaPasien,
      'nikOrKeluhan': nikOrKeluhan,
      'poli': poli,
      'waktu': waktu,
      'estimasiMenit': estimasiMenit,
      'isEmergency': isEmergency,
      'status': status,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'userId': userId,
      'doctorName': doctorName,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    // Format date string for mobile app (Indonesian format e.g. "Kamis, 4 Juni 2026")
    List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    List<String> months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    String formattedDate = '${days[tanggal.weekday - 1]}, ${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';

    return {
      'appointment_date': Timestamp.fromDate(tanggal),
      'date': formattedDate,
      'doctorName': doctorName,
      'poli': poli,
      'status': status,
      'time': waktu,
      'timestamp': Timestamp.now(),
      'userId': userId,
    };
  }

  Appointment copyWith({
    String? id,
    String? namaPasien,
    String? nikOrKeluhan,
    String? poli,
    String? waktu,
    int? estimasiMenit,
    bool? isEmergency,
    String? status,
    DateTime? tanggal,
    String? userId,
    String? doctorName,
  }) {
    return Appointment(
      id: id ?? this.id,
      namaPasien: namaPasien ?? this.namaPasien,
      nikOrKeluhan: nikOrKeluhan ?? this.nikOrKeluhan,
      poli: poli ?? this.poli,
      waktu: waktu ?? this.waktu,
      estimasiMenit: estimasiMenit ?? this.estimasiMenit,
      isEmergency: isEmergency ?? this.isEmergency,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      userId: userId ?? this.userId,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}
