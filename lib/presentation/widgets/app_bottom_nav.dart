import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/app_nav/app_nav_bloc.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const _labels = ['Нүүр', 'Үүсгэх', 'AI туслах', 'Лобби', 'Профайл'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppNavBloc, AppNavState>(
      buildWhen: (a, b) => a.selectedIndex != b.selectedIndex,
      builder: (context, state) {
        final index = state.selectedIndex;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.95 : 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: _labels[AppConstants.navHome],
                    isSelected: index == AppConstants.navHome,
                    onTap: () => context.read<AppNavBloc>().add(
                      const AppNavTabChanged(AppConstants.navHome),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.add_circle,
                    label: _labels[AppConstants.navCreate],
                    isSelected: index == AppConstants.navCreate,
                    accent: true,
                    onTap: () => context.read<AppNavBloc>().add(
                      const AppNavTabChanged(AppConstants.navCreate),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.psychology_rounded,
                    label: _labels[AppConstants.navAi],
                    isSelected: index == AppConstants.navAi,
                    onTap: () => context.read<AppNavBloc>().add(
                      const AppNavTabChanged(AppConstants.navAi),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.groups_rounded,
                    label: _labels[AppConstants.navLobby],
                    isSelected: index == AppConstants.navLobby,
                    onTap: () => context.read<AppNavBloc>().add(
                      const AppNavTabChanged(AppConstants.navLobby),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: _labels[AppConstants.navProfile],
                    isSelected: index == AppConstants.navProfile,
                    onTap: () => context.read<AppNavBloc>().add(
                      const AppNavTabChanged(AppConstants.navProfile),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = accent ? AppTheme.accentPurple : scheme.primary;
    final color = isSelected
        ? activeColor
        : scheme.onSurface.withValues(alpha: 0.6);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
