import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/wardrobe/presentation/add_clothing_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // 메인 탭 화면 (Bottom Navigation)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe',
        builder: (context, state) => const HomeScreen(tab: 1),
      ),
      GoRoute(
        path: '/outfit-builder',
        name: 'outfit-builder',
        builder: (context, state) => const HomeScreen(tab: 2),
      ),

      // 옷 추가 화면 (전체 화면)
      GoRoute(
        path: '/wardrobe/add',
        name: 'add-clothing',
        builder: (context, state) => const AddClothingScreen(),
      ),
    ],
  );
});
