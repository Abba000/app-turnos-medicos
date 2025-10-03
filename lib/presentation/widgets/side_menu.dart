import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final List<_MenuItem> menuItems = [
      _MenuItem(label: 'Home', icon: Icons.home_outlined, route: '/main/home'),
      _MenuItem(
          label: 'Mi perfil',
          icon: Icons.person_outline,
          route: '/main/perfil'),
      _MenuItem(
          label: 'Turnos',
          icon: Icons.calendar_today_outlined,
          route: '/main/turnos'),
      _MenuItem(
          label: 'Consultas',
          icon: Icons.chat_outlined,
          route: '/main/consultas'),
    ];

    final String currentRoute = GoRouterState.of(context).uri.path;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Sin bordes redondeados
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Encabezado de usuario sin borde
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  // Borde removido
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Usuario',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Ítems de navegación
              ...menuItems.map((item) {
                final isSelected = currentRoute == item.route;

                return InkWell(
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    if (!isSelected) context.go(item.route);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F4156)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Botón de cerrar sesión al final
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    context.go('/'); // Redirige al login
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    backgroundColor: const Color(0xFF222222),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final String route;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
