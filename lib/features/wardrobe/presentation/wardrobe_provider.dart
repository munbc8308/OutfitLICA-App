import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wardrobe_repository.dart';
import '../domain/clothing_item.dart';
import '../domain/clothing_category.dart';

class WardrobeState {
  const WardrobeState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  final List<ClothingItem> items;
  final bool isLoading;
  final String? error;
  final ClothingCategory? selectedCategory;

  List<ClothingItem> get filteredItems => selectedCategory == null
      ? items
      : items.where((i) => i.category == selectedCategory).toList();

  WardrobeState copyWith({
    List<ClothingItem>? items,
    bool? isLoading,
    String? error,
    ClothingCategory? selectedCategory,
    bool clearCategory = false,
  }) =>
      WardrobeState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedCategory:
            clearCategory ? null : selectedCategory ?? this.selectedCategory,
      );
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier(this._repo) : super(const WardrobeState()) {
    loadItems();
  }

  final WardrobeRepository _repo;

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getAll();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<ClothingItem?> addItem({
    required File imageFile,
    required ClothingCategory category,
    String? name,
    List<ClothingSeason> seasons = const [ClothingSeason.all],
    List<OutfitOccasion> occasions = const [],
    List<String> tags = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final item = await _repo.addItem(
        imageFile: imageFile,
        category: category,
        name: name,
        seasons: seasons,
        occasions: occasions,
        tags: tags,
      );
      state = state.copyWith(
        items: [...state.items, item],
        isLoading: false,
      );
      return item;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> deleteItem(String id) async {
    await _repo.deleteItem(id);
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  void filterByCategory(ClothingCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }
}

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier(WardrobeRepository.instance);
});
