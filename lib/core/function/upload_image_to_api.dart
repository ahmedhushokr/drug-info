import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

Future uploadImageToApi(XFile image) {
  return MultipartFile.fromFile(
    image.path,
    filename: image.path.split("/").last,
  );
}

// دالة لمسح الصورة المختارة وإعادة الحالة للوضع الأصلي
