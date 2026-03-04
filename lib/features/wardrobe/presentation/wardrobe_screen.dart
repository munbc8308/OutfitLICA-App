import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/clothing_category.dart';
import 'wardrobe_provider.dart';
import '../../../shared/widgets/clothing_card.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wardrobeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 옷장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await context.push<bool>('/wardrobe/add');
              if (added == true) {
                ref.read(wardrobeProvider.notifier).loadItems();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터
          _CategoryFilter(
            selected: state.selectedCategory,
            onChanged: (c) =>
                ref.read(wardrobeProvider.notifier).filterByCategory(c),
          ),

          // 아이템 그리드
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredItems.isEmpty
                    ? _EmptyView(
                        onAdd: () async {
                          final added =
                              await context.push<bool>('/wardrobe/add');
                          if (added == true) {
                            ref
                                .read(wardrobeProvider.notifier)
                                .loadItems();
                          }
                        },
                      )
                    : _ClothingGrid(
                        items: state.filteredItems,
                        onDelete: (id) =>
                            ref.read(wardrobeProvider.notifier).deleteItem(id),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── 카테고리 필터 탭 ─────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});
  final ClothingCategory? selected;
  final ValueChanged<ClothingCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 전체 탭
          _FilterChip(
            label: '전체',
            emoji: '👗',
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          ...ClothingCategory.values.map(
            (c) => _FilterChip(
              label: c.label,
              emoji: c.emoji,
              isSelected: selected == c,
              onTap: () => onChanged(selected == c ? null : c),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 그리드 ───────────────────────────────────────────────────────────────────

class _ClothingGrid extends StatelessWidget {
  const _ClothingGrid({required this.items, required this.onDelete});
  final List items;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return ClothingCard(
          item: item,
          showCategory: true,
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => _ItemActions(
                itemName: item.name ?? item.category.label,
                onDelete: () {
                  Navigator.pop(context);
                  onDelete(item.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ItemActions extends StatelessWidget {
  const _ItemActions({required this.itemName, required this.onDelete});
  final String itemName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(itemName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 빈 화면 ──────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.checkroom, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('옷장이 비어있어요',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('카메라로 옷을 찍어 추가해보세요',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('첫 번째 옷 추가'),
          ),
        ],
      ),
    );
  }
}
