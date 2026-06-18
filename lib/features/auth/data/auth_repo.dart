// import 'package:dio/dio.dart';
// import 'package:untitled7/core/network/api_error.dart';
// import 'package:untitled7/core/network/api_exceptions.dart';
// import 'package:untitled7/core/network/api_servic.dart';
// import 'package:untitled7/core/utils/pref_helper.dart';
// import 'package:untitled7/features/auth/data/user_model.dart';

// class AuthRepo {
//   ApiServic apiServic = ApiServic();

//   Future<UserModel?> login(String email, String password) async {



//     try {
//       final response = await apiServic.post("/login", {
//         "email": email,
//         'password': password,
//       });
//       final user = UserModel.fromJson(response['data']);
//       if (user.token != null) {
//         await PrefHelper.saveToken(user.token!);
//       }return user;





//     } on DioException catch (e) {
//       throw ApiExceptions.handleError(e);
//     } catch (e) {
//       throw ApiError(message: e.toString());
//     }
//   }
// }
