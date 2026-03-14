import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './widgets/pulse_card.dart';
import './widgets/compact_pulse_card.dart';
import './providers/home_providers.dart';
import './providers/greeting_provider.dart';
import '../../../shared/widgets/qsh_search_bar.dart';
import '../../../shared/widgets/qsh_chip.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/qsh_empty_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../notifications/presentation/providers/notifications_providers.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredLugares = ref.watch(filteredLugaresProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final greeting = ref.watch(greetingProvider);
    final recommended = ref.watch(recommendedLugaresProvider);

    return QshScaffoldBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: GradientText(
                '¡Qué hacemos pues!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: AuthBrandLogo(
                    maxWidth: 40,
                    glowOpacity: 0,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () => context.push('/notifications'),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_outline),
                  onPressed: () => context.push('/profile/favorites'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personalized greeting ──
                    GradientText(
                      greeting,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GradientText(
                      'Descubre lo mejor de ${selectedCategory == 'Toda la ciudad' ? 'tu ciudad' : selectedCategory.toLowerCase()}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    QshSearchBar(
                      readOnly: true,
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: 32),
                    _buildCategories(ref, selectedCategory),

                    // ── "Para ti" section ──
                    if (recommended.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const SectionHeader(title: 'Para ti'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommended.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            final lugar = recommended[index];
                            return CompactPulseCard(
                              lugar: lugar,
                              onTap: () => context.push(
                                '/detail/${lugar.id}',
                                extra: lugar,
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    const SectionHeader(title: 'En tendencia'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (filteredLugares.isEmpty)
              const SliverFillRemaining(
                child: QshEmptyState(
                  icon: Icons.explore_off,
                  title: 'No hay parches en esta categoría aún',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final lugar = filteredLugares[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: PulseCard(
                      lugar: lugar,
                      onTap: () =>
                          context.push('/detail/${lugar.id}', extra: lugar),
                    ),
                  );
                }, childCount: filteredLugares.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(WidgetRef ref, String selected) {
    final categories = [
      'Toda la ciudad',
      'Rumba',
      'Gastronomía',
      'Aventura',
      'Parques',
      'Café',
      'Cultura',
      'Hospedaje',
      'Comercio',
      'Servicios',
      'Educación',
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: QshChip(
                  label: category,
                  isSelected: category == selected,
                  onTap: () =>
                      ref.read(selectedCategoryProvider.notifier).state =
                          category,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
