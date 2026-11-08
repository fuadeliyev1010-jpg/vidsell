import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/enums/gender.dart';
import 'package:vidsell/models/enums/role.dart';
import 'package:vidsell/models/user/user.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  sendingOtp,
  otpSent,
  verifyingOtp,
  registering,
  authenticated,
  failure,
}

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class OtpRequested extends AuthEvent {
  const OtpRequested(this.identifier);

  final String identifier;
}

final class OtpSubmitted extends AuthEvent {
  const OtpSubmitted({required this.identifier, required this.code});

  final String identifier;
  final String code;
}

final class RegistrationSubmitted extends AuthEvent {
  const RegistrationSubmitted({
    required this.identifier,
    required this.name,
    required this.email,
    required this.password,
  });

  final String identifier;
  final String name;
  final String email;
  final String password;
}

final class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

final class AuthFlowCancelled extends AuthEvent {
  const AuthFlowCancelled();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.identifier,
    this.verifiedUser,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? identifier;
  final User? verifiedUser;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? identifier,
    User? verifiedUser,
    String? errorMessage,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      identifier: identifier ?? this.identifier,
      verifiedUser: verifiedUser ?? this.verifiedUser,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    session,
    identifier,
    verifiedUser,
    errorMessage,
  ];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthRepository? repository})
    : _repository = repository ?? MockAuthRepository(),
      super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<OtpRequested>(_onOtpRequested);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthFlowCancelled>(_onAuthFlowCancelled);
    on<AuthSessionExpired>(_onSessionExpired);
    _sessionExpiredSubscription = _repository.onSessionExpired.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  SendOtpRequest _otpRequest(String identifier) => SendOtpRequest(
    countryCode: _countryCode(identifier),
    phoneNumber: _phoneNumber(identifier),
  );

  String _countryCode(String identifier) {
    if (identifier.startsWith('+994')) return '+994';
    if (identifier.startsWith('994')) return '994';
    return '';
  }

  String _phoneNumber(String identifier) {
    final countryCode = _countryCode(identifier);
    return countryCode.isEmpty
        ? identifier
        : identifier.substring(countryCode.length);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final session = await _repository.restoreSession();
      emit(
        state.copyWith(
          status: session == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          session: session,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.sendingOtp,
        identifier: event.identifier,
        clearError: true,
      ),
    );
    try {
      await _repository.sendOtp(_otpRequest(event.identifier));
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          identifier: event.identifier,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.verifyingOtp, clearError: true));
    try {
      final user = await _repository.verifyOtp(
        VerifyOtpRequest(
          countryCode: _countryCode(event.identifier),
          phoneNumber: _phoneNumber(event.identifier),
          code: event.code,
        ),
      );
      if (user != null) {
        final session = await _repository.loginAfterOtp(
          identifier: event.identifier,
          user: user,
        );
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            identifier: event.identifier,
            verifiedUser: user,
            session: session,
            clearError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          identifier: event.identifier,
          verifiedUser: user,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registering, clearError: true));
    try {
      final session = await _repository.register(
        RegisterRequest(
          fullName: event.name,
          countryCode: _countryCode(event.identifier),
          phoneNumber: _phoneNumber(event.identifier),
          password: event.password,
          email: event.email,
          gender: Gender.male,
          termsAccepted: true,
          role: Role.buyer,
          verificationCode: '',
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onAuthFlowCancelled(AuthFlowCancelled event, Emitter<AuthState> emit) {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
