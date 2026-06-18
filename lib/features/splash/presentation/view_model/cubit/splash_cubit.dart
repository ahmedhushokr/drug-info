import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<bool>{
  SplashCubit():super(false);
  void startSplash () async{
    await Future.delayed(Duration(seconds: 3));
    emit(true);
  }
}