import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/models/item.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dressify_app/constants.dart' as constants; // Import constants separately

void main() {

  // FINAL-- DO NOT CHANGE FROM HERE
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Item.incrementTimesWorn', () {
    test('should increment timesWorn and update firestore', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      // Save the original username so we can restore it later
      final originalUsername = constants.kUsername;

      // 🌟 Set a dummy username for testing
      constants.kUsername = 'dummy';

      try {
        // Create dummy document
        await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('1')
            .set({'timesWorn': 0});

        final item = Item(
          category: 'Top',
          id: 1,
          label: 'Test Top',
          timesWorn: 0,
          url: 'https://example.com',
          weather: ['Warm'],
        );

        await item.incrementTimesWorn(firestore: fakeFirestore);

        // Local check
        expect(item.timesWorn, 1);

        // Firestore check
        final updatedDoc = await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('1')
            .get();
        expect(updatedDoc.data()?['timesWorn'], 1);
      } finally {
        // Always reset username after the test
        constants.kUsername = originalUsername;
      }
    });
  });
  // FINAL-- TO HERE
}