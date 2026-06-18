abstract class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFailure extends AuthState {
  final String errorMassage;

  AuthFailure({required this.errorMassage});
}

final class SignUpSuccess extends AuthState {
  final String massage;

  SignUpSuccess({required this.massage});
}

final class SignUpLoading extends AuthState {}

final class SignUpFailure extends AuthState {
  final String errorMassage;

  SignUpFailure({required this.errorMassage});
}
