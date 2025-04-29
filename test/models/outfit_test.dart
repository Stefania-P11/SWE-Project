// test/models/outfit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset static state before each test
    Item.itemList.clear();
    Outfit.outfitList.clear();
    Outfit.outfitCount = 0;
  });

  group('Outfit.fromSurpriseMe', () {
    test('creates outfit with correct tempCategory', () {
      final top = Item(
          id: 1,
          category: 'Top',
          label: 'T',
          timesWorn: 0,
          url: '',
          weather: ['sunny']);
      final bottom = Item(
          id: 2,
          category: 'Bottom',
          label: 'B',
          timesWorn: 0,
          url: '',
          weather: ['sunny']);
      final shoe = Item(
          id: 3,
          category: 'Shoes',
          label: 'S',
          timesWorn: 0,
          url: '',
          weather: ['sunny']);

      final outfit = Outfit.fromSurpriseMe(
        top: top,
        bottom: bottom,
        shoe: shoe,
        tempCategory: 'rainy',
      );

      expect(outfit.label, 'Surprise Me Outfit');
      expect(outfit.topItem, top);
      expect(outfit.bottomItem, bottom);
      expect(outfit.shoeItem, shoe);
      expect(outfit.weather, ['rainy']);
    });
  });

  group('Outfit.fromItemList', () {
    test('chooses the first matching category and intersects weather', () {
      final items = [
        Item(
            id: 1,
            category: 'Top',
            label: 'T1',
            timesWorn: 0,
            url: '',
            weather: ['a', 'b']),
        Item(
            id: 2,
            category: 'Bottom',
            label: 'B1',
            timesWorn: 0,
            url: '',
            weather: ['b', 'c']),
        Item(
            id: 3,
            category: 'Shoes',
            label: 'S1',
            timesWorn: 0,
            url: '',
            weather: ['b']),
      ];
      final outfit = Outfit.fromItemList(items);
      expect(outfit.topItem, items[0]);
      expect(outfit.bottomItem, items[1]);
      expect(outfit.shoeItem, items[2]);
      expect(outfit.weather, ['b']);
    });

    test('falls back when list is empty', () {
      final outfit = Outfit.fromItemList([]);
      expect(outfit.topItem.id, -1);
      expect(outfit.bottomItem.id, -1);
      expect(outfit.shoeItem.id, -1);
      expect(outfit.weather, isEmpty);
    });
  });

  group('Outfit.fromFirestore with seeded itemList', () {
    test('maps all fields correctly when itemList contains matching items',
        () async {
      final fake = FakeFirebaseFirestore();
      // Seed itemList
      Item.itemList.addAll([
        Item(
            id: 1,
            category: 'Top',
            label: 'T',
            timesWorn: 0,
            url: '',
            weather: []),
        Item(
            id: 2,
            category: 'Bottom',
            label: 'B',
            timesWorn: 0,
            url: '',
            weather: []),
        Item(
            id: 3,
            category: 'Shoes',
            label: 'S',
            timesWorn: 0,
            url: '',
            weather: []),
      ]);
      // Write a document into fake Firestore
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o1')
          .set({
        'id': 42,
        'label': 'MyOutfit',
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'timesWorn': 5,
        'weather': ['x', 'y'],
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o1')
          .get();
      final outfit = Outfit.fromFirestore(doc);
      expect(outfit.id, 42);
      expect(outfit.label, 'MyOutfit');
      expect(outfit.topItem.id, 1);
      expect(outfit.bottomItem.id, 2);
      expect(outfit.shoeItem.id, 3);
      expect(outfit.timesWorn, 5);
      expect(outfit.weather, ['x', 'y']);
    });
  });

  group('Outfit.fromFirestore fallback missing items', () {
    test('returns Unknown items for missing IDs', () async {
      final fake = FakeFirebaseFirestore();
      // Seed with a different ID so fallback triggers
      Item.itemList.add(Item(
          id: 999,
          category: 'Top',
          label: 'Z',
          timesWorn: 0,
          url: '',
          weather: []));
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o2')
          .set({
        'id': 7,
        'label': 'Fallback',
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'timesWorn': 2,
        'weather': ['w'],
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o2')
          .get();
      final outfit = Outfit.fromFirestore(doc);
      expect(outfit.topItem.id, -1);
      expect(outfit.bottomItem.id, -1);
      expect(outfit.shoeItem.id, -1);
      expect(outfit.label, 'Fallback');
      expect(outfit.timesWorn, 2);
      expect(outfit.weather, ['w']);
    });
  });

  group('Outfit.fromFirestore empty itemList throws', () {
    test('throws Exception when itemList is empty', () async {
      final fake = FakeFirebaseFirestore();
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('x')
          .set({
        'id': 1,
        'label': 'Test',
        'topID': 1,
        'bottomID': 1,
        'shoesID': 1,
        'timesWorn': 1,
        'weather': ['none'],
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('x')
          .get();
      expect(() => Outfit.fromFirestore(doc), throwsException);
    });
  });

  group('Outfit.toJson', () {
    test('serializes all fields correctly', () {
      final outfit = Outfit(
        id: 5,
        label: 'L',
        topItem: Item(
            id: 1,
            category: 'Top',
            label: 'T',
            timesWorn: 0,
            url: '',
            weather: []),
        bottomItem: Item(
            id: 2,
            category: 'Bottom',
            label: 'B',
            timesWorn: 0,
            url: '',
            weather: []),
        shoeItem: Item(
            id: 3,
            category: 'Shoes',
            label: 'S',
            timesWorn: 0,
            url: '',
            weather: []),
        timesWorn: 3,
        weather: ['z'],
      );
      final json = outfit.toJson();
      expect(json['id'], 5);
      expect(json['label'], 'L');
      expect(json['topID'], 1);
      expect(json['bottomID'], 2);
      expect(json['shoesID'], 3);
      expect(json['timesWorn'], 3);
      expect(json['weather'], ['z']);
      expect(json['createdAt'], isA<Timestamp>());
    });
  });

  group('Outfit.countOutfits', () {
    test('sets outfitCount to outfitList length', () async {
      Outfit.outfitList = [
        Outfit(
          id: 1,
          label: 'A',
          topItem: Item(
              id: 1,
              category: 'Top',
              label: 'T',
              timesWorn: 0,
              url: '',
              weather: []),
          bottomItem: Item(
              id: 2,
              category: 'Bottom',
              label: 'B',
              timesWorn: 0,
              url: '',
              weather: []),
          shoeItem: Item(
              id: 3,
              category: 'Shoes',
              label: 'S',
              timesWorn: 0,
              url: '',
              weather: []),
          timesWorn: 0,
          weather: [],
        ),
      ];
      await Outfit.countOutfits('ignored');
      expect(Outfit.outfitCount, 1);
    });
  });
}
