import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapp/screens/tasks/task_detail_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'package:sapp/screens/auth/auth.dart';
import 'package:sapp/screens/home/home.dart';
import 'package:sapp/screens/profile/profile.dart';

const String _placeholderSupabaseUrl = 'https://placeholder-url.supabase.co';
const String _placeholderSupabaseAnonKey = 'placeholder-anon-key';

const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: _placeholderSupabaseUrl,
);
const String _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: _placeholderSupabaseAnonKey,
);

const bool _hasSupabaseConfig = _supabaseUrl != _placeholderSupabaseUrl &&
    _supabaseAnonKey != _placeholderSupabaseAnonKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (_hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  } else {
    debugPrint('Supabase is not configured. Running with local empty data.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3525CD),
          primary: const Color(0xFF3525CD),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFF4F46E5),
          secondary: const Color(0xFF5A5F68),
          surface: const Color(0xFFF8F9FF),
          onSurface: const Color(0xFF0B1C30),
          surfaceContainer: const Color(0xFFEFF4FF),
          surfaceContainerLowest: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: IconThemeData(color: Color(0xFF0B1C30)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF3525CD).withValues(alpha: 0.08),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();

    if (!service.isAuthenticated) {
      return const AuthScreen();
    }

    return const MainTabNavigation();
  }
}

class MainTabNavigation extends StatefulWidget {
  const MainTabNavigation({super.key});

  @override
  State<MainTabNavigation> createState() => _MainTabNavigationState();
}

class _MainTabNavigationState extends State<MainTabNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<SupabaseService>(context, listen: false);
      service.fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3525CD).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -10),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFF3525CD)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person, color: Color(0xFF3525CD)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}