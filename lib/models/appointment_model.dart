class Appointment {
  final String id;
  final String namaPasien;
  final String nikOrKeluhan;
  final String poli;
  final String waktu; // e.g. "08:30"
  final int estimasiMenit;
  final bool isEmergency;
  final String status; // "menunggu" / "selesai" / "dibatalkan"
  final DateTime tanggal;

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
      status: data['status'] ?? 'menunggu',
      tanggal: parseTanggal(data['tanggal']),
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
    );
  }
}
