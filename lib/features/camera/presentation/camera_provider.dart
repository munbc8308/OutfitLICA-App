import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum CameraSource { camera, gallery }

class CameraState {
  const CameraState({this.selectedImage, this.isLoading = false, this.error});
  final File? selectedImage;
  final bool isLoading;
  final String? error;

  CameraState copyWith({
    File? selectedImage,
    bool? isLoading,
    String? error,
  }) =>
      CameraState(
        selectedImage: selectedImage ?? this.selectedImage,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(const CameraState());

  final _picker = ImagePicker();

  Future<void> pickImage(CameraSource source) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final picked = await _picker.pickImage(
        source: source == CameraSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        state = state.copyWith(
          selectedImage: File(picked.path),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearImage() => state = const CameraState();
}

final cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});
