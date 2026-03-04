import '../../wardrobe/domain/clothing_category.dart';

class OutfitCombo {
  OutfitCombo({
    required this.id,
    required this.clothingItemIds,
    required this.createdAt,
    this.name,
    this.occasions = const [],
    this.savedImagePath,
    this.weatherCondition,
  });

  final String id;

  /// category -> clothingItemId 매핑
  final Map<String, String> clothingItemIds;

  final String? name;
  final List<OutfitOccasion> occasions;
  final DateTime createdAt;

  /// 합성된 코디 이미지 저장 경로
  final String? savedImagePath;

  final String? weatherCondition;

  OutfitCombo copyWith({
    String? name,
    List<OutfitOccasion>? occasions,
    String? savedImagePath,
  }) {
    return OutfitCombo(
      id: id,
      clothingItemIds: clothingItemIds,
      name: name ?? this.name,
      occasions: occasions ?? this.occasions,
      createdAt: createdAt,
      savedImagePath: savedImagePath ?? this.savedImagePath,
      weatherCondition: weatherCondition,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clothingItemIds': clothingItemIds,
        'name': name,
        'occasions': occasions.map((o) => o.name).toList(),
        'createdAt': createdAt.toIso8601String(),
        'savedImagePath': savedImagePath,
        'weatherCondition': weatherCondition,
      };

  factory OutfitCombo.fromJson(Map<String, dynamic> json) {
    return OutfitCombo(
      id: json['id'] as String,
      clothingItemIds: Map<String, String>.from(
          json['clothingItemIds'] as Map? ?? {}),
      name: json['name'] as String?,
      occasions: (json['occasions'] as List? ?? [])
          .map((o) => OutfitOccasion.values.firstWhere(
                (oo) => oo.name == o,
                orElse: () => OutfitOccasion.casual,
              ))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      savedImagePath: json['savedImagePath'] as String?,
      weatherCondition: json['weatherCondition'] as String?,
    );
  }
}
