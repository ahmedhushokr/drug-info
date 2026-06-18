import 'package:untitled7/core/api/end_point.dart';

class ErrorModel {
  final int statusMsg;

  final String errorMessage;

  ErrorModel({required this.statusMsg, required this.errorMessage});

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    String? extractedMessage;

    // 1. البحث عن المفاتيح التقليدية
    if (jsonData.containsKey(ApiKey.errorMessage)) {
      extractedMessage = jsonData[ApiKey.errorMessage];
    } else if (jsonData.containsKey(ApiKey.message)) {
      extractedMessage = jsonData[ApiKey.message];
    } else {
      // 2. البحث عن أخطاء الحقول (مثل خطأ الإيميل أو اسم المستخدم في Django)
      final firstError = jsonData.values.firstWhere(
        (e) => e != null,
        orElse: () => null,
      );
      if (firstError is List && firstError.isNotEmpty) {
        extractedMessage = firstError.first.toString();
      } else if (firstError != null) {
        extractedMessage = firstError.toString();
      }
    }

    return ErrorModel(
      statusMsg: int.tryParse(jsonData[ApiKey.status].toString()) ?? 500,
      errorMessage: extractedMessage ?? 'An unknown error occurred',
    );
  }
}
