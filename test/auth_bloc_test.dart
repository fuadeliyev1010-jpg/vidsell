import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';

void main() {
  test(
    'mock auth completes OTP registration and restores the session',
    () async {
      final bloc = AuthBloc(repository: MockAuthRepository());
      addTearDown(bloc.close);

      bloc.add(const OtpRequested('+994501112233'));
      await bloc.stream.firstWhere(
        (state) => state.operation == AuthOperation.otpSent,
      );

      bloc.add(const OtpSubmitted(identifier: '+994501112233', code: '123456'));
      final otpState = await bloc.stream.firstWhere(
        (state) => state.verificationCode == '123456',
      );
      expect(otpState.verifiedUser, isNull);

      bloc.add(
        RegistrationSubmitted(
          identifier: '+994501112233',
          name: 'Test User',
          email: 'test@example.com',
          password: 'password',
          verificationCode: otpState.verificationCode!,
        ),
      );
      final authenticatedState = await bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.authenticated,
      );
      expect(authenticatedState.session, isNotNull);
    },
  );

  test('mock registration rejects an invalid OTP code', () async {
    final bloc = AuthBloc(repository: MockAuthRepository());
    addTearDown(bloc.close);

    bloc.add(const OtpRequested('+994501112244'));
    await bloc.stream.firstWhere(
      (state) => state.operation == AuthOperation.otpSent,
    );
    bloc.add(const OtpSubmitted(identifier: '+994501112244', code: '000000'));
    final otpState = await bloc.stream.firstWhere(
      (state) => state.verificationCode == '000000',
    );
    bloc.add(
      RegistrationSubmitted(
        identifier: '+994501112244',
        name: 'Test User',
        email: 'test@example.com',
        password: 'password',
        verificationCode: otpState.verificationCode!,
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.operation == AuthOperation.failure,
    );
    expect(state.errorMessage, contains('geçersiz'));
    expect(state.errorCode, 'INVALID_OTP');
  });

  test('OTP submission rejects codes that are not six digits', () async {
    final bloc = AuthBloc(repository: MockAuthRepository());
    addTearDown(bloc.close);

    bloc.add(const OtpRequested('+994501112255'));
    await bloc.stream.firstWhere(
      (state) => state.operation == AuthOperation.otpSent,
    );
    bloc.add(const OtpSubmitted(identifier: '+994501112255', code: '1234'));
    final state = await bloc.stream.firstWhere(
      (state) => state.operation == AuthOperation.failure,
    );

    expect(state.verificationCode, isNull);
    expect(state.errorCode, 'INVALID_OTP');
  });

  test('cancelling the auth flow clears the pending OTP state', () async {
    final bloc = AuthBloc(repository: MockAuthRepository());
    addTearDown(bloc.close);

    bloc.add(const OtpRequested('+994501112233'));
    await bloc.stream.firstWhere(
      (state) => state.operation == AuthOperation.otpSent,
    );

    bloc.add(const AuthFlowCancelled());
    final state = await bloc.stream.firstWhere(
      (state) => state.status == AuthStatus.unauthenticated,
    );

    expect(state.identifier, isNull);
    expect(state.verifiedUser, isNull);
    expect(state.errorMessage, isNull);
  });
}
