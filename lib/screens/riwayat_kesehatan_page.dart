import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:antreyuk_admin/models/medical_record_model.dart';
import 'package:antreyuk_admin/widgets/sidebar_widget.dart';
import 'package:antreyuk_admin/widgets/top_bar_widget.dart';
import 'package:antreyuk_admin/screens/dashboard_page.dart';
import 'package:antreyuk_admin/screens/jadwal_dokter_page.dart';
import 'package:antreyuk_admin/utils/fade_route.dart';

class RiwayatKesehatanPage extends StatefulWidget {
  final String adminName;
  final String adminRole;

  const RiwayatKesehatanPage({
    super.key,
    required this.adminName,
    required this.adminRole,
  });

  @override
  State<RiwayatKesehatanPage> createState() => _RiwayatKesehatanPageState();
}

class _RiwayatKesehatanPageState extends State<RiwayatKesehatanPage> {
  final int _sidebarIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<MedicalRecord> _allRecords = [];
  bool _isLoading = false;
  MedicalRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medical_records')
          .orderBy('tanggalPengecekan', descending: true)
          .get();

      final records = querySnapshot.docs
          .map((doc) => MedicalRecord.fromFirestore(doc))
          .toList();

      setState(() {
        _allRecords = records;
        // Keep selected if still exists, otherwise pick first
        if (_selectedRecord != null) {
          final stillExists = records.any((r) => r.id == _selectedRecord!.id);
          if (!stillExists) {
            _selectedRecord = records.isNotEmpty ? records.first : null;
          } else {
            _selectedRecord = records.firstWhere((r) => r.id == _selectedRecord!.id);
          }
        } else if (records.isNotEmpty) {
          _selectedRecord = records.first;
        }
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal memuat riwayat medis: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MedicalRecord> get _filteredRecords {
    if (_searchQuery.isEmpty) return _allRecords;
    final query = _searchQuery.toLowerCase();
    return _allRecords.where((r) =>
        r.namaPasien.toLowerCase().contains(query) ||
        r.noRekamMedis.toLowerCase().contains(query) ||
        r.diagnosa.toLowerCase().contains(query)).toList();
  }

  // ─── CRUD Actions ─────────────────────────────────────────────────────────

  void _showAddDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RiwayatFormDialog(
        doctorName: widget.adminName,
        existingRecord: null, // null = mode tambah
        onSaved: () {
          _fetchRecords();
        },
      ),
    );
  }

