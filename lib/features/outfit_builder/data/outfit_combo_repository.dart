import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/local_database.dart';
import '../domain/outfit_combo.dart';

class OutfitComboRepository {
  OutfitComboRepository._();
  static final OutfitComboRepository instance = OutfitComboRepository._();

  final _db = LocalDatabase.instance;
  final _uuid = const Uuid();

  Future<List<OutfitCombo>> getAll() => _db.loadOutfits();

  Future<OutfitCombo> saveCombo({
    required Map<String, String> clothingItemIds,
    String? name,
    List<dynamic> occasions = const [],
    String? weatherCondition,
    RenderRepaintBoundary? boundary,
  }) async {
    final id = _uuid.v4();
    String? savedImagePath;

    // 캔버스 이미지 저장
    if (boundary != null) {
      final imagePath = await _captureAndSave(boundary, id);
      savedImagePath = imagePath;
    }

    final combo = OutfitCombo(
      id: id,
      clothingItemIds: clothingItemIds,
      name: name,
      occasions: List.from(occasions),
      createdAt: DateTime.now(),
      savedImagePath: savedImagePath,
      weatherCondition: weatherCondition,
    );

    await _db.addOutfitCombo(combo);
    return combo;
  }

  Future<void> deleteCombo(String id) async {
    final outfits = await _db.loadOutfits();
    final outfit = outfits.firstWhere((o) => o.id == id,
        orElse: () => throw Exception('not found'));

    if (outfit.savedImagePath != null) {
      final file = File(outfit.savedImagePath!);
      if (await file.exists()) await file.delete();
    }

    await _db.deleteOutfitCombo(id);
  }

  Future<String?> _captureAndSave(
      RenderRepaintBoundary boundary, String id) async {
    try {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final dir = await LocalDatabase.instance.outfitImagesDir;
      final file = File('${dir.path}/$id.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
