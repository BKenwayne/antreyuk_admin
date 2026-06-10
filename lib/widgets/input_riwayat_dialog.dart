import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:antreyuk_admin/models/patient_queue_model.dart';
import 'package:antreyuk_admin/models/medical_record_model.dart';

import 'package:antreyuk_admin/utils/queue_helper.dart';

class InputRiwayatDialog extends StatefulWidget {
  final PatientQueue patient;
  final String doctorName;

  const InputRiwayatDialog({
    super.key,
    required this.patient,
    required this.doctorName,
  });

  @override
  State<InputRiwayatDialog> createState() => _InputRiwayatDialogState();
}

class _InputRiwayatDialogState extends State<InputRiwayatDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tensiController = TextEditingController();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _tbController = TextEditingController();
  final TextEditingController _suhuController = TextEditingController();
  final TextEditingController _diagnosaController = TextEditingController();
  final TextEditingController _resepController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _tensiController.dispose();
    _bbController.dispose();
    _tbController.dispose();
    _suhuController.dispose();
    _diagnosaController.dispose();
    _resepController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double bb = double.tryParse(_bbController.text) ?? 0.0;
      final double tb = double.tryParse(_tbController.text) ?? 0.0;
      final double suhu = double.tryParse(_suhuController.text) ?? 0.0;

      final record = MedicalRecord(
        id: '', // Firestore auto-id
        patientId: widget.patient.id,
        noRekamMedis: widget.patient.noRekamMedis,
        namaPasien: widget.patient.namaPasien,
        tanggalPengecekan: DateTime.now(),
        dokterName: widget.doctorName,
        keluhan: widget.patient.keluhanAwal,
        tensiDarah: _tensiController.text.trim(),
        beratBadan: bb,
        tinggiBadan: tb,
        suhuTubuh: suhu,
        diagnosa: _diagnosaController.text.trim(),
        resepObat: _resepController.text.trim(),
        catatanDokter: _catatanController.text.trim(),
      );

      // 1. Simpan ke Firestore
      await FirebaseFirestore.instance
          .collection('medical_records')
          .add(record.toMap());

      // 2. Ubah status antrean di Realtime Database menjadi 'selesai'
      await FirebaseDatabase.instance
          .ref('antrean')
          .child(widget.patient.id)
          .update({'status': 'selesai'});

      // 3. Hapus antrean aktif dari node user terkait
      await clearUserActiveQueue(widget.patient.id);

      if (mounted) {
        Navigator.pop(context, true); // Tutup dialog dan beri signal sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Input Riwayat Pemeriksaan',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pasien: ${widget.patient.namaPasien} (${widget.patient.noRekamMedis})',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form fields scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Keluhan Awal Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keluhan Awal Pasien:',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.patient.keluhanAwal,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tanda-Tanda Vital Grid
                      Text(
                        'Tanda-Tanda Vital',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.8,
                        children: [
                          _buildTextField(
                            controller: _tensiController,
                            label: 'Tensi Darah (mmHg)',
                            hint: 'Contoh: 120/80',
                            validator: (v) => v!.isEmpty ? 'Tensi wajib diisi' : null,
                          ),
                          _buildTextField(
                            controller: _suhuController,
                            label: 'Suhu Tubuh (°C)',
                            hint: 'Contoh: 36.5',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty ? 'Suhu wajib diisi' : null,
                          ),
                          _buildTextField(
                            controller: _bbController,
                            label: 'Berat Badan (kg)',
                            hint: 'Contoh: 65',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty ? 'BB wajib diisi' : null,
                          ),
                          _buildTextField(
                            controller: _tbController,
                            label: 'Tinggi Badan (cm)',
                            hint: 'Contoh: 168',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty ? 'TB wajib diisi' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Diagnosa & Catatan Medis
                      Text(
                        'Hasil Pemeriksaan Medis',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _diagnosaController,
                        label: 'Diagnosa Penyakit',
                        hint: 'Tuliskan diagnosa medis...',
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'Diagnosa wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _resepController,
                        label: 'Resep Obat',
                        hint: 'Tulis resep beserta dosis...',
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Resep wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _catatanController,
                        label: 'Catatan Dokter (Optional)',
                        hint: 'Catatan tambahan atau instruksi pasien...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.montserrat(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1B2D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan & Selesai Pemeriksaan',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
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
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          flex: maxLines > 1 ? 0 : 1,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.montserrat(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0F1B2D), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
