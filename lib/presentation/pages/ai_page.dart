import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  static const _suggestions = [
    'Математикийн тусламж',
    'Физикийн бодлого',
    'Англи хэлний дүрэм',
    'Түүхийн он цаг',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology_rounded, color: AppTheme.accentCyan, size: 28),
            const SizedBox(width: 8),
            const Text('AI Assistant'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: AppTheme.successGreen),
                  const SizedBox(width: 6),
                  Text('ONLINE', style: TextStyle(color: AppTheme.successGreen, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Bubble(
                    isMe: false,
                    text: 'Сайн байна уу? Танд юугаар туслах вэ? Хичээлтэй холбоотой бүх асуултаа асууж болно.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions
                    .map((s) => ActionChip(
                          label: Text(s),
                          onPressed: () {},
                          backgroundColor: AppTheme.surfaceVariant,
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Асуултаа энд бичнэ үү....',
                  prefixIcon: const Icon(Icons.attach_file_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.isMe, required this.text});

  final bool isMe;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.surfaceVariant : AppTheme.accentCyan.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Text(text),
      ),
    );
  }
}
