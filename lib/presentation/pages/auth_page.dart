import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/auth/auth_bloc.dart';
import 'main_shell.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  int _selectedClass = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 64, color: AppTheme.accentCyan),
                  const SizedBox(height: 16),
                  Text(
                    'Олимпиад',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentCyan,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.accentCyan,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: const [
                      Tab(text: 'Нэвтрэх'),
                      Tab(text: 'Бүртгүүлэх'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _LoginForm(
                          emailCtrl: _emailCtrl,
                          passwordCtrl: _passwordCtrl,
                          onLogin: () => context.read<AuthBloc>().add(AuthLoginRequested(
                                email: _emailCtrl.text.trim(),
                                password: _passwordCtrl.text,
                              )),
                        ),
                        _SignUpForm(
                          emailCtrl: _emailCtrl,
                          passwordCtrl: _passwordCtrl,
                          nameCtrl: _nameCtrl,
                          selectedClass: _selectedClass,
                          onClassChanged: (v) => setState(() => _selectedClass = v),
                          onSignUp: () => context.read<AuthBloc>().add(AuthSignUpRequested(
                                email: _emailCtrl.text.trim(),
                                password: _passwordCtrl.text,
                                displayName: _nameCtrl.text.trim(),
                                classGrade: _selectedClass,
                              )),
                        ),
                      ],
                    ),
                  ),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state.status == AuthStatus.authenticated) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainShell()),
                        );
                      }
                      if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state.status == AuthStatus.loading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onLogin,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(
            labelText: 'Имэйл',
            hintText: 'example@mail.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'Нууц үг'),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onLogin,
            child: const Text('Нэвтрэх'),
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.selectedClass,
    required this.onClassChanged,
    required this.onSignUp,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final int selectedClass;
  final ValueChanged<int> onClassChanged;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Нэр'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(labelText: 'Имэйл'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'Нууц үг'),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: selectedClass,
          decoration: const InputDecoration(labelText: 'Анги'),
          items: List.generate(
            AppConstants.maxClass - AppConstants.minClass + 1,
            (i) => DropdownMenuItem(value: AppConstants.minClass + i, child: Text('${AppConstants.minClass + i}-р анги')),
          ),
          onChanged: (v) => onClassChanged(v ?? 10),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSignUp,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
            child: const Text('Бүртгүүлэх'),
          ),
        ),
      ],
    );
  }
}
