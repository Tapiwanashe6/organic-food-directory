import 'package:equatable/equatable.dart';
import '../../models/list_model.dart';

abstract class ListsEvent extends Equatable {
  const ListsEvent();
  @override
  List<Object> get props => [];
}

class LoadListsEvent extends ListsEvent {}

class CreateListEvent extends ListsEvent {
  final String title;
  const CreateListEvent(this.title);
  @override
  List<Object> get props => [title];
}

class UpdateListEvent extends ListsEvent {
  final ListModel list;
  const UpdateListEvent(this.list);
  @override
  List<Object> get props => [list];
}

class DeleteListEvent extends ListsEvent {
  final String listId;
  const DeleteListEvent(this.listId);
  @override
  List<Object> get props => [listId];
}

class AddItemToListEvent extends ListsEvent {
  final String listId;
  final String item;
  const AddItemToListEvent(this.listId, this.item);
  @override
  List<Object> get props => [listId, item];
}

class RemoveItemFromListEvent extends ListsEvent {
  final String listId;
  final String item;
  const RemoveItemFromListEvent(this.listId, this.item);
  @override
  List<Object> get props => [listId, item];
}
