import 'package:dio/dio.dart';
import 'package:untitled7/core/error/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;

  ServerException({required this.errorModel});
}

void handelDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          statusMsg: 504,
          errorMessage: "Connection Timeout",
        ),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        errorModel: ErrorModel(statusMsg: 504, errorMessage: "Send Timeout"),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        errorModel: ErrorModel(statusMsg: 504, errorMessage: "Receive Timeout"),
      );
    case DioExceptionType.badCertificate:
      throw ServerException(
        errorModel: ErrorModel(statusMsg: 400, errorMessage: "Bad Certificate"),
      );
    case DioExceptionType.cancel:
      throw ServerException(
        errorModel: ErrorModel(
          statusMsg: 400,
          errorMessage: "Request Cancelled",
        ),
      );
    case DioExceptionType.connectionError:
      throw ServerException(
        errorModel: ErrorModel(
          statusMsg: 503,
          errorMessage: "Connection Error",
        ),
      );
    case DioExceptionType.unknown:
      throw ServerException(
        errorModel: ErrorModel(statusMsg: 500, errorMessage: "Unknown Error"),
      );
    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );

        case 401:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );

        case 403:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );

        case 409:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );

        case 422:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );

        case 504:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        default:
          throw ServerException(
            errorModel: ErrorModel(
              statusMsg: e.response?.statusCode ?? 500,
              errorMessage: "Unexpected Error, please try again",
            ),
          );
      }
  }
}
