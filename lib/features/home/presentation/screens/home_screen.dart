import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../providers/consent_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(consentProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Cyber Dot Grid Canvas Background ───
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(
                dotColor: isDark 
                    ? Colors.white.withValues(alpha: 0.04) 
                    : Colors.indigo.withValues(alpha: 0.05),
                gridSpacing: 24,
              ),
            ),
          ),
          
          // Subtle glow blobs behind layout
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.07 : 0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 16),
                
                // AppBar Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      onPressed: () => context.push('/settings'),
                      tooltip: 'Pengaturan',
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Pirate Logo Brand Avatar
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/pirate_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Brand Titles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDDikti',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Explorer',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cari informasi terverifikasi mengenai perguruan tinggi, program studi, dosen, dan mahasiswa di seluruh Indonesia.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Glassmorphic Search Bar Tap Area
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.push('/search');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.08) 
                                : Colors.indigo.withValues(alpha: 0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Cari universitas, prodi, dosen, mahasiswa...',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Category Bento Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategori Pencarian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'BENTO TILES',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Grid Bento Cards (Responsive crossAxisCount and childAspectRatio)
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final crossAxisCount = screenWidth > 600 ? 4 : 2;
                    final childAspectRatio = screenWidth > 600
                        ? 1.4
                        : (screenWidth < 360 ? 1.05 : 1.15);

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _BentoCard(
                          icon: Icons.account_balance,
                          title: 'Kampus',
                          subtitle: 'Perguruan Tinggi',
                          gradientColors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          onTap: () => context.push('/search?q=universitas'),
                        ),
                        _BentoCard(
                          icon: Icons.school,
                          title: 'Prodi',
                          subtitle: 'Program Studi',
                          gradientColors: const [Color(0xFF0F766E), Color(0xFF0D9488)],
                          onTap: () => context.push('/search?q=informatika'),
                        ),
                        _BentoCard(
                          icon: Icons.person,
                          title: 'Dosen',
                          subtitle: 'Tenaga Pendidik',
                          gradientColors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
                          onTap: () => context.push('/search?q=dosen'),
                        ),
                        _BentoCard(
                          icon: Icons.badge,
                          title: 'Mahasiswa',
                          subtitle: 'Peserta Didik',
                          gradientColors: const [Color(0xFF6B21A8), Color(0xFF9333EA)],
                          onTap: () => context.push('/search?q=mahasiswa'),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Consent overlay if they haven't agreed
          consentAsync.when(
            data: (hasConsent) {
              if (hasConsent) return const SizedBox.shrink();
              return _ConsentOverlay(ref: ref);
            },
            loading: () => Container(
              color: theme.colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _ConsentOverlay(ref: ref), // fallback
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw micro dot grids (SaaS/Cybertech feel)
class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double gridSpacing;

  _DotGridPainter({required this.dotColor, required this.gridSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor || oldDelegate.gridSpacing != gridSpacing;
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  gradientColors[0].withValues(alpha: isDark ? 0.15 : 0.06),
                  gradientColors[1].withValues(alpha: isDark ? 0.05 : 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: gradientColors[0].withValues(alpha: isDark ? 0.25 : 0.12),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: gradientColors[0],
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentOverlay extends StatelessWidget {
  final WidgetRef ref;
  const _ConsentOverlay({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: theme.colorScheme.surface.withValues(alpha: 0.97),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48, // offset padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/pirate_logo.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Persetujuan Penggunaan Data',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sesuai UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP), kami memerlukan izin Anda untuk memproses permintaan data publik.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const _PermissionTile(
                        icon: Icons.wifi,
                        title: 'Akses Jaringan & Internet',
                        subtitle: 'Diperlukan untuk menghubungkan aplikasi ke server database.',
                      ),
                      const SizedBox(height: 18),
                      const _PermissionTile(
                        icon: Icons.search,
                        title: 'Transmisi Keyword Pencarian',
                        subtitle: 'Kata kunci pencarian dikirim ke server API untuk mendapatkan hasil pencarian.',
                      ),
                      const SizedBox(height: 18),
                      const _PermissionTile(
                        icon: Icons.save_alt,
                        title: 'Penyimpanan Preferences',
                        subtitle: 'Menyimpan konfigurasi persetujuan ini pada perangkat Anda.',
                      ),
                      const SizedBox(height: 36),
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(consentProvider.notifier).grantConsent();
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Setuju & Izinkan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else {
                            exit(0);
                          }
                        },
                        child: Text(
                          'Tolak & Keluar',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
