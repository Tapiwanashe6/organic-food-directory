import 'package:equatable/equatable.dart';
import '../../models/list_model.dart';

abstract class ListsState extends Equatable {
  const ListsState();
  @override
  List<Object?> get props => [];
}

class ListsInitial extends ListsState {}

class ListsLoading extends ListsState {}

class ListsLoaded extends ListsState {
  final List<ListModel> lists;
  const ListsLoaded(this.lists);
  @override
  List<Object> get props => [lists];
}

class ListsStreamLoaded extends ListsState {
  final Stream<List<ListModel>> listingsStream;
  const ListsStreamLoaded(this.listingsStream);
  @override
  List<Object?> get props => [listingsStream];
}

class ListsError extends ListsState {
  final String message;
  const ListsError(this.message);
  @override
  List<Object> get props => [message];
}
