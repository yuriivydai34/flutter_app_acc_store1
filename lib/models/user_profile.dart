class UserProfile {
  final String sub;
  final String username;
  final bool isAdmin;
  final int iat;
  final int exp;

  UserProfile({
    required this.sub,
    required this.username,
    required this.isAdmin,
    required this.iat,
    required this.exp,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      sub: json['sub'],
      username: json['username'],
      isAdmin: json['isAdmin'] ?? false,
      iat: json['iat'],
      exp: json['exp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'username': username,
      'isAdmin': isAdmin,
      'iat': iat,
      'exp': exp,
    };
  }
} 