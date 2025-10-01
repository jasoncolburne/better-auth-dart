class IAuthenticationPaths {
  final AuthenticatePaths authenticate;
  final RegisterPaths register;
  final RotatePaths rotate;

  IAuthenticationPaths({
    required this.authenticate,
    required this.register,
    required this.rotate,
  });
}

class AuthenticatePaths {
  final String start;
  final String finish;

  AuthenticatePaths({
    required this.start,
    required this.finish,
  });
}

class RegisterPaths {
  final String create;
  final String link;
  final String recover;

  RegisterPaths({
    required this.create,
    required this.link,
    required this.recover,
  });
}

class RotatePaths {
  final String authentication;
  final String access;

  RotatePaths({
    required this.authentication,
    required this.access,
  });
}
