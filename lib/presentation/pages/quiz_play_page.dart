import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';

/// Quiz play – no hearts. Correct = green + explanation; wrong = explanation.
class QuizPlayPage extends StatefulWidget {
  const QuizPlayPage({
    super.key,
    required this.title,
    this.questionCount = 5,
    this.questions,
  });

  final String title;
  final int questionCount;
  final List<QuestionModel>? questions;

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late List<QuestionModel> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? _mockQuestions(widget.questionCount);
  }

  List<QuestionModel> _mockQuestions(int n) {
    return List.generate(n, (i) {
      return QuestionModel(
        id: 'q$i',
        type: QuestionType.multipleChoice,
        text: 'Хэрэв у = 2х функц өгөгдсөн бол х = ${i + 5} үед у-ийн утга хэд вэ?',
        options: ['${(i + 5) * 2 - 2}', '${(i + 5) * 2}', '${(i + 5) * 2 + 2}', '${(i + 5) + 2}'],
        correctOptionIndex: 1,
        explanation: 'у = 2х функцэд х = ${i + 5} орлуулбал у = 2(${i + 5}) = ${(i + 5) * 2}',
      );
    });
  }

  void _onAnswerSelected(int index) {
    if (_showFeedback) return;
    final q = _questions[_currentIndex];
    final correct = q.correctOptionIndex == index;
    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _isCorrect = correct;
      if (correct) _correctCount++;
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showFeedback = false;
    });
  }

  void _finish() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Дууслаа'),
        content: Text(
          'Та ${_questions.length}-аас $_correctCount зөв хариуллаа. (${(_correctCount / _questions.length * 100).round()}%)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Хаах'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Гарах'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded),
                    onPressed: () {},
                  ),
                  const Text('Сонсох', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                q.text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: q.options.length,
                  itemBuilder: (context, i) {
                    Color? bg;
                    if (_showFeedback) {
                      if (i == q.correctOptionIndex) {
                        bg = AppTheme.successGreen.withValues(alpha: 0.3);
                      } else if (i == _selectedIndex && !_isCorrect) {
                        bg = AppTheme.errorRed.withValues(alpha: 0.3);
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: bg ?? AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _onAnswerSelected(i),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Text(
                                  String.fromCharCode(0x41 + i),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentCyan,
                                ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(q.options[i])),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_showFeedback && q.explanation != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? AppTheme.successGreen.withValues(alpha: 0.2)
                        : AppTheme.errorRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCorrect ? 'Зөв' : 'Буруу',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q.explanation!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentIndex + 1 >= _questions.length ? 'Дуусгах' : 'Дараагийн'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
