import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false; // Чтобы показывать крутилку

  // Логика для кнопки "Войти через Google"
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true); // Включаем загрузку

    final provider = Provider.of<UserStatsProvider>(context, listen: false);
    bool success = await provider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false); // Выключаем загрузку

    if (success) {
      // Если вошли успешно - сразу в Дашборд
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вход отменен или произошла ошибка')),
      );
    }
  }

  // Логика для кнопки "Начать с нуля"
  void _startNewGame() {
    final provider = Provider.of<UserStatsProvider>(context, listen: false);
    // Если нужно задать имя по умолчанию
    if (provider.userStats.name.isEmpty || provider.userStats.name == 'Боец') {
      provider.updateName("Боец");
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип или заголовок
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFF00E676),
                ),
                const SizedBox(height: 20),
                const Text(
                  "MR. STAMINA",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Твой путь к совершенству",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 80),

                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00E676))
                else
                  Column(
                    children: [
                      // Кнопка GOOGLE
                      ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            // Иконка Google (можно заменить на Image.asset если есть)
                            Icon(
                              Icons.cloud_download,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Загрузить прогресс (Google)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Разделитель
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "ИЛИ",
                              style: TextStyle(color: Colors.white24),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Кнопка НОВАЯ ИГРА
                      OutlinedButton(
                        onPressed: _startNewGame,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00E676),
                          side: const BorderSide(
                            color: Color(0xFF00E676),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Начать путь с начала",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
