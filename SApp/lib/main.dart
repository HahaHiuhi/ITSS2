import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapp/screens/schedule/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/schedule.dart';
import 'screens/auth/auth.dart';
import 'screens/home/home.dart';
import 'screens/profile/profile.dart';

import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'services/setting_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
    ),
  );

  runApp(const AppProviders());
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsService()
            ..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationService(),
        ),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: const AuthGate(),
    );
  }

  ThemeData _theme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3525CD),
        primary: const Color(0xFF3525CD),
        onPrimary: Colors.white,
        primaryContainer: const Color(
          0xFF4F46E5,
        ),
        secondary: const Color(
          0xFF5A5F68,
        ),
        surface: const Color(
          0xFFF8F9FF,
        ),
        onSurface: const Color(
          0xFF0B1C30,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      final auth =
      context.read<AuthService>();

      final tasks =
      context.read<TaskService>();

      if (auth.isAuthenticated) {
        await auth.fetchProfile();
        final now = DateTime.now();
        final weekday = now.weekday; // Mon = 1 ... Sun = 7
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekday));
        tasks.sleepSchedules = generateSleepSchedules(
          startOfWeek,        // startDay
          8,                     // days
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            auth.profile!.bedtime.hour,
            auth.profile!.bedtime.minute,
          )
        ,
          auth.profile!.sleepHours,    // sleepHours
        );
        print(tasks.sleepSchedules);
        await tasks.fetchTasks(rebuild: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth =
    context.watch<AuthService>();

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    return const MainNavigation();
  }
}

class MainNavigation
    extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthService>();
      final tasks = context.read<TaskService>();
      
      if (auth.isAuthenticated) {
        await auth.fetchProfile();
        if (auth.profile != null) {
          final now = DateTime.now();
          final weekday = now.weekday;
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: weekday));
          
          tasks.sleepSchedules = generateSleepSchedules(
            startOfWeek,
            8,
            DateTime(
              now.year,
              now.month,
              now.day,
              auth.profile!.bedtime.hour,
              auth.profile!.bedtime.minute,
            ),
            auth.profile!.sleepHours,
          );
        }
        await tasks.fetchTasks(rebuild: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar:
      NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected:
            (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}