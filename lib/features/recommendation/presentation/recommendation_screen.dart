import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../wardrobe/domain/clothing_category.dart';
import '../../wardrobe/domain/clothing_item.dart';
import 'recommendation_provider.dart';
import '../../outfit_builder/presentation/outfit_canvas_widget.dart';
import '../../../core/services/weather_service.dart';

class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 코디 추천'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(recommendationProvider.notifier).loadWeather();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(recommendationProvider.notifier).loadWeather(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날씨 카드
              _WeatherCard(state: state),
              const SizedBox(height: 16),

              // 목적 선택
              const Text('목적',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              _OccasionSelector(
                selected: state.selectedOccasion,
                onChanged: (o) =>
                    ref.read(recommendationProvider.notifier).selectOccasion(o),
              ),
              const SizedBox(height: 20),

              // 추천 코디 목록
              const Text('추천 코디',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),

              if (state.suggestedOutfits.isEmpty)
                _EmptySuggestion(
                  hasWardrobe: true,
                  onGoToWardrobe: () => context.go('/wardrobe'),
                )
              else
                ...state.suggestedOutfits.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SuggestedOutfitCard(
                      index: entry.key + 1,
                      items: entry.value,
                      onApply: () {
                        // 코디 빌더로 이동하며 해당 코디 아이템 전달
                        context.push('/outfit-builder');
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 날씨 카드 ────────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.state});
  final RecommendationState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingWeather) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text('날씨 불러오는 중...'),
            ],
          ),
        ),
      );
    }

    final weather = state.weather;
    if (weather == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off, color: Colors.grey),
          title: const Text('날씨 정보를 가져올 수 없습니다'),
          subtitle: const Text('위치 권한을 확인해주세요'),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(weather.conditionEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.city,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${weather.conditionLabel} · ${weather.description}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 목적 선택기 ──────────────────────────────────────────────────────────────

class _OccasionSelector extends StatelessWidget {
  const _OccasionSelector(
      {required this.selected, required this.onChanged});
  final OutfitOccasion? selected;
  final ValueChanged<OutfitOccasion?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OutfitOccasion.values.map((o) {
        final isSelected = o == selected;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(o.emoji),
                const SizedBox(width: 6),
                Text(
                  o.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 추천 코디 카드 ───────────────────────────────────────────────────────────

class _SuggestedOutfitCard extends StatelessWidget {
  const _SuggestedOutfitCard({
    required this.index,
    required this.items,
    required this.onApply,
  });
  final int index;
  final Map<ClothingCategory, ClothingItem> items;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text('추천 #$index',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                TextButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('수정'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 280,
              child: OutfitCanvasWidget(
                selectedItems: items,
                showPlaceholder: false,
                backgroundColor: Colors.grey[50],
              ),
            ),
          ),
          // 포함된 아이템 태그
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items.entries.map((e) {
                return Chip(
                  label: Text(
                    '${e.key.emoji} ${e.value.name ?? e.key.label}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySuggestion extends StatelessWidget {
  const _EmptySuggestion(
      {required this.hasWardrobe, required this.onGoToWardrobe});
  final bool hasWardrobe;
  final VoidCallback onGoToWardrobe;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.checkroom_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('옷장에 옷이 없어요',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('먼저 옷을 추가해주세요',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onGoToWardrobe,
              icon: const Icon(Icons.add),
              label: const Text('옷장 가기'),
            ),
          ],
        ),
      ),
    );
  }
}
