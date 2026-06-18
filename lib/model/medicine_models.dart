// موديل الدواء الفردي داخل القائمة
class MatchedItemModel {
  final String name;
  final double score;

  MatchedItemModel({required this.name, required this.score});

  factory MatchedItemModel.fromJson(Map<String, dynamic> json) {
    return MatchedItemModel(
      // السيرفر يرسل الاسم في حقل 'name'
      name: json['name'] ?? 'Unknown',
      // السيرفر يرسل النتيجة في حقل 'score'
      score: (json['score'] as num).toDouble(),
    );
  }
}

// موديل الرد الكامل من عملية الـ OCR
class OCRResponseModel {
  final double ocrConfidence;
  final List<MatchedItemModel> matchedItems;
  final String actionHint;
  final String message;

  OCRResponseModel({
    required this.ocrConfidence,
    required this.matchedItems,
    required this.actionHint,
    required this.message,
  });

  factory OCRResponseModel.fromJson(Map<String, dynamic> json) {
    return OCRResponseModel(
      ocrConfidence: (json['ocr_confidence'] as num).toDouble(),
      actionHint: json['action_hint'] ?? 'show_results',
      message: json['message'] ?? '',
      matchedItems: (json['matched_items'] as List)
          .map((item) => MatchedItemModel.fromJson(item))
          .toList(),
    );
  }
}
