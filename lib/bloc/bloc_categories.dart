import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tv/models/category_entity.dart';
import 'package:flutter_tv/repositories/category_reposityory.dart';

class CategoriesBloc extends Bloc<CategoryEvent, CategoryState> {
  List<CategoryEntity> categories = [];
  CategoryRepository _repository;
  StreamSubscription _subscription;

  CategoriesBloc(CategoryRepository repository)
      : assert(repository != null),
        _repository = repository,
        super(CategoryStateLoading());

  @override
  Stream<CategoryState> mapEventToState(CategoryEvent event) async* {
    if (event == CategoryEvent.LOAD) {
      yield* _mapToLoadEvent();
    } else if (event == CategoryEvent.UPDATE) {
      yield* _mapToUpdate();
    }
  }

  Stream<CategoryState> _mapToLoadEvent() async* {
    _subscription?.cancel();
    _subscription = _repository.getCategories().listen((event) {
      categories = event;
      add(CategoryEvent.UPDATE);
    });
  }

  Stream<CategoryState> _mapToUpdate() async* {
    yield CategoryStateLoaded(categories);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

//states
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryStateLoading extends CategoryState {}

class CategoryStateLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryStateLoaded(this.categories);

  @override
  List<Object> get props => [this.categories];
}

//events
enum CategoryEvent { LOAD, UPDATE }