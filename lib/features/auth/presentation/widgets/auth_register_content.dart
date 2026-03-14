import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/auth_mobile_components.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/qsh_chip.dart';
import '../../../../shared/widgets/social_login_buttons.dart';
import '../auth_strings.dart';
import '../providers/auth_form_provider.dart';

class AuthRegisterContent extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final VoidCallback onRegister;

  const AuthRegisterContent({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authFormProvider);
    final notifier = ref.read(authFormProvider.notifier);

    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          AuthStrings.registerTitle,
          style: AppTheme.headline(fontSize: 22),
        ),
        const SizedBox(height: 14),
        AuthInputField(
          controller: nameController,
          focusNode: nameFocus,
          hintText: AuthStrings.nameHint,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          enabled: !state.isLoading,
          onSubmitted: (_) => emailFocus.requestFocus(),
        ),
        const SizedBox(height: 10),
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
          onSubmitted: (_) {
            if (state.acceptTerms) onRegister();
          },
          suffix: Semantics(
            label: state.obscurePassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',
            child: IconButton(
              icon: Icon(
                state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: context.textSecondary,
              ),
              onPressed: () => notifier.togglePasswordVisibility(),
            ),
          ),
        ),
        const SizedBox(height: 18),
        // ── Interests section ──
        Text(
          AuthStrings.interestsTitle,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AuthStrings.interestsSubtitle,
          style: TextStyle(
            color: context.textTertiary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AuthStrings.interests.map((interest) {
            final isSelected = state.selectedInterests.contains(interest);
            return QshChip(
              label: interest,
              isSelected: isSelected,
              onTap: state.isLoading
                  ? null
                  : () => notifier.toggleInterest(interest),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        // ── Terms checkbox ──
        _TermsCheckbox(
          accepted: state.acceptTerms,
          isLoading: state.isLoading,
          onChanged: (v) => notifier.setAcceptTerms(v ?? false),
        ),
        const SizedBox(height: 14),
        _SubmitButton(
          isLoading: state.isLoading,
          enabled: state.acceptTerms,
          label: AuthStrings.registerButton,
          onPressed: onRegister,
        ),
        const SocialLoginSection(),
      ],
    );
  }
}

// ── Terms checkbox ───────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final bool isLoading;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({
    required this.accepted,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.overlaySubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: accepted,
              onChanged: isLoading ? null : onChanged,
              activeColor: AppTheme.primary,
              side: BorderSide(color: context.iconFaint),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: AuthStrings.termsPrefix,
                style: TextStyle(
                  color: context.textTertiary,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: AuthStrings.termsLink,
                    style: TextStyle(color: AppTheme.primary),
                  ),
                  TextSpan(text: AuthStrings.termsSeparator),
                  TextSpan(
                    text: AuthStrings.privacyLink,
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
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
