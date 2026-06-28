import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/detail/presentation/screens/pt_detail_screen.dart';
import '../../features/detail/presentation/screens/prodi_detail_screen.dart';
import '../../features/detail/presentation/screens/dosen_detail_screen.dart';
import '../../features/detail/presentation/screens/mhs_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/pt/:id',
      builder: (context, state) => PtDetailScreen(idPt: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/prodi/:id',
      builder: (context, state) => ProdiDetailScreen(idProdi: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/dosen/:id',
      builder: (context, state) => DosenDetailScreen(idDosen: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/mhs/:id',
      builder: (context, state) => MhsDetailScreen(idMhs: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
