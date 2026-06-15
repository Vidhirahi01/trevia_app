import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/themes/app_colors.dart';
import '../models/question_model.dart';
import '../provider/custom_quiz_provider.dart';

class AdminQuizScreen extends ConsumerStatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  ConsumerState<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends ConsumerState<AdminQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  final Set<int> _correctIndexes = {};
  String? _editingId;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(customQuizProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${questions.length}/10',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              _editingId == null ? 'Create Question' : 'Edit Question',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter quiz question',
                      prefixIcon: Icon(Icons.quiz),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Question is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0; index < _optionControllers.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                prefixIcon: const Icon(Icons.drag_indicator),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Tooltip(
                            message: 'Mark correct',
                            child: FilterChip(
                              selected: _correctIndexes.contains(index),
                              showCheckmark: true,
                              label: const Icon(Icons.check),
                              selectedColor: (isDark
                                      ? AppColors.successDark
                                      : AppColors.success)
                                  .withOpacity(.25),
                              onSelected: (_) {
                                setState(() {
                                  if (_correctIndexes.contains(index)) {
                                    _correctIndexes.remove(index);
                                  } else {
                                    _correctIndexes.add(index);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: questions.length >= 10 && _editingId == null
                              ? null
                              : _saveQuestion,
                          icon: Icon(_editingId == null ? Icons.add : Icons.save),
                          label: Text(_editingId == null ? 'Add' : 'Save'),
                        ),
                      ),
                      if (_editingId != null) ...[
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          tooltip: 'Cancel edit',
                          onPressed: _clearForm,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Questions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text('No custom questions yet. Add one above.'),
              )
            else
              ...questions.map(
                (question) => _QuestionTile(
                  question: question,
                  isDark: isDark,
                  onEdit: () => _editQuestion(question),
                  onDelete: () {
                    ref
                        .read(customQuizProvider.notifier)
                        .deleteQuestion(question.id);
                    if (_editingId == question.id) {
                      _clearForm();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;

    if (_correctIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one correct answer.')),
      );
      return;
    }

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .toList(growable: false);
    final uniqueOptions = options.toSet();

    if (uniqueOptions.length != options.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Options must be unique.')),
      );
      return;
    }

    final question = QuestionModel.custom(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      options: options,
      correctAnswers:
          _correctIndexes.map((index) => options[index]).toList(growable: false),
    );

    final notifier = ref.read(customQuizProvider.notifier);
    if (_editingId == null) {
      notifier.addQuestion(question);
    } else {
      notifier.updateQuestion(question);
    }

    _clearForm();
  }

  void _editQuestion(QuestionModel question) {
    setState(() {
      _editingId = question.id;
      _questionController.text = question.question;
      for (var index = 0; index < _optionControllers.length; index++) {
        _optionControllers[index].text = question.options[index];
      }
      _correctIndexes
        ..clear()
        ..addAll(
          question.options
              .asMap()
              .entries
              .where((entry) => question.correctAnswers.contains(entry.value))
              .map((entry) => entry.key),
        );
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _questionController.clear();
      for (final controller in _optionControllers) {
        controller.clear();
      }
      _correctIndexes.clear();
    });
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final QuestionModel question;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                isDark ? AppColors.cardYellowDark : AppColors.cardYellow,
            child: const Icon(Icons.question_mark, color: AppColors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: question.options.map((option) {
                    final isCorrect = question.correctAnswers.contains(option);
                    return Chip(
                      label: Text(option),
                      avatar:
                          isCorrect ? const Icon(Icons.check, size: 16) : null,
                      backgroundColor: isCorrect
                          ? (isDark ? AppColors.successDark : AppColors.success)
                              .withOpacity(.18)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
