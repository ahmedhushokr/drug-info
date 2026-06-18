import 'package:untitled7/core/api/end_point.dart';

class SignUpModel {
  final dynamic user;
  final String token;

  SignUpModel({required this.user, required this.token});

  factory SignUpModel.fromJson(Map<String, dynamic> jsonData) {
    return SignUpModel(
      user: jsonData[ApiKey.user],
      token: jsonData[ApiKey.token],
    );
  }
}
