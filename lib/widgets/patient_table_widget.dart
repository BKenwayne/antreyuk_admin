import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:antreyuk_admin/models/patient_queue_model.dart';

class PatientTableWidget extends StatelessWidget {
  final List<PatientQueue> patients;
  final String activeFilter;
  final Function(String) onFilterChanged;
  final Function(PatientQueue, String) onStatusChanged;
  final int currentPage;
  final int totalPatients;
  final int patientsPerPage;
  final Function(int) onPageChanged;
  final bool isSuperAdmin;

  const PatientTableWidget({
    super.key,
    required this.patients,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onStatusChanged,
    required this.currentPage,
    required this.totalPatients,
    required this.patientsPerPage,
    required this.onPageChanged,
    this.isSuperAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and filter tabs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Antrean Pasien',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                // Filter Tabs
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab('Semua'),
                      _buildFilterTab('Menunggu'),
                      _buildFilterTab('Selesai'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 290,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                headingRowHeight: 48,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 72,
                horizontalMargin: 20,
                columnSpacing: 24,
                columns: [
                  DataColumn(
                    label: Text(
                      'NOMOR\nANTREAN',
                      style: _headerStyle(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NAMA PASIEN',
                      style: _headerStyle(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'KELUHAN AWAL',
                      style: _headerStyle(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'WAKTU\nDAFTAR',
                      style: _headerStyle(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: _headerStyle(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AKSI',
                      style: _headerStyle(),
                    ),
                  ),
                ],
                rows: patients.map((patient) => _buildRow(patient, context)).toList(),
              ),
            ),
          ),
          // Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getPaginationText(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Row(
                  children: [
                    _buildPageButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: currentPage > 0
                          ? () => onPageChanged(currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    _buildPageButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: (currentPage + 1) * patientsPerPage < totalPatients
                          ? () => onPageChanged(currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.montserrat(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF64748B),
      letterSpacing: 0.5,
    );
  }

  Widget _buildFilterTab(String label) {
    final bool isActive = activeFilter == label;
    return InkWell(
      onTap: () => onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F1B2D) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(PatientQueue patient, BuildContext context) {
    return DataRow(
      cells: [
        // Nomor Antrean
        DataCell(
          Text(
            patient.nomorAntrean,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        // Nama Pasien + No Rekam Medis
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.namaPasien,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                patient.poliTujuan,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Keluhan Awal
        DataCell(
          SizedBox(
            width: 180,
            child: Text(
              patient.keluhanAwal,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Waktu Daftar
        DataCell(
          Text(
            _formatTime(patient.waktuDaftar),
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFF475569),
            ),
          ),
        ),
        // Status
        DataCell(_buildStatusBadge(patient.status)),
        // Aksi
        DataCell(_buildActionButton(patient, context)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'dipanggil':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFEA580C);
        label = 'Dipanggil';
        break;
      case 'menunggu':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        label = 'Menunggu';
        break;
      case 'selesai':
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        label = 'Selesai';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(PatientQueue patient, BuildContext context) {
    if (!isSuperAdmin) {
      switch (patient.status.toLowerCase()) {
        case 'dipanggil':
          return IconButton(
            onPressed: () => onStatusChanged(patient, 'selesai'),
            icon: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF16A34A),
              size: 20,
            ),
            tooltip: 'Tandai Selesai',
          );
        case 'menunggu':
          return const SizedBox.shrink();
        case 'selesai':
          return Icon(
            Icons.check_circle_outline,
            color: Colors.grey.shade400,
            size: 20,
          );
        default:
          return const SizedBox.shrink();
      }
    }

    switch (patient.status.toLowerCase()) {
      case 'dipanggil':
        return PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
          onSelected: (value) => onStatusChanged(patient, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'selesai',
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text('Tandai Selesai', style: GoogleFonts.montserrat(fontSize: 13)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'menunggu',
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text('Kembalikan ke Antrean', style: GoogleFonts.montserrat(fontSize: 13)),
                ],
              ),
            ),
          ],
        );
      case 'menunggu':
        return IconButton(
          onPressed: () => onStatusChanged(patient, 'dipanggil'),
          icon: const Icon(
            Icons.call_rounded,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          tooltip: 'Panggil Pasien',
        );
      case 'selesai':
        return Icon(
          Icons.check_circle_outline,
          color: Colors.grey.shade400,
          size: 20,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPageButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  String _getPaginationText() {
    final start = currentPage * patientsPerPage + 1;
    final end = ((currentPage + 1) * patientsPerPage).clamp(0, totalPatients);
    return 'Menampilkan $start-$end dari $totalPatients antrean hari ini';
  }
}
