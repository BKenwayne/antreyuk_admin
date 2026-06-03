import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antreyuk_admin/models/patient_queue_model.dart';
import 'package:antreyuk_admin/widgets/sidebar_widget.dart';
import 'package:antreyuk_admin/widgets/top_bar_widget.dart';
import 'package:antreyuk_admin/widgets/current_queue_card.dart';
import 'package:antreyuk_admin/widgets/stats_card_widget.dart';
import 'package:antreyuk_admin/widgets/patient_table_widget.dart';
import 'package:antreyuk_admin/screens/jadwal_dokter_page.dart';
import 'package:antreyuk_admin/login_page.dart';

class DashboardPage extends StatefulWidget {
  final String adminName;
  final String adminRole;

  const DashboardPage({
    super.key,
    required this.adminName,
    required this.adminRole,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool get isSuperAdmin => widget.adminRole == 'super admin';

  int _sidebarIndex = 0;
  String _activeFilter = 'Semua';
  int _currentPage = 0;
  final int _patientsPerPage = 10;
  List<PatientQueue> _allPatients = [];

  // Firebase Realtime Database reference
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('antrean');

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            SidebarWidget(
              selectedIndex: _sidebarIndex,
              onItemSelected: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JadwalDokterPage(
                        adminName: widget.adminName,
                        adminRole: widget.adminRole,
                      ),
                    ),
                  );
                } else {
                  setState(() => _sidebarIndex = index);
                }
              },
              onLogout: _logout,
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  TopBarWidget(
                    doctorName: widget.adminName,
                    poliName: widget.adminRole,
                  ),
                  // Content Area
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: StreamBuilder<DatabaseEvent>(
                        stream: _dbRef.orderByChild('waktuDaftar').onValue,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.montserrat(),
                              ),
                            );
                          }

                          // Parse all patients
                          final data = snapshot.data?.snapshot.value;
                          _allPatients = [];
                          if (data is Map) {
                            data.forEach((key, value) {
                              if (value is Map) {
                                _allPatients.add(
                                  PatientQueue.fromRealtime(key.toString(), value),
                                );
                              }
                            });
                            // Sort by waktuDaftar ascending
                            _allPatients.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
                          }

                          return _buildDashboardContent();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    // Calculate stats
    final menunggu =
        _allPatients.where((p) => p.status == 'menunggu').length;
    final selesai =
        _allPatients.where((p) => p.status == 'selesai').length;
    final dipanggil =
        _allPatients.where((p) => p.status == 'dipanggil').toList();

    // Current called patient
    final PatientQueue? currentPatient =
        dipanggil.isNotEmpty ? dipanggil.first : null;

    // Filter patients for table
    List<PatientQueue> filteredPatients;
    switch (_activeFilter) {
      case 'Menunggu':
        filteredPatients =
            _allPatients.where((p) => p.status == 'menunggu').toList();
        break;
      case 'Selesai':
        filteredPatients =
            _allPatients.where((p) => p.status == 'selesai').toList();
        break;
      default:
        filteredPatients = _allPatients;
    }

    final totalFiltered = filteredPatients.length;
    final startIndex = _currentPage * _patientsPerPage;
    final endIndex =
        (startIndex + _patientsPerPage).clamp(0, totalFiltered);
    final paginatedPatients = filteredPatients.sublist(
      startIndex.clamp(0, totalFiltered),
      endIndex,
    );

    // Rata-rata durasi (estimate)
    final avgDuration = _allPatients.isNotEmpty
        ? (_allPatients.fold<int>(
                0, (acc, p) => acc + p.estimasiMenit) /
            _allPatients.length)
            .round()
        : 0;

    // Date string
    final now = DateTime.now();
    final dayNames = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr =
        '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pusat Kontrol Antrean',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Poli Umum — $dateStr',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Current Queue + Stats Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Queue Card
              Expanded(
                flex: 3,
                child: CurrentQueueCard(
                  currentPatient: currentPatient,
                  onCallNext: _callNextPatient,
                  onRecall: () => _recallPatient(currentPatient),
                  isSuperAdmin: isSuperAdmin,
                ),
              ),
              const SizedBox(width: 20),
              // Stats Cards
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    StatsCardWidget(
                      icon: Icons.people_alt_rounded,
                      iconBgColor: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Total Menunggu',
                      value: '$menunggu Pasien',
                    ),
                    const SizedBox(height: 12),
                    StatsCardWidget(
                      icon: Icons.check_circle_rounded,
                      iconBgColor: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF16A34A),
                      title: 'Telah Dilayani',
                      value: '$selesai Pasien',
                    ),
                    const SizedBox(height: 12),
                    StatsCardWidget(
                      icon: Icons.timer_rounded,
                      iconBgColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      title: 'Rata-Rata Durasi',
                      value: '$avgDuration Menit',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Patient Table
          PatientTableWidget(
            patients: paginatedPatients,
            activeFilter: _activeFilter,
            onFilterChanged: (filter) {
              setState(() {
                _activeFilter = filter;
                _currentPage = 0;
              });
            },
            onStatusChanged: _updatePatientStatus,
            currentPage: _currentPage,
            totalPatients: totalFiltered,
            patientsPerPage: _patientsPerPage,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            isSuperAdmin: isSuperAdmin,
          ),
        ],
      ),
    );
  }

  Future<void> _callNextPatient() async {
    try {
      // Mark current "dipanggil" patients as "selesai"
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        final val = snapshot.value;
        final updates = <String, dynamic>{};
        if (val is Map) {
          val.forEach((key, value) {
            if (value is Map && value['status'] == 'dipanggil') {
              updates['$key/status'] = 'selesai';
            }
          });
        } else if (val is List) {
          for (int i = 0; i < val.length; i++) {
            final value = val[i];
            if (value is Map && value['status'] == 'dipanggil') {
              updates['$i/status'] = 'selesai';
            }
          }
        }
        if (updates.isNotEmpty) {
          await _dbRef.update(updates);
        }
      }

      // Get next "menunggu" patient
      final queryEvent = await _dbRef
          .orderByChild('status')
          .equalTo('menunggu')
          .limitToFirst(1)
          .get();

      if (queryEvent.exists) {
        String? nextKey;
        final val = queryEvent.value;
        if (val is Map) {
          nextKey = val.keys.first.toString();
        } else if (val is List) {
          for (int i = 0; i < val.length; i++) {
            if (val[i] != null) {
              nextKey = i.toString();
              break;
            }
          }
        }

        if (nextKey != null) {
          await _dbRef.child(nextKey).update({'status': 'dipanggil'});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Memanggil pasien berikutnya...',
                  style: GoogleFonts.montserrat(),
                ),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } else {
          _showNoWaitingSnackbar();
        }
      } else {
        _showNoWaitingSnackbar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNoWaitingSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak ada pasien yang menunggu.',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _recallPatient(PatientQueue? patient) async {
    if (patient == null) return;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Memanggil ulang ${patient.namaPasien} (${patient.nomorAntrean})...',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _updatePatientStatus(
      PatientQueue patient, String newStatus) async {
    try {
      await _dbRef.child(patient.id).update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status ${patient.namaPasien} diubah ke "$newStatus".',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
