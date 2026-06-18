import 'package:flutter/material.dart';
import 'package:untitled7/core/color/app_colors.dart';
import 'package:untitled7/features/on_boarding/data/models/on_boarding_model.dart';
import 'package:untitled7/features/on_boarding/presentation/view/widget/on_boarding_widget_body.dart';
import 'package:untitled7/features/on_boarding/presentation/view/widget/smooth_page_indicator_widgt.dart';
import 'package:untitled7/features/auth/presentation/view/screen/create_account_screen.dart';
import 'package:untitled7/features/auth/presentation/view/screen/login_screen.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_elevated_button.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_navigator_sign.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 40,
          bottom: 20,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Skip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: OnBoardingWidgetBody(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 50)),
            SliverToBoxAdapter(
              child: SmoothPageWidget(controller: _controller),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 30)),

            SliverToBoxAdapter(
              child: currentIndex == onBoardingData.length - 1
                  ? Column(
                      children: [
                        ElevatedButtonWidget(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAccountScreen(),
                              ),
                            );
                          },
                          text: 'Create Account',
                        ),
                        NavigatorSigninSignup(
                          account: 'Already have an account?',
                          Sign: 'Login',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          color: AppColors.primary,
                        ),
                      ],
                    )
                  : ElevatedButtonWidget(
                      onPressed: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.bounceIn,
                        );
                      },
                      text: 'Next',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
