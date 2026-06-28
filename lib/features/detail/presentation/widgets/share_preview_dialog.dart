import 'package:flutter/material.dart';
import '../../../../core/utils/share_helper.dart';

class SharePreviewDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final String type; // 'mahasiswa' or 'dosen'
  final List<dynamic> eduHistory;
  final List<dynamic> teachingHistory;

  const SharePreviewDialog({
    super.key,
    required this.data,
    required this.type,
    this.eduHistory = const [],
    this.teachingHistory = const [],
  });

  @override
  State<SharePreviewDialog> createState() => _SharePreviewDialogState();
}

class _SharePreviewDialogState extends State<SharePreviewDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  void _shareCard() async {
    setState(() => _isSharing = true);
    final name = widget.type == 'mahasiswa'
        ? (widget.data['nama']?.toString() ?? 'Mahasiswa')
        : (widget.data['nama_dosen']?.toString() ?? 'Dosen');
    
    try {
      await ShareHelper.shareWidgetAsImage(
        boundaryKey: _boundaryKey,
        fileName: 'CARD_${name.replaceAll(' ', '_')}',
        shareText: 'Berikut merupakan kartu profil $name terverifikasi di PDDikti Explorer.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kartu profil $name berhasil dibagikan!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal Membagikan', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Terjadi kesalahan saat memproses gambar profil: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _exportPdf() async {
    final name = widget.type == 'mahasiswa'
        ? (widget.data['nama']?.toString() ?? 'Mahasiswa')
        : (widget.data['nama_dosen']?.toString() ?? 'Dosen');
    try {
      if (widget.type == 'mahasiswa') {
        await ShareHelper.exportMhsPdf(data: widget.data);
      } else {
        await ShareHelper.exportDosenPdf(
          profileData: widget.data,
          eduHistory: widget.eduHistory,
          teachingHistory: widget.teachingHistory,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan PDF untuk $name berhasil dibuat!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal Ekspor PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Terjadi kesalahan saat memproses data PDF: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF121212) : Colors.white;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bagikan Profil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card Preview (wrapped in FittedBox to fit dialog width)
              FittedBox(
                child: _buildShareableCard(),
              ),
              const SizedBox(height: 24),
              // Actions
              Column(
                children: [
                  FilledButton.icon(
                    onPressed: _isSharing ? null : _shareCard,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.share, size: 18),
                    label: Text(_isSharing ? 'Memproses...' : 'Bagikan Kartu (PNG)'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Cetak & Simpan Laporan (PDF)'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildShareableCard() {
    final name = widget.type == 'mahasiswa'
        ? (widget.data['nama']?.toString() ?? 'Tidak Diketahui')
        : (widget.data['nama_dosen']?.toString() ?? 'Tidak Diketahui');

    final codeLabel = widget.type == 'mahasiswa' ? 'NIM' : 'NIDN';
    final codeVal = widget.type == 'mahasiswa'
        ? (widget.data['nim']?.toString() ?? '-')
        : (widget.data['nidn']?.toString() ?? '-');

    final subHeader = widget.type == 'mahasiswa'
        ? (widget.data['status_saat_ini']?.toString() ?? '-')
        : (widget.data['jabatan_akademik']?.toString() ?? '-');

    final prodi = widget.type == 'mahasiswa'
        ? (widget.data['prodi']?.toString() ?? '-')
        : (widget.data['nama_prodi']?.toString() ?? '-');

    final pt = widget.type == 'mahasiswa'
        ? (widget.data['nama_pt']?.toString() ?? '-')
        : (widget.data['nama_pt']?.toString() ?? '-');

    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        width: 360,
        height: 520,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F1E36),
              Color(0xFF1B2E4F),
              Color(0xFF0A1526),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF2E4D7A), width: 2),
        ),
        child: Stack(
          children: [
            // Decorative background patterns
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyan.withValues(alpha: 0.05),
                ),
              ),
            ),
            
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PDDIKTI EXPLORER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'VERIFIED DIGITAL RECORD',
                                style: TextStyle(
                                  color: Colors.blueAccent.shade100,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF00C853), width: 0.5),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFF00C853),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AKTIF',
                              style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Decorative separator
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 20),

                  // Avatar & Name
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$codeLabel : $codeVal',
                              style: TextStyle(
                                color: Colors.amber.shade200,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Details Card Box
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDetailRow('Perguruan Tinggi', pt, Icons.business),
                          _buildDetailRow('Program Studi', prodi, Icons.school),
                          _buildDetailRow('Status/Jabatan', subHeader, Icons.stars),
                          if (widget.type == 'mahasiswa') ...[
                            _buildDetailRow(
                              'Jenis Daftar',
                              widget.data['jenis_daftar']?.toString() ?? '-',
                              Icons.assignment_ind,
                            ),
                            _buildDetailRow(
                              'Masuk',
                              widget.data['tanggal_masuk']?.toString() ?? '-',
                              Icons.calendar_month,
                            ),
                          ] else ...[
                            _buildDetailRow(
                              'Pendidikan',
                              widget.data['pendidikan_tertinggi']?.toString() ?? '-',
                              Icons.workspace_premium,
                            ),
                            _buildDetailRow(
                              'Ikatan Kerja',
                              widget.data['status_ikatan_kerja']?.toString() ?? '-',
                              Icons.handshake,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Footer / Metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Simulated Barcode
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              22,
                              (index) => Container(
                                width: index % 3 == 0
                                    ? 3
                                    : (index % 4 == 0 ? 1 : 2),
                                height: 24,
                                color: Colors.white38,
                                margin: const EdgeInsets.only(right: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDDK-EXP-${codeVal.hashCode.abs().toString().padLeft(6, '0')}',
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 7,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      // Verified Stamp
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.cyanAccent.shade200),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                value.isNotEmpty ? value : '-',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
