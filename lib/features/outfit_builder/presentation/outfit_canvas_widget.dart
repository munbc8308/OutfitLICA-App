import 'dart:io';
import 'package:flutter/material.dart';
import '../../wardrobe/domain/clothing_item.dart';
import '../../wardrobe/domain/clothing_category.dart';

/// 선택된 옷들을 실제 착장 순서에 맞게 레이어드하여 보여주는 캔버스
///
/// 레이아웃 (캔버스 400 × 600):
/// ┌────────────────────┐
/// │  [accessories] 상단│
/// │  [outer]           │
/// │  [top]    [bag]    │
/// │  [bottom]          │
/// │  [shoes]           │
/// └────────────────────┘
class OutfitCanvasWidget extends StatelessWidget {
  const OutfitCanvasWidget({
    super.key,
    required this.selectedItems,
    this.canvasKey,
    this.backgroundColor,
    this.showPlaceholder = true,
  });

  final Map<ClothingCategory, ClothingItem> selectedItems;
  final GlobalKey? canvasKey;
  final Color? backgroundColor;
  final bool showPlaceholder;

  // 각 카테고리의 레이아웃 설정 (left%, top%, width%, height%)
  static const _layouts = {
    ClothingCategory.outer: _ItemLayout(
        left: 0.08, top: 0.08, width: 0.70, height: 0.52, zIndex: 1),
    ClothingCategory.top: _ItemLayout(
        left: 0.12, top: 0.12, width: 0.62, height: 0.46, zIndex: 2),
    ClothingCategory.bottom: _ItemLayout(
        left: 0.12, top: 0.46, width: 0.62, height: 0.47, zIndex: 3),
    ClothingCategory.shoes: _ItemLayout(
        left: 0.18, top: 0.82, width: 0.50, height: 0.16, zIndex: 4),
    ClothingCategory.bag: _ItemLayout(
        left: 0.65, top: 0.38, width: 0.28, height: 0.32, zIndex: 2),
    ClothingCategory.accessories: _ItemLayout(
        left: 0.05, top: 0.03, width: 0.25, height: 0.14, zIndex: 5),
  };

  @override
  Widget build(BuildContext context) {
    final canvas = RepaintBoundary(
      key: canvasKey,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 배경 패턴 (아이템 없을 때)
                if (selectedItems.isEmpty && showPlaceholder)
                  _EmptyCanvasPlaceholder(),

                // z-order 정렬 후 렌더링
                ..._buildLayeredItems(w, h),
              ],
            );
          },
        ),
      ),
    );

    return AspectRatio(aspectRatio: 400 / 600, child: canvas);
  }

  List<Widget> _buildLayeredItems(double w, double h) {
    // zIndex 오름차순 정렬
    final entries = _layouts.entries.toList()
      ..sort((a, b) => a.value.zIndex.compareTo(b.value.zIndex));

    return entries.map((entry) {
      final category = entry.key;
      final layout = entry.value;
      final item = selectedItems[category];

      if (item == null) {
        // 플레이스홀더 (회색 도형)
        if (!showPlaceholder) return const SizedBox.shrink();
        return Positioned(
          left: layout.left * w,
          top: layout.top * h,
          width: layout.width * w,
          height: layout.height * h,
          child: _CategoryPlaceholder(category: category),
        );
      }

      return Positioned(
        left: layout.left * w,
        top: layout.top * h,
        width: layout.width * w,
        height: layout.height * h,
        child: _ClothingLayer(item: item),
      );
    }).toList();
  }
}

class _ItemLayout {
  const _ItemLayout({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.zIndex,
  });
  final double left;
  final double top;
  final double width;
  final double height;
  final int zIndex;
}

// ── 레이어 위젯 ──────────────────────────────────────────────────────────────

class _ClothingLayer extends StatelessWidget {
  const _ClothingLayer({required this.item});
  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(item.displayImagePath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => _CategoryPlaceholder(category: item.category),
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder({required this.category});
  final ClothingCategory category;

  static const _placeholderColors = {
    ClothingCategory.top: Color(0xFFD4E6F1),
    ClothingCategory.bottom: Color(0xFFD5E8D4),
    ClothingCategory.outer: Color(0xFFF8CECC),
    ClothingCategory.shoes: Color(0xFFFFE6CC),
    ClothingCategory.bag: Color(0xFFE1D5E7),
    ClothingCategory.accessories: Color(0xFFFFF2CC),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _placeholderColors[category]?.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _placeholderColors[category] ?? Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              category.label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCanvasPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            '아래에서 옷을 선택해\n코디를 완성해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
