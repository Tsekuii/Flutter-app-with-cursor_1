import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/subject_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/lesson/lesson_bloc.dart';
import 'auth_page.dart';
import 'lesson_unit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _lessonLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.unauthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            }
          },
          builder: (context, authState) {
            if (authState.status != AuthStatus.authenticated &&
                authState.status != AuthStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (authState.status == AuthStatus.initial) {
              context.read<AuthBloc>().add(AuthCheckRequested());
              return const Center(child: CircularProgressIndicator());
            }
            final user = authState.user;
            if (user != null && !_lessonLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_lessonLoaded && context.mounted) {
                  _lessonLoaded = true;
                  context.read<LessonBloc>().add(
                    LessonClassSelected(user.classGrade),
                  );
                }
              });
            }
            return _HomeBody(
              userName: user?.displayName ?? 'Хэрэглэгч',
              classGrade: user?.classGrade ?? 10,
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.userName, required this.classGrade});

  final String userName;
  final int classGrade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          final selectedClass = state.selectedClass;
          final subjects = state.subjects;
          final loading = state.loading;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.16),
                          AppTheme.accentPurple.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сайн байна уу, $userName',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Өнөөдөр $selectedClass-р ангийн даалгавруудаа үргэлжлүүлээрэй.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickBadge(
                              icon: Icons.auto_stories_rounded,
                              label: '${subjects.length} хичээл',
                            ),
                            _QuickBadge(
                              icon: Icons.school_rounded,
                              label: '$selectedClass-р анги',
                            ),
                            const _QuickBadge(
                              icon: Icons.bolt_rounded,
                              label: 'Өдөр бүр ахиц',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Анги сонгох',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          AppConstants.maxClass - AppConstants.minClass + 1,
                      itemBuilder: (context, i) {
                        final grade = AppConstants.minClass + i;
                        final selected = grade == selectedClass;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: selected,
                            label: Text('$grade-р анги'),
                            onSelected: (_) => context.read<LessonBloc>().add(
                              LessonClassSelected(grade),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Таны хичээлүүд',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (subjects.isEmpty)
                    _EmptySubjectsCard(selectedClass: selectedClass)
                  else
                    ...subjects.map(
                      (s) => _SubjectCard(
                        subject: s,
                        onTap: () {
                          context.read<LessonBloc>().add(
                            LessonSubjectSelected(s),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<LessonBloc>(),
                                child: const LessonUnitPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickBadge extends StatelessWidget {
  const _QuickBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _EmptySubjectsCard extends StatelessWidget {
  const _EmptySubjectsCard({required this.selectedClass});

  final int selectedClass;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.warningYellow.withValues(alpha: 0.2),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppTheme.warningYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$selectedClass-р ангид одоогоор хичээл бүртгэгдээгүй байна. Өөр анги сонгоод үзээрэй.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final SubjectModel subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _subjectIcon(subject.iconName);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.18),
                child: Icon(icon, color: AppTheme.accentCyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.nameMn,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.classGrade}-р анги | Дасгал, тайлбар, шалгалт',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _subjectIcon(String? iconName) {
    switch (iconName) {
      case 'math':
        return Icons.calculate_rounded;
      case 'chemistry':
        return Icons.science_rounded;
      case 'physics':
        return Icons.science_outlined;
      case 'biology':
        return Icons.eco_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}
