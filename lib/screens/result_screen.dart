import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../provider/quiz_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(quizProvider);
      if (state.score >= state.questions.length * 6) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final maxScore = state.questions.length * 10;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.trophy,
                          size: 68,
                          color: scheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.lives == 0 ? 'Out of Hearts' : 'Quiz Complete',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${state.score} / $maxScore',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _resultMessage(state.score, maxScore),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(quizProvider.notifier).resetQuiz();
                      Get.offAllNamed('/');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back Home'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Get.offAllNamed('/admin'),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Open Admin'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: .08,
            numberOfParticles: 18,
            gravity: .18,
          ),
        ],
      ),
    );
  }

  String _resultMessage(int score, int maxScore) {
    if (maxScore <= 0) return 'Create or fetch a quiz to start scoring.';

    final percentage = score / maxScore;
    if (percentage >= .8) return 'Excellent run. Your trivia game is sharp.';
    if (percentage >= .5) return 'Good score. A few more rounds and it climbs.';
    return 'Keep practicing. Every miss is a useful hint.';
  }
}
