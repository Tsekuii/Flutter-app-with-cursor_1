import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/unit_model.dart';
import '../blocs/lesson/lesson_bloc.dart';
import 'quiz_play_page.dart';

class LessonUnitPage extends StatelessWidget {
  const LessonUnitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хичээл'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          final subject = state.selectedSubject;
          final units = state.units;
          if (subject == null) {
            return const Center(child: Text('Хичээл сонгоно уу'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: units.length,
            itemBuilder: (context, i) {
              final unit = units[i];
              return _UnitCard(
                unit: unit,
                onTap: () => _openUnitDetail(context, unit),
              );
            },
          );
        },
      ),
    );
  }

  void _openUnitDetail(BuildContext context, UnitModel unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _UnitDetailPage(unit: unit),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.onTap});

  final UnitModel unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.2),
          child: Text(
            '${unit.unitNumber}',
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${unit.lessonCount} хичээл, ${unit.testCount} шалгалт'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _UnitDetailPage extends StatelessWidget {
  const _UnitDetailPage({required this.unit});

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('НЭГЖ ${unit.unitNumber} - ${unit.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentCyan.withValues(alpha: 0.3),
                  AppTheme.accentCyan.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'НЭГЖ ${unit.unitNumber}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${unit.lessonCount} хичээл • ${unit.testCount} шалгалт',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...unit.nodes.map((node) => _NodeTile(
                node: node,
                onStart: node.isLocked
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuizPlayPage(
                              title: node.title,
                              questionCount: 5,
                            ),
                          ),
                        );
                      },
              )),
        ],
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node, this.onStart});

  final LessonNodeModel node;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: node.isCompleted
                ? AppTheme.successGreen
                : node.isLocked
                    ? Colors.grey.shade700
                    : AppTheme.accentCyan,
            child: node.isLocked
                ? const Icon(Icons.lock_rounded, color: Colors.white, size: 28)
                : node.isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                    : Icon(
                        node.type == 'test' ? Icons.quiz_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (node.type == 'test') Text('Шалгалт', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (onStart != null && !node.isLocked)
            TextButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Эхлэх'),
            ),
        ],
      ),
    );
  }
}
