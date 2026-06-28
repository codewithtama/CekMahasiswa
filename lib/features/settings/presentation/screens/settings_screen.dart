import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../home/presentation/providers/consent_provider.dart';
import '../../../search/presentation/providers/search_history_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final showIcons = MediaQuery.of(context).size.width > 340;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ─── Theme Section ───
          const _SectionLabel('Tampilan'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBadge(Icons.palette_outlined, color: Colors.indigo.shade400),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tema Aplikasi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(
                              _themeModeLabel(themeMode),
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: showIcons ? const Icon(Icons.brightness_auto, size: 16) : null,
                            label: const Text('Otomatis', style: TextStyle(fontSize: 11)),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: showIcons ? const Icon(Icons.light_mode, size: 16) : null,
                            label: const Text('Terang', style: TextStyle(fontSize: 11)),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: showIcons ? const Icon(Icons.dark_mode, size: 16) : null,
                            label: const Text('Gelap', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (s) {
                          HapticFeedback.lightImpact();
                          ref.read(themeModeProvider.notifier).setThemeMode(s.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Data & Privacy Section ───
          const _SectionLabel('Data & Privasi'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.manage_search,
                iconColor: Colors.blue.shade500,
                title: 'Riwayat Pencarian',
                subtitle: searchHistory.isEmpty
                    ? 'Kosong'
                    : '${searchHistory.length} kata kunci tersimpan',
                trailing: searchHistory.isEmpty
                    ? null
                    : _CountBadge(searchHistory.length),
                onTap: searchHistory.isEmpty
                    ? null
                    : () => _showClearHistoryDialog(context, ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                iconColor: Colors.green.shade600,
                title: 'Persetujuan UU PDP',
                subtitle: 'Status: Disetujui',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      SizedBox(width: 4),
                      Text('Aktif', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                onTap: () => _showRevokeConsentDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Tentang Section ───
          const _SectionLabel('Tentang Aplikasi'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.account_balance_outlined,
                iconColor: Colors.teal.shade500,
                title: 'Sumber Data',
                subtitle: 'PDDikti – Kemdiktisaintek RI',
                trailing: null,
                onTap: null,
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.tag,
                iconColor: Colors.purple.shade400,
                title: 'Versi Aplikasi',
                subtitle: 'PDDikti Explorer',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('v1.0.0', style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                onTap: null,
              ),

            ],
          ),

          const SizedBox(height: 32),

          // ─── Danger Zone ───
          const _SectionLabel('Zona Bahaya', danger: true),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.logout,
                iconColor: Colors.red.shade400,
                title: 'Tarik Persetujuan & Keluar',
                subtitle: 'Membatalkan izin UU PDP dan menutup akses aplikasi.',
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.red),
                titleColor: Colors.red,
                onTap: () => _showRevokeConsentDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ─── Brand Showcase ───
          const _BrandShowcase(),

          const SizedBox(height: 32),

          // ─── Footer ───
          Center(
            child: Column(
              children: [
                Text(
                  'PDDikti Explorer',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Data bersumber dari pddikti.kemdiktisaintek.go.id',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.25), fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Mengikuti sistem perangkat',
      ThemeMode.light => 'Tema terang aktif',
      ThemeMode.dark => 'Tema gelap aktif',
    };
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Seluruh kata kunci pencarian terakhir Anda akan dihapus secara permanen dari perangkat ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(searchHistoryProvider.notifier).clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Riwayat pencarian berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  void _showRevokeConsentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
        title: const Text('Tarik Persetujuan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Dengan menarik persetujuan pengolahan data pribadi (UU PDP), akses aplikasi akan diblokir hingga Anda menyetujui kembali ketentuan privasi saat membuka aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(consentProvider.notifier).revokeConsent();
              Navigator.pop(ctx);
              context.go('/');
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Tarik & Keluar'),
          ),
        ],
      ),
    );
  }

}

// ─── Shared component widgets ───────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final bool danger;
  const _SectionLabel(this.title, {this.danger = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: danger ? Colors.red.shade400 : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 10.5,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Column(children: children),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: _IconBadge(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge(this.icon, {required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 68, endIndent: 0);
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge(this.count);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ─── Brand Showcase Widget ──────────────────────────────────────────

class _BrandShowcase extends StatelessWidget {
  const _BrandShowcase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Didukung Oleh'),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BrandLogoItem(
                  imagePath: 'assets/images/google.png',
                  label: 'Google',
                  height: 28,
                ),
                _BrandLogoItem(
                  imagePath: 'assets/images/github.png',
                  label: 'GitHub',
                  height: 28,
                  imageColor: isDark ? Colors.white : Colors.black87,
                ),
                _BrandLogoItem(
                  imagePath: 'assets/images/android.png',
                  label: 'Android',
                  height: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandLogoItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final double height;
  final Color? imageColor;

  const _BrandLogoItem({
    required this.imagePath,
    required this.label,
    required this.height,
    this.imageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Image.asset(
        imagePath,
        height: height,
        color: imageColor,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }
}

