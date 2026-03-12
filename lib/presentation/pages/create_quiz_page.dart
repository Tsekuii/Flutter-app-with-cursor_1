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
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<QuizCreateBloc, QuizCreateState>(
          listener: (context, state) {
            if (state.saveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz амжилттай хадгалагдлаа! 🎉')),
              );
              context.read<QuizCreateBloc>().add(QuizCreateLoadMyQuizzes());
            }
            if (state.saveError != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.saveError!)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz-ийн нэр',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      onChanged: (v) => context.read<QuizCreateBloc>().add(QuizCreateTitleChanged(v)),
                      decoration: const InputDecoration(
                        hintText: 'Математикийн Quiz #1',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _UploadCard(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF оруулах',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _UploadCard(
                          icon: Icons.image_rounded,
                          label: 'Зураг оруулах',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _UploadCard(
                          icon: Icons.text_snippet_rounded,
                          label: 'Текст оруулах',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(Icons.add_circle_rounded, color: AppTheme.accentCyan, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Шинэ асуулт нэмэх',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.accentCyan,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _openAddQuestion(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Асуулт нэмэх'),
                    ),
                    const SizedBox(height: 16),
                    ...state.questions.asMap().entries.map((e) => _QuestionTile(
                          index: e.key + 1,
                          question: e.value,
                          onRemove: () => context.read<QuizCreateBloc>().add(QuizCreateQuestionRemoved(e.value.id)),
                        )),
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
                                : () => context.read<QuizCreateBloc>().add(QuizCreateSaveRequested()),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                            icon: state.saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
                            label: const Text('Хадгалах'),
                          ),
                        ),
                      ],
                    ),
                  ],
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
  const _UploadCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 32, color: AppTheme.accentCyan),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({required this.index, required this.question, required this.onRemove});

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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text('#$index', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(typeLabel, style: Theme.of(context).textTheme.labelSmall),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.text.isEmpty ? '(Асуулт оруулах)' : question.text,
                maxLines: 1,
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
