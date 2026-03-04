import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/outfit_repository.dart';
import '../domain/outfit_model.dart';

class OutfitState {
  const OutfitState({this.analysis, this.isLoading = false, this.error});
  final OutfitAnalysis? analysis;
  final bool isLoading;
  final String? error;

  OutfitState copyWith({
    OutfitAnalysis? analysis,
    bool? isLoading,
    String? error,
  }) =>
      OutfitState(
        analysis: analysis ?? this.analysis,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class OutfitNotifier extends StateNotifier<OutfitState> {
  OutfitNotifier(this._repository) : super(const OutfitState());

  final OutfitRepository _repository;

  Future<void> analyze(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.analyzeOutfit(File(imagePath));
      state = state.copyWith(analysis: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const OutfitState();
}

final outfitProvider =
    StateNotifierProvider<OutfitNotifier, OutfitState>((ref) {
  return OutfitNotifier(outfitRepositoryInstance);
});
