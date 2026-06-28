import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  /// Captures a widget wrapped in [RepaintBoundary] using its [GlobalKey]
  /// and shares it as a PNG image.
  static Future<void> shareWidgetAsImage({
    required GlobalKey boundaryKey,
    required String fileName,
    String? shareText,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RenderRepaintBoundary not found on global key');
      }

      // Check if the repaint boundary is ready to be drawn
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
        return shareWidgetAsImage(
          boundaryKey: boundaryKey,
          fileName: fileName,
          shareText: shareText,
        );
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      
      // Sanitize the filename to remove any invalid path/file characters (like slashes)
      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final file = await File('${tempDir.path}/$safeFileName.png').create();
      await file.writeAsBytes(bytes);

      final xFile = XFile(file.path);
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: shareText ?? 'Detail data dari PDDikti Explorer',
        ),
      );
    } catch (e, stack) {
      debugPrint('Error sharing widget as image: $e\n$stack');
      rethrow;
    }
  }

  /// Generates a PDF document for a Student (Mahasiswa) and triggers the print/save dialogue.
  static Future<void> exportMhsPdf({
    required Map<String, dynamic> data,
  }) async {
    try {
      final pdf = pw.Document();

      pw.Font font;
      pw.Font fontBold;
      try {
        font = await PdfGoogleFonts.plusJakartaSansRegular();
        fontBold = await PdfGoogleFonts.plusJakartaSansBold();
      } catch (_) {
        font = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      }

      final nama = data['nama']?.toString() ?? 'Tidak Diketahui';
      final nim = data['nim']?.toString() ?? '-';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PDDIKTI EXPLORER',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          color: PdfColor.fromHex('#1565C0'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Laporan Data Mahasiswa Resmi',
                        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal Unduh',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
                      ),
                      pw.Text(
                        DateTime.now().toLocal().toString().substring(0, 16),
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // Title Section
              pw.Text(
                'PROFIL MAHASISWA',
                style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.blueGrey800),
              ),
              pw.SizedBox(height: 12),

              // Details Card/Table
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(150),
                  1: const pw.FlexColumnWidth(),
                },
                border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                children: [
                  _pdfTableRow(fontBold, font, 'Nama Lengkap', nama),
                  _pdfTableRow(fontBold, font, 'NIM', nim),
                  _pdfTableRow(fontBold, font, 'Jenis Kelamin', data['jenis_kelamin']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Program Studi', data['prodi']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Perguruan Tinggi', data['nama_pt']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Tanggal Masuk', data['tanggal_masuk']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Jenis Pendaftaran', data['jenis_daftar']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Status Mahasiswa', data['status_saat_ini']?.toString() ?? '-'),
                ],
              ),

              pw.SizedBox(height: 40),
              // Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Pernyataan Penting:',
                      style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Data ini diperoleh dari server pddikti.kemdiktisaintek.go.id secara real-time melalui aplikasi PDDikti Explorer. Laporan ini bersifat informatif dan bukan merupakan bukti kelulusan atau keabsahan akademik hukum yang sah tanpa validasi langsung dari pihak perguruan tinggi bersangkutan atau kementerian terkait.',
                      style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final safeNama = nama.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final safeNim = nim.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'MHS_${safeNama}_$safeNim.pdf',
      );
    } catch (e, stack) {
      debugPrint('Error generating Student PDF: $e\n$stack');
      rethrow;
    }
  }

  /// Generates a PDF document for a Lecturer (Dosen) with education and teaching histories.
  static Future<void> exportDosenPdf({
    required Map<String, dynamic> profileData,
    required List<dynamic> eduHistory,
    required List<dynamic> teachingHistory,
  }) async {
    try {
      final pdf = pw.Document();

      pw.Font font;
      pw.Font fontBold;
      try {
        font = await PdfGoogleFonts.plusJakartaSansRegular();
        fontBold = await PdfGoogleFonts.plusJakartaSansBold();
      } catch (_) {
        font = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      }

      final nama = profileData['nama_dosen']?.toString() ?? 'Tidak Diketahui';
      final nidn = profileData['nidn']?.toString() ?? '-';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PDDIKTI EXPLORER',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          color: PdfColor.fromHex('#1565C0'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Laporan Data Dosen Resmi',
                        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal Unduh',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
                      ),
                      pw.Text(
                        DateTime.now().toLocal().toString().substring(0, 16),
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // Title Section
              pw.Text(
                'PROFIL DOSEN',
                style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.blueGrey800),
              ),
              pw.SizedBox(height: 12),

              // Profile Table
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(150),
                  1: const pw.FlexColumnWidth(),
                },
                border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                children: [
                  _pdfTableRow(fontBold, font, 'Nama Dosen', nama),
                  _pdfTableRow(fontBold, font, 'NIDN', nidn),
                  _pdfTableRow(fontBold, font, 'Jabatan Akademik', profileData['jabatan_akademik']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Pendidikan Tertinggi', profileData['pendidikan_tertinggi']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Status Ikatan Kerja', profileData['status_ikatan_kerja']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Status Aktif', profileData['status_aktivitas']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Homebase Perguruan Tinggi', profileData['nama_pt']?.toString() ?? '-'),
                  _pdfTableRow(fontBold, font, 'Homebase Program Studi', profileData['nama_prodi']?.toString() ?? '-'),
                ],
              ),

              pw.SizedBox(height: 20),

              // Riwayat Pendidikan
              if (eduHistory.isNotEmpty) ...[
                pw.Text(
                  'RIWAYAT PENDIDIKAN',
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.blueGrey800),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FixedColumnWidth(80),
                  },
                  border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Jenjang', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Perguruan Tinggi & Program Studi', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Tahun Lulus', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                      ],
                    ),
                    ...eduHistory.map((edu) {
                      final m = edu as Map;
                      final jenjang = m['jenjang']?.toString() ?? m['gelar']?.toString() ?? '-';
                      final pt = m['nama_pt']?.toString() ?? m['perguruan_tinggi']?.toString() ?? m['pt']?.toString() ?? '-';
                      final prodi = m['nama_prodi']?.toString() ?? m['program_studi']?.toString() ?? m['prodi']?.toString() ?? '';
                      final tahun = m['tahun_lulus']?.toString() ?? m['tahun']?.toString() ?? '-';
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(jenjang, style: pw.TextStyle(font: font, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              prodi.isNotEmpty ? '$pt\nProdi: $prodi' : pt,
                              style: pw.TextStyle(font: font, fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(tahun, style: pw.TextStyle(font: font, fontSize: 9)),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Riwayat Mengajar
              if (teachingHistory.isNotEmpty) ...[
                pw.Text(
                  'RIWAYAT MENGAJAR',
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.blueGrey800),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(),
                    1: const pw.FixedColumnWidth(80),
                    2: const pw.FixedColumnWidth(100),
                  },
                  border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Mata Kuliah', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Kelas', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Semester', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                        ),
                      ],
                    ),
                    ...teachingHistory.take(15).map((teach) {
                      final m = teach as Map;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${m['nama_matkul'] ?? '-'}\n${m['nama_pt'] ?? ''}',
                              style: pw.TextStyle(font: font, fontSize: 8),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(m['nama_kelas']?.toString() ?? '-', style: pw.TextStyle(font: font, fontSize: 8)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(m['nama_semester']?.toString() ?? '-', style: pw.TextStyle(font: font, fontSize: 8)),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                if (teachingHistory.length > 15) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '* Menampilkan 15 mata kuliah terakhir dari total ${teachingHistory.length} riwayat mengajar.',
                    style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
                pw.SizedBox(height: 32),
              ],

              // Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Pernyataan Penting:',
                      style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Data ini diperoleh dari server pddikti.kemdiktisaintek.go.id secara real-time melalui aplikasi PDDikti Explorer. Laporan ini bersifat informatif dan bukan merupakan surat keterangan mengajar resmi hukum yang sah tanpa validasi langsung dari pihak perguruan tinggi bersangkutan atau kementerian terkait.',
                      style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final safeNama = nama.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final safeNidn = nidn.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'DOSEN_${safeNama}_$safeNidn.pdf',
      );
    } catch (e, stack) {
      debugPrint('Error generating Lecturer PDF: $e\n$stack');
      rethrow;
    }
  }

  static pw.TableRow _pdfTableRow(
    pw.Font fontBold,
    pw.Font font,
    String label,
    String value,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
        ),
      ],
    );
  }
}
