import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../domain/outfit_model.dart';

class OutfitRepository {
  Future<OutfitAnalysis> analyzeOutfit(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('${AppConstants.aiApiBaseUrl}/analyze'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.aiApiKey}',
      },
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      return OutfitAnalysis.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('분석 실패: ${response.statusCode}');
  }
}

final outfitRepositoryInstance = OutfitRepository();
