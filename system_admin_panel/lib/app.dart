import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/shops/shop_list_screen.dart';
import 'screens/staff_approval/staff_approval_screen.dart';
import 'screens/users/user_list_screen.dart';
import 'widgets/sidebar.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3B82F6),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.user != null) {
          return const MainScaffold();
        }
        return const LoginScreen();
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _labels = ['Dashboard', 'Staff Approval', 'Users', 'Shops'];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const StaffApprovalScreen(),
      const UserListScreen(),
      const ShopListScreen(),
    ];
  }

  void _onNavigate(int index) {
    setState(() => _currentIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isWide
          ? null
          : AppBar(
              title: Text(_labels[_currentIndex]),
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      drawer: isWide
          ? null
          : Drawer(
              child: Sidebar(
                currentIndex: _currentIndex,
                onIndexChanged: _onNavigate,
                isCollapsed: false,
                onToggleCollapse: (_) {},
              ),
            ),
      body: Row(
        children: [
          if (isWide)
            Sidebar(
              currentIndex: _currentIndex,
              onIndexChanged: _onNavigate,
              isCollapsed: false,
              onToggleCollapse: (_) {},
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}
