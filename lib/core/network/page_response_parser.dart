import 'package:vidsell/models/common/page_response.dart';

PageResponse<T> parsePage<T>(
  dynamic data,
  T Function(Map<String, dynamic>) mapper, {
  String? itemKey,
  int? requestedPage,
}) => PageResponse<T>.fromData(
  data,
  mapper,
  itemKey: itemKey,
  requestedPage: requestedPage,
);
