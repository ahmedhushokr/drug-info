import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled7/core/api/end_point.dart'; // تأكد من استيراد الـ EndPoint الصحيح
import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  GlobalKey<FormState> searchFormKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  final Dio _dio = Dio();
  List<dynamic> historyEntries = [];
  bool isHistoryLoading = false;
  String historyError = '';

  Future<void> searchMedicineByName(String token) async {
    if (searchController.text.isEmpty) return;
    try {
      emit(HomeSearchLoading());

      final response = await _dio.get(
        '${EndPoint.baseUrl}/api/medicines/', // استخدام الـ baseUrl الموحد
        queryParameters: {'search': searchController.text.trim()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      List<dynamic> results = [];

      // بناءً على الـ Paginated Envelope (StandardPagination) الـ response عبارة عن Map دائمًا
      if (response.data is Map) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        results =
            data['results'] ?? []; // الـ DTO يحدد الكلمة بـ results دائمًا
      }

      if (results.isEmpty) {
        emit(HomeSearchFailure("عذراً، لم يتم العثور على دواء بهذا الاسم"));
      } else {
        emit(HomeSearchSuccess(results));
      }
    } on DioException catch (e) {
      // الـ Auth والـ Medicinesendpoints بترجع الخطأ في 'detail' عادةً
      final errorMessage =
          e.response?.data['detail'] ??
          e.message ??
          "حدث خطأ في الاتصال بالسيرفر";
      emit(HomeSearchFailure(errorMessage.toString()));
    } catch (e) {
      emit(HomeSearchFailure("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }

  Future<void> uploadImageOCR(String token) async {
    if (pickedFile == null) return;

    try {
      emit(HomeImageUploadLoading());

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          pickedFile!.path,
          filename: pickedFile!.name,
        ),
      });

      final response = await _dio.post(
        '${EndPoint.baseUrl}${EndPoint.ocr}',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      emit(HomeImageUploadSuccess(response.data));
    } on DioException catch (e) {
      debugPrint("OCR Error: ${e.response?.data}");

      final errorMessage =
          e.response?.data['error'] ??
          e.response?.data['detail'] ??
          "فشل في تحليل الصورة";

      emit(HomeImageUploadFailure(errorMessage));
    } catch (e) {
      emit(HomeImageUploadFailure("حدث خطأ غير متوقع"));
    }
  }

  Future<void> fetchMedicineHistory(String token) async {
    if (token.isEmpty) {
      historyEntries = [];
      historyError = 'رمز المستخدم غير متوفر';
      emit(HomeHistoryFailure(historyError));
      return;
    }

    try {
      debugPrint('Fetching medicine history with token: $token');
      isHistoryLoading = true;
      emit(HomeHistoryLoading());

      final response = await _dio.get(
        '${EndPoint.baseUrl}/api/medicine-history/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('History response status: ${response.statusCode}');
      debugPrint('History response data: ${response.data}');

      if (response.data is List) {
        historyEntries = response.data as List<dynamic>;
      } else if (response.data is Map) {
        historyEntries = response.data['results'] ?? [];
      } else {
        historyEntries = [];
      }

      historyError = '';
      isHistoryLoading = false;
      emit(HomeHistorySuccess(historyEntries));
    } on DioException catch (e) {
      historyEntries = [];
      historyError =
          e.response?.data['detail']?.toString() ??
          e.message ??
          'فشل في جلب سجل الأدوية';
      isHistoryLoading = false;
      emit(HomeHistoryFailure(historyError));
    } catch (e) {
      historyEntries = [];
      historyError = 'حدث خطأ غير متوقع في جلب السجل';
      isHistoryLoading = false;
      emit(HomeHistoryFailure(historyError));
    }
  }

  Future<void> saveMedicineHistoryEntry(
    String token,
    String medicineName, {
    String status = 'current',
    String dose = '',
    String? startDate,
    String? endDate,
    String notes = '',
  }) async {
    if (token.isEmpty || medicineName.trim().isEmpty) return;

    final String start =
        startDate ?? DateTime.now().toIso8601String().split('T').first;

    try {
      await _dio.post(
        '${EndPoint.baseUrl}/api/medicine-history/',
        data: {
          'medicine_name': medicineName.trim(),
          'status': status,
          'dose': dose,
          'start_date': start,
          'end_date': endDate,
          'notes': notes,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      debugPrint('Failed to save medicine history entry: $e');
    }
  }

  String _historyListToXml(List<dynamic> history) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<MedicineHistory>');
    for (var item in history) {
      if (item is Map<String, dynamic>) {
        buffer.writeln('  <Entry>');
        buffer.writeln(
          '    <Id>${_xmlEscape(item['id']?.toString() ?? '')}</Id>',
        );
        buffer.writeln(
          '    <MedicineName>${_xmlEscape(item['medicine_name']?.toString() ?? '')}</MedicineName>',
        );
        buffer.writeln(
          '    <Status>${_xmlEscape(item['status']?.toString() ?? '')}</Status>',
        );
        buffer.writeln(
          '    <Dose>${_xmlEscape(item['dose']?.toString() ?? '')}</Dose>',
        );
        buffer.writeln(
          '    <StartDate>${_xmlEscape(item['start_date']?.toString() ?? '')}</StartDate>',
        );
        buffer.writeln(
          '    <EndDate>${_xmlEscape(item['end_date']?.toString() ?? '')}</EndDate>',
        );
        buffer.writeln(
          '    <Notes>${_xmlEscape(item['notes']?.toString() ?? '')}</Notes>',
        );
        buffer.writeln('  </Entry>');
      }
    }
    buffer.writeln('</MedicineHistory>');
    return buffer.toString();
  }

  String _xmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  Future<void> exportMedicineHistory(String token, String format) async {
    if (token.isEmpty) {
      emit(HomeExportFileFailure('رمز المستخدم غير متوفر'));
      return;
    }

    try {
      emit(HomeExportFileLoading());
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedFormat = format.toLowerCase();
      final filePath =
          '${directory.path}/medicine_history_$timestamp.$sanitizedFormat';

      if (sanitizedFormat == 'xml') {
        final response = await _dio.get(
          '${EndPoint.baseUrl}/api/integrations/medicine-history/export.xml',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            responseType: ResponseType.plain,
          ),
        );

        String xmlText;
        if (response.data is String) {
          xmlText = response.data as String;
        } else {
          final historyData = response.data is List
              ? response.data as List<dynamic>
              : response.data is Map
              ? response.data['results'] ?? []
              : [];
          xmlText = _historyListToXml(historyData);
        }

        await File(
          filePath,
        ).writeAsString(xmlText, flush: true, encoding: utf8);
      } else {
        final response = await _dio.get(
          '${EndPoint.baseUrl}/api/medicine-history/',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        final historyData = response.data is List
            ? response.data as List<dynamic>
            : response.data is Map
            ? response.data['results'] ?? []
            : [];

        final jsonText = const JsonEncoder.withIndent(
          '  ',
        ).convert(historyData);
        await File(
          filePath,
        ).writeAsString(jsonText, flush: true, encoding: utf8);
      }

      emit(HomeExportFileSuccess(filePath, sanitizedFormat));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail']?.toString() ??
          e.message ??
          'فشل في تصدير السجل';
      emit(HomeExportFileFailure(errorMessage));
    } catch (e) {
      emit(HomeExportFileFailure('حدث خطأ غير متوقع أثناء التصدير'));
    }
  }

  Future<void> pickerImage(ImageSource source) async {
    try {
      pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        emit(HomeImagePicked(File(pickedFile!.path)));
      }
    } catch (e) {
      emit(HomeInitial());
    }
  }

  void clearImageData() {
    pickedFile = null;
    searchController.clear();
    emit(HomeInitial());
  }

  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source", textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickerImage(ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickerImage(ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }
}
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   HomeCubit() : super(HomeInitial());

//   final ImagePicker _picker = ImagePicker();
//   XFile? pickedFile;

//   Future<void> uploadImage(File imageFile, String token) async {
//     final dio = Dio();
//      final formData = FormData.fromMap({
//       'image': await MultipartFile.fromFile(
//         imageFile.,
//         filename: imageFile.path.split('/').last,
//       ),
//     });

//     final response = await dio.post(
//       'http://46.101.108.29:8000/api/uploads/ocr-search/',
//       data: formData,
//       options: Options(
//         headers: {
//           'Authorization':
//               'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc4Mzc4MDExLCJpYXQiOjE3NzgzNzQ0MTEsImp0aSI6IjU3NGQyOTczNjA4MzRhOTk5ZGNhZWE3MDY5ZjNmYTliIiwidXNlcl9pZCI6IjE3In0.Iy2GrVGAVcWgUYUeP-Buva9aE8n_37fQI4Oy0zzKL28',
//         },
//       ),
//     );

//     print(response.data);
//   }

//   Future<void> pickerImage(ImageSource source) async {
//     try {
//       pickedFile = await _picker.pickImage(source: source);

//       if (pickedFile != null) {
//         emit(HomeImagePicked(File(pickedFile!.path)));
//       }
//     } catch (e) {
//       emit(HomeInitial());
//     }
//   }

//   void showImageSourceDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             "Select Image Source",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickerImage(ImageSource.camera);
//               },
//               child: Text("Camera"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 pickerImage(ImageSource.gallery);
//               },
//               child: Text("Gallery"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   sendPictureMedicion() {}
// }
