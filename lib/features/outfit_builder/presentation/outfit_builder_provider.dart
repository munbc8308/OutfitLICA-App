import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wardrobe/domain/clothing_item.dart';
import '../../wardrobe/domain/clothing_category.dart';
import '../../wardrobe/presentation/wardrobe_provider.dart';
import '../data/outfit_combo_repository.dart';
import '../domain/outfit_combo.dart';

class OutfitBuilderState {
  const OutfitBuilderState({
    this.selected = const {},
    this.savedOutfits = const [],
    this.isLoading = false,
    this.error,
  });

  /// category → 선택된 ClothingItem
  final Map<ClothingCategory, ClothingItem> selected;
  final List<OutfitCombo> savedOutfits;
  final bool isLoading;
  final String? error;

  bool get hasAnyItem => selected.isNotEmpty;

  OutfitBuilderState copyWith({
    Map<ClothingCategory, ClothingItem>? selected,
    List<OutfitCombo>? savedOutfits,
    bool? isLoading,
    String? error,
  }) =>
      OutfitBuilderState(
        selected: selected ?? this.selected,
        savedOutfits: savedOutfits ?? this.savedOutfits,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  OutfitBuilderNotifier(this._repo) : super(const OutfitBuilderState()) {
    loadOutfits();
  }

  final OutfitComboRepository _repo;

  Future<void> loadOutfits() async {
    final outfits = await _repo.getAll();
    state = state.copyWith(savedOutfits: outfits);
  }

  void selectItem(ClothingItem item) {
    final updated = Map<ClothingCategory, ClothingItem>.from(state.selected);
    if (updated[item.category]?.id == item.id) {
      updated.remove(item.category);
    } else {
      updated[item.category] = item;
    }
    state = state.copyWith(selected: updated);
  }

  void removeCategory(ClothingCategory category) {
    final updated = Map<ClothingCategory, ClothingItem>.from(state.selected);
    updated.remove(category);
    state = state.copyWith(selected: updated);
  }

  void clearAll() => state = state.copyWith(selected: {});

  Future<OutfitCombo?> saveCurrentOutfit({String? name}) async {
    if (!state.hasAnyItem) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final ids = state.selected.map(
        (cat, item) => MapEntry(cat.name, item.id),
      );
      final combo = await _repo.saveCombo(
        clothingItemIds: ids,
        name: name,
      );
      state = state.copyWith(
        savedOutfits: [combo, ...state.savedOutfits],
        isLoading: false,
      );
      return combo;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> deleteOutfit(String id) async {
    await _repo.deleteCombo(id);
    state = state.copyWith(
      savedOutfits: state.savedOutfits.where((o) => o.id != id).toList(),
    );
  }
}

final outfitBuilderProvider =
    StateNotifierProvider<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  return OutfitBuilderNotifier(OutfitComboRepository.instance);
});

/// 카테고리별 옷장 아이템을 wardrobe에서 가져오는 provider
final categoryItemsProvider =
    Provider.family<List<ClothingItem>, ClothingCategory>((ref, category) {
  final wardrobe = ref.watch(wardrobeProvider);
  return wardrobe.items.where((i) => i.category == category).toList();
});
