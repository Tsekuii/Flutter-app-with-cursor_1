import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';
import '../blocs/quiz_create/quiz_create_bloc.dart';
import 'add_question_sheet.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _uuid = const Uuid();
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<QuizCreateBloc>().add(QuizCreateLoadMyQuizzes());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<QuizCreateBloc, QuizCreateState>(
          listener: (context, state) {
            if (state.saveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz амжилттай хадгалагдлаа! 🎉'),
                ),
              );
              context.read<QuizCreateBloc>().add(QuizCreateLoadMyQuizzes());
            }
            if (state.saveError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.saveError!)));
            }
          },
          builder: (context, state) {
            final completionValue = (state.questions.length / 10)
                .clamp(0, 1)
                .toDouble();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary.withValues(alpha: 0.16),
                              AppTheme.accentPurple.withValues(alpha: 0.14),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Шалгалт үүсгэх студи',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Агуулга нэмээд шууд хадгалах боломжтой. 10+ асуулттай quiz нь илүү үр дүнтэй.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: completionValue,
                                minHeight: 8,
                                backgroundColor: scheme.surface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${state.questions.length} асуулт нэмэгдсэн',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Quiz-ийн нэр',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleCtrl,
                        onChanged: (v) => context.read<QuizCreateBloc>().add(
                          QuizCreateTitleChanged(v),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Математикийн Quiz #1',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Агуулга оруулах',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _UploadCard(
                            icon: Icons.picture_as_pdf_rounded,
                            label: 'PDF',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _UploadCard(
                            icon: Icons.image_rounded,
                            label: 'Зураг',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _UploadCard(
                            icon: Icons.text_snippet_rounded,
                            label: 'Текст',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_rounded,
                            color: AppTheme.accentCyan,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Асуултын сан',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.accentCyan,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _openAddQuestion(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Асуулт нэмэх'),
                      ),
                      const SizedBox(height: 14),
                      if (state.questions.isEmpty)
                        const _EmptyQuestionCard()
                      else
                        ...state.questions.asMap().entries.map(
                          (e) => _QuestionTile(
                            index: e.key + 1,
                            question: e.value,
                            onRemove: () => context.read<QuizCreateBloc>().add(
                              QuizCreateQuestionRemoved(e.value.id),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.preview_rounded),
                              label: const Text('Урьдчилж харах'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.saving
                                  ? null
                                  : () => context.read<QuizCreateBloc>().add(
                                      QuizCreateSaveRequested(),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                              ),
                              icon: state.saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: const Text('Хадгалах'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openAddQuestion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddQuestionSheet(
        onAdd: (q) {
          context.read<QuizCreateBloc>().add(QuizCreateQuestionAdded(q));
          Navigator.pop(ctx);
        },
        nextId: _uuid.v4(),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, size: 28, color: AppTheme.accentCyan),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.index,
    required this.question,
    required this.onRemove,
  });

  final int index;
  final QuestionModel question;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final typeLabel = question.type == QuestionType.multipleChoice
        ? 'Олон сонголт'
        : question.type == QuestionType.trueFalse
        ? 'Үнэн/Худал'
        : 'Текст';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$index',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                typeLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.text.isEmpty ? '(Асуулт оруулах)' : question.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppTheme.errorRed, size: 22),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuestionCard extends StatelessWidget {
  const _EmptyQuestionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Одоогоор асуулт алга байна. "Асуулт нэмэх" товчоор эхлүүлээрэй.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
