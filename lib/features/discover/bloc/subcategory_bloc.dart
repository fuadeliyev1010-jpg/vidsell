import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/mock_subcategory_repository.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';

enum SubcategoryStatus { initial, loading, success, failure }

sealed class SubcategoryEvent {
  const SubcategoryEvent();
}

final class SubcategoriesRequested extends SubcategoryEvent {
  const SubcategoriesRequested(this.categoryLabel);

  final String categoryLabel;
}

final class SubcategoryState {
  final SubcategoryStatus status;
  final List<Subcategory> subcategories;
  final String? errorMessage;

  const SubcategoryState({
    this.status = SubcategoryStatus.initial,
    this.subcategories = const [],
    this.errorMessage,
  });
}

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  SubcategoryBloc({SubcategoryRepository? repository})
    : _repository = repository ?? MockSubcategoryRepository(),
      super(const SubcategoryState()) {
    on<SubcategoriesRequested>(_onSubcategoriesRequested);
  }

  final SubcategoryRepository _repository;

  Future<void> _onSubcategoriesRequested(
    SubcategoriesRequested event,
    Emitter<SubcategoryState> emit,
  ) async {
    emit(const SubcategoryState(status: SubcategoryStatus.loading));

    try {
      final subcategories = await _repository.fetchForCategory(
        event.categoryLabel,
      );
      emit(
        SubcategoryState(
          status: SubcategoryStatus.success,
          subcategories: List.unmodifiable(subcategories),
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        final rawBody = error is ApiException
            ? error.rawResponseBody
            : 'unavailable; see repository diagnostics';
        debugPrint(
          '[SubcategoryBloc] Load failed: $error\n'
          '$stackTrace\n'
          'Raw response body: $rawBody',
        );
      }
      emit(
        SubcategoryState(
          status: SubcategoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
