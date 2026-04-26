class PasswordResetOtp {
  final int id;
  final int expireTime;

  const PasswordResetOtp({required this.id, required this.expireTime});

  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expireTime);
}
