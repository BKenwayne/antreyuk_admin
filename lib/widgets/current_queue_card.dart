import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:antreyuk_admin/models/patient_queue_model.dart';

class CurrentQueueCard extends StatelessWidget {
  final PatientQueue? currentPatient;
  final VoidCallback onCallNext;
  final VoidCallback onRecall;
  final bool isSuperAdmin;

  const CurrentQueueCard({
    super.key,
    required this.currentPatient,
    required this.onCallNext,
    required this.onRecall,
    this.isSuperAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1B2D), Color(0xFF1A3A5C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1B2D).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: currentPatient == null
          ? _buildEmptyState()
          : _buildQueueContent(context),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada antrean aktif',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueContent(BuildContext context) {
    final patient = currentPatient!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Queue info
        Expanded(
          flex: isSuperAdmin ? 3 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ANTREAN SEKARANG',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Queue Number
              Text(
                patient.nomorAntrean,
                style: GoogleFonts.montserrat(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              // Patient Name
              Text(
                patient.namaPasien,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              // Info Row
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estimasi: ${patient.estimasiMenit} Menit',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.medical_information_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Keluhan: ${patient.keluhanAwal}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Right: Action Buttons (only for Super Admin)
        if (isSuperAdmin) ...[
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Panggil Berikutnya Button
                ElevatedButton.icon(
                  onPressed: onCallNext,
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  label: Text(
                    'Panggil Berikutnya',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F1B2D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 12),
                // Panggil Ulang Button
                OutlinedButton.icon(
                  onPressed: onRecall,
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  label: Text(
                    'Panggil Ulang',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
