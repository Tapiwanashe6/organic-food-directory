import 'package:bloc/bloc.dart';
import '../../repositories/lists_repository.dart';
import 'lists_event.dart';
import 'lists_state.dart';

class ListsBloc extends Bloc<ListsEvent, ListsState> {
  final ListsRepository _repository;

  ListsBloc({required ListsRepository repository})
      : _repository = repository,
        super(ListsInitial()) {
    on<LoadListsEvent>(_onLoadLists);
    on<CreateListEvent>(_onCreateList);
    on<UpdateListEvent>(_onUpdateList);
    on<DeleteListEvent>(_onDeleteList);
    on<AddItemToListEvent>(_onAddItemToList);
    on<RemoveItemFromListEvent>(_onRemoveItemFromList);
  }

  Future<void> _onLoadLists(LoadListsEvent event, Emitter<ListsState> emit) async {
    try {
      final listingsStream = _repository.getLists();
      emit(ListsStreamLoaded(listingsStream));
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onCreateList(CreateListEvent event, Emitter<ListsState> emit) async {
    try {
      await _repository.createList(event.title);
      // Stream will automatically update - no need to reload
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onUpdateList(UpdateListEvent event, Emitter<ListsState> emit) async {
    try {
      await _repository.updateList(event.list);
      // Stream will automatically update - no need to reload
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onDeleteList(DeleteListEvent event, Emitter<ListsState> emit) async {
    try {
      await _repository.deleteList(event.listId);
      // Stream will automatically update - no need to reload
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onAddItemToList(AddItemToListEvent event, Emitter<ListsState> emit) async {
    try {
      await _repository.addItemToList(event.listId, event.item);
      // Stream will automatically update - no need to reload
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onRemoveItemFromList(RemoveItemFromListEvent event, Emitter<ListsState> emit) async {
    try {
      await _repository.removeItemFromList(event.listId, event.item);
      // Stream will automatically update - no need to reload
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }
}
