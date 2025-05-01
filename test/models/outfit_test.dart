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
      expect(outfit.timesWorn, 0);
    });

    test('id is a positive integer', () {
      final top = Item(
          id: 1,
          category: 'Top',
          label: 'T',
          timesWorn: 0,
          url: '',
          weather: []);
      final bottom = Item(
          id: 2,
          category: 'Bottom',
          label: 'B',
          timesWorn: 0,
          url: '',
          weather: []);
      final shoe = Item(
          id: 3,
          category: 'Shoes',
          label: 'S',
          timesWorn: 0,
          url: '',
          weather: []);

      final o = Outfit.fromSurpriseMe(
          top: top, bottom: bottom, shoe: shoe, tempCategory: 'cold');
      expect(o.id, isA<int>());
      expect(o.id, greaterThan(0));
    });

    test('empty tempCategory yields list with empty string', () {
      final top = Item(
          id: 1,
          category: 'Top',
          label: 'T',
          timesWorn: 0,
          url: '',
          weather: []);
      final bottom = Item(
          id: 2,
          category: 'Bottom',
          label: 'B',
          timesWorn: 0,
          url: '',
          weather: []);
      final shoe = Item(
          id: 3,
          category: 'Shoes',
          label: 'S',
          timesWorn: 0,
          url: '',
          weather: []);

      final outfit = Outfit.fromSurpriseMe(
          top: top, bottom: bottom, shoe: shoe, tempCategory: '');
      expect(outfit.weather, ['']);
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

    test('partial list triggers fallback for missing categories', () {
      final items = [
        Item(
            id: 1,
            category: 'Top',
            label: 'T2',
            timesWorn: 0,
            url: '',
            weather: ['x']),
      ];
      final outfit = Outfit.fromItemList(items);
      expect(outfit.topItem.id, 1);
      expect(outfit.bottomItem.id, -1);
      expect(outfit.shoeItem.id, -1);
      expect(outfit.weather, isEmpty);
    });

    test('disjoint weather produces empty intersection', () {
      final items = [
        Item(
            id: 1,
            category: 'Top',
            label: 'T3',
            timesWorn: 0,
            url: '',
            weather: ['sun']),
        Item(
            id: 2,
            category: 'Bottom',
            label: 'B3',
            timesWorn: 0,
            url: '',
            weather: ['rain']),
        Item(
            id: 3,
            category: 'Shoes',
            label: 'S3',
            timesWorn: 0,
            url: '',
            weather: ['snow']),
      ];
      final outfit = Outfit.fromItemList(items);
      expect(outfit.weather, isEmpty);
    });
  });

  group('Outfit.fromFirestore', () {
    late FakeFirebaseFirestore fake;
    setUp(() => fake = FakeFirebaseFirestore());

    test('maps all fields correctly when fields present', () async {
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
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o')
          .set({
        'id': 99,
        'label': 'Test',
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'timesWorn': 7,
        'weather': ['c']
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('o')
          .get();
      final o = Outfit.fromFirestore(doc);
      expect(o.id, 99);
      expect(o.label, 'Test');
      expect(o.timesWorn, 7);
      expect(o.weather, ['c']);
    });

    test('missing weather yields empty weather list', () async {
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
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('p')
          .set({
        'id': 1,
        'label': 'NoWeather',
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'timesWorn': 0
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('p')
          .get();
      final o = Outfit.fromFirestore(doc);
      expect(o.weather, isEmpty);
    });

    test('missing timesWorn defaults to zero', () async {
      Item.itemList.addAll([
        Item(
            id: 1,
            category: 'Top',
            label: 'T',
            timesWorn: 5,
            url: '',
            weather: []),
        Item(
            id: 2,
            category: 'Bottom',
            label: 'B',
            timesWorn: 5,
            url: '',
            weather: []),
        Item(
            id: 3,
            category: 'Shoes',
            label: 'S',
            timesWorn: 5,
            url: '',
            weather: []),
      ]);
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('q')
          .set({
        'id': 2,
        'label': 'NoTimes',
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'weather': ['z']
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('q')
          .get();
      final o = Outfit.fromFirestore(doc);
      expect(o.timesWorn, 0);
    });

    test('missing label and id fallback defaults', () async {
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
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('r')
          .set({
        'topID': 1,
        'bottomID': 2,
        'shoesID': 3,
        'timesWorn': 3,
        'weather': []
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('r')
          .get();
      final o = Outfit.fromFirestore(doc);
      expect(o.id, 0);
      expect(o.label, 'Unknown Outfit');
    });

    test('fallback when itemList empty throws Exception', () async {
      // do not seed itemList
      await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('s')
          .set({
        'id': 5,
        'label': 'E',
        'topID': 1,
        'bottomID': 1,
        'shoesID': 1,
        'timesWorn': 4,
        'weather': []
      });
      final doc = await fake
          .collection('users')
          .doc('u')
          .collection('Outfits')
          .doc('s')
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

    test('includes createdAt as current Timestamp', () {
      final outfit = Outfit(
        id: 6,
        label: 'M',
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
      );
      final json = outfit.toJson();
      final now = Timestamp.now();
      expect((now.seconds - (json['createdAt'] as Timestamp).seconds).abs() < 5,
          isTrue);
    });
  });

  group('Outfit.countOutfits', () {
    test('sets outfitCount to zero when empty', () async {
      Outfit.outfitList.clear();
      await Outfit.countOutfits('x');
      expect(Outfit.outfitCount, 0);
    });

    test('sets outfitCount to list length', () async {
      Outfit.outfitList = List.generate(
          3,
          (i) => Outfit(
                id: i,
                label: '\$i',
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
              ));
      await Outfit.countOutfits('y');
      expect(Outfit.outfitCount, 3);
    });

    test('updates count after modifying outfitList', () async {
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
        )
      ];
      await Outfit.countOutfits('z');
      expect(Outfit.outfitCount, 1);
      Outfit.outfitList.add(Outfit(
        id: 2,
        label: 'B',
        topItem: Item(
            id: 4,
            category: 'Top',
            label: 'T',
            timesWorn: 0,
            url: '',
            weather: []),
        bottomItem: Item(
            id: 5,
            category: 'Bottom',
            label: 'B',
            timesWorn: 0,
            url: '',
            weather: []),
        shoeItem: Item(
            id: 6,
            category: 'Shoes',
            label: 'S',
            timesWorn: 0,
            url: '',
            weather: []),
        timesWorn: 0,
        weather: [],
      ));
      await Outfit.countOutfits('z');
      expect(Outfit.outfitCount, 2);
    });
  });
  test('findItemById fallback via fromFirestore', () async {
    // 1) seed with one item so list isn't empty
    Item.itemList.add(Item(
        id: 999,
        category: 'Top',
        label: 'X',
        timesWorn: 0,
        url: '',
        weather: []));

    // 2) write a doc with topID=1 (missing), bottomID=2 (missing), shoesID=3 (missing)
    final fake = FakeFirebaseFirestore();
    await fake.collection('users').doc('u').collection('Outfits').doc('f').set({
      'id': 5,
      'label': 'Fall',
      'topID': 1,
      'bottomID': 2,
      'shoesID': 3,
      'timesWorn': 1,
      'weather': ['none'],
    });
    final doc = await fake
        .collection('users')
        .doc('u')
        .collection('Outfits')
        .doc('f')
        .get();

    // 3) invoking fromFirestore will now exercise all three orElse closures
    final o = Outfit.fromFirestore(doc);

    expect(o.topItem.id, -1);
    expect(o.bottomItem.id, -1);
    expect(o.shoeItem.id, -1);
  });


  //-- FROM HERE -- Yabbi 

  group('Outfit.fetchOutfits', () {

    test('fetches and populates outfitList from Firestore', () async {

      final fakeFirestore = FakeFirebaseFirestore();



      // Add required items to Item.itemList

      Item.itemList = [

        Item(

          id: 1,

          category: 'Top',

          label: 'T',

          timesWorn: 0,

          url: '',

          weather: ['sun'],

        ),

        Item(

          id: 2,

          category: 'Bottom',

          label: 'B',

          timesWorn: 0,

          url: '',

          weather: ['sun'],

        ),

        Item(

          id: 3,

          category: 'Shoes',

          label: 'S',

          timesWorn: 0,

          url: '',

          weather: ['sun'],

        ),

      ];



      // Create a sample outfit in Firestore

      await fakeFirestore

          .collection('users')

          .doc('testuser')

          .collection('Outfits')

          .doc('1')

          .set({

        'id': 123,

        'label': 'Sunny Outfit',

        'topID': 1,

        'bottomID': 2,

        'shoesID': 3,

        'timesWorn': 2,

        'weather': ['sun'],

      });



      // Run the method with injected fakeFirestore

      await Outfit.fetchOutfits('testuser', firestore: fakeFirestore);



      // Verify results

      expect(Outfit.outfitList.length, 1);

      final outfit = Outfit.outfitList.first;

      expect(outfit.label, 'Sunny Outfit');

      expect(outfit.topItem.label, 'T');

      expect(outfit.timesWorn, 2);

      expect(outfit.weather, ['sun']);

    });



    test('creates fallback outfit when fromFirestore throws', () async {

      final fakeFirestore = FakeFirebaseFirestore();



      // Do NOT seed Item.itemList → this should cause fromFirestore to throw

      Item.itemList.clear();



      await fakeFirestore

          .collection('users')

          .doc('baduser')

          .collection('Outfits')

          .doc('2')

          .set({

        'id': 999,

        'label': 'Broken Outfit',

        'topID': 100,

        'bottomID': 101,

        'shoesID': 102,

        'timesWorn': 3,

        'weather': ['storm'],

      });



      await Outfit.fetchOutfits('baduser', firestore: fakeFirestore);



      expect(Outfit.outfitList.length, 1);

      final fallback = Outfit.outfitList.first;

      expect(fallback.label, 'Error Outfit');

      expect(fallback.topItem.label, 'Unknown Top');

      expect(fallback.bottomItem.label, 'Unknown Bottom');

      expect(fallback.shoeItem.label, 'Unknown Shoes');

    });

  });
}
