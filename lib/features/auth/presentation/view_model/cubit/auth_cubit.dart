import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/api/api_consumer.dart';
import 'package:untitled7/core/api/end_point.dart';
import 'package:untitled7/core/cache/cashe_helper.dart';
import 'package:untitled7/core/error/exception.dart';
import 'package:untitled7/features/auth/presentation/view_model/cubit/auth_state.dart';
import 'package:untitled7/model/sign_in_model.dart';
import 'package:untitled7/model/sign_up_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiConsumer api;
  AuthCubit(this.api) : super(AuthInitial());

  GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  TextEditingController signInEmail = TextEditingController();
  TextEditingController signInPassword = TextEditingController();

  TextEditingController signUpName = TextEditingController();
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  SignInModel? user;

  /// ميثود إنشاء حساب جديد
  Future<void> signUp() async {
    try {
      emit(SignUpLoading());

      final response = await api.post(
        EndPoint.signUp,
        isformData:
            false, // تم تعديلها لـ false لتتوافق مع الـ JSON المتوقع في الـ DTO
        data: {
          ApiKey.userName: signUpName.text.trim(),
          ApiKey.email: signUpEmail.text.trim(),
          ApiKey.password: signUpPassword.text.trim(),
          ApiKey.password2: confirmPassword.text.trim(),
        },
      );

      final signUpModel = SignUpModel.fromJson(response);

      // حفظ الـ Token والـ ID في الكاش
      await CacheHelper().saveData(key: ApiKey.token, value: signUpModel.token);

      final userId = response[ApiKey.user]['id'];
      await CacheHelper().saveData(key: ApiKey.id, value: userId);

      emit(SignUpSuccess(massage: "Account created successfully"));
    } on ServerException catch (e) {
      print(e.toString());
      emit(SignUpFailure(errorMassage: e.errorModel.errorMessage));
    } catch (e) {
      emit(
        SignUpFailure(
          errorMassage: "Unexpected error occurred while creating account",
        ),
      );
    }
  }

  /// ميثود تسجيل الدخول (تم تعديلها لحل مشكلة الـ Token)
  Future<void> signIn() async {
    if (signInFormKey.currentState?.validate() ?? false) {
      try {
        emit(AuthLoading());

        final response = await api.post(
          '/api/auth/token/', // الـ Endpoint الرسمي لتسجيل الدخول
          isformData: false,
          data: {
            ApiKey.userName: signInEmail.text
                .trim(), // الـ Backend يتوقع اسم الحقل username
            ApiKey.password: signInPassword.text.trim(),
          },
        );

        // 1. استخراج الـ Access Token مباشرة من الـ response الخام لضمان عدم قراءة قيمة null
        final String accessToken =
            response['access'] ?? response[ApiKey.token] ?? '';

        // 2. حفظ الـ Access Token والـ Refresh Token في الكاش فورًا
        await CacheHelper().saveData(key: ApiKey.token, value: accessToken);

        final String? refreshToken =
            response['refresh'] ?? response[ApiKey.refresh];
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await CacheHelper().saveData(
            key: ApiKey.refresh,
            value: refreshToken,
          );
        }

        // 3. تحويل الـ response للموديل الخاص بتسجيل الدخول للحفاظ على بقية البيانات الـ DTO
        user = SignInModel.fromJson(response);

        // طباعة اختيارية للتأكد من نجاح العملية في الـ Console
        debugPrint("===> Login Success! Token Stored: $accessToken");

        emit(AuthSuccess());
      } on ServerException catch (e) {
        print(e.toString());
        emit(AuthFailure(errorMassage: e.errorModel.errorMessage));
      } catch (e) {
        print(e.toString());
        emit(
          AuthFailure(
            errorMassage: "Unexpected error occurred, please try again",
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    signInEmail.dispose();
    signInPassword.dispose();
    signUpName.dispose();
    signUpEmail.dispose();
    signUpPassword.dispose();
    confirmPassword.dispose();
    return super.close();
  }
}
