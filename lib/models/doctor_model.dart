class Doctor {
  final String id;
  final String name;
  final String poli;
  final bool isActive;
  final String avatarUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.poli,
    required this.isActive,
    required this.avatarUrl,
  });

  factory Doctor.fromRealtime(String id, Map<dynamic, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] ?? '',
      poli: data['poli'] ?? '',
      isActive: data['isActive'] ?? false,
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toRealtimeMap() {
    return {
      'name': name,
      'poli': poli,
      'isActive': isActive,
      'avatarUrl': avatarUrl,
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? poli,
    bool? isActive,
    String? avatarUrl,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      poli: poli ?? this.poli,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
