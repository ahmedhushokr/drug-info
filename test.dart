import 'dart:io';
import 'package:dio/dio.dart';

Future<void> uploadImage(File imageFile, String token) async {
  final dio = Dio();

  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
    ),
  });

  final response = await dio.post(
    'http://46.101.108.29:8000/api/uploads/ocr-search/',
    data: formData,
    options: Options(
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc4Mzc4MDExLCJpYXQiOjE3NzgzNzQ0MTEsImp0aSI6IjU3NGQyOTczNjA4MzRhOTk5ZGNhZWE3MDY5ZjNmYTliIiwidXNlcl9pZCI6IjE3In0.Iy2GrVGAVcWgUYUeP-Buva9aE8n_37fQI4Oy0zzKL28',
      },
    ),
  );

  print(response.data);
}
