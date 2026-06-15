import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:trevia_app/core/themes/app_theme.dart';
import 'package:trevia_app/core/themes/theme_provider.dart';

import 'screens/admin_quiz_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'treviaX',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const HomeScreen()),
          GetPage(name: '/admin', page: () => const AdminQuizScreen()),
          GetPage(name: '/quiz', page: () => const QuizScreen()),
          GetPage(name: '/result', page: () => const ResultScreen()),
        ],
      ),
    );
  }
}
