import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/qsh_chip.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';
import 'providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  String _selectedCity = 'Medellín';
  final Set<String> _selectedInterests = {};
  bool _isSaving = false;

  static const _cities = [
    'Medellín',
    'Bogotá',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Santa Marta',
    'Villavicencio',
  ];

  static const _interests = [
    'Rumba',
    'Gastronomía',
    'Aventura',
    'Parques',
    'Café',
    'Música',
    'Arte',
    'Deportes',
    'Cultura',
    'Hospedaje',
    'Comercio',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    if (user != null) {
      _nameController.text = user.nombre;
      _selectedCity = user.ciudad;
      _selectedInterests.addAll(user.intereses);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            nombre: name,
            ciudad: _selectedCity,
            intereses: _selectedInterests.toList(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar. Intenta de nuevo.'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final subtitleColor = context.textTertiary;
    final surfaceColor = context.surface;
    final user = ref.watch(userProfileProvider);

    return QshScaffoldBackground(
      appBar: AppBar(
        title: const GradientText('Editar perfil'),
        actions: [
          const AuthBrandLogo(
            maxWidth: 40,
            glowOpacity: 0,
            padding: EdgeInsets.zero,
          ),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      user?.iniciales ?? '',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Próximamente: foto de perfil',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 28),

            // ── Nombre ──
            Text(
              'Nombre',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Tu nombre completo',
                filled: true,
                fillColor: surfaceColor,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: context.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: context.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Ciudad ──
            Text(
              'Ciudad',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _isSaving ? null : _showCityPicker,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: context.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCity,
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Intereses ──
            Text(
              'Intereses',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona lo que más te gusta para personalizar tu experiencia.',
              style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _interests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return QshChip(
                  label: interest,
                  isSelected: isSelected,
                  onTap: _isSaving
                      ? null
                      : () {
                          setState(() {
                            if (isSelected) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // ── Guardar ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('GUARDAR CAMBIOS'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.iconFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Selecciona tu ciudad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...(_cities.map(
              (city) => ListTile(
                title: Text(city),
                trailing: _selectedCity == city
                    ? const Icon(Icons.check, color: AppTheme.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedCity = city);
                  Navigator.pop(context);
                },
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