  void _showEditDialog(MedicalRecord record) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RiwayatFormDialog(
        doctorName: widget.adminName,
        existingRecord: record, // ada data = mode edit
        onSaved: () {
          _fetchRecords();
        },
      ),
    );
  }

  Future<void> _deleteRecord(MedicalRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Hapus Rekam Medis',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus riwayat pemeriksaan ${record.namaPasien} '
          'pada ${DateFormat('dd MMM yyyy').format(record.tanggalPengecekan)}? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.montserrat(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('medical_records')
          .doc(record.id)
          .delete();
      _showSuccessSnackbar('Rekam medis berhasil dihapus.');
      await _fetchRecords();
    } catch (e) {
      _showErrorSnackbar('Gagal menghapus: $e');
    }
  }

  // ─── Snackbars ─────────────────────────────────────────────────────────────

  void _showSuccessSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  void _showErrorSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        body: Row(
          children: [
            SidebarWidget(
              selectedIndex: _sidebarIndex,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    FadeRoute(
                      page: DashboardPage(
                        adminName: widget.adminName,
                        adminRole: widget.adminRole,
                      ),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    FadeRoute(
                      page: JadwalDokterPage(
                        adminName: widget.adminName,
                        adminRole: widget.adminRole,
                      ),
                    ),
                  );
                }
              },
              onLogout: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: Column(
                children: [
                  TopBarWidget(
                    doctorName: widget.adminName,
                    poliName: widget.adminRole,
                    showSearchBar: false,
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildListSection(_filteredRecords),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 6,
                                  child: _buildDetailsSection(),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rekam Medis & Riwayat Kesehatan',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tambah, edit, dan kelola hasil riwayat kesehatan pasien Puskesmas.',
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // ── Tombol Tambah Riwayat
        ElevatedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          label: Text(
            'Tambah Riwayat',
            style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F1B2D),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ─── Left: List ────────────────────────────────────────────────────────────

  Widget _buildListSection(List<MedicalRecord> records) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Cari nama pasien atau No. Rekam Medis...',
              hintStyle: GoogleFonts.montserrat(
                  fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      })
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF0F1B2D), width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada rekam medis ditemukan.',
                              style: GoogleFonts.montserrat(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (_, i) {
                          final r = records[i];
                          final isSelected = _selectedRecord?.id == r.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRecord = r),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEFF6FF)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFBFDBFE)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          r.namaPasien,
                                          style:
                                              GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: const Color(
                                                0xFF1E293B),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    6),
                                          ),
                                          child: Text(
                                            r.noRekamMedis,
                                            style:
                                                GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(
                                                  0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Diagnosa: ${r.diagnosa}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color:
                                              const Color(0xFF475569)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          r.dokterName,
                                          style:
                                              GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey.shade500),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm')
                                              .format(
                                                  r.tanggalPengecekan),
                                          style:
                                              GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Right: Detail ─────────────────────────────────────────────────────────

  Widget _buildDetailsSection() {
    final record = _selectedRecord;
    if (record == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Pilih rekam medis dari daftar',
                style: GoogleFonts.montserrat(
                    color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'atau tambah riwayat baru',
                style: GoogleFonts.montserrat(
                    color: Colors.grey.shade400, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Detail Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.namaPasien,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F1B2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.noRekamMedis,
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Oleh: ${record.dokterName}',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              // ── Action Buttons
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Waktu Pemeriksaan',
                          style: GoogleFonts.montserrat(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(record.tanggalPengecekan),
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B)),
                      ),
                      Text(
                        DateFormat('HH:mm WIB')
                            .format(record.tanggalPengecekan),
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Edit button
                  Tooltip(
                    message: 'Edit riwayat',
                    child: InkWell(
                      onTap: () => _showEditDialog(record),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 18, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  Tooltip(
                    message: 'Hapus riwayat',
                    child: InkWell(
                      onTap: () => _deleteRecord(record),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            size: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 28),

          // ── Body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vital Signs
                  _sectionLabel('TANDA-TANDA VITAL'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _vitalCard(
                            Icons.speed_rounded, Colors.red,
                            'Tensi Darah', record.tensiDarah)),
                      Expanded(
                        child: _vitalCard(
                            Icons.thermostat_rounded, Colors.orange,
                            'Suhu', '${record.suhuTubuh} °C')),
                      Expanded(
                        child: _vitalCard(
                            Icons.monitor_weight_rounded, Colors.blue,
                            'Berat Badan', '${record.beratBadan} kg')),
                      Expanded(
                        child: _vitalCard(
                            Icons.height_rounded, Colors.green,
                            'Tinggi Badan', '${record.tinggiBadan} cm')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Keluhan
                  _sectionLabel('KELUHAN UTAMA'),
                  _sectionBody(record.keluhan),
                  const SizedBox(height: 16),

                  // Diagnosa
                  _sectionLabel('DIAGNOSA MEDIS'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Text(record.diagnosa,
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC2410C))),
                  ),
                  const SizedBox(height: 16),

                  // Resep
                  _sectionLabel('RESEP OBAT'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Text(record.resepObat,
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF15803D))),
                  ),

                  // Catatan
                  if (record.catatanDokter.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _sectionLabel('CATATAN PEMERIKSA'),
                    _sectionBody(record.catatanDokter),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper Widgets ────────────────────────────────────────────────────────

  Widget _vitalCard(IconData icon, Color color, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 1.0)),
    );
  }

  Widget _sectionBody(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Text(text,
          style: GoogleFonts.montserrat(
              fontSize: 13, color: const Color(0xFF334155))),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Dialog Form: Tambah & Edit Riwayat Kesehatan
// ══════════════════════════════════════════════════════════════════════════════

class _RiwayatFormDialog extends StatefulWidget {
  final String doctorName;
  final MedicalRecord? existingRecord; // null → tambah, ada data → edit
  final VoidCallback onSaved;

  const _RiwayatFormDialog({
    required this.doctorName,
    required this.existingRecord,
    required this.onSaved,
  });

  @override
  State<_RiwayatFormDialog> createState() => _RiwayatFormDialogState();
}

class _RiwayatFormDialogState extends State<_RiwayatFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _namaController;
  late final TextEditingController _rmController;
  late final TextEditingController _keluhanController;
  late final TextEditingController _tensiController;
  late final TextEditingController _suhuController;
  late final TextEditingController _bbController;
  late final TextEditingController _tbController;
  late final TextEditingController _diagnosaController;
  late final TextEditingController _resepController;
  late final TextEditingController _catatanController;

  bool get _isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _namaController    = TextEditingController(text: r?.namaPasien ?? '');
    _rmController      = TextEditingController(text: r?.noRekamMedis ?? '');
    _keluhanController = TextEditingController(text: r?.keluhan ?? '');
    _tensiController   = TextEditingController(text: r?.tensiDarah ?? '');
    _suhuController    = TextEditingController(text: r != null ? '${r.suhuTubuh}' : '');
    _bbController      = TextEditingController(text: r != null ? '${r.beratBadan}' : '');
    _tbController      = TextEditingController(text: r != null ? '${r.tinggiBadan}' : '');
    _diagnosaController = TextEditingController(text: r?.diagnosa ?? '');
    _resepController   = TextEditingController(text: r?.resepObat ?? '');
    _catatanController = TextEditingController(text: r?.catatanDokter ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _namaController, _rmController, _keluhanController, _tensiController,
      _suhuController, _bbController, _tbController, _diagnosaController,
      _resepController, _catatanController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final Map<String, dynamic> data = {
        'patientId'         : widget.existingRecord?.patientId ?? '',
        'noRekamMedis'      : _rmController.text.trim(),
        'namaPasien'        : _namaController.text.trim(),
        'tanggalPengecekan' : _isEditMode
            ? Timestamp.fromDate(widget.existingRecord!.tanggalPengecekan)
            : Timestamp.fromDate(now),
        'dokterName'        : widget.doctorName,
        'keluhan'           : _keluhanController.text.trim(),
        'tensiDarah'        : _tensiController.text.trim(),
        'beratBadan'        : double.tryParse(_bbController.text) ?? 0.0,
        'tinggiBadan'       : double.tryParse(_tbController.text) ?? 0.0,
        'suhuTubuh'         : double.tryParse(_suhuController.text) ?? 0.0,
        'diagnosa'          : _diagnosaController.text.trim(),
        'resepObat'         : _resepController.text.trim(),
        'catatanDokter'     : _catatanController.text.trim(),
      };

      final col = FirebaseFirestore.instance.collection('medical_records');

      if (_isEditMode) {
        await col.doc(widget.existingRecord!.id).update(data);
      } else {
        await col.add(data);
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dialog Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1B2D),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditMode
                          ? Icons.edit_rounded
                          : Icons.add_circle_outline_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditMode
                            ? 'Edit Riwayat Pemeriksaan'
                            : 'Tambah Riwayat Pemeriksaan',
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ),

              // ── Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data Pasien
                      _formSectionLabel('Data Pasien'),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _field(
                            controller: _namaController,
                            label: 'Nama Pasien',
                            hint: 'Nama lengkap...',
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _field(
                            controller: _rmController,
                            label: 'No. Rekam Medis',
                            hint: 'Contoh: P-00981',
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _field(
                        controller: _keluhanController,
                        label: 'Keluhan Utama',
                        hint: 'Tuliskan keluhan pasien...',
                        maxLines: 2,
                        validator: (v) =>
                            v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),

                      // Tanda Vital
                      _formSectionLabel('Tanda-Tanda Vital'),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _field(
                            controller: _tensiController,
                            label: 'Tensi Darah',
                            hint: '120/80 mmHg',
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _suhuController,
                            label: 'Suhu Tubuh (°C)',
                            hint: '36.5',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _bbController,
                            label: 'Berat Badan (kg)',
                            hint: '65',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _tbController,
                            label: 'Tinggi Badan (cm)',
                            hint: '168',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Hasil Medis
                      _formSectionLabel('Hasil Pemeriksaan'),
                      const SizedBox(height: 10),
                      _field(
                        controller: _diagnosaController,
                        label: 'Diagnosa',
                        hint: 'Tuliskan diagnosa medis...',
                        maxLines: 2,
                        validator: (v) =>
                            v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _resepController,
                        label: 'Resep Obat',
                        hint: 'Nama obat, dosis, aturan minum...',
                        maxLines: 3,
                        validator: (v) =>
                            v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _catatanController,
                        label: 'Catatan Dokter (Opsional)',
                        hint: 'Instruksi lanjutan, pantangan, dll...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text('Batal',
                          style: GoogleFonts.montserrat(
                              color: Colors.grey.shade600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(
                              _isEditMode
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                              size: 16),
                      label: Text(
                        _isEditMode ? 'Simpan Perubahan' : 'Tambah Riwayat',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1B2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formSectionLabel(String label) => Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF334155),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
                fontSize: 12, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFF0F1B2D), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
