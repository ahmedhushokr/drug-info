class UserModel {
  final String? name;
  final String? email;
  final String token; // الـ Access Token الأساسي
  final String? refresh;

  UserModel({this.name, this.email, required this.token, this.refresh});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // إذا كان الـ الـ response جاي من الـ Login (فيه access بس) هيقرأ الـ access
      // وإذا كان جاي من الـ SignUp (فيه كائن user وجواه token) هيقرأ المتاح
      token: json['access'] ?? json['token'] ?? '',
      refresh: json['refresh'],
      name: json['name'] ?? (json['user'] != null ? json['user']['name'] : ''),
      email:
          json['email'] ?? (json['user'] != null ? json['user']['email'] : ''),
    );
  }
}
