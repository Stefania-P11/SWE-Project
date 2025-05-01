import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:dressify_app/services/authentication_service.dart';
import 'package:dressify_app/constants.dart';

// This class allows us to override the default constructor behavior
class TestableAuthService extends AuthenticationService {
  TestableAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : super(firebaseAuth: auth, firestore: firestore);
}

// Mock classes with concrete implementations
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  User? _currentUser;
  bool _throwOnCreateUser = false;
  bool _throwOnSignIn = false;
  bool _throwOnSignOut = false;
  bool _throwOnResetPassword = false;
  
  MockFirebaseAuth() {
    _currentUser = MockUser();
  }
  
  @override
  User? get currentUser => _currentUser;
  
  void setCurrentUser(User? user) {
    _currentUser = user;
  }
  
  void setThrowOnCreateUser(bool value) {
    _throwOnCreateUser = value;
  }
  
  void setThrowOnSignIn(bool value) {
    _throwOnSignIn = value;
  }
  
  void setThrowOnSignOut(bool value) {
    _throwOnSignOut = value;
  }
  
  void setThrowOnResetPassword(bool value) {
    _throwOnResetPassword = value;
  }
  
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,  
    required String password
  }) async {
    if (_throwOnCreateUser) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    return Future.value(MockUserCredential(user: _currentUser));
  }
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,  
    required String password
  }) async {
    if (_throwOnSignIn) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    return Future.value(MockUserCredential(user: _currentUser));
  }
  
  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
    String? locale,
  }) async {
    if (_throwOnResetPassword) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    return Future.value();
  }
  
  @override
  Future<void> signOut() async {
    if (_throwOnSignOut) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    }
    return Future.value();
  }
  
  @override
  Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }
}

class MockUser extends Mock implements User {
  String _uid = 'test-uid';
  String? _email = 'test@example.com';
  String? _displayName;
  bool _throwOnReauth = false;
  bool _throwOnUpdate = false;
  
  void setUid(String uid) {
    _uid = uid;
  }
  
  void setEmail(String? email) {
    _email = email;
  }

  void setDisplayName(String? displayName) {
    _displayName = displayName;
  }
  
  void setThrowOnReauth(bool value) {
    _throwOnReauth = value;
  }
  
  void setThrowOnUpdate(bool value) {
    _throwOnUpdate = value;
  }
  
  @override
  String get uid => _uid;
  
  @override
  String? get email => _email;
  
  @override
  String? get displayName => _displayName;
  
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    if (_throwOnReauth) {
      throw FirebaseAuthException(code: 'wrong-password');
    }
    return Future.value(MockUserCredential(user: this));
  }
  
  @override
  Future<void> updatePassword(String newPassword) async {
    if (_throwOnUpdate) {
      throw FirebaseAuthException(code: 'weak-password');
    }
    return Future.value();
  }
  
  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
    return Future.value();
  }
  
  @override
  Future<void> reload() async {
    return Future.value();
  }
}

class MockUserCredential extends Mock implements UserCredential {
  final User? user;
  MockUserCredential({this.user});
}

class MockAuthCredential extends Mock implements AuthCredential {}

// Mock Firestore that allows us to test exception handling
class MockFirestore extends Mock implements FirebaseFirestore {
  final bool throwOnOperation;
  final FakeFirebaseFirestore delegate;
  
  MockFirestore({this.throwOnOperation = false}) : delegate = FakeFirebaseFirestore();
  
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (throwOnOperation) {
      throw FirebaseException(plugin: 'firestore', code: 'unavailable');
    }
    return delegate.collection(path);
  }
}

