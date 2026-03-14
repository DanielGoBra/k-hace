import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/auth_mobile_components.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/social_login_buttons.dart';
import '../auth_strings.dart';
import '../providers/auth_form_provider.dart';

class AuthLoginContent extends ConsumerWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;

  const AuthLoginContent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.onLogin,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authFormProvider);

    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          AuthStrings.loginTitle,
          style: AppTheme.headline(fontSize: 22),
        ),
        const SizedBox(height: 4),
        GradientText(
          AuthStrings.loginSubtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        AuthInputField(
          controller: emailController,
          focusNode: emailFocus,
          hintText: AuthStrings.emailHint,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !state.isLoading,
          onSubmitted: (_) => passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 10),
        AuthInputField(
          controller: passwordController,
          focusNode: passwordFocus,
          hintText: AuthStrings.passwordHint,
          prefixIcon: Icons.lock_outline,
          textInputAction: TextInputAction.done,
          enabled: !state.isLoading,
          obscureText: state.obscurePassword,
          onSubmitted: (_) => onLogin(),
          suffix: Semantics(
            label: state.obscurePassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',
            child: IconButton(
              icon: Icon(
                state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: context.textSecondary,
              ),
              onPressed: () => ref
                  .read(authFormProvider.notifier)
                  .togglePasswordVisibility(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: state.isLoading ? null : onResetPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AuthStrings.forgotPassword,
              style: TextStyle(color: context.textTertiary, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _SubmitButton(
          isLoading: state.isLoading,
          label: AuthStrings.loginButton,
          onPressed: onLogin,
        ),
        const SocialLoginSection(),
      ],
    );
  }
}

/// Shared submit button with loading indicator.
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
