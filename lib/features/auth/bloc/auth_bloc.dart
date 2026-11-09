import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/models/auth/login_request.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/enums/gender.dart';
import 'package:vidsell/models/enums/role.dart';
import 'package:vidsell/models/user/user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

enum AuthOperation {
  idle,
  sendingOtp,
  otpSent,
  verifyingOtp,
  registering,
  authenticating,
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
    required this.verificationCode,
  });

  final String identifier;
  final String name;
  final String email;
  final String password;
  final String verificationCode;
}

final class PasswordLoginSubmitted extends AuthEvent {
  const PasswordLoginSubmitted({
    required this.identifier,
    required this.password,
  });

  final String identifier;
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
    this.operation = AuthOperation.idle,
    this.session,
    this.identifier,
    this.verifiedUser,
    this.verificationCode,
    this.errorMessage,
    this.errorCode,
  });

  final AuthStatus status;
  final AuthOperation operation;
  final AuthSession? session;
  final String? identifier;
  final User? verifiedUser;
  final String? verificationCode;
  final String? errorMessage;
  final String? errorCode;

  AuthState copyWith({
    AuthStatus? status,
    AuthOperation? operation,
    AuthSession? session,
    String? identifier,
    User? verifiedUser,
    String? verificationCode,
    String? errorMessage,
    String? errorCode,
    bool clearSession = false,
    bool clearError = false,
    bool clearVerificationCode = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      session: clearSession ? null : session ?? this.session,
      identifier: identifier ?? this.identifier,
      verifiedUser: verifiedUser ?? this.verifiedUser,
      verificationCode: clearVerificationCode
          ? null
          : verificationCode ?? this.verificationCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    operation,
    session,
    identifier,
    verifiedUser,
    verificationCode,
    errorMessage,
    errorCode,
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
    on<PasswordLoginSubmitted>(_onPasswordLoginSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthFlowCancelled>(_onAuthFlowCancelled);
    on<AuthSessionExpired>(_onSessionExpired);
    _sessionExpiredSubscription = _repository.onSessionExpired.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  String? _errorCode(Object error) =>
      error is ApiException ? error.apiError?.code : null;

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
          operation: AuthOperation.idle,
          session: session,
          clearError: true,
        ),
      );
    } catch (error) {
      debugPrint('[AuthBloc] Session restore failed: $error');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          operation: AuthOperation.failure,
          errorMessage: error.toString(),
          errorCode: _errorCode(error),
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
        operation: AuthOperation.sendingOtp,
        identifier: event.identifier,
        clearVerificationCode: true,
        clearError: true,
      ),
    );
    try {
      await _repository.sendOtp(_otpRequest(event.identifier));
      emit(
        state.copyWith(
          operation: AuthOperation.otpSent,
          identifier: event.identifier,
        ),
      );
    } catch (error) {
      debugPrint('[AuthBloc] Sending registration OTP failed: $error');
      emit(
        state.copyWith(
          operation: AuthOperation.failure,
          errorMessage: error.toString(),
          errorCode: _errorCode(error),
        ),
      );
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operation: AuthOperation.otpSent,
        identifier: event.identifier,
        verificationCode: event.code,
        clearError: true,
      ),
    );
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(operation: AuthOperation.registering, clearError: true),
    );
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
          verificationCode: event.verificationCode,
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operation: AuthOperation.idle,
          session: session,
          clearError: true,
        ),
      );
    } catch (error) {
      debugPrint('[AuthBloc] Registration failed: $error');
      emit(
        state.copyWith(
          operation: AuthOperation.failure,
          errorMessage: error.toString(),
          errorCode: _errorCode(error),
        ),
      );
    }
  }

  Future<void> _onPasswordLoginSubmitted(
    PasswordLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(operation: AuthOperation.authenticating, clearError: true),
    );
    try {
      final session = await _repository.login(
        LoginRequest(
          countryCode: _countryCode(event.identifier),
          phoneNumber: _phoneNumber(event.identifier),
          password: event.password,
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operation: AuthOperation.idle,
          identifier: event.identifier,
          session: session,
          clearError: true,
        ),
      );
    } catch (error) {
      debugPrint('[AuthBloc] Password login failed: $error');
      emit(
        state.copyWith(
          operation: AuthOperation.failure,
          errorMessage: error.toString(),
          errorCode: _errorCode(error),
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

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    debugPrint(
      '[AuthBloc] ${transition.event.runtimeType}: '
      '${transition.currentState.status}/${transition.currentState.operation} '
      '-> ${transition.nextState.status}/${transition.nextState.operation}',
    );
  }
}
