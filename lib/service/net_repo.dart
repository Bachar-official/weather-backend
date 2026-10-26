import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:weather_backend/constants/constants.dart';
import 'package:weather_backend/entity/entity.dart';

const defaultDuration = Duration(seconds: 60);

class NetRepo {
  late final Dio _dio;
  final Environment env;

  NetRepo({required this.env}) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: defaultDuration,
        receiveTimeout: defaultDuration,
        sendTimeout: defaultDuration,
      ),
    );
  }

  Future<List<Holiday>> getHolidays() async {
    final response = await _dio.get(Constants.holidaysUrl(env.locale));
    if (response.statusCode == 200) {
      final data = response.data['holidays'] as List<dynamic>;
      return data.map((el) => Holiday.fromJson(el)).toList();
    }
    throw Exception('code ${response.statusCode}');
  }

  Future<Weather> getWeather() async {
    final response = await _dio.get(Constants.weatherUrl(city: env.city, locale: env.locale, apiKey: env.weatherApiToken));
    if (response.statusCode == 200) {
      final map = response.data as Map<String, dynamic>;
      return Weather.fromMap(map, env: env);
    }
    throw Exception('code ${response.statusCode}');
  }

  Future<Geomagnetic> getGeomagnetic() async {
    final response = await _dio.get(Constants.noaaSwpcKIndex);
    if (response.statusCode == 200) {
      final list = response.data as List<dynamic>;
      return Geomagnetic.fromJson(list.last);
    }
    throw Exception('code ${response.statusCode}');
  }

  Future<Uint8List?> getCloudflareImage(String prompt) async {
    print(prompt);
    final response = await _dio.post(
      Constants.cloudflareAiUrl(env.cloudflareAccountId!),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${env.cloudflareToken}',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'prompt': prompt,
      },
    );    

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('code ${response.statusCode}');
    }

    final base64String = response.data['result']?['image'] as String?;
    if (base64String == null || base64String.isEmpty) {
      throw Exception('image is empty');
    }

    try {
      return base64Decode(base64String);
    } catch(e) {
      rethrow;
    }
  }
}