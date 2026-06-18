import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled7/core/color/app_colors.dart';
import 'package:untitled7/core/routing/app_routes.dart';
import 'package:untitled7/core/validators/validators.dart';
import 'package:untitled7/features/auth/presentation/view_model/cubit/auth_cubit.dart';
import 'package:untitled7/features/auth/presentation/view_model/cubit/auth_state.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_elevated_button.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_navigator_sign.dart';
import 'package:untitled7/features/home/presentation/view/widget/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Success')));
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMassage)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(1000),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment(0.3, -0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        // border: BorderDirectional(bottom: BorderSide(width: 4,color: Colors.lightGreenAccent)),
                      ),
                      child: Image.asset('assets/image_home.png', height: 200),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: context.read<AuthCubit>().signInFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Login to your Account',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        CustomTextField(
                          hintText: 'Email',
                          topPadding: 30,
                          validator: Validators.validatorEmail,
                          controller: context.read<AuthCubit>().signInEmail,
                        ),
                        CustomTextField(
                          controller: context.read<AuthCubit>().signInPassword,
                          hintText: 'Password',
                          obscureText: true,
                          validator: Validators.validatorPassword,
                          topPadding: 20,
                          bottomPadding: 40,
                        ),
                        state is AuthLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButtonWidget(
                                onPressed: () {
                                  if (context
                                      .read<AuthCubit>()
                                      .signInFormKey
                                      .currentState!
                                      .validate()) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.homeScreen,
                                    );
                                  } else {}
                                  // context.read<AuthCubit>().login();
                                },
                                text: 'Sign In',
                              ),
                        SizedBox(height: 40),
                        NavigatorSigninSignup(
                          account: "Don't have an account?",
                          Sign: 'Sign Up',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.createAccount,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
