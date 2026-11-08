// TODO(api): verify against /i18n/enums or openapi.json
final class TopUpStatus {
  const TopUpStatus._(this.code, this._kind);

  static const pending = TopUpStatus._('PENDING', 'pending');
  static const completed = TopUpStatus._('COMPLETED', 'completed');
  static const failed = TopUpStatus._('FAILED', 'failed');
  static const unknown = TopUpStatus._('UNKNOWN', 'unknown');

  final String code;
  final String _kind;

  bool get isUnknown => _kind == 'unknown';

  static TopUpStatus fromCode(Object? rawCode) {
    final normalized = rawCode?.toString().trim().toUpperCase();
    return switch (normalized) {
      'PENDING' => pending,
      'COMPLETED' => completed,
      'FAILED' => failed,
      'UNKNOWN' || null || '' => unknown,
      _ => TopUpStatus._(rawCode.toString(), 'unknown'),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is TopUpStatus && other._kind == _kind;

  @override
  int get hashCode => _kind.hashCode;
}
