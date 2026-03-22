import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserModel user;
  const UpdateProfileEvent(this.user);
  @override
  List<Object> get props => [user];
}

class UploadProfilePictureEvent extends ProfileEvent {
  final String imagePath;
  const UploadProfilePictureEvent(this.imagePath);
  @override
  List<Object> get props => [imagePath];
}

class IncrementNotificationEvent extends ProfileEvent {}
