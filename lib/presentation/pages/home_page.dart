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
            if (authState.status != AuthStatus.authenticated && authState.status != AuthStatus.initial) {
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
                  context.read<LessonBloc>().add(LessonClassSelected(user.classGrade));
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
    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          final selectedClass = state.selectedClass;
          final subjects = state.subjects;
          final loading = state.loading;
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сайн байна уу, $userName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Анги сонгох',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.maxClass - AppConstants.minClass + 1,
                    itemBuilder: (context, i) {
                      final grade = AppConstants.minClass + i;
                      final selected = grade == selectedClass;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: selected ? AppTheme.accentCyan : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => context.read<LessonBloc>().add(LessonClassSelected(grade)),
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '$grade-р анги',
                                  style: TextStyle(
                                    color: selected ? Colors.white : null,
                                    fontWeight: selected ? FontWeight.w600 : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else
                  ...subjects.map((s) => _SubjectCard(
                        subject: s,
                        onTap: () {
                          context.read<LessonBloc>().add(LessonSubjectSelected(s));
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<LessonBloc>(),
                                child: const LessonUnitPage(),
                              ),
                            ),
                          );
                        },
                      )),
              ],
            ),
          );
        },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.2),
          child: Icon(Icons.menu_book_rounded, color: AppTheme.accentCyan),
        ),
        title: Text(subject.nameMn),
        subtitle: Text('${subject.classGrade}-р анги'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
