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

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  int _selectedClass = 10;
  bool _hidePasswordLogin = true;
  bool _hidePasswordSignUp = true;

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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.primary.withValues(alpha: 0.09),
                      scheme.secondary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: scheme.primary.withValues(
                              alpha: 0.18,
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 32,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Олимпиад',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Шалгалтандаа бэлдэх хамгийн хялбар, ухаалаг платформ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: scheme.primary,
                            ),
                            dividerColor: Colors.transparent,
                            unselectedLabelColor: AppTheme.textSecondary,
                            tabs: const [
                              Tab(text: 'Нэвтрэх'),
                              Tab(text: 'Бүртгүүлэх'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 360,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _LoginForm(
                                  formKey: _loginFormKey,
                                  emailCtrl: _emailCtrl,
                                  passwordCtrl: _passwordCtrl,
                                  hidePassword: _hidePasswordLogin,
                                  onTogglePasswordVisibility: () {
                                    setState(
                                      () => _hidePasswordLogin =
                                          !_hidePasswordLogin,
                                    );
                                  },
                                  onLogin: () {
                                    if (_loginFormKey.currentState
                                            ?.validate() !=
                                        true) {
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        email: _emailCtrl.text.trim(),
                                        password: _passwordCtrl.text,
                                      ),
                                    );
                                  },
                                ),
                                _SignUpForm(
                                  formKey: _signUpFormKey,
                                  emailCtrl: _emailCtrl,
                                  passwordCtrl: _passwordCtrl,
                                  nameCtrl: _nameCtrl,
                                  selectedClass: _selectedClass,
                                  hidePassword: _hidePasswordSignUp,
                                  onTogglePasswordVisibility: () {
                                    setState(
                                      () => _hidePasswordSignUp =
                                          !_hidePasswordSignUp,
                                    );
                                  },
                                  onClassChanged: (v) =>
                                      setState(() => _selectedClass = v),
                                  onSignUp: () {
                                    if (_signUpFormKey.currentState
                                            ?.validate() !=
                                        true) {
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                      AuthSignUpRequested(
                                        email: _emailCtrl.text.trim(),
                                        password: _passwordCtrl.text,
                                        displayName: _nameCtrl.text.trim(),
                                        classGrade: _selectedClass,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.status == AuthStatus.authenticated) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const MainShell(),
                                  ),
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
                                  padding: EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(height: 24);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.hidePassword,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool hidePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Имэйл',
              hintText: 'example@mail.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Имэйлээ оруулна уу';
              if (!text.contains('@')) return 'Зөв имэйл хаяг оруулна уу';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordCtrl,
            decoration: InputDecoration(
              labelText: 'Нууц үг',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            obscureText: hidePassword,
            validator: (value) {
              final text = value ?? '';
              if (text.isEmpty) {
                return 'Нууц үгээ оруулна уу';
              }
              if (text.length < 6) {
                return 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLogin,
              child: const Text('Нэвтрэх'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Дэвшил, хичээл, сорилууд тань аюулгүй хадгалагдана.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.selectedClass,
    required this.hidePassword,
    required this.onTogglePasswordVisibility,
    required this.onClassChanged,
    required this.onSignUp,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final int selectedClass;
  final bool hidePassword;
  final VoidCallback onTogglePasswordVisibility;
  final ValueChanged<int> onClassChanged;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Нэр',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if ((value?.trim().isEmpty ?? true)) {
                return 'Нэрээ оруулна уу';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Имэйл',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Имэйлээ оруулна уу';
              if (!text.contains('@')) return 'Зөв имэйл хаяг оруулна уу';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordCtrl,
            decoration: InputDecoration(
              labelText: 'Нууц үг',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            obscureText: hidePassword,
            validator: (value) {
              final text = value ?? '';
              if (text.isEmpty) {
                return 'Нууц үгээ оруулна уу';
              }
              if (text.length < 6) {
                return 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: selectedClass,
            decoration: const InputDecoration(
              labelText: 'Анги',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: List.generate(
              AppConstants.maxClass - AppConstants.minClass + 1,
              (i) => DropdownMenuItem(
                value: AppConstants.minClass + i,
                child: Text('${AppConstants.minClass + i}-р анги'),
              ),
            ),
            onChanged: (v) => onClassChanged(v ?? 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
              ),
              child: const Text('Бүртгүүлэх'),
            ),
          ),
        ],
      ),
    );
  }
}