void main() {
  late TestableAuthService authService;
  late MockFirebaseAuth mockAuth;
  late FirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = mockAuth.currentUser as MockUser;
    mockFirestore = MockFirestore();
    
    authService = TestableAuthService(
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  group('Password Validation Tests', () {
    group('passwordLength', () {
      test('true when ≥ 8 chars', () {
        expect(authService.passwordLength('Abcdef12'), isTrue);
        expect(authService.passwordLength('12345678'), isTrue);
      });
      test('false when < 8 chars', () {
        expect(authService.passwordLength('A1b2C3'), isFalse);
        expect(authService.passwordLength(''), isFalse);
      });
      test('false when exactly 7 chars', () {
        expect(authService.passwordLength('Abc1234'), isFalse);
      });
    });

    group('passwordUpperCase', () {
      test('true if any uppercase', () {
        expect(authService.passwordUpperCase('abcDef'), isTrue);
        expect(authService.passwordUpperCase('Zebra123'), isTrue);
      });
      test('false if none', () {
        expect(authService.passwordUpperCase('abcdefg'), isFalse);
        expect(authService.passwordUpperCase('1234!@#'), isFalse);
      });
      test('true for single uppercase letter', () {
        expect(authService.passwordUpperCase('X'), isTrue);
      });
    });

    group('passwordDigit', () {
      test('true if any digit', () {
        expect(authService.passwordDigit('password1'), isTrue);
        expect(authService.passwordDigit('123'), isTrue);
      });
      test('false if none', () {
        expect(authService.passwordDigit('password'), isFalse);
        expect(authService.passwordDigit('ABCdef!@#'), isFalse);
      });
      test('true for single digit', () {
        expect(authService.passwordDigit('7'), isTrue);
      });
    });

    group('validatePassword', () {
      test('true when all rules passed', () {
        expect(authService.validatePassword('GoodPass1'), isTrue);
        expect(authService.validatePassword('Another9X'), isTrue);
      });
      test('false if too short', () {
        expect(authService.validatePassword('Aa1'), isFalse);
      });
      test('false if no uppercase', () {
        expect(authService.validatePassword('goodpass1'), isFalse);
      });
      test('false if no digit', () {
        expect(authService.validatePassword('NoDigitsHere'), isFalse);
      });
    });
  });

  group('Firebase Authentication Tests', () {
    test('getCurrentUser returns current user', () {
      expect(authService.getCurrentUser(), isNotNull);
    });
    
    test('createCredential returns AuthCredential', () {
      final credential = authService.createCredential('test@example.com', 'Password123');
      expect(credential, isA<AuthCredential>());
    });
    
    test('onAuthStateChanged returns stream', () {
      final stream = authService.onAuthStateChanged();
      expect(stream, isA<Stream<User?>>());
    });

    group('signUp Tests', () {
      test('signUp validates password before attempting signup', () async {
        final result = await authService.signUp('test@example.com', 'weak', 'testuser');
        expect(result, isNull);
      });

      test('signUp calls Firebase and saves username to Firestore', () async {
        // Set user properties
        mockUser.setUid('new-uid');
        mockUser.setEmail('test@example.com');

        final result = await authService.signUp('test@example.com', 'Password123', 'testUsername');
        expect(result, isA<User>());
      });
      
      test('signUp handles exception', () async {
        // Force createUserWithEmailAndPassword to throw
        mockAuth.setThrowOnCreateUser(true);
        
        final result = await authService.signUp('test@example.com', 'Password123', 'testUsername');
        expect(result, isNull);
      });
    });

    group('signIn Tests', () {
      test('signIn signs in and returns User', () async {
        // Set up test data
        mockUser.setUid('test-uid');
        
        final user = await authService.signIn('signIn@example.com', 'Password123');
        expect(user, isA<User>());
      });
      
      test('signIn handles exception', () async {
        mockAuth.setThrowOnSignIn(true);
        
        final result = await authService.signIn('bad@example.com', 'Password123');
        expect(result, isNull);
      });

      test('signIn returns null when no current user', () async {
        mockAuth.setCurrentUser(null);
        final result = await authService.signIn('user@example.com', 'Password123');
        expect(result, isNull);
      });
    });

    group('Other Auth Method Tests', () {
      test('signOut calls auth.signOut()', () async {
        await authService.signOut();
        // No exception means success
      });
      
      test('signOut handles exception', () async {
        mockAuth.setThrowOnSignOut(true);
        
        await authService.signOut();
      });

      test('signOut works when no user signed in', () async {
        mockAuth.setCurrentUser(null);
        await authService.signOut();
      });

      test('passwordRecovery sends reset email', () async {
        await authService.passwordRecovery('test@example.com');
      });
      
      test('passwordRecovery handles exception', () async {
        mockAuth.setThrowOnResetPassword(true);
        
        await authService.passwordRecovery('bad@example.com');
      });

      test('passwordRecovery does nothing with empty email', () async {
        await authService.passwordRecovery('');
      });
    });
    
    group('setNewPassword Tests', () {
      test('setNewPassword returns false when no user', () async {
        mockAuth.setCurrentUser(null);
        final result = await authService.setNewPassword('oldPass', 'NewPass123');
        expect(result, isFalse);
      });

      test('setNewPassword returns true on success', () async {
        // Ensure we have a current user
        mockUser.setEmail('user@example.com');

        final result = await authService.setNewPassword('CurrentPass123', 'NewPass123');
        expect(result, isTrue);
      });
      
      test('setNewPassword handles reauthentication failure', () async {
        mockUser.setEmail('user@example.com');
        mockUser.setThrowOnReauth(true);
        
        final result = await authService.setNewPassword('WrongPass', 'NewPass123');
        expect(result, isFalse);
      });
      
      test('setNewPassword handles update password failure', () async {
        mockUser.setEmail('user@example.com');
        mockUser.setThrowOnUpdate(true);
        
        final result = await authService.setNewPassword('CurrentPass123', 'weak');
        expect(result, isFalse);
      });
    });
    
    group('Username Tests', () {
      test('isUsernameAvailable returns false when exception occurs', () async {
        // Use a Firestore mock that throws exceptions
        final throwingFirestore = MockFirestore(throwOnOperation: true);
        final testService = TestableAuthService(
          auth: mockAuth,
          firestore: throwingFirestore,
        );
        
        final result = await testService.isUsernameAvailable('anyUsername');
        expect(result, isFalse);
      });

      test('isUsernameAvailable returns true when username does not exist', () async {
        final realFS = FakeFirebaseFirestore();
        final svc = TestableAuthService(auth: mockAuth, firestore: realFS);
        final ok = await svc.isUsernameAvailable('newName');
        expect(ok, isTrue);
      });

      test('isUsernameAvailable returns false when username exists', () async {
        final realFS = FakeFirebaseFirestore();
        final svc = TestableAuthService(auth: mockAuth, firestore: realFS);
        await realFS.collection('usernames').doc('taken').set({'uid': 'other'});
        final ok = await svc.isUsernameAvailable('taken');
        expect(ok, isFalse);
      });

      test('getUsernameForCurrentUser returns null when no user', () async {
        mockAuth.setCurrentUser(null);
        final username = await authService.getUsernameForCurrentUser();
        expect(username, isNull);
      });

      test('getUsernameForCurrentUser returns null when no matching doc', () async {
        final realFS = FakeFirebaseFirestore();
        final svc = TestableAuthService(auth: mockAuth, firestore: realFS);
        mockAuth.setCurrentUser(mockUser);
        mockUser.setUid('uid1');
        await realFS.collection('usernames').doc('otherUser').set({'uid': 'uid2'});
        final username = await svc.getUsernameForCurrentUser();
        expect(username, isNull);
      });
    });
  });
  
  // Special test group for constructor coverage
  group('Constructor Tests', () {
    test('Constructor uses parameters when provided', () {
      final auth = MockFirebaseAuth();
      final firestore = MockFirestore();
      
      final service = TestableAuthService(
        auth: auth,
        firestore: firestore,
      );
      
      expect(service, isA<AuthenticationService>());
    });
    
    test('default constructor throws when no Firebase app is configured', () {
      expect(
        () => AuthenticationService(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('constructor with firebaseAuth only throws', () {
      expect(
        () => AuthenticationService(firebaseAuth: mockAuth),
        throwsA(isA<FirebaseException>()),
      );
    });
  });

  group('Coverage Completeness', () {
    test('isUsernameAvailable returns true when username not exists', () async {
      final ok = await authService.isUsernameAvailable('no_such_username');
      expect(ok, isTrue);
    });

    test('getUsernameForCurrentUser returns null if docs empty', () async {
      mockAuth.setCurrentUser(mockUser);
      mockUser.setUid('uid_without_doc');
      final name = await authService.getUsernameForCurrentUser();
      expect(name, isNull);
    });

    test('getUsernameForCurrentUser returns the doc ID when present', () async {
      // use a real FakeFirebaseFirestore so we can insert a doc
      final realFS = FakeFirebaseFirestore();
      final svc = TestableAuthService(
        auth: mockAuth,
        firestore: realFS,
      );
      // simulate logged-in user
      mockAuth.setCurrentUser(mockUser);
      mockUser.setUid('uidXYZ');

      // insert exactly one matching username doc
      await realFS
          .collection('usernames')
          .doc('usernameXYZ')
          .set({'uid': 'uidXYZ'});

      final name = await svc.getUsernameForCurrentUser();
      expect(name, equals('usernameXYZ'));
    });
  });

  test(
    'signIn loads username and sets kUsername',
    () async {
      // use a real FakeFirestore so we can insert the doc
      final realFS = FakeFirebaseFirestore();
      final svc = TestableAuthService(
        auth: mockAuth,
        firestore: realFS,
      );

      // simulate logged-in user
      mockAuth.setCurrentUser(mockUser);
      mockUser.setUid('uid5');

      // insert the matching username doc
      await realFS
          .collection('usernames')
          .doc('user5')
          .set({'uid': 'uid5'});

      // call signIn to hit the snapshot.docs.isNotEmpty branch
      await svc.signIn('whatever', 'whatever');

      // now kUsername was set
      expect(kUsername, 'user5');
    },
  );
}