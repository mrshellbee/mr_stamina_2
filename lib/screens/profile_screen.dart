import 'dart:io'; // Для работы с файлами
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_stats_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Безопасная инициализация имени
    final stats = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    ).userStats;
    _nameController = TextEditingController(text: stats.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Функция выбора фото
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      await Provider.of<UserStatsProvider>(
        context,
        listen: false,
      ).updateProfilePicture(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем провайдер
    final provider = Provider.of<UserStatsProvider>(context);
    final stats = provider.userStats;

    // --- ЛОГИКА АВАТАРКИ (Самое важное место) ---
    ImageProvider? avatarImage;

    if (stats.profilePicturePath != null) {
      final file = File(stats.profilePicturePath!);
      if (file.existsSync()) {
        // Файл существует - грузим его
        avatarImage = FileImage(file);
      } else {
        // Путь есть, а файла нет (удалили) - будет иконка
        avatarImage = null;
      }
    }
    // ---------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Темный фон
      appBar: AppBar(
        title: const Text('Профиль бойца'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- АВАТАР ---
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E676),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage:
                            avatarImage, // Используем нашу переменную
                        child: avatarImage == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white54,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- ПОЛЕ ИМЕНИ ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Имя бойца", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintText: "Введите имя",
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.edit, color: Colors.grey),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      provider.updateName(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Имя сохранено!')),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 30),

              // --- КНОПКА GOOGLE ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4), // Небольшой отступ
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: provider.firebaseUser != null
                        ? Colors.green
                        : Colors.white10,
                  ),
                ),
                child: provider.firebaseUser == null
                    ? Material(
                        // Material нужен для эффекта нажатия
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            provider.signInWithGoogle();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Сохранить прогресс в Google",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Привязано к:",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      provider.firebaseUser?.email ?? "Google",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => provider.signOut(),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Привязка к Google позволит не потерять\nуровень при удалении приложения.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
