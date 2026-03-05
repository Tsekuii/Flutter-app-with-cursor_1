import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';

class AddQuestionSheet extends StatefulWidget {
  const AddQuestionSheet({
    super.key,
    required this.onAdd,
    required this.nextId,
  });

  final void Function(QuestionModel question) onAdd;
  final String nextId;

  @override
  State<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends State<AddQuestionSheet> {
  QuestionType _type = QuestionType.multipleChoice;
  final _textCtrl = TextEditingController();
  final _optionACtrl = TextEditingController();
  final _optionBCtrl = TextEditingController();
  final _optionCCtrl = TextEditingController();
  final _optionDCtrl = TextEditingController();
  int? _correctIndex;
  final _correctTextCtrl = TextEditingController();
  final _explanationCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _optionACtrl.dispose();
    _optionBCtrl.dispose();
    _optionCCtrl.dispose();
    _optionDCtrl.dispose();
    _correctTextCtrl.dispose();
    _explanationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Асуулт оруулна уу')));
      return;
    }
    if (_type == QuestionType.multipleChoice) {
      final options = [
        _optionACtrl.text.trim(),
        _optionBCtrl.text.trim(),
        _optionCCtrl.text.trim(),
        _optionDCtrl.text.trim(),
      ].where((e) => e.isNotEmpty).toList();
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Дор хаяж 2 сонголт оруулна уу')));
        return;
      }
      widget.onAdd(QuestionModel(
        id: widget.nextId,
        type: QuestionType.multipleChoice,
        text: text,
        options: options,
        correctOptionIndex: _correctIndex != null && _correctIndex! < options.length ? _correctIndex : 0,
        explanation: _explanationCtrl.text.trim().isEmpty ? null : _explanationCtrl.text.trim(),
      ));
    } else if (_type == QuestionType.trueFalse) {
      widget.onAdd(QuestionModel(
        id: widget.nextId,
        type: QuestionType.trueFalse,
        text: text,
        options: ['Үнэн', 'Худал'],
        correctOptionIndex: _correctIndex ?? 0,
        explanation: _explanationCtrl.text.trim().isEmpty ? null : _explanationCtrl.text.trim(),
      ));
    } else {
      widget.onAdd(QuestionModel(
        id: widget.nextId,
        type: QuestionType.textAnswer,
        text: text,
        correctTextAnswer: _correctTextCtrl.text.trim().isEmpty ? null : _correctTextCtrl.text.trim(),
        explanation: _explanationCtrl.text.trim().isEmpty ? null : _explanationCtrl.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Шинэ асуулт нэмэх', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Асуултын төрөл', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypeChip(
                  label: 'Олон сонголт',
                  selected: _type == QuestionType.multipleChoice,
                  onTap: () => setState(() => _type = QuestionType.multipleChoice),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Үнэн/Худал',
                  selected: _type == QuestionType.trueFalse,
                  onTap: () => setState(() => _type = QuestionType.trueFalse),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Текст хариулт',
                  selected: _type == QuestionType.textAnswer,
                  onTap: () => setState(() => _type = QuestionType.textAnswer),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Асуулт', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _textCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Асуултаа бичнэ үү...'),
            ),
            if (_type == QuestionType.multipleChoice) ...[
              const SizedBox(height: 16),
              Text('Сонголтууд', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _OptionField(label: 'Сонголт А', controller: _optionACtrl, isCorrect: _correctIndex == 0, onTap: () => setState(() => _correctIndex = 0)),
              _OptionField(label: 'Сонголт В', controller: _optionBCtrl, isCorrect: _correctIndex == 1, onTap: () => setState(() => _correctIndex = 1)),
              _OptionField(label: 'Сонголт С', controller: _optionCCtrl, isCorrect: _correctIndex == 2, onTap: () => setState(() => _correctIndex = 2)),
              _OptionField(label: 'Сонголт D', controller: _optionDCtrl, isCorrect: _correctIndex == 3, onTap: () => setState(() => _correctIndex = 3)),
            ],
            if (_type == QuestionType.trueFalse) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _TypeChip(label: 'Үнэн', selected: _correctIndex == 0, onTap: () => setState(() => _correctIndex = 0)),
                  const SizedBox(width: 8),
                  _TypeChip(label: 'Худал', selected: _correctIndex == 1, onTap: () => setState(() => _correctIndex = 1)),
                ],
              ),
            ],
            if (_type == QuestionType.textAnswer) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _correctTextCtrl,
                decoration: const InputDecoration(labelText: 'Зөв хариулт'),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _explanationCtrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Тайлбар (заавал биш)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Асуулт нэмэх'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.accentCyan : AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : null,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    required this.label,
    required this.controller,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.check_circle_rounded,
              color: isCorrect ? AppTheme.successGreen : AppTheme.textSecondary,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
