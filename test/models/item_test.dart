import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/models/item.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dressify_app/constants.dart'
    as constants; // Import constants separately

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  // FINAL-- DO NOT CHANGE FROM HERE
  TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
    // Reset static variables before each test
    Item.itemList.clear();
    Item.isLoaded = false;
    Item.topCount = 0;
    Item.bottomCount = 0;
    Item.shoeCount = 0;
  });

  // INCREMENT TIMES WORN TESTS
  group('Item.incrementTimesWorn', () {
    test('should increment timesWorn and update firestore', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      // Save the original username so we can restore it later
      final originalUsername = constants.kUsername;

      // Set a dummy username for testing
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

    test('should not increment timesWorn if firestore update fails', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final originalUsername = constants.kUsername;
      constants.kUsername = 'dummy';

      try {
        final item = Item(
          category: 'Top',
          id: 1,
          label: 'Test Top',
          timesWorn: 5,
          url: 'https://example.com',
          weather: ['Warm'],
        );

        // No document created here → update will fail

        expect(
          () => item.incrementTimesWorn(firestore: fakeFirestore),
          throwsA(isA<FirebaseException>()),
        );

        // Check that timesWorn stayed the same
        expect(item.timesWorn, 5);
      } finally {
        constants.kUsername = originalUsername;
      }
    });

    test('fetchItems should handle empty Clothes collection', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final originalUsername = constants.kUsername;
      constants.kUsername = 'dummy';

      try {
        
        // No documents created
        await Item.fetchItems('dummy', firestore: fakeFirestore);

        expect(Item.itemList.length, 0);
      } finally {
        constants.kUsername = originalUsername;
      }
    });
  });

 
  // FETCH ITEMS TESTS
  group('Item.fetchItems', () {
    test('should fetch items from firestore and populate itemList', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      // Save the original username
      final originalUsername = constants.kUsername;

      // Set dummy username
      constants.kUsername = 'dummy';

      try {
        // Create dummy document
        await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('1')
            .set({
          'category': 'Top',
          'id': 1,
          'label': 'Fetched Top',
          'timesWorn': 5,
          'url': 'https://example.com',
          'weather': ['Warm'],
        });

        // Call the fetchItems method using the fakeFirestore
        await Item.fetchItems('dummy', firestore: fakeFirestore);

        expect(Item.itemList.length, 1);
        expect(Item.itemList.first.label, 'Fetched Top');
        expect(Item.itemList.first.timesWorn, 5);
      } finally {
        constants.kUsername = originalUsername;
      }
    });

    test('should fetch multiple items correctly', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final originalUsername = constants.kUsername;
      constants.kUsername = 'dummy';

      try {

        // Create multiple dummy items
        await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('1')
            .set({
          'category': 'Top',
          'id': 1,
          'label': 'Top One',
          'timesWorn': 2,
          'url': 'https://example.com/1',
          'weather': ['Warm'],
        });

        await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('2')
            .set({
          'category': 'Bottom',
          'id': 2,
          'label': 'Bottom One',
          'timesWorn': 3,
          'url': 'https://example.com/2',
          'weather': ['Cold'],
        });

        await Item.fetchItems('dummy', firestore: fakeFirestore);

        expect(Item.itemList.length, 2);
        expect(Item.itemList.map((item) => item.label), containsAll(['Top One', 'Bottom One']));
      } finally {
        constants.kUsername = originalUsername;
      }
    });

    test('should handle missing timesWorn field gracefully', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final originalUsername = constants.kUsername;
      constants.kUsername = 'dummy';

      try {
        // Document missing 'timesWorn' field
        await fakeFirestore
            .collection('users')
            .doc('dummy')
            .collection('Clothes')
            .doc('3')
            .set({
          'category': 'Shoes',
          'id': 3,
          'label': 'Shoes One',
          'url': 'https://example.com/3',
          'weather': ['Rainy'],
        });

        await Item.fetchItems('dummy', firestore: fakeFirestore);

        final shoeItem = Item.itemList.firstWhere((item) => item.id == 3);
        expect(shoeItem.timesWorn, 0); // Should default to 0
      } finally {
        constants.kUsername = originalUsername;
      }
    });
  
  });

 //-- TO HERE -- Stefania

 
   // COUNT ITEMS PER CATEGORY TESTS
  group('Item.countItemsPerCategory()', () {
    setUp(() {
      Item.itemList.clear();  // Ensure fresh start for each test
      Item.topCount = 0;      // Reset counters
      Item.bottomCount = 0;
      Item.shoeCount = 0;
    });

    test('should count one item per category correctly', () {
      Item.itemList.addAll([
        Item(category: 'Top', id: 1, label: 'T-Shirt', timesWorn: 0, url: '', weather: []),
        Item(category: 'Bottom', id: 2, label: 'Jeans', timesWorn: 0, url: '', weather: []),
        Item(category: 'Shoes', id: 3, label: 'Sneakers', timesWorn: 0, url: '', weather: []),
      ]);

      Item.countItemsPerCategory();

      expect(Item.topCount, equals(1));
      expect(Item.bottomCount, equals(1));
      expect(Item.shoeCount, equals(1));
    });

    test('should count multiple items in same category', () {
      Item.itemList.addAll([
        Item(category: 'Top', id: 1, label: 'T-Shirt', timesWorn: 0, url: '', weather: []),
        Item(category: 'Top', id: 2, label: 'Blouse', timesWorn: 0, url: '', weather: []),
        Item(category: 'Shoes', id: 3, label: 'Sneakers', timesWorn: 0, url: '', weather: []),
      ]);

      Item.countItemsPerCategory();

      expect(Item.topCount, equals(2));
      expect(Item.bottomCount, equals(0));
      expect(Item.shoeCount, equals(1));
    });

    test('should return zeros when itemList is empty', () {
      Item.countItemsPerCategory();

      expect(Item.topCount, equals(0));
      expect(Item.bottomCount, equals(0));
      expect(Item.shoeCount, equals(0));
    });

    test('should reset previous counts before counting', () {
      Item.topCount = 5;
      Item.bottomCount = 3;
      Item.shoeCount = 2;

      Item.itemList.add(
        Item(category: 'Top', id: 1, label: 'T-Shirt', timesWorn: 0, url: '', weather: [])
      );

      Item.countItemsPerCategory();

      expect(Item.topCount, equals(1));
      expect(Item.bottomCount, equals(0));
      expect(Item.shoeCount, equals(0));
    });
  });

  // ITEM.FROMFIRESTORE TESTS
