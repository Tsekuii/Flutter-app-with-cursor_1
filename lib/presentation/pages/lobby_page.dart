import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lobby_model.dart' show LobbyModel, LobbyStatus;
import '../blocs/lobby/lobby_bloc.dart';
class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  @override
  void initState() {
    super.initState();
    context.read<LobbyBloc>().add(LobbyLoadOpenRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Лобби'),
            Text(
              'Kahoot + Quizlet style хамтын тоглоом',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: AppTheme.warningYellow, size: 22),
                const SizedBox(width: 4),
                const Text('1250', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<LobbyBloc, LobbyState>(
          builder: (context, state) {
            final isPlay = state.activeTab == 'play';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Тоглох',
                          icon: Icons.play_arrow_rounded,
                          selected: isPlay,
                          onTap: () => context.read<LobbyBloc>().add(const LobbyTabChanged('play')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TabButton(
                          label: '+ Үүсгэх',
                          icon: Icons.add_rounded,
                          selected: !isPlay,
                          accent: true,
                          onTap: () => context.read<LobbyBloc>().add(const LobbyTabChanged('create')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isPlay) ...[
                    Text('PIN код оруулах', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(hintText: 'PIN код оруулах...'),
                            onChanged: (v) => context.read<LobbyBloc>().add(LobbySearchChanged(v)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('ОРОХ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Лобби хайх...', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Text('Нээлттэй тэмцээнүүд', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (state.loading)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else
                      ...state.openLobbies.map((l) => _LobbyCard(lobby: l)),
                  ] else
                    _CreateLobbyForm(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = selected ? (accent ? AppTheme.accentPurple : AppTheme.accentCyan) : AppTheme.surfaceVariant;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? Colors.white : null),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LobbyCard extends StatelessWidget {
  const _LobbyCard({required this.lobby});

  final LobbyModel lobby;

  @override
  Widget build(BuildContext context) {
    final isLive = lobby.status == LobbyStatus.live;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? AppTheme.errorRed.withValues(alpha: 0.2) : AppTheme.warningYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: isLive ? AppTheme.successGreen : AppTheme.errorRed),
                      const SizedBox(width: 6),
                      Text(
                        isLive ? 'LIVE' : (lobby.startsAt != null ? 'ЭХЛЭХ ${lobby.startsAt!.minute.toString().padLeft(2, '0')}:${lobby.startsAt!.second.toString().padLeft(2, '0')}' : ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: isLive ? AppTheme.successGreen : AppTheme.warningYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lobby.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Зохион байгуулагч: ${lobby.organizerName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 18, color: AppTheme.accentCyan),
                const SizedBox(width: 4),
                Text('${lobby.participantCount}/${lobby.maxParticipants}'),
                const SizedBox(width: 16),
                Icon(Icons.emoji_events_rounded, size: 18, color: AppTheme.warningYellow),
                const SizedBox(width: 4),
                Text('${lobby.questionCount} асуулт'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLive ? AppTheme.successGreen : AppTheme.accentCyan,
                ),
                icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.group_add_rounded, size: 20),
                label: Text(isLive ? 'Одоо орох' : 'Бүртгүүлэх'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateLobbyForm extends StatefulWidget {
  const _CreateLobbyForm({required this.state});

  final LobbyState state;

  @override
  State<_CreateLobbyForm> createState() => _CreateLobbyFormState();
}

class _CreateLobbyFormState extends State<_CreateLobbyForm> {
  final _titleCtrl = TextEditingController(text: 'Математикийн тэмцээн');
  final _maxCtrl = TextEditingController(text: '20');
  bool _isPrivate = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Шинэ лобби үүсгэх', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Лобби нэр'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: 'saved',
          decoration: const InputDecoration(labelText: 'Хичээлээс сонгох'),
          items: const [
            DropdownMenuItem(value: 'saved', child: Text('Хадгалсан Quiz-үүдээс сонгох')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _maxCtrl,
                decoration: const InputDecoration(labelText: 'Хамгийн их хүн'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<bool>(
                initialValue: _isPrivate,
                decoration: const InputDecoration(labelText: 'Төрөл'),
                items: const [
                  DropdownMenuItem(value: false, child: Text('Нээлттэй')),
                  DropdownMenuItem(value: true, child: Text('Хувийн (PIN)')),
                ],
                onChanged: (v) => setState(() => _isPrivate = v ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.state.creating
                ? null
                : () {
                    context.read<LobbyBloc>().add(LobbyCreateRequested(
                          title: _titleCtrl.text.trim(),
                          quizOrLessonId: 'quiz-1',
                          maxParticipants: int.tryParse(_maxCtrl.text) ?? 20,
                          isPrivate: _isPrivate,
                        ));
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
            icon: widget.state.creating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add_rounded),
            label: const Text('+ Лобби үүсгэх'),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentPurple.withValues(alpha: 0.3),
                AppTheme.accentPurple.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: AppTheme.warningYellow),
                  const SizedBox(width: 8),
                  Text('Зөвлөмж', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('• Хувийн лобби үүсгэвэл PIN код автоматаар үүснэ'),
              const Text('• Өөрийн Quiz эсвэл Lesson-оос сонгож болно'),
              const Text('• Тоглогчид real-time тоглох боломжтой'),
              const Text('• Шилдэг 3 тоглогч шагнал авна'),
            ],
          ),
        ),
      ],
    );
  }
}
