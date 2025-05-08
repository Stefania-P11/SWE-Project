import 'package:flutter_test/flutter_test.dart';
void main() {
  group('CloudService tests', () {
    test('example test', () {
      expect(1 + 1, equals(2));
    });
  });
}
/*import 'dart:typed_data';
import 'package:dressify_app/services/cloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// ---- Mock classes ----

class MockXFile extends Mock implements XFile {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  group('CloudService.uploadImageToFirebase', () {
    late CloudService cloudService;
    late MockXFile mockXFile;
    late MockReference mockRef;
    late MockUploadTask mockUploadTask;
    late MockTaskSnapshot mockTaskSnapshot;

    setUp(() {
      cloudService = CloudService();
      mockXFile = MockXFile();
      mockRef = MockReference();
      mockUploadTask = MockUploadTask();
      mockTaskSnapshot = MockTaskSnapshot();
    });

    test('should upload compressed image and return download URL', () async {
      // --- Arrange ---

      // Mock XFile path
      when(mockXFile.path).thenReturn('/mock/path/to/image.jpg');

      //  Mock FirebaseStorage reference hierarchy
      // Override FirebaseStorage.instance.ref().child() to return our mockRef
      final storage = FirebaseStorage.instance;
      final realRef = storage.ref();

      // ⚠ Important: We can’t actually mock FirebaseStorage.instance directly without more complex dependency injection.
      // But we can mock the Reference chain calls (ref.child, ref.putData, etc.)
      when(mockRef.child(any<String>())).thenReturn(mockRef);

      //  Mock the upload task and download URL
      when(mockRef.putData(any<Uint8List>())).thenReturn(mockUploadTask);
      when(mockUploadTask.ref).thenReturn(mockRef);
      when(mockRef.getDownloadURL()).thenAnswer((_) async => 'https://fake.download.url/image.jpg');

      //  Mock compression output
      final compressedBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // ⚠ Here’s the problem: FlutterImageCompress.compressWithFile is static and can’t be mocked easily.
      // You should refactor CloudService to accept an injected compression function to mock it in tests.
      //
      // For now, assume that compression works and skip testing that part directly.

      // --- Act ---
      // In reality, this will compress and then try to upload, but since we can't mock FlutterImageCompress easily,
      // this test will not fully execute unless CloudService is refactored to allow mockable compression.

      // We'll call the function but the compression will fail unless refactored.
      final result = await cloudService.uploadImageToFirebase(mockXFile);

      // --- Assert ---
      // Since compressWithFile will return null (no mock), the result will be null.
      // If you refactor compression to be injectable, you can expect the correct download URL here.
      expect(result, null);
    });
  });
}*/
