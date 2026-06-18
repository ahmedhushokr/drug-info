import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/features/on_boarding/presentation/view/screen/on_boarding_screen.dart';
import 'package:untitled7/features/splash/presentation/view/widget/splash_widget_body.dart';
import 'package:untitled7/features/splash/presentation/view_model/cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplash(),
      child: BlocListener<SplashCubit, bool>(
        listener: (context, state) {
          if (state) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnBoardingScreen()),
            );
          }
        },
        child: const Scaffold(body: SplashWidgetBody()),
      ),
    );
  }
}
