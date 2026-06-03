import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antreyuk_admin/models/doctor_model.dart';
import 'package:antreyuk_admin/models/appointment_model.dart';
import 'package:antreyuk_admin/widgets/sidebar_widget.dart';
import 'package:antreyuk_admin/widgets/top_bar_widget.dart';
import 'package:antreyuk_admin/screens/dashboard_page.dart';
import 'package:antreyuk_admin/login_page.dart';

class JadwalDokterPage extends StatefulWidget {
  final String adminName;
  final String adminRole;

  const JadwalDokterPage({
    super.key,
    required this.adminName,
    required this.adminRole,
  });

  @override
  State<JadwalDokterPage> createState() => _JadwalDokterPageState();
}

class _JadwalDokterPageState extends State<JadwalDokterPage> {
  bool get isSuperAdmin => widget.adminRole.toLowerCase() == 'super admin';

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  // State for selected date in calendar
  late DateTime _selectedDate;
  late DateTime _startOfWeek;
  
  // Filter for weekly vs monthly view (for UI toggles)
  String _calendarViewMode = 'Minggu'; // 'Minggu' or 'Bulan'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _calculateWeekRange();
  }

  void _calculateWeekRange() {
    // Start of week is Monday
    int currentWeekday = _selectedDate.weekday;
    _startOfWeek = _selectedDate.subtract(Duration(days: currentWeekday - 1));
  }

  void _changeWeek(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _calculateWeekRange();
    });
  }

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
              selectedIndex: 1,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(
                        adminName: widget.adminName,
                        adminRole: widget.adminRole,
                      ),
                    ),
                  );
                }
              },
              onLogout: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  TopBarWidget(
                    doctorName: widget.adminName,
                    poliName: widget.adminRole,
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: StreamBuilder<DatabaseEvent>(
                        stream: _dbRef.onValue,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.montserrat(),
                              ),
                            );
                          }

                          // Parsing Doctors
                          List<Doctor> doctors = [];
                          final dataVal = snapshot.data?.snapshot.value as Map?;
                          if (dataVal != null && dataVal['dokter'] is Map) {
                            final dokterMap = dataVal['dokter'] as Map;
                            dokterMap.forEach((key, val) {
                              if (val is Map) {
                                doctors.add(Doctor.fromRealtime(key.toString(), val));
                              }
                            });
                          }

                          // Parsing Appointments
                          List<Appointment> appointments = [];
                          if (dataVal != null && dataVal['antrean_janjitemu'] is Map) {
                            final aptMap = dataVal['antrean_janjitemu'] as Map;
                            aptMap.forEach((key, val) {
                              if (val is Map) {
                                appointments.add(Appointment.fromRealtime(key.toString(), val));
                              }
                            });
                          }

                          // Filter appointments for the selected date
                          final filteredAppointments = appointments.where((apt) {
                            return apt.tanggal.year == _selectedDate.year &&
                                apt.tanggal.month == _selectedDate.month &&
                                apt.tanggal.day == _selectedDate.day;
                          }).toList();
                          
                          // Sort by waktu ascending
                          filteredAppointments.sort((a, b) => a.waktu.compareTo(b.waktu));

                          return _buildMainLayout(doctors, filteredAppointments);
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

  Widget _buildMainLayout(List<Doctor> doctors, List<Appointment> selectedDayAppointments) {
    // Hitung statistics dari seluruh appointment hari ini
    final selesaiHariIni = selectedDayAppointments.where((a) => a.status == 'selesai').length;
    final sisaAntrean = selectedDayAppointments.where((a) => a.status == 'menunggu').length;
    final pembatalan = selectedDayAppointments.where((a) => a.status == 'dibatalkan').length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Jadwal',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atur ketersediaan staf medis dan pantau antrean janji temu real-time.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Button Tambah Janji Temu (Super Admin Only Enabled)
                  ElevatedButton.icon(
                    onPressed: isSuperAdmin 
                      ? () => _showAddAppointmentDialog()
                      : () => _showAccessDeniedSnackbar('tambah janji temu'),
                    icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    label: Text(
                      'Tambah Janji Temu',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuperAdmin ? const Color(0xFF0F3A60) : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Status Dokter
              Expanded(
                flex: 4,
                child: _buildDoctorsCard(doctors),
              ),
              const SizedBox(width: 24),
              // Right Column: Kalender Janji Temu
              Expanded(
                flex: 7,
                child: _buildCalendarCard(selectedDayAppointments),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bottom Summary Row
          _buildBottomSummary(selesaiHariIni, sisaAntrean, pembatalan),
        ],
      ),
    );
  }

  // Left Card: Status Dokter
  Widget _buildDoctorsCard(List<Doctor> doctors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF0F3A60), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Status Dokter',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          doctors.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Tidak ada data dokter.',
                      style: GoogleFonts.montserrat(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getDoctorIcon(doctor.poli),
                            color: const Color(0xFF2563EB),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                doctor.poli,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Toggle Switch (Super Admin Enabled, Admin Disabled)
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeTrackColor: const Color(0xFF16A34A),
                            value: doctor.isActive,
                            onChanged: isSuperAdmin
                                ? (value) => _toggleDoctorStatus(doctor, value)
                                : (value) => _showAccessDeniedSnackbar('mengubah status aktif dokter'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          const SizedBox(height: 20),
          // Lihat Semua Dokter Button
          OutlinedButton(
            onPressed: () {
              _showInfoSnackbar('Menampilkan seluruh daftar dokter puskesmas...');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Lihat Semua Dokter',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDoctorIcon(String poli) {
    switch (poli.toLowerCase()) {
      case 'poli gigi':
        return Icons.medical_services_outlined;
      case 'poli kia':
        return Icons.child_care_rounded;
      case 'lab utama':
        return Icons.science_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  Future<void> _toggleDoctorStatus(Doctor doctor, bool value) async {
    try {
      await _dbRef.child('dokter/${doctor.id}').update({'isActive': value});
      _showSuccessSnackbar('Status ${doctor.name} diubah ke ${value ? "Aktif" : "Tidak Aktif"}.');
    } catch (e) {
      _showErrorSnackbar('Gagal memperbarui status: $e');
    }
  }

  // Right Card: Kalender Janji Temu
  Widget _buildCalendarCard(List<Appointment> appointments) {
    final endOfWeek = _startOfWeek.add(const Duration(days: 6));
    final String rangeText = "${_startOfWeek.day} - ${endOfWeek.day} ${_getMonthName(_selectedDate)} ${_selectedDate.year}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Kalender Title, View Toggle, Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: Color(0xFF0F3A60), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kalender Janji Temu',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Toggle Minggu Ini / Bulan
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildViewModeToggle('Minggu Ini', 'Minggu'),
                        _buildViewModeToggle('Bulan', 'Bulan'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Navigasi Tanggal (Panah kiri, Tanggal Range, Panah kanan)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _changeWeek(-7),
                        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rangeText,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _changeWeek(7),
                        icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Horizontal Days Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = _startOfWeek.add(Duration(days: index));
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F3A60) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F3A60) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getShortDayName(date.weekday),
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white54 : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString().padLeft(2, '0'),
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Appointments list
          appointments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada janji temu hari ini.',
                          style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          // Time & Duration
                          SizedBox(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.waktu,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: appointment.isEmergency 
                                      ? const Color(0xFFEF4444) 
                                      : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.isEmergency ? 'DARURAT' : '${appointment.estimasiMenit} Menit',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: appointment.isEmergency 
                                      ? const Color(0xFFEF4444) 
                                      : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Avatar placeholder
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: appointment.isEmergency
                              ? const Icon(Icons.star_rounded, color: Color(0xFFEF4444), size: 18)
                              : const Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                          ),
                          const SizedBox(width: 16),
                          // Patient Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.namaPasien,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: appointment.isEmergency 
                                      ? const Color(0xFFEF4444) 
                                      : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.nikOrKeluhan,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Badge Poli
                          _buildPoliBadge(appointment),
                          const SizedBox(width: 16),
                          // Dropdown / Three-dots Actions
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                            onSelected: (action) => _handleAppointmentAction(appointment, action),
                            itemBuilder: (BuildContext context) {
                              return [
                                if (appointment.status != 'selesai')
                                  const PopupMenuItem<String>(
                                    value: 'selesai',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                                        SizedBox(width: 8),
                                        Text('Selesaikan Janji Temu'),
                                      ],
                                    ),
                                  ),
                                if (isSuperAdmin) ...[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                                        SizedBox(width: 8),
                                        Text('Ubah Detail'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'hapus',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                        SizedBox(width: 8),
                                        Text('Hapus Janji Temu'),
                                      ],
                                    ),
                                  ),
                                ]
                              ];
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20),
          // Footer Link
          Center(
            child: InkWell(
              onTap: () {
                _showInfoSnackbar('Menampilkan seluruh jadwal dokter & janji temu...');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Seluruh Jadwal Hari Ini',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F3A60),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F3A60), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle(String title, String mode) {
    final bool active = _calendarViewMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarViewMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? const Color(0xFF0F3A60) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPoliBadge(Appointment appointment) {
    Color bg;
    Color text;
    String label = appointment.poli;

    if (appointment.isEmergency) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFEF4444);
    } else {
      switch (appointment.poli.toLowerCase()) {
        case 'poli umum':
          bg = const Color(0xFFDCFCE7);
          text = const Color(0xFF16A34A);
          break;
        case 'poli kia':
          bg = const Color(0xFFFEF9C3);
          text = const Color(0xFFCA8A04);
          break;
        case 'poli gigi':
          bg = const Color(0xFFE0F2FE);
          text = const Color(0xFF0284C7);
          break;
        default:
          bg = const Color(0xFFF1F5F9);
          text = const Color(0xFF475569);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  // Appointment action handlers
  void _handleAppointmentAction(Appointment appointment, String action) async {
    if (action == 'selesai') {
      try {
        await _dbRef.child('antrean_janjitemu/${appointment.id}').update({'status': 'selesai'});
        _showSuccessSnackbar('Janji temu ${appointment.namaPasien} selesai.');
      } catch (e) {
        _showErrorSnackbar('Gagal mengubah status: $e');
      }
    } else if (action == 'edit') {
      if (isSuperAdmin) {
        _showAddAppointmentDialog(existing: appointment);
      } else {
        _showAccessDeniedSnackbar('mengubah data');
      }
    } else if (action == 'hapus') {
      if (isSuperAdmin) {
        try {
          await _dbRef.child('antrean_janjitemu/${appointment.id}').remove();
          _showSuccessSnackbar('Janji temu ${appointment.namaPasien} berhasil dihapus.');
        } catch (e) {
          _showErrorSnackbar('Gagal menghapus janji temu: $e');
        }
      } else {
        _showAccessDeniedSnackbar('menghapus data');
      }
    }
  }

  // Bottom Summary row
  Widget _buildBottomSummary(int selesai, int sisa, int batal) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.check_circle_outline_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'SELESAI HARI INI',
            value: selesai.toString().padLeft(2, '0'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.list_alt_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            title: 'SISA ANTREAN',
            value: sisa.toString().padLeft(2, '0'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.timer_outlined,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            title: 'RATA-RATA TUNGGU',
            value: '18m',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.cancel_outlined,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFEF4444),
            title: 'PEMBATALAN',
            value: batal.toString().padLeft(2, '0'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog for Adding or Editing an Appointment (Super Admin only)
  void _showAddAppointmentDialog({Appointment? existing}) {
    final nameController = TextEditingController(text: existing?.namaPasien ?? '');
    final infoController = TextEditingController(text: existing?.nikOrKeluhan ?? '');
    final timeController = TextEditingController(text: existing?.waktu ?? '09:00');
    final durationController = TextEditingController(text: existing?.estimasiMenit.toString() ?? '15');
    
    String selectedPoli = existing?.poli ?? 'Poli Umum';
    bool isEmergency = existing?.isEmergency ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                existing == null ? 'Tambah Janji Temu Baru' : 'Ubah Detail Janji Temu',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pasien',
                        hintText: 'e.g. Budi Santoso',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: infoController,
                      decoration: const InputDecoration(
                        labelText: 'NIK / Keluhan',
                        hintText: 'e.g. NIK: 32750...4401 atau Sesak Napas',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: timeController,
                            decoration: const InputDecoration(
                              labelText: 'Waktu Mulai',
                              hintText: 'e.g. 08:30',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Durasi (Menit)',
                              hintText: 'e.g. 15',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPoli,
                      decoration: const InputDecoration(labelText: 'Poli Tujuan'),
                      items: ['Poli Umum', 'Poli KIA', 'Poli Gigi', 'IGD / Umum']
                          .map((poli) => DropdownMenuItem(value: poli, child: Text(poli)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedPoli = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text(
                        'Pasien Darurat (Emergency)',
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                      value: isEmergency,
                      activeColor: Colors.red,
                      onChanged: (val) {
                        setDialogState(() {
                          isEmergency = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.montserrat(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final Map<String, dynamic> data = {
                      'namaPasien': nameController.text,
                      'nikOrKeluhan': infoController.text,
                      'poli': selectedPoli,
                      'waktu': timeController.text,
                      'estimasiMenit': int.tryParse(durationController.text) ?? 15,
                      'isEmergency': isEmergency,
                      'status': existing?.status ?? 'menunggu',
                      'tanggal': (existing?.tanggal ?? _selectedDate).millisecondsSinceEpoch,
                    };

                    try {
                      if (existing == null) {
                        // Generate key
                        final newKey = _dbRef.child('antrean_janjitemu').push().key;
                        if (newKey != null) {
                          await _dbRef.child('antrean_janjitemu/$newKey').set(data);
                        }
                      } else {
                        await _dbRef.child('antrean_janjitemu/${existing.id}').set(data);
                      }
                      if (context.mounted) Navigator.pop(context);
                      _showSuccessSnackbar(existing == null 
                          ? 'Janji temu baru ditambahkan.' 
                          : 'Janji temu berhasil diubah.');
                    } catch (e) {
                      _showErrorSnackbar('Gagal menyimpan janji temu: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3A60),
                  ),
                  child: Text('Simpan', style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helpers for snackbars
  void _showInfoSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAccessDeniedSnackbar(String actionName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Akses ditolak: Hanya Super Admin yang diizinkan untuk $actionName.',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper date parsing
  String _getMonthName(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[date.month - 1];
  }

  String _getShortDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[weekday - 1];
  }
}
