import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled7/core/color/app_colors.dart';
import 'package:untitled7/features/on_boarding/data/models/on_boarding_model.dart';

class SmoothPageWidget extends StatelessWidget {
  const SmoothPageWidget({super.key, required this.controller});
   final PageController controller;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SmoothPageIndicator(
        controller: controller,
        count: onBoardingData.length,
        effect: ExpandingDotsEffect(
          dotWidth: 10,
          dotHeight: 9,
          activeDotColor: AppColors.primary
        ),
      ),
    );
  }
}
