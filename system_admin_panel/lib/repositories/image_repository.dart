import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ImageRepository {
  final Dio _dio;

  ImageRepository(this._dio);

  Future<Map<String, String>> uploadImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _dio.post(ApiConfig.images, data: formData);
    final data = response.data['data'] ?? response.data;

    return {
      'url': data['url'] ?? data['data']['url'] ?? '',
      'delete_url': data['delete_url'] ?? data['data']['delete_url'] ?? '',
    };
  }
}
