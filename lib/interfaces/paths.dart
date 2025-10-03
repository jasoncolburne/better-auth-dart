class IAuthenticationPaths {
  final AccountPaths account;
  final AuthenticatePaths authenticate;
  final RotatePaths rotate;

  IAuthenticationPaths({
    required this.account,
    required this.authenticate,
    required this.rotate,
  });
}

class AccountPaths {
  final String create;

  AccountPaths({
    required this.create,
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

class RotatePaths {
  final String authentication;
  final String access;
  final String link;
  final String unlink;
  final String recover;

  RotatePaths({
    required this.authentication,
    required this.access,
    required this.link,
    required this.unlink,
    required this.recover,
  });
}
