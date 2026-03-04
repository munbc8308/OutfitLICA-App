import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'camera_provider.dart';
import '../../../shared/widgets/app_button.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 촬영'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: cameraState.selectedImage != null
                    ? _ImagePreview(
                        imagePath: cameraState.selectedImage!.path,
                        onClear: notifier.clearImage,
                      )
                    : _PickerPlaceholder(
                        isLoading: cameraState.isLoading,
                        onCamera: () => notifier.pickImage(CameraSource.camera),
                        onGallery: () =>
                            notifier.pickImage(CameraSource.gallery),
                      ),
              ),
              if (cameraState.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    cameraState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              if (cameraState.selectedImage != null)
                AppButton(
                  label: 'AI 코디 분석하기',
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    context.push(
                      '/result',
                      extra: cameraState.selectedImage!.path,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath, required this.onClear});
  final String imagePath;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(imagePath, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, size: 64)))),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
            onPressed: onClear,
          ),
        ),
      ],
    );
  }
}

class _PickerPlaceholder extends StatelessWidget {
  const _PickerPlaceholder({
    required this.isLoading,
    required this.onCamera,
    required this.onGallery,
  });
  final bool isLoading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('코디 사진을 선택하세요',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionChip(
                icon: Icons.camera_alt,
                label: '카메라',
                onTap: onCamera,
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.photo_library,
                label: '갤러리',
                onTap: onGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
