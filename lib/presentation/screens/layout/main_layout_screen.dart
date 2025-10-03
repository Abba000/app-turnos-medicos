import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<_NavItemData> _navItems = [
    _NavItemData(
      icon: FontAwesomeIcons.house,
      label: 'Home',
      route: '/main/home',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.calendar,
      label: 'Turnos',
      route: '/main/turnos',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.comments,
      label: 'Consultas',
      route: '/main/consultas',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.user,
      label: 'Mi perfil',
      route: '/main/perfil',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentUri = GoRouterState.of(context).uri.toString();

    final index =
        _navItems.indexWhere((item) => currentUri.startsWith(item.route));
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 59, 59, 59),
        elevation: 1,
        title: Text(
          _navItems[_currentIndex].label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) context.go('/');
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(_navItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItemData item, int index) {
    const selectedColor = Color(0xFF1B4A5A);
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 24,
            color: isSelected ? selectedColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? selectedColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
