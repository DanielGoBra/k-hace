import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_gif_background.dart';
import '../../../shared/widgets/auth_mobile_components.dart';
import 'auth_strings.dart';
import 'providers/auth_form_provider.dart';
import 'widgets/auth_glow_logo.dart';
import 'widgets/auth_login_content.dart';
import 'widgets/auth_register_content.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with AuthFeedbackMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Auth actions (delegate to provider) ─────────────────────────────────

  Future<void> _login() async {
    final result = await ref
        .read(authFormProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (result != null && mounted) _showResult(result);
  }

  Future<void> _resetPassword() async {
    final result = await ref
        .read(authFormProvider.notifier)
        .resetPassword(email: _emailController.text);
    if (mounted) _showResult(result);
  }

  Future<void> _register() async {
    final result = await ref
        .read(authFormProvider.notifier)
        .register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (result != null && mounted) _showResult(result);
  }

  void _showResult(AuthResult result) {
    switch (result.type) {
      case AuthResultType.error:
        showAuthError(result.message);
      case AuthResultType.success:
        showAuthSuccess(result.message);
      case AuthResultType.info:
        showAuthInfo(result.message);
    }
  }

  void _toggleMode() {
    ref.read(authFormProvider.notifier).toggleMode();
    _passwordController.clear();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormProvider);
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final isLogin = state.mode == AuthMode.login;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AmbientGifBackground(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        preset: AmbientGifPreset.authFormRight,
        imageAlignment: const Alignment(0.16, -0.18),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(top: 28, bottom: kb),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthGlowLogo(),
                  const SizedBox(height: 10),

                  // ── Card with animated content ──
                  AuthSurfaceCard(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: isLogin
                            ? AuthLoginContent(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                emailFocus: _emailFocus,
                                passwordFocus: _passwordFocus,
                                onLogin: _login,
                                onResetPassword: _resetPassword,
                              )
                            : AuthRegisterContent(
                                nameController: _nameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                nameFocus: _nameFocus,
                                emailFocus: _emailFocus,
                                passwordFocus: _passwordFocus,
                                onRegister: _register,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Toggle mode link ──
                  AuthNavigationLink(
                    label: isLogin
                        ? AuthStrings.noAccountLabel
                        : AuthStrings.hasAccountLabel,
                    actionText: isLogin
                        ? AuthStrings.noAccountAction
                        : AuthStrings.hasAccountAction,
                    onTap: state.isLoading ? () {} : _toggleMode,
                  ),

                  // ── Skip auth ──
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(
                        AuthStrings.skipAuth,
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ),
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
