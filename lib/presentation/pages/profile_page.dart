import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/settings/settings_cubit.dart';
import '../widgets/app_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final user = state.user ?? context.read<AuthBloc>().state.user;
              if (user == null) {
                return const Center(child: Text('Нэвтрэнэ үү'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.warningYellow.withValues(alpha: 0.3),
                          child: Icon(Icons.school_rounded, size: 40, color: AppTheme.warningYellow),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${user.classGrade}-р анги | Түвшин ${user.level}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(icon: Icons.local_fire_department_rounded, value: '${user.streakDays}', label: 'Дэс'),
                              _StatItem(icon: Icons.emoji_events_rounded, value: '${user.coins}', label: 'Зоос'),
                              _StatItem(icon: Icons.gps_fixed_rounded, value: '${user.xp}', label: 'XP'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (user.xp % 1000) / 1000,
                              minHeight: 8,
                              backgroundColor: AppTheme.surfaceVariant,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warningYellow),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Түвшин ${user.level}', style: Theme.of(context).textTheme.labelSmall),
                              Text('Түвшин ${user.level + 1}', style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _ProfileTab(
                          label: 'Явц',
                          selected: state.activeTab == 'progress',
                          onTap: () => context.read<ProfileBloc>().add(const ProfileTabChanged('progress')),
                        ),
                        const SizedBox(width: 12),
                        _ProfileTab(
                          label: 'Тохиргоо',
                          icon: Icons.settings_rounded,
                          selected: state.activeTab == 'settings',
                          onTap: () => context.read<ProfileBloc>().add(const ProfileTabChanged('settings')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (state.activeTab == 'progress') ...[
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _MetricCard(icon: Icons.menu_book_rounded, value: '${user.completedLessonsCount}', label: 'Дууссан хичээл'),
                          _MetricCard(icon: Icons.access_time_rounded, value: '${user.totalTimeMinutes}м', label: 'Нийт цаг'),
                          _MetricCard(icon: Icons.gps_fixed_rounded, value: '${user.averageScorePercent}%', label: 'Дундаж оноо'),
                          _MetricCard(icon: Icons.emoji_events_rounded, value: '${user.awardsCount}', label: 'Авсан шагнал'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: AppTheme.warningYellow, size: 22),
                          const SizedBox(width: 8),
                          Text('Амжилтууд', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: state.achievements.length,
                          itemBuilder: (context, i) {
                            final a = state.achievements[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _achievementIcon(a.iconName),
                                      size: 36,
                                      color: a.isUnlocked ? AppTheme.warningYellow : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      a.titleMn,
                                      style: Theme.of(context).textTheme.labelMedium,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ] else
                      _SettingsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  static IconData _achievementIcon(String name) {
    switch (name) {
      case 'target':
        return Icons.gps_fixed_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'math':
        return Icons.calculate_rounded;
      case 'graduation':
        return Icons.school_rounded;
      case 'crown':
        return Icons.emoji_events_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppTheme.accentCyan),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.label, this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData? icon;
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: selected ? Colors.white : null),
                const SizedBox(width: 8),
              ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.accentCyan, size: 32),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Хэл', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            _SettingsChip(
              label: 'Монгол',
              selected: settings.localeCode == 'mn',
              onTap: () => context.read<SettingsCubit>().setLocale('mn'),
            ),
            const SizedBox(width: 8),
            _SettingsChip(
              label: 'English',
              selected: settings.localeCode == 'en',
              onTap: () => context.read<SettingsCubit>().setLocale('en'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Гэрэл', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            _SettingsChip(
              label: 'Харанхуй',
              selected: settings.themeMode == ThemeMode.dark,
              onTap: () => context.read<SettingsCubit>().setThemeMode(ThemeMode.dark),
            ),
            const SizedBox(width: 8),
            _SettingsChip(
              label: 'Гэрэл',
              selected: settings.themeMode == ThemeMode.light,
              onTap: () => context.read<SettingsCubit>().setThemeMode(ThemeMode.light),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Гарах'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed),
          ),
        ),
      ],
    );
  }
}

class _SettingsChip extends StatelessWidget {
  const _SettingsChip({required this.label, required this.selected, required this.onTap});

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
