import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/clothing_category.dart';
import 'wardrobe_provider.dart';
import '../../../shared/widgets/app_button.dart';

class AddClothingScreen extends ConsumerStatefulWidget {
  const AddClothingScreen({super.key});

  @override
  ConsumerState<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends ConsumerState<AddClothingScreen> {
  File? _selectedImage;
  ClothingCategory _category = ClothingCategory.top;
  ClothingSeason _season = ClothingSeason.all;
  final _nameController = TextEditingController();
  bool _isProcessing = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);
    final item = await ref.read(wardrobeProvider.notifier).addItem(
          imageFile: _selectedImage!,
          category: _category,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          seasons: [_season],
        );
    setState(() => _isProcessing = false);

    if (item != null && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('옷 추가')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 선택 영역
            _ImagePickerArea(
              image: _selectedImage,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onClear: () => setState(() => _selectedImage = null),
            ),
            const SizedBox(height: 24),

            // 카테고리 선택
            const Text('카테고리',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _CategorySelector(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 24),

            // 시즌 선택
            const Text('시즌',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _SeasonSelector(
              selected: _season,
              onChanged: (s) => setState(() => _season = s),
            ),
            const SizedBox(height: 24),

            // 이름 입력 (선택)
            const Text('이름 (선택)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '예: 흰색 면 티셔츠',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('배경 제거 중...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            AppButton(
              label: '옷장에 추가',
              icon: Icons.add,
              isLoading: _isProcessing,
              onPressed: _selectedImage != null ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 서브 위젯들 ──────────────────────────────────────────────────────────────

class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({
    required this.image,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });
  final File? image;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(image!,
                width: double.infinity, height: 280, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.black54,
                  foregroundColor: Colors.white),
              onPressed: onClear,
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PickButton(icon: Icons.camera_alt, label: '카메라', onTap: onCamera),
          const SizedBox(width: 24),
          _PickButton(icon: Icons.photo_library, label: '갤러리', onTap: onGallery),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  const _PickButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector(
      {required this.selected, required this.onChanged});
  final ClothingCategory selected;
  final ValueChanged<ClothingCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ClothingCategory.values.map((c) {
        final isSelected = c == selected;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.emoji),
                const SizedBox(width: 6),
                Text(
                  c.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector(
      {required this.selected, required this.onChanged});
  final ClothingSeason selected;
  final ValueChanged<ClothingSeason> onChanged;

  static const _seasons = [
    (ClothingSeason.all, '사계절', '🌈'),
    (ClothingSeason.spring, '봄', '🌸'),
    (ClothingSeason.summer, '여름', '☀️'),
    (ClothingSeason.fall, '가을', '🍂'),
    (ClothingSeason.winter, '겨울', '❄️'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _seasons.map((s) {
        final (season, label, emoji) = s;
        final isSelected = season == selected;
        return GestureDetector(
          onTap: () => onChanged(season),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
