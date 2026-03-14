import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/qsh_search_bar.dart';
import '../../../shared/widgets/qsh_empty_state.dart';
import '../../../shared/widgets/qsh_rating_badge.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../home/domain/lugar.dart';
import '../../search/domain/search_result.dart';
import 'providers/search_providers.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return QshScaffoldBackground(
      appBar: AppBar(
        title: const GradientText('Buscar'),
        actions: const [
          AuthBrandLogo(maxWidth: 40, glowOpacity: 0, padding: EdgeInsets.zero),
          SizedBox(width: 8),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: QshSearchBar(
              controller: _controller,
              autofocus: true,
              hintText: 'Buscar lugares, eventos...',
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _buildSuggestions(context)
                : results.isEmpty
                ? const QshEmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    subtitle:
                        'No encontramos nada con ese término. Intenta con otra palabra.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      if (result.tipo == SearchResultType.lugar) {
                        return _LugarResultTile(
                          result: result,
                          onTap: () =>
                              context.push('/detail/${result.lugar!.id}'),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: EventCard(
                            evento: result.evento!,
                            onTap: () =>
                                context.push('/event/${result.evento!.id}'),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      'Rumba',
      'Café',
      'Gastronomía',
      'Aventura',
      'Música',
      'Parques',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sugerencias', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions
                .map(
                  (s) => ActionChip(
                    label: Text(s),
                    backgroundColor: context.surface,
                    side: BorderSide(color: context.dividerColor),
                    onPressed: () {
                      _controller.text = s;
                      ref.read(searchQueryProvider.notifier).state = s;
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LugarResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback? onTap;

  const _LugarResultTile({required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final lugar = result.lugar!;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: lugar.imagenUrl.startsWith('http')
            ? Image.network(
                lugar.imagenUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.surface,
                  child: Icon(Icons.image, color: context.iconFaint),
                ),
              )
            : Image.asset(
                lugar.imagenUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.surface,
                  child: Icon(Icons.image, color: context.iconFaint),
                ),
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              lugar.nombre,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lugar.planTipo == PlanTipo.pro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.highlight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: AppTheme.highlight,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            lugar.categoria,
            style: TextStyle(color: context.textSubtle, fontSize: 13),
          ),
          const SizedBox(width: 8),
          QshRatingBadge(
            rating: lugar.rating,
            iconSize: 12,
            fontSize: 12,
            textColor: context.textSubtle,
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: context.iconFaint, size: 20),
    );
  }
}
