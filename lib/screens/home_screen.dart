import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_colors.dart';
import '../themes/theme_provider.dart';
import '../provider/custom_quiz_provider.dart';
import '../provider/quiz_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customQuestions = ref.watch(customQuizProvider);
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'TriviaX',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 58,
                            height: .9,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.emoji_events, size: 30),
                    ],
                  ),
                ),
                Obx(
                  () => IconButton.filled(
                    tooltip: 'Toggle theme',
                    onPressed: themeController.toggleTheme,
                    icon: Icon(
                      themeController.isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Challenge your memory, protect your hearts, and climb through smarter questions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            _UpgradeStrip(isDark: isDark),
            const SizedBox(height: 26),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text('Popular Game', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 14),
            _DifficultyCard(
              title: 'Easy',
              subtitle: 'Warm up with quick wins and friendly trivia.',
              color: AppColors.cardYellow,
              icon: Icons.lightbulb,
              onTap: () => _startApiQuiz(ref, 'easy'),
            ),
            _DifficultyCard(
              title: 'Medium',
              subtitle: 'Sharper questions for a focused quiz streak.',
              color: AppColors.primary,
              icon: Icons.psychology,
              onTap: () => _startApiQuiz(ref, 'medium'),
            ),
            _DifficultyCard(
              title: 'Hard',
              subtitle: 'High-pressure trivia for serious knowledge hunters.',
              color: AppColors.cardGreen,
              icon: Icons.workspace_premium,
              onTap: () => _startApiQuiz(ref, 'hard'),
            ),
            const SizedBox(height: 10),
            Text('Custom Quiz', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${customQuestions.length}/10 questions ready',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.toNamed('/admin'),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Admin'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: customQuestions.isEmpty
                              ? null
                              : () {
                                  ref
                                      .read(quizProvider.notifier)
                                      .startCustomQuiz(customQuestions);
                                  Get.toNamed('/quiz');
                                },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startApiQuiz(WidgetRef ref, String difficulty) {
    ref.read(quizProvider.notifier).startQuiz(difficulty);
    Get.toNamed('/quiz');
  }
}

class _UpgradeStrip extends StatelessWidget {
  const _UpgradeStrip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upgrade pro', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('Unlimited quiz play and celebration effects.'),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(backgroundColor: AppColors.black),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 380;
          final cardPadding = isCompact ? 18.0 : 22.0;
          final badgeHorizontalPadding = isCompact ? 14.0 : 18.0;
          final titleGap = isCompact ? 14.0 : 18.0;
          final titleFontSize = isCompact ? 24.0 : 28.0;
          final iconSize = isCompact ? 72.0 : 84.0;

          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: isCompact ? 170 : 164),
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: Colors.white.withOpacity(.38),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: badgeHorizontalPadding,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(height: titleGap),
                      Text(
                        '$title Quiz',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: isCompact ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, height: 1.35),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
