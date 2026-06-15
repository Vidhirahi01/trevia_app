import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../themes/app_colors.dart';
import '../models/question_model.dart';
import '../provider/quiz_provider.dart';
import '../provider/quiz_state.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String? selectedAnswer;
  bool answerSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    ref.listen<QuizState>(quizProvider, (previous, next) {
      if (next.isFinished) {
        Get.offNamed('/result');
      }
    });

    if (quizState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/quiz_loading.json',
                width: 148,
                height: 148,
              ),
              const SizedBox(height: 10),
              Text(
                'Loading Quiz',
                style: GoogleFonts.bebasNeue(
                  fontSize: 34,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (quizState.errorMessage != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 58, color: AppColors.primary),
                const SizedBox(height: 18),
                Text(
                  quizState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Back Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizState.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: ElevatedButton.icon(
            onPressed: () => Get.offAllNamed('/'),
            icon: const Icon(Icons.home),
            label: const Text('No Questions Found'),
          ),
        ),
      );
    }

    final question = quizState.questions[quizState.currentIndex];
    final options = question.shuffledOptions;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(quizState),
              const SizedBox(height: 24),
              _buildProgressBar(quizState),
              const SizedBox(height: 32),
              _buildQuestionCard(question.question, quizState.currentIndex),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionTile(index, option, question),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: answerSubmitted
                      ? null
                      : () {
                          ref.read(quizProvider.notifier).skipQuestion();
                        },
                  child: const Text('Skip Question (-5)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(QuizState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'Quiz',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 64,
                        height: .85,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                ],
              ),
              Text(
                '${state.mode.toUpperCase()} • Question ${state.currentIndex + 1}/${state.questions.length}',
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                        ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      index < state.lives
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(index < state.lives),
                      color: index < state.lives
                          ? AppColors.error
                          : AppColors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${state.score} pts',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(QuizState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        minHeight: 10,
        value: (state.currentIndex + 1) / state.questions.length,
        color: AppColors.primary,
        backgroundColor: Colors.black12,
      ),
    );
  }

  Widget _buildQuestionCard(String question, int currentIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(currentIndex),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.08)),
        ],
      ),
      child: Text(
        question,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
    )
        .animate(key: ValueKey('question-$currentIndex'))
        .fadeIn(duration: 280.ms)
        .slideY(begin: .12, end: 0, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(.98, .98), end: const Offset(1, 1));
  }

  Widget _buildOptionTile(int index, String option, QuestionModel question) {
    Color background = Theme.of(context).colorScheme.surface;
    Color border = Colors.black12;
    Color foreground = Theme.of(context).colorScheme.onSurface;
    Color badgeBackground = AppColors.black;
    Color badgeForeground = Colors.white;
    IconData trailingIcon = Icons.arrow_forward;

    if (answerSubmitted) {
      if (question.isCorrect(option)) {
        background = AppColors.success;
        foreground = Colors.white;
        border = AppColors.success;
        badgeBackground = Colors.white;
        badgeForeground = AppColors.success;
        trailingIcon = Icons.check_circle;
      } else if (option == selectedAnswer) {
        background = AppColors.error;
        foreground = Colors.white;
        border = AppColors.error;
        badgeBackground = Colors.white;
        badgeForeground = AppColors.error;
        trailingIcon = Icons.cancel;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: answerSubmitted ? null : () => _submitAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  color: badgeForeground,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(trailingIcon, color: foreground),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      answerSubmitted = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    ref.read(quizProvider.notifier).answerQuestion(answer);

    setState(() {
      selectedAnswer = null;
      answerSubmitted = false;
    });
  }
}
