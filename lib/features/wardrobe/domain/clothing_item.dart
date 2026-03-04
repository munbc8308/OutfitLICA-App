import 'clothing_category.dart';

class ClothingItem {
  ClothingItem({
    required this.id,
    required this.originalImagePath,
    required this.category,
    required this.addedAt,
    this.croppedImagePath,
    this.name,
    this.colors = const [],
    this.seasons = const [ClothingSeason.all],
    this.occasions = const [],
    this.tags = const [],
  });

  final String id;
  final String originalImagePath;

  /// 배경 제거 후 이미지 경로 (PNG, 투명 배경)
  final String? croppedImagePath;

  final ClothingCategory category;
  final String? name;
  final List<String> colors;
  final List<ClothingSeason> seasons;
  final List<OutfitOccasion> occasions;
  final List<String> tags;
  final DateTime addedAt;

  /// 실제 표시에 사용할 이미지 경로 (크롭된 이미지 우선)
  String get displayImagePath => croppedImagePath ?? originalImagePath;

  ClothingItem copyWith({
    String? croppedImagePath,
    String? name,
    List<String>? colors,
    List<ClothingSeason>? seasons,
    List<OutfitOccasion>? occasions,
    List<String>? tags,
  }) {
    return ClothingItem(
      id: id,
      originalImagePath: originalImagePath,
      croppedImagePath: croppedImagePath ?? this.croppedImagePath,
      category: category,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      tags: tags ?? this.tags,
      addedAt: addedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalImagePath': originalImagePath,
        'croppedImagePath': croppedImagePath,
        'category': category.name,
        'name': name,
        'colors': colors,
        'seasons': seasons.map((s) => s.name).toList(),
        'occasions': occasions.map((o) => o.name).toList(),
        'tags': tags,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      originalImagePath: json['originalImagePath'] as String,
      croppedImagePath: json['croppedImagePath'] as String?,
      category: ClothingCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ClothingCategory.top,
      ),
      name: json['name'] as String?,
      colors: List<String>.from(json['colors'] as List? ?? []),
      seasons: (json['seasons'] as List? ?? ['all'])
          .map((s) => ClothingSeason.values.firstWhere(
                (cs) => cs.name == s,
                orElse: () => ClothingSeason.all,
              ))
          .toList(),
      occasions: (json['occasions'] as List? ?? [])
          .map((o) => OutfitOccasion.values.firstWhere(
                (oo) => oo.name == o,
                orElse: () => OutfitOccasion.casual,
              ))
          .toList(),
      tags: List<String>.from(json['tags'] as List? ?? []),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
