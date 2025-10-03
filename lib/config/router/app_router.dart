import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesis/presentation/screens/layout/main_layout_screen.dart';
import 'package:tesis/presentation/screens/login/login_screen.dart';
import 'package:tesis/presentation/screens/consultas/consultas_screen.dart';
import 'package:tesis/presentation/screens/home/home_screen.dart';
import 'package:tesis/presentation/screens/perfil/perfil_screen.dart';
import 'package:tesis/presentation/screens/turnos/turnos_screen.dart';

// 🔑 navigatorKey global para mostrar diálogos o hacer navegación fuera del context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: navigatorKey, // ✅ ahora el GoRouter lo tiene
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/main/home',
          name: HomeScreen.name,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/main/perfil',
          name: PerfilScreen.name,
          builder: (context, state) => const PerfilScreen(),
        ),
        GoRoute(
          path: '/main/turnos',
          name: TurnosScreen.name,
          builder: (context, state) => const TurnosScreen(),
        ),
        GoRoute(
          path: '/main/consultas',
          name: ConsultasScreen.name,
          builder: (context, state) => ConsultasScreen(
            mensajeInicial: state.extra as String?,
          ),
        ),
      ],
    ),
  ],
);
