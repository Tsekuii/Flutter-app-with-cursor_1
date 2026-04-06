import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _suggestions = [
    'Математикийн тусламж',
    'Физикийн бодлого',
    'Англи хэлний дүрэм',
    'Түүхийн он цаг',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology_rounded, color: scheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text('AI туслах'),
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
                  Text(
                    'Идэвхтэй',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                    ),
                  ),
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
              child: CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          _Bubble(
                            isMe: false,
                            text:
                                'Сайн байна уу? Танд юугаар туслах вэ? Хичээлтэй холбоотой бүх асуултаа асууж болно.',
                          ),
                          const Spacer(),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 56,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Асуултаа доор бичнэ үү',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Доорх саналуудыг дарж эхлэх боломжтой',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.85),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestions
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(s),
                            onPressed: () {
                              _messageCtrl.text = s;
                            },
                            backgroundColor: scheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: scheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Material(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Хавсралт',
                      onPressed: () {},
                      icon: Icon(
                        Icons.attach_file_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendStub(),
                        decoration: InputDecoration(
                          hintText: 'Асуултаа энд бичнэ үү…',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.fromLTRB(
                            0,
                            12,
                            8,
                            12,
                          ),
                          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: FilledButton(
                        onPressed: _sendStub,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(Icons.send_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendStub() {
    FocusScope.of(context).unfocus();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.isMe, required this.text});

  final bool isMe;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? scheme.surfaceContainerHighest
              : scheme.primary.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: Text(
          text,
          style: TextStyle(color: scheme.onSurface, height: 1.4),
        ),
      ),
    );
  }
}