group('Item.fromFirestore()', () {
  late MockDocumentSnapshot mockDoc;

  const Map<String, dynamic> completeTestData = {
    'category': 'Top',
    'id': 123,
    'label': 'Test Shirt',
    'timesWorn': 5,
    'url': 'https://example.com/shirt.jpg',
    'weather': ['Warm', 'Sunny'],
  };

  setUp(() {
    mockDoc = MockDocumentSnapshot();
  });

  test('should correctly convert complete Firestore document', () {
    when(mockDoc.data()).thenReturn(completeTestData);
    final item = Item.fromFirestore(mockDoc);
    expect(item.category, equals('Top'));
    expect(item.id, equals(123));
    expect(item.label, equals('Test Shirt'));
    expect(item.timesWorn, equals(5));
    expect(item.url, equals('https://example.com/shirt.jpg'));
    expect(item.weather, equals(['Warm', 'Sunny']));
  });

  test('should handle weather list with string elements', () {
    when(mockDoc.data()).thenReturn({
      ...completeTestData,
      'weather': ['Rainy', 'Cloudy'],
    });
    final item = Item.fromFirestore(mockDoc);
    expect(item.weather, equals(['Rainy', 'Cloudy']));
  });

  test('should handle empty weather list', () {
    when(mockDoc.data()).thenReturn({
      ...completeTestData,
      'weather': [],
    });
    final item = Item.fromFirestore(mockDoc);
    expect(item.weather, isEmpty);
  });
});

}
 //-- TO HERE -- Yabbi