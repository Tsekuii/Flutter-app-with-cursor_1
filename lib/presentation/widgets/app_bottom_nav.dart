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
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: _labels[AppConstants.navHome],
                    isSelected: index == AppConstants.navHome,
                    onTap: () => context.read<AppNavBloc>().add(const AppNavTabChanged(AppConstants.navHome)),
                  ),
                  _NavItem(
                    icon: Icons.add_circle,
                    label: _labels[AppConstants.navCreate],
                    isSelected: index == AppConstants.navCreate,
                    accent: true,
                    onTap: () => context.read<AppNavBloc>().add(const AppNavTabChanged(AppConstants.navCreate)),
                  ),
                  _NavItem(
                    icon: Icons.psychology_rounded,
                    label: _labels[AppConstants.navAi],
                    isSelected: index == AppConstants.navAi,
                    onTap: () => context.read<AppNavBloc>().add(const AppNavTabChanged(AppConstants.navAi)),
                  ),
                  _NavItem(
                    icon: Icons.groups_rounded,
                    label: _labels[AppConstants.navLobby],
                    isSelected: index == AppConstants.navLobby,
                    onTap: () => context.read<AppNavBloc>().add(const AppNavTabChanged(AppConstants.navLobby)),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: _labels[AppConstants.navProfile],
                    isSelected: index == AppConstants.navProfile,
                    onTap: () => context.read<AppNavBloc>().add(const AppNavTabChanged(AppConstants.navProfile)),
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
    final color = isSelected
        ? (accent ? AppTheme.accentCyan : Theme.of(context).colorScheme.primary)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accent && isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              )
            else
              Icon(icon, size: 26, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
