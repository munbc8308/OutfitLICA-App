import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../../core/database/local_database.dart';
import '../../../core/services/background_removal_service.dart';
import '../domain/clothing_item.dart';
import '../domain/clothing_category.dart';

class WardrobeRepository {
  WardrobeRepository._();
  static final WardrobeRepository instance = WardrobeRepository._();

  final _db = LocalDatabase.instance;
  final _bgRemoval = BackgroundRemovalService.instance;
  final _uuid = const Uuid();

  Future<List<ClothingItem>> getAll() => _db.loadWardrobe();

  Future<List<ClothingItem>> getByCategory(ClothingCategory category) async {
    final all = await _db.loadWardrobe();
    return all.where((item) => item.category == category).toList();
  }

  /// 새 옷 추가: 이미지 캡처 → 배경 제거 → 저장
  Future<ClothingItem> addItem({
    required File imageFile,
    required ClothingCategory category,
    String? name,
    List<ClothingSeason> seasons = const [ClothingSeason.all],
    List<OutfitOccasion> occasions = const [],
    List<String> tags = const [],
  }) async {
    final id = _uuid.v4();

    // 배경 제거 (API 키 없으면 원본 복사)
    final croppedPath = await _bgRemoval.removeBackground(imageFile, id);

    final item = ClothingItem(
      id: id,
      originalImagePath: imageFile.path,
      croppedImagePath: croppedPath,
      category: category,
      name: name,
      seasons: seasons,
      occasions: occasions,
      tags: tags,
      addedAt: DateTime.now(),
    );

    await _db.addClothingItem(item);
    return item;
  }

  Future<void> updateItem(ClothingItem item) => _db.updateClothingItem(item);

  Future<void> deleteItem(String id) async {
    final items = await _db.loadWardrobe();
    final item = items.firstWhere((i) => i.id == id, orElse: () => throw Exception('not found'));

    // 연결된 이미지 파일 삭제
    for (final path in [item.croppedImagePath, item.originalImagePath]) {
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }

    await _db.deleteClothingItem(id);
  }
}
