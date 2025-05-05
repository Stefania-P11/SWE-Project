import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/services/item_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart'; 

// Create a mock Firestore that throws on collection access
class ThrowingFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw FirebaseException(
      plugin: 'fake_firestore',
      code: 'permission-denied',
      message: 'Simulated Firestore failure',
    );
  }
}

void main() {
  late ItemService itemService;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    itemService = ItemService();
    fakeFirestore = FakeFirebaseFirestore();

    // Reset static fields before each test
    Item.itemList.clear();
    Item.isLoaded = false;
    Item.topCount = 0;
    Item.bottomCount = 0;
    Item.shoeCount = 0;

    // VERY IMPORTANT: force Item class to use the fake Firestore
    Item.dbInstance = fakeFirestore;
  });

  group('fetchItemsByCategory', () {
    test('returns filtered items when no error occurs', () async {
      // Arrange
      await fakeFirestore
          .collection('users')
          .doc('dummy')
          .collection('Clothes')
          .doc('1')
          .set({
        'category': 'Top',
        'id': 1,
        'label': 'Shirt',
        'timesWorn': 0,
        'url': 'https://example.com/top.jpg',
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
        'label': 'Jeans',
        'timesWorn': 0,
        'url': 'https://example.com/bottom.jpg',
        'weather': ['Cool'],
      });

      // Act
      final result = await itemService.fetchItemsByCategory(
          'Top', 'dummy', firestore: fakeFirestore);

      // Assert
      expect(result.length, 1);
      expect(result.first.category, 'Top');
    });

    test('returns empty list when no matching items found', () async {
      await fakeFirestore
          .collection('users')
          .doc('dummy')
          .collection('Clothes')
          .doc('1')
          .set({
        'category': 'Bottom',
        'id': 1,
        'label': 'Jeans',
        'timesWorn': 0,
        'url': 'https://example.com/bottom.jpg',
        'weather': ['Cool'],
      });

      final result = await itemService.fetchItemsByCategory(
          'Top', 'dummy', firestore: fakeFirestore);

      expect(result, isEmpty);
    });

    test('returns empty list on exception', () async {
      // No clothes collection created → should handle and return empty list
      final result = await itemService.fetchItemsByCategory(
          'Top', 'dummy', firestore: fakeFirestore);

      expect(result, []);
    });

    test('fetchItemsByCategory skips invalid documents gracefully', () async {
      await fakeFirestore
          .collection('users')
          .doc('dummy')
          .collection('Clothes')
          .doc('bad1')
          .set({
            // Missing 'category' and 'url'
            'id': 999,
            'label': 'Corrupt Item'
          });

      final result = await itemService.fetchItemsByCategory('Top', 'dummy', firestore: fakeFirestore);
      expect(result, isEmpty); // Should skip invalid doc and return []
    });

  });

  group('fetchAndCountItems', () {
    test('returns correct counts when items exist', () async {
      // Arrange
      await fakeFirestore
          .collection('users')
          .doc('dummy')
          .collection('Clothes')
          .doc('1')
          .set({
        'category': 'Top',
        'id': 1,
        'label': 'T-Shirt',
        'timesWorn': 0,
        'url': 'https://example.com/top.jpg',
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
        'label': 'Jeans',
        'timesWorn': 0,
        'url': 'https://example.com/bottom.jpg',
        'weather': ['Cool'],
      });

      await fakeFirestore
          .collection('users')
          .doc('dummy')
          .collection('Clothes')
          .doc('3')
          .set({
        'category': 'Shoes',
        'id': 3,
        'label': 'Sneakers',
        'timesWorn': 0,
        'url': 'https://example.com/shoes.jpg',
        'weather': ['All'],
      });

      // Act
      final result = await itemService.fetchAndCountItems(
          'dummy', firestore: fakeFirestore);

      // Assert
      expect(result['topCount'], 1);
      expect(result['bottomCount'], 1);
      expect(result['shoeCount'], 1);
    });

    test('returns zeros when no items exist', () async {
      // No items added to Firestore

      final result = await itemService.fetchAndCountItems(
          'dummy', firestore: fakeFirestore);

      expect(result['topCount'], 0);
      expect(result['bottomCount'], 0);
      expect(result['shoeCount'], 0);
    });
  });

  group('Exception handling coverage', () {
    test('fetchItemsByCategory returns empty list on Firestore failure', () async {
      final throwingFirestore = ThrowingFirestore();

      final result = await itemService.fetchItemsByCategory(
          'Top', 'dummy', firestore: throwingFirestore);

      expect(result, isEmpty); // Should trigger the catch and return []
    });

    test('fetchAndCountItems returns empty counts on Firestore failure', () async {
      final throwingFirestore = ThrowingFirestore();

      final result = await itemService.fetchAndCountItems(
          'dummy', firestore: throwingFirestore);

      expect(result['topCount'], 0);
      expect(result['bottomCount'], 0);
      expect(result['shoeCount'], 0);
    });
  });
}
