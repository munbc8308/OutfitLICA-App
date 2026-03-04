import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class WeatherInfo {
  const WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.city,
    required this.icon,
  });

  final double temperature; // 섭씨
  final WeatherCondition condition;
  final String description;
  final String city;
  final String icon;

  String get conditionLabel {
    switch (condition) {
      case WeatherCondition.hot:
        return '더움';
      case WeatherCondition.warm:
        return '따뜻함';
      case WeatherCondition.cool:
        return '선선함';
      case WeatherCondition.cold:
        return '추움';
      case WeatherCondition.rainy:
        return '비';
      case WeatherCondition.snowy:
        return '눈';
    }
  }

  String get conditionEmoji {
    switch (condition) {
      case WeatherCondition.hot:
        return '☀️';
      case WeatherCondition.warm:
        return '🌤️';
      case WeatherCondition.cool:
        return '🌥️';
      case WeatherCondition.cold:
        return '🧊';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.snowy:
        return '❄️';
    }
  }
}

enum WeatherCondition { hot, warm, cool, cold, rainy, snowy }

class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  Future<WeatherInfo?> getCurrentWeather() async {
    try {
      final position = await _getLocation();
      if (position == null) return null;

      final apiKey = AppConstants.weatherApiKey;
      if (apiKey.isEmpty || apiKey == 'your_openweathermap_api_key') {
        // API 키 없을 때 기본값 반환
        return const WeatherInfo(
          temperature: 20,
          condition: WeatherCondition.warm,
          description: '맑음',
          city: '서울',
          icon: '01d',
        );
      }

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=${position.latitude}&lon=${position.longitude}'
        '&appid=$apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final temp = (json['main']['temp'] as num).toDouble();
      final weatherId = json['weather'][0]['id'] as int;
      final description = json['weather'][0]['description'] as String;
      final city = json['name'] as String;
      final icon = json['weather'][0]['icon'] as String;

      return WeatherInfo(
        temperature: temp,
        condition: _toCondition(temp, weatherId),
        description: description,
        city: city,
        icon: icon,
      );
    } catch (_) {
      return null;
    }
  }

  WeatherCondition _toCondition(double temp, int weatherId) {
    // 비/눈 판단
    if (weatherId >= 600 && weatherId < 700) return WeatherCondition.snowy;
    if (weatherId >= 300 && weatherId < 600) return WeatherCondition.rainy;

    // 온도 기반
    if (temp >= 28) return WeatherCondition.hot;
    if (temp >= 18) return WeatherCondition.warm;
    if (temp >= 8) return WeatherCondition.cool;
    return WeatherCondition.cold;
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (_) {
      return null;
    }
  }
}
