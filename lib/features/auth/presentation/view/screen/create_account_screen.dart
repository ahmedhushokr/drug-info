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

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.massage)));
          Navigator.pushNamed(context, AppRoutes.homeScreen);
        } else if (state is SignUpFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMassage)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: context.read<AuthCubit>().signUpFormKey,
              child: Column(
                children: [
                  Container(
                    height: 300,
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
                        child: Image.asset(
                          'assets/image_home.png',
                          height: 200,
                        ),
                        // child: Text('ScanMed',style: TextStyle(color: Colors.deepPurple[900],fontSize: 27,fontWeight: FontWeight.w800),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create to your Account',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        CustomTextField(
                          topPadding: 30,
                          hintText: 'Name',
                          validator: Validators.validatorName,
                          // controller: context.read<AuthCubit>().signUpName,
                        ),
                        CustomTextField(
                          topPadding: 30,
                          hintText: 'User Name',
                          validator: Validators.validatorName,
                          controller: context.read<AuthCubit>().signUpName,
                        ),
                        CustomTextField(
                          topPadding: 20,
                          hintText: 'Email',
                          validator: Validators.validatorEmail,
                          controller: context.read<AuthCubit>().signUpEmail,
                        ),

                        CustomTextField(
                          topPadding: 20,
                          hintText: 'Password',
                          obscureText: true,
                          validator: Validators.validatorPassword,
                          controller: context.read<AuthCubit>().signUpPassword,
                        ),
                        CustomTextField(
                          topPadding: 20,
                          bottomPadding: 30,
                          hintText: 'Confirm Password',
                          obscureText: true,
                          validator: Validators.validatorPassword,
                          controller: context.read<AuthCubit>().confirmPassword,
                        ),

                        state is SignUpLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButtonWidget(
                                onPressed: () {
                                  if (context
                                      .read<AuthCubit>()
                                      .signUpFormKey
                                      .currentState!
                                      .validate()) {
                                    context.read<AuthCubit>().signUp();
                                  }
                                },
                                text: 'Sign Up',
                              ),
                        SizedBox(height: 40),
                        NavigatorSigninSignup(
                          account: 'Already have an account?',
                          Sign: 'Login',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
