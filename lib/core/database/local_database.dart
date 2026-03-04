import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../features/wardrobe/domain/clothing_item.dart';
import '../../features/outfit_builder/domain/outfit_combo.dart';

/// JSON 파일 기반 로컬 데이터베이스
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static const _wardrobeFile = 'wardrobe.json';
  static const _outfitsFile = 'outfits.json';

  Future<Directory> get _appDir async {
    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory('${dir.path}/outfitlica');
    if (!await appDir.exists()) await appDir.create(recursive: true);
    return appDir;
  }

  Future<Directory> get clothingImagesDir async {
    final dir = await _appDir;
    final imgDir = Directory('${dir.path}/clothing_images');
    if (!await imgDir.exists()) await imgDir.create();
    return imgDir;
  }

  Future<Directory> get outfitImagesDir async {
    final dir = await _appDir;
    final imgDir = Directory('${dir.path}/outfit_images');
    if (!await imgDir.exists()) await imgDir.create();
    return imgDir;
  }

  // ── Wardrobe CRUD ──────────────────────────────────────────────────────────

  Future<List<ClothingItem>> loadWardrobe() async {
    final dir = await _appDir;
    final file = File('${dir.path}/$_wardrobeFile');
    if (!await file.exists()) return [];
    final raw = await file.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => ClothingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveWardrobe(List<ClothingItem> items) async {
    final dir = await _appDir;
    final file = File('${dir.path}/$_wardrobeFile');
    await file.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> addClothingItem(ClothingItem item) async {
    final items = await loadWardrobe();
    items.add(item);
    await saveWardrobe(items);
  }

  Future<void> updateClothingItem(ClothingItem updated) async {
    final items = await loadWardrobe();
    final idx = items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      items[idx] = updated;
      await saveWardrobe(items);
    }
  }

  Future<void> deleteClothingItem(String id) async {
    final items = await loadWardrobe();
    items.removeWhere((i) => i.id == id);
    await saveWardrobe(items);
  }

  // ── Outfit Combos CRUD ─────────────────────────────────────────────────────

  Future<List<OutfitCombo>> loadOutfits() async {
    final dir = await _appDir;
    final file = File('${dir.path}/$_outfitsFile');
    if (!await file.exists()) return [];
    final raw = await file.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => OutfitCombo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveOutfits(List<OutfitCombo> outfits) async {
    final dir = await _appDir;
    final file = File('${dir.path}/$_outfitsFile');
    await file.writeAsString(jsonEncode(outfits.map((e) => e.toJson()).toList()));
  }

  Future<void> addOutfitCombo(OutfitCombo outfit) async {
    final outfits = await loadOutfits();
    outfits.add(outfit);
    await saveOutfits(outfits);
  }

  Future<void> deleteOutfitCombo(String id) async {
    final outfits = await loadOutfits();
    outfits.removeWhere((o) => o.id == id);
    await saveOutfits(outfits);
  }
}
