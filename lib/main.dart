import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- Импорт Firebase
import 'providers/user_stats_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Эти две строчки обязательны для Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserStatsProvider()..loadUserStats(),
      child: const MrStaminaApp(),
    ),
  );
}

class MrStaminaApp extends StatelessWidget {
  const MrStaminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Stamina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
      ),
      home: const MainWrapper(),
    );
  }
}

// Обертка, которая решает, куда пускать юзера
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Получаем состояние пользователя (слушаем провайдер)
    final provider = Provider.of<UserStatsProvider>(context);
    final stats = provider.userStats;

    // 2. Получаем пользователя Firebase
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // ЛОГИКА ПРОПУСКА:
    // Пускаем сразу в игру, если:
    // А) Пользователь вошел через Google
    // Б) ИЛИ у пользователя уже есть прогресс (прошел хоть 1 тренировку или сменил имя)
    bool hasLocalProgress = stats.totalWorkouts > 0 || stats.name != 'Боец';
    bool isLoggedIn = firebaseUser != null;

    if (isLoggedIn || hasLocalProgress) {
      return const DashboardScreen();
    }

    // Иначе -> показываем экран выбора (Приветствие)
    return const WelcomeScreen();
  }
}
