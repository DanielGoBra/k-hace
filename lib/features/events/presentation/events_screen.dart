import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/qsh_chip.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/qsh_empty_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import 'providers/events_providers.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEventos = ref.watch(filteredEventosProvider);
    final selectedCategory = ref.watch(selectedEventCategoryProvider);
    final selectedDate = ref.watch(selectedEventDateProvider);

    return QshScaffoldBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: GradientText(
                'Eventos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                const AuthBrandLogo(
                  maxWidth: 40,
                  glowOpacity: 0,
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar strip
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 14,
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isToday = index == 0;
                        final isSelected =
                            selectedDate != null &&
                            date.year == selectedDate.year &&
                            date.month == selectedDate.month &&
                            date.day == selectedDate.day;
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              ref
                                      .read(selectedEventDateProvider.notifier)
                                      .state =
                                  null;
                            } else {
                              ref
                                      .read(selectedEventDateProvider.notifier)
                                      .state =
                                  date;
                            }
                          },
                          child: Container(
                            width: 56,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : isToday
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dayAbbr(date),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black87
                                        : context.textSubtle,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black87
                                        : context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _monthAbbr(date),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black54
                                        : context.textSubtle,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children:
                          [
                                'Todos',
                                'Música',
                                'Gastronomía',
                                'Aventura',
                                'Fiesta',
                                'Arte',
                              ]
                              .map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: QshChip(
                                    label: cat,
                                    isSelected: selectedCategory == cat,
                                    onTap: () =>
                                        ref
                                                .read(
                                                  selectedEventCategoryProvider
                                                      .notifier,
                                                )
                                                .state =
                                            cat,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (filteredEventos.isEmpty)
              const SliverFillRemaining(
                child: QshEmptyState(
                  icon: Icons.event_busy,
                  title: 'No hay eventos',
                  subtitle:
                      'No encontramos eventos con estos filtros. Prueba otra fecha o categoría.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final evento = filteredEventos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: EventCard(
                      evento: evento,
                      onTap: () => context.push('/event/${evento.id}'),
                    ),
                  );
                }, childCount: filteredEventos.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _dayAbbr(DateTime date) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return days[date.weekday - 1];
  }

  String _monthAbbr(DateTime date) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    return months[date.month - 1];
  }
}
