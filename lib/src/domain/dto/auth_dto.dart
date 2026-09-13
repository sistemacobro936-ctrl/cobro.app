class AuthDto {
  final String username;
  final String password;

  AuthDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {"username": username, "password": password};
}
