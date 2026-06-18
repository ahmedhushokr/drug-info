import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/api/end_point.dart';
import 'package:untitled7/core/cache/cashe_helper.dart';
import 'package:untitled7/core/color/app_colors.dart';
import 'package:untitled7/core/validators/validators.dart';
import 'package:untitled7/features/home/presentation/view/screens/data_output_screen.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_elevated_button.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_text_field.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_cubit.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled7/features/splash/presentation/view/widget/splash_widget_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) async {
        // --- منطق البحث والنتائج (لم يتم لمسه) ---
        if (state is HomeSearchSuccess) {
          final cubit = context.read<HomeCubit>();
          final lastQuery = cubit.searchController.text.trim();
          String? token = CacheHelper().getData(key: ApiKey.token);
          if (token != null && lastQuery.isNotEmpty) {
            await cubit.saveMedicineHistoryEntry(token, lastQuery);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MedicineResultsScreen(results: state.results),
            ),
          ).then((_) {
            final cubit = context.read<HomeCubit>();
            cubit.clearImageData();
            _pollForHistory(context, token ?? "", lastQuery);
          });
        } else if (state is HomeImageUploadSuccess) {
          List<dynamic> finalResults = [];
          if (state.data is Map && state.data['matched_items'] != null) {
            finalResults = state.data['matched_items'];
          } else if (state.data is List) {
            finalResults = state.data;
          }
          final cubit = context.read<HomeCubit>();
          String expectedName = '';
          if (finalResults.isNotEmpty && finalResults.first is Map) {
            expectedName =
                (finalResults.first['name'] ??
                        finalResults.first['trade_name'] ??
                        '')
                    .toString();
          }
          String? token = CacheHelper().getData(key: ApiKey.token);
          if (token != null && expectedName.isNotEmpty) {
            await cubit.saveMedicineHistoryEntry(token, expectedName);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MedicineResultsScreen(results: finalResults),
            ),
          ).then((_) {
            final cubit = context.read<HomeCubit>();
            cubit.clearImageData();
            _pollForHistory(context, token ?? "", expectedName);
          });
        } else if (state is HomeExportFileSuccess) {
          Share.shareFiles([
            state.filePath,
          ], text: 'Medication Record(${state.format.toUpperCase()})');
        } else if (state is HomeExportFileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
        // معالجة الأخطاء
        else if (state is HomeSearchFailure ||
            state is HomeImageUploadFailure) {
          String error = (state is HomeSearchFailure)
              ? state.error
              : (state as HomeImageUploadFailure).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool isLoading =
            state is HomeSearchLoading || state is HomeImageUploadLoading;

        return Stack(
          children: [
            Form(
              key: context.read<HomeCubit>().searchFormKey,
              child: Scaffold(
                backgroundColor: AppColors.primary,
                // تعديل 1: تم تغييرها هنا إلى endDrawer لتصبح القائمة جهة اليمين هندسياً
                endDrawer: _buildHistoryDrawer(context),
                appBar: _buildAppBar(context),
                body: _buildBody(context, state),
              ),
            ),

            if (isLoading)
              Container(
                color: Colors.white.withOpacity(0.85),
                width: double.infinity,
                height: double.infinity,
                child: const Center(child: SplashWidgetBody()),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pollForHistory(
    BuildContext context,
    String token,
    String expectedName, {
    int attempts = 5,
    int delayMs = 600,
  }) async {
    if (expectedName.isEmpty) return;
    final cubit = context.read<HomeCubit>();

    for (int i = 0; i < attempts; i++) {
      await cubit.fetchMedicineHistory(token);
      try {
        final found = cubit.historyEntries.any((entry) {
          if (entry == null || entry is! Map) return false;
          final item = entry as Map<String, dynamic>;
          final name =
              (item['medicine_name'] ??
                      (item['medicine_details'] is Map
                          ? item['medicine_details']['trade_name']
                          : null))
                  .toString()
                  .toLowerCase();
          return name.contains(expectedName.trim().toLowerCase());
        });

        if (found) return;
      } catch (_) {}

      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions:
          false, // منع الأيقونة التلقائية الزائدة يميناً ويساراً بشكل صحيح
      toolbarHeight: 200,
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 20,
          bottom: 30,
          right: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Hello, ',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
                      String? token = CacheHelper().getData(key: ApiKey.token);
                      context.read<HomeCubit>().fetchMedicineHistory(
                        token ?? "",
                      );
                      // تعديل 2: يفتح القائمة من جهة اليمين الآن بنجاح وبدون مشاكل
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.menu, size: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Find your medicine now ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: 'Search by name...',
              controller: context.read<HomeCubit>().searchController,
              validator: Validators.validatorName,
              onFieldSubmitted: (value) {
                if (context
                    .read<HomeCubit>()
                    .searchFormKey
                    .currentState!
                    .validate()) {
                  String? token = CacheHelper().getData(key: ApiKey.token);
                  context.read<HomeCubit>().searchMedicineByName(token ?? "");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final token = CacheHelper().getData(key: ApiKey.token) ?? "";
    if (cubit.historyEntries.isEmpty && !cubit.isHistoryLoading) {
      cubit.fetchMedicineHistory(token);
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Medication Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    ' Your Recent Search History',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeHistoryLoading &&
                      cubit.historyEntries.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HomeHistoryFailure &&
                      cubit.historyEntries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (cubit.historyEntries.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('لا يوجد سجلات حتى الآن'),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: cubit.historyEntries.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = cubit.historyEntries[index];
                      if (entry == null || entry is! Map) {
                        return const SizedBox.shrink();
                      }
                      final item = entry as Map<String, dynamic>;
                      final name =
                          item['medicine_name'] ??
                          (item['medicine_details'] is Map
                              ? item['medicine_details']['trade_name']
                              : 'اسم غير معروف');
                      final startDate = item['start_date'];
                      final endDate = item['end_date'];
                      final displayDate = (startDate ?? endDate ?? 'غير محدد')
                          .toString();

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(name.toString()),
                        subtitle: Text(
                          'Date: $displayDate',
                          style: const TextStyle(height: 1.4),
                        ),
                        trailing: const Icon(Icons.history),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      cubit.exportMedicineHistory(token, 'json');
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('حفظ JSON'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      cubit.exportMedicineHistory(token, 'xml');
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('حفظ XML'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  '  How to scan :',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                _buildImagePreview(state),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Try to fit the following in the camera frame :\n * Medication name (required)\n * Strength\n * Form (table, capsule etc.)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildStartButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(HomeState state) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: state is HomeImagePicked
                  ? Image.file(state.file, fit: BoxFit.cover)
                  : Image.asset('assets/image_home.png', fit: BoxFit.contain),
            ),
          ),
          if (state is HomeImageUploadLoading)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    var cubit = context.read<HomeCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: ElevatedButtonWidget(
        onPressed: () {
          if (cubit.pickedFile == null) {
            cubit.showImageSourceDialog(context);
          } else {
            String? token = CacheHelper().getData(key: ApiKey.token);
            cubit.uploadImageOCR(token ?? "");
          }
        },
        text: cubit.pickedFile == null ? 'Pick Image' : 'Start Scan',
        borderRadius: 25,
      ),
    );
  }
}
