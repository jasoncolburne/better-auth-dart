class IAuthenticationPaths {
  final AccountPaths account;
  final SessionPaths session;
  final DevicePaths device;
  final RecoveryPaths recovery;

  IAuthenticationPaths({
    required this.account,
    required this.session,
    required this.device,
    required this.recovery,
  });
}

class AccountPaths {
  final String create;
  final String recover;
  final String delete;

  AccountPaths({
    required this.create,
    required this.recover,
    required this.delete,
  });
}

class SessionPaths {
  final String request;
  final String create;
  final String refresh;

  SessionPaths({
    required this.request,
    required this.create,
    required this.refresh,
  });
}

class DevicePaths {
  final String rotate;
  final String link;
  final String unlink;

  DevicePaths({
    required this.rotate,
    required this.link,
    required this.unlink,
  });
}

class RecoveryPaths {
  final String change;

  RecoveryPaths({
    required this.change,
  });
}
