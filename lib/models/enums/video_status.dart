enum VideoStatus {
  uploaded('UPLOADED'),
  processing('PROCESSING'),
  processed('PROCESSED'),
  paused('PAUSED'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const VideoStatus(this.code);
  final String code;

  static VideoStatus? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => VideoStatus.unknown,
  );
}
