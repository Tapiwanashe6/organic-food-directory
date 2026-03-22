import 'package:bloc/bloc.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();
  final UserRepository _repository;

  AuthBloc({required UserRepository repository})
      : _repository = repository,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStateEvent>(_onCheckAuthState);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleLogin(GoogleLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Just emit EmailVerificationPending - let AuthWrapper handle the rest
      await _authService.signUp(event.email, event.password, event.name);
      emit(EmailVerificationPending(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthState(CheckAuthStateEvent event, Emitter<AuthState> emit) async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null && user.emailVerified) {
        // User is logged in and verified, fetch full user data
        final userData = await _repository.getCurrentUser();
        emit(AuthSuccess(userData));
      } else if (user != null && !user.emailVerified) {
        // User exists but email not verified
        emit(EmailVerificationPending(user.email ?? 'unknown'));
      } else {
        // No user logged in
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }
}