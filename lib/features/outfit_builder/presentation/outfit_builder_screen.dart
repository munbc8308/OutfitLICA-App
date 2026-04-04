import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../wardrobe/domain/clothing_category.dart';
import '../../wardrobe/domain/clothing_item.dart';
import 'outfit_builder_provider.dart';
import 'outfit_canvas_widget.dart';
import '../../wardrobe/presentation/wardrobe_provider.dart';
import '../../../shared/widgets/clothing_card.dart';
import '../../../shared/widgets/app_button.dart';

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState
    extends ConsumerState<OutfitBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: ClothingCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveOutfit() async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('코디 저장'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: '코디 이름 (선택)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(outfitBuilderProvider.notifier).saveCurrentOutfit(
            name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('코디가 저장되었습니다!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outfitBuilderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 조합'),
        actions: [
          if (state.hasAnyItem)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(outfitBuilderProvider.notifier).clearAll(),
            ),
        ],
      ),
      body: Column(
        children: [
          // 코디 캔버스
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OutfitCanvasWidget(
                selectedItems: state.selected,
                canvasKey: _canvasKey,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 카테고리 탭
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: ClothingCategory.values.map((c) {
              final hasItem = state.selected.containsKey(c);
              return Tab(
                child: Row(
                  children: [
                    Text(c.emoji),
                    const SizedBox(width: 4),
                    Text(c.label),
                    if (hasItem) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle,
                          size: 14, color: Colors.green),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          // 옷 선택 패널
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: ClothingCategory.values.map((category) {
                return _CategoryItemPanel(
                  category: category,
                  selectedItem: state.selected[category],
                );
              }).toList(),
            ),
          ),

          // 저장 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              label: '이 코디 저장하기',
              icon: Icons.save_alt,
              isLoading: state.isLoading,
              onPressed: state.hasAnyItem ? _saveOutfit : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 카테고리별 아이템 선택 패널 ───────────────────────────────────────────────

class _CategoryItemPanel extends ConsumerWidget {
  const _CategoryItemPanel({
    required this.category,
    required this.selectedItem,
  });
  final ClothingCategory category;
  final ClothingItem? selectedItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(categoryItemsProvider(category));

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text('${category.label} 아이템이 없어요',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final added = await context.push<bool>('/wardrobe/add');
                if (added == true) {
                  ref.read(wardrobeProvider.notifier).loadItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('추가하기'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return ClothingCard(
          item: item,
          isSelected: selectedItem?.id == item.id,
          onTap: () =>
              ref.read(outfitBuilderProvider.notifier).selectItem(item),
        );
      },
    );
  }
}
