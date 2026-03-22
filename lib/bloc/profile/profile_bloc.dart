import 'package:bloc/bloc.dart';
import '../../repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _repository;

  ProfileBloc({required UserRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfilePictureEvent>(_onUploadProfilePicture);
    on<IncrementNotificationEvent>(_onIncrementNotification);
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await _repository.getCurrentUser();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await _repository.updateProfile(event.user);
      emit(ProfileLoaded(event.user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadProfilePicture(UploadProfilePictureEvent event, Emitter<ProfileState> emit) async {
    try {
      final user = await _repository.uploadProfilePicture(event.imagePath);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onIncrementNotification(IncrementNotificationEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentUser = (state as ProfileLoaded).user;
      if (currentUser.notificationCount < 2) {
        final updatedUser = currentUser.copyWith(notificationCount: currentUser.notificationCount + 1);
        emit(ProfileLoaded(updatedUser));
      }
    }
  }
}
