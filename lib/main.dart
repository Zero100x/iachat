import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_history_screen.dart'; // 🆕 Import del nuevo menú de historiales

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase (usa tus credenciales reales)
  await Supabase.initialize(
    url: 'https://luunhjsngerghytnxzja.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1dW5oanNuZ2VyZ2h5dG54emphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NTAyMjIsImV4cCI6MjA3NjEyNjIyMn0.GwqPegF6lVEWHj-tmpWVvHdhwet6dZXUUjMr4_kAwJo',
  );

  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma - Apoyo Emocional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.pink[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.pinkAccent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/chat': (context) => const ChatScreen(),
        '/history': (context) => const ChatHistoryScreen(), // Menú de historiales, 
      },
    );
  }
}

/// Pantalla de carga para verificar sesión activa
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _loggedIn = session != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    // 🔐 Si hay sesión activa → ChatScreen
    // 🚪 Si no hay sesión → LoginScreen
    return _loggedIn ? const ChatScreen() : const LoginScreen();
  }
}
