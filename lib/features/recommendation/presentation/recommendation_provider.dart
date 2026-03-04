import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wardrobe/domain/clothing_item.dart';
import '../../wardrobe/domain/clothing_category.dart';
import '../../wardrobe/presentation/wardrobe_provider.dart';
import '../../../core/services/weather_service.dart';

class RecommendationState {
  const RecommendationState({
    this.weather,
    this.isLoadingWeather = false,
    this.selectedOccasion,
    this.suggestedOutfits = const [],
    this.error,
  });

  final WeatherInfo? weather;
  final bool isLoadingWeather;
  final OutfitOccasion? selectedOccasion;
  final List<Map<ClothingCategory, ClothingItem>> suggestedOutfits;
  final String? error;

  RecommendationState copyWith({
    WeatherInfo? weather,
    bool? isLoadingWeather,
    OutfitOccasion? selectedOccasion,
    List<Map<ClothingCategory, ClothingItem>>? suggestedOutfits,
    String? error,
    bool clearOccasion = false,
  }) =>
      RecommendationState(
        weather: weather ?? this.weather,
        isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
        selectedOccasion:
            clearOccasion ? null : selectedOccasion ?? this.selectedOccasion,
        suggestedOutfits: suggestedOutfits ?? this.suggestedOutfits,
        error: error,
      );
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  RecommendationNotifier(this._ref) : super(const RecommendationState()) {
    loadWeather();
  }

  final Ref _ref;

  Future<void> loadWeather() async {
    state = state.copyWith(isLoadingWeather: true, error: null);
    final weather = await WeatherService.instance.getCurrentWeather();
    state = state.copyWith(weather: weather, isLoadingWeather: false);
    if (weather != null) _generateSuggestions();
  }

  void selectOccasion(OutfitOccasion? occasion) {
    if (occasion == state.selectedOccasion) {
      state = state.copyWith(clearOccasion: true);
    } else {
      state = state.copyWith(selectedOccasion: occasion);
    }
    _generateSuggestions();
  }

  void _generateSuggestions() {
    final allItems = _ref.read(wardrobeProvider).items;
    if (allItems.isEmpty) {
      state = state.copyWith(suggestedOutfits: []);
      return;
    }

    final weather = state.weather;
    final occasion = state.selectedOccasion;

    // 날씨에 맞는 시즌 필터
    final suitableSeasons = weather != null
        ? _weatherToSeasons(weather.condition)
        : ClothingSeason.values.toSet();

    // 각 카테고리별로 필터링
    Map<ClothingCategory, List<ClothingItem>> pool = {};
    for (final category in ClothingCategory.values) {
      pool[category] = allItems.where((item) {
        if (item.category != category) return false;

        // 시즌 필터
        final seasonMatch = item.seasons.contains(ClothingSeason.all) ||
            item.seasons.any(suitableSeasons.contains);
        if (!seasonMatch) return false;

        // 목적 필터 (목적 미지정 or 아이템에 목적 없음이면 통과)
        if (occasion != null && item.occasions.isNotEmpty) {
          return item.occasions.contains(occasion);
        }

        return true;
      }).toList();
    }

    // 아우터 제외 조건 (더운 날씨)
    if (weather?.condition == WeatherCondition.hot) {
      pool[ClothingCategory.outer] = [];
    }

    // 최대 3개 조합 생성
    final suggestions = <Map<ClothingCategory, ClothingItem>>[];
    for (int i = 0; i < 3; i++) {
      final outfit = _pickRandomOutfit(pool);
      if (outfit.isNotEmpty) suggestions.add(outfit);
    }

    state = state.copyWith(suggestedOutfits: suggestions);
  }

  Map<ClothingCategory, ClothingItem> _pickRandomOutfit(
      Map<ClothingCategory, List<ClothingItem>> pool) {
    final outfit = <ClothingCategory, ClothingItem>{};
    for (final entry in pool.entries) {
      if (entry.value.isNotEmpty) {
        final items = List<ClothingItem>.from(entry.value)..shuffle();
        outfit[entry.key] = items.first;
      }
    }
    return outfit;
  }

  Set<ClothingSeason> _weatherToSeasons(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.hot:
        return {ClothingSeason.summer, ClothingSeason.all};
      case WeatherCondition.warm:
        return {ClothingSeason.spring, ClothingSeason.summer, ClothingSeason.all};
      case WeatherCondition.cool:
        return {ClothingSeason.spring, ClothingSeason.fall, ClothingSeason.all};
      case WeatherCondition.cold:
      case WeatherCondition.snowy:
        return {ClothingSeason.winter, ClothingSeason.fall, ClothingSeason.all};
      case WeatherCondition.rainy:
        return {ClothingSeason.spring, ClothingSeason.fall, ClothingSeason.all};
    }
  }
}

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  return RecommendationNotifier(ref);
});
