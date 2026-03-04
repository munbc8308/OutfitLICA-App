class OutfitAnalysis {
  const OutfitAnalysis({
    required this.id,
    required this.style,
    required this.score,
    required this.tags,
    required this.recommendations,
    required this.colorPalette,
  });

  final String id;
  final String style;
  final int score;
  final List<String> tags;
  final List<String> recommendations;
  final List<String> colorPalette;

  factory OutfitAnalysis.fromJson(Map<String, dynamic> json) {
    return OutfitAnalysis(
      id: json['id'] as String,
      style: json['style'] as String,
      score: json['score'] as int,
      tags: List<String>.from(json['tags'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      colorPalette: List<String>.from(json['color_palette'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'style': style,
        'score': score,
        'tags': tags,
        'recommendations': recommendations,
        'color_palette': colorPalette,
      };
}
