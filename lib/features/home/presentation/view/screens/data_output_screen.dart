import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled7/core/color/app_colors.dart';

class MedicineResultsScreen extends StatefulWidget {
  final List results;

  const MedicineResultsScreen({super.key, required this.results});

  @override
  State<MedicineResultsScreen> createState() => _MedicineResultsScreenState();
}

class _MedicineResultsScreenState extends State<MedicineResultsScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setLanguage('en-US');
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // إزالة التكرارات حسب الاسم التجاري أو الحقل name
    final List original = widget.results;
    final List<Map<String, dynamic>> uniqueResults = [];
    final Set<String> seen = {};
    for (var r in original) {
      if (r == null || r is! Map) continue;
      final Map<String, dynamic> m = r as Map<String, dynamic>;
      final name = (m['trade_name'] ?? m['name'] ?? '')
          .toString()
          .toLowerCase();
      if (name.isEmpty) continue;
      if (!seen.contains(name)) {
        seen.add(name);
        uniqueResults.add(m);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], // خلفية مريحة للعين
      appBar: AppBar(
        title: const Text(
          "نتائج تحليل الدواء",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: uniqueResults.isEmpty
          ? const Center(child: Text("لم يتم العثور على أدوية مطابقة"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: uniqueResults.length,
              itemBuilder: (context, index) {
                final medicine = uniqueResults[index];

                final Map<String, dynamic> medicineMap = medicine;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    maintainState: true,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.medication, color: Colors.white),
                    ),
                    title: Text(
                      medicineMap['trade_name'] ??
                          medicineMap['name'] ??
                          "اسم غير معروف",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      "المادة الفعالة: ${medicineMap['active_ingredient'] ?? 'غير متوفرة'}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // تفاصيل أساسية
                            _buildInfoRow(
                              "القوة والتركيز:",
                              medicineMap['strength'],
                              Icons.flash_on,
                            ),
                            _buildInfoRow(
                              "الشكل الدوائي:",
                              medicineMap['dosage_form'],
                              Icons.layers,
                            ),
                            _buildInfoRow(
                              "الفئة الدوائية:",
                              medicineMap['drug_class'],
                              Icons.category,
                            ),

                            const Divider(height: 25),

                            // تحذيرات وآثار (بألوان مميزة)
                            _buildInfoRow(
                              "الآثار الجانبية:",
                              medicineMap['common_side_effects'],
                              Icons.warning_amber_rounded,
                              textColor: Colors.orange[800],
                            ),
                            _buildInfoRow(
                              "تحذير خطير:",
                              medicineMap['serious_warning'],
                              Icons.report_gmailerrorred,
                              textColor: Colors.red[700],
                            ),
                            _buildInfoRow(
                              "التفاعلات الدوائية:",
                              medicineMap['interaction_notes'],
                              Icons.info_outline,
                            ),

                            const SizedBox(height: 15),

                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _speakMedicineName(medicineMap);
                                },
                                icon: const Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "نطق الاسم التجاري",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _buildScoreText(medicineMap),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _speakMedicineName(Map<String, dynamic> medicine) async {
    final text =
        medicine['trade_name'] ??
        medicine['name'] ??
        'Medicine name unavailable';

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(text.toString());
    } catch (e) {
      debugPrint('TTS speak error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TTS error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _buildScoreText(Map<String, dynamic> medicine) {
    try {
      final score = medicine['score'];
      if (score == null) return "دقة التطابق: غير متوفرة";

      if (score is num) {
        return "دقة التطابق: ${(score * 100).toStringAsFixed(1)}%";
      } else if (score is String) {
        final numScore = double.tryParse(score);
        if (numScore != null) {
          return "دقة التطابق: ${(numScore * 100).toStringAsFixed(1)}%";
        }
      }
      return "دقة التطابق: غير متوفرة";
    } catch (e) {
      return "دقة التطابق: غير متوفرة";
    }
  }

  // ودجت مساعدة لبناء الأسطر المعلوماتية بشكل منظم
  Widget _buildInfoRow(
    String title,
    dynamic value,
    IconData icon, {
    Color? textColor,
  }) {
    // فحص شامل للقيم الفارغة والـ null
    final displayValue = value ?? 'غير متوفرة';
    if (displayValue == null || displayValue.toString().trim().isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 26),
            child: Text(
              displayValue.toString().isEmpty
                  ? 'غير متوفرة'
                  : displayValue.toString(),
              style: TextStyle(
                fontSize: 14,
                color: textColor ?? Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
