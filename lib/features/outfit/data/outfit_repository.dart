import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../domain/outfit_model.dart';

class OutfitRepository {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';

  Future<OutfitAnalysis> analyzeOutfit(File imageFile) async {
    final apiKey = AppConstants.aiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('AI_API_KEY가 설정되지 않았습니다.');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mediaType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 512,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mediaType,
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': '''이 코디 사진을 분석해서 아래 JSON 형식으로만 답해주세요. 설명 없이 JSON만 출력하세요.

{"style": "<스타일>", "score": <0-100 점수>, "tags": ["<태그1>", "<태그2>"], "recommendations": ["<추천1>", "<추천2>"], "colorPalette": ["<색상1>", "<색상2>"]}''',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final text = (body['content'] as List).first['text'] as String;
      final jsonMatch = RegExp(r'\{[\s\S]+\}').firstMatch(text);
      if (jsonMatch == null) throw Exception('응답 파싱 실패');
      return OutfitAnalysis.fromJson(
        jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>,
      );
    }
    throw Exception('분석 실패: ${response.statusCode}');
  }
}

final outfitRepositoryInstance = OutfitRepository();
