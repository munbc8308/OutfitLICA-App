enum ClothingCategory {
  top,          // 상의 (티셔츠, 셔츠, 블라우스 등)
  bottom,       // 하의 (바지, 치마, 반바지 등)
  outer,        // 아우터 (코트, 자켓, 패딩 등)
  shoes,        // 신발
  bag,          // 가방
  accessories;  // 악세사리 (모자, 스카프, 벨트 등)

  String get label {
    switch (this) {
      case ClothingCategory.top:
        return '상의';
      case ClothingCategory.bottom:
        return '하의';
      case ClothingCategory.outer:
        return '아우터';
      case ClothingCategory.shoes:
        return '신발';
      case ClothingCategory.bag:
        return '가방';
      case ClothingCategory.accessories:
        return '악세사리';
    }
  }

  String get emoji {
    switch (this) {
      case ClothingCategory.top:
        return '👕';
      case ClothingCategory.bottom:
        return '👖';
      case ClothingCategory.outer:
        return '🧥';
      case ClothingCategory.shoes:
        return '👟';
      case ClothingCategory.bag:
        return '👜';
      case ClothingCategory.accessories:
        return '💍';
    }
  }
}

enum ClothingSeason { spring, summer, fall, winter, all }

extension ClothingSeasonLabel on ClothingSeason {
  String get label {
    switch (this) {
      case ClothingSeason.spring:
        return '봄';
      case ClothingSeason.summer:
        return '여름';
      case ClothingSeason.fall:
        return '가을';
      case ClothingSeason.winter:
        return '겨울';
      case ClothingSeason.all:
        return '사계절';
    }
  }
}

enum OutfitOccasion { casual, work, date, sport, formal }

extension OutfitOccasionLabel on OutfitOccasion {
  String get label {
    switch (this) {
      case OutfitOccasion.casual:
        return '캐주얼';
      case OutfitOccasion.work:
        return '출근';
      case OutfitOccasion.date:
        return '데이트';
      case OutfitOccasion.sport:
        return '운동';
      case OutfitOccasion.formal:
        return '포멀';
    }
  }

  String get emoji {
    switch (this) {
      case OutfitOccasion.casual:
        return '😊';
      case OutfitOccasion.work:
        return '💼';
      case OutfitOccasion.date:
        return '💕';
      case OutfitOccasion.sport:
        return '🏃';
      case OutfitOccasion.formal:
        return '🎩';
    }
  }
}
