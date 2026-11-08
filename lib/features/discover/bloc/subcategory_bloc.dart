import 'package:flutter_bloc/flutter_bloc.dart';
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
    } catch (error) {
      emit(
        SubcategoryState(
          status: SubcategoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
