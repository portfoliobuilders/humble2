class UserDetails {

  UserDetails._privateConstructor();
  static final UserDetails _instance = UserDetails._privateConstructor();
  factory UserDetails() {
    return _instance;
  }


  String? userId;
}
