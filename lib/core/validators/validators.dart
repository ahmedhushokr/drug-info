class Validators {

  static String? validatorEmail(String? value) {
  final String val = value?.trim() ?? '';

    if ( val.isEmpty) {
      return 'Email is required';
    }
    if (!val.contains('@') || !val.contains('.')) {
      return 'Invalid email';
    }
    return null;
  }

  static String? validatorPassword(String? value) {
    String val = value?.trim() ?? '';
    if (val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  static String? validatorName(String? value){
    String val = value?.trim() ?? '';
    if (val.isEmpty || val.length < 3){
      return ' Name is required';
    }
    return null;
  }
}
