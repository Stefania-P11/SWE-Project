import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dressify_app/services/authentication_service.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth])
import 'authentication_service_test.mocks.dart';

void main() {
  late AuthenticationService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    // Pass the mock directly into the constructor
    authService = AuthenticationService(firebaseAuth: mockFirebaseAuth);
  });

  group('passwordRecovery', () {
    const validEmail = 'test@example.com';
    const invalidEmail = 'invalid-email';

    test('successfully sends password recovery email', () async {
      // Arrange: When password reset email is sent, do nothing (succeed)
      when(mockFirebaseAuth.sendPasswordResetEmail(email: validEmail))
          .thenAnswer((_) => Future.value());

      // Act
      await authService.passwordRecovery(validEmail);

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: validEmail)).called(1);
    });

    test('handles invalid email format gracefully', () async {
      // Arrange: When password reset email fails, throw an exception
      when(mockFirebaseAuth.sendPasswordResetEmail(email: invalidEmail))
          .thenThrow(FirebaseAuthException(
            code: 'invalid-email',
            message: 'The email address is badly formatted.',
          ));

      // Act & Assert
      expect(() => authService.passwordRecovery(invalidEmail), returnsNormally);
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: invalidEmail)).called(1);
    });
  });
}

 //-- TO HERE -- Yabbi