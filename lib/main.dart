import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/api/dio_consumer.dart';
import 'package:untitled7/core/cache/cashe_helper.dart';
import 'package:untitled7/features/home/presentation/view_model/cubit/home_cubit.dart';
import 'package:untitled7/features/splash/presentation/view_model/cubit/splash_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'features/auth/presentation/view_model/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(DioConsumer(dio: Dio()))),
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => HomeCubit()),
      ],

      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splashscreen,
      ),
    );
  }
}
