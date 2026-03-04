import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../database/local_database.dart';

/// remove.bg API를 사용하여 이미지 배경을 제거합니다.
/// API 키가 없으면 원본 이미지를 그대로 반환합니다.
class BackgroundRemovalService {
  BackgroundRemovalService._();
  static final BackgroundRemovalService instance = BackgroundRemovalService._();

  static const _apiUrl = 'https://api.remove.bg/v1.0/removebg';

  /// [imageFile] 원본 이미지 파일
  /// [itemId] 저장할 아이템 ID (파일명으로 사용)
  /// 배경이 제거된 PNG 파일 경로 반환
  Future<String?> removeBackground(File imageFile, String itemId) async {
    final apiKey = AppConstants.removeBgApiKey;

    // API 키가 없으면 원본 그대로 사용
    if (apiKey.isEmpty || apiKey == 'your_remove_bg_api_key') {
      return _copyToClothingImages(imageFile, itemId);
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..headers['X-Api-Key'] = apiKey
        ..fields['size'] = 'auto'
        ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        return _savePng(bytes, itemId);
      }
    } catch (_) {
      // 네트워크 오류 시 원본 사용
    }

    return _copyToClothingImages(imageFile, itemId);
  }

  Future<String> _savePng(Uint8List bytes, String itemId) async {
    final dir = await LocalDatabase.instance.clothingImagesDir;
    final file = File('${dir.path}/$itemId.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> _copyToClothingImages(File source, String itemId) async {
    final dir = await LocalDatabase.instance.clothingImagesDir;
    final ext = source.path.split('.').last;
    final dest = File('${dir.path}/$itemId.$ext');
    await source.copy(dest.path);
    return dest.path;
  }
}
