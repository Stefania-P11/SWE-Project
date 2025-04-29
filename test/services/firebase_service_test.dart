import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/services/firebase_service.dart';
import 'package:dressify_app/constants.dart' as constants;
import 'package:firebase_core/firebase_core.dart';
import 'package:dressify_app/firebase_options.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async{
  group('doItemsExist', () {
    String originalUsername = constants.kUsername;
    FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
    setUp(() {
      constants.kUsername = 'dummy';
      final item1 = {
        'category': 'Top',
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 32,
        'timesWorn' : 0
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('32').set(item1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('32').delete();
    });
    test('Expects item to not exist', () async{
      bool result = await FirebaseService.doesItemExist(fakeFirestore, 15);
      expect(result, false);
    });
    test('Expects item to exist', () async{
      bool result = await FirebaseService.doesItemExist(fakeFirestore, 32);
      expect(result, true);
    });

  });
  group('isValidItems', () {
    test('ArgumentError should be thrown due to empty category', (){
      expect(FirebaseService.isValidItem(Item(category : '', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to  invalid value for category', (){
      expect(FirebaseService.isValidItem(Item(category : 'Groovy Headgear', label : 'Mine', weather : [], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to empty label', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : '', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'This is a reallyreallyreally long label', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to empty weather string list', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : [], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to weather list containing invalid values', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Hot', 'HotCrossBuns'], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to invalid timesWorn', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : -1)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to invalid id', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 0)), 
      isFalse);
    });
  });
  group('doesOutfitExist', () {
    String originalUsername = constants.kUsername;
    FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
    setUp(() {
      constants.kUsername = 'dummy';
      final outfit1 = {
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'id' : 32,
        'timesWorn' : 0,
        'bottomID' : 5,
        'topID' : 6,
        'shoesID' : 7
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').set(outfit1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').delete();
    }); 
    test('Expects false since outfit does not exist', () async{
      bool result = await FirebaseService.doesOutfitExist(fakeFirestore, 1);
      expect(result, false);
    });
    test('Expects true since outfit exists', () async{
      bool result = await FirebaseService.doesOutfitExist(fakeFirestore, 32);
      expect(result, true);
    });
  });
  group('removeFirestoreItems', () {
    final fakeFirestore = FakeFirebaseFirestore();
    String originalUsername = constants.kUsername;
    setUp(() {
      constants.kUsername = 'dummy';
      final item1 = {
        'category': 'Top',
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 32,
        'timesWorn' : 0
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('32').set(item1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('32').delete();
    });
    test('ArgumentError should be thrown due to invalid ID', (){
      expect(() => FirebaseService.removeFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 1)), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to item not existing', (){
      expect(() => FirebaseService.removeFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 1, timesWorn : 1)), throwsA(isA<ArgumentError>()));
    });

    test('Successful remove', () async {
      await FirebaseService.removeFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 32, timesWorn : 1));
      var doc = fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('32');
      var docRef = await doc.get();
      expect(docRef.exists, false);
    });
  });
  /*
  group('removeLocalItems', (){
    test('ArgumentError should be thrown due to invalid ID', (){
      expect(() => FirebaseService.removeLocalItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 1)), throwsA(isA<ArgumentError>()));
    });
  });
  */
  /*
  group('editLocalItemDetails', (){
  });
  */
  group('addFirestoreOutfits', (){
    String originalUsername = constants.kUsername;
    FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
    Item top = Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 32, timesWorn : 1);
    final topData = {
        'category': 'Top',
        'label' : 'My Shoes',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 32,
        'timesWorn' : 0
    };
    Item invalidTop = Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 1, timesWorn : 1);
    Item bottom = Item(category : 'Bottom', label : 'Mine', weather : ['Hot'], url : 'fake', id : 33, timesWorn : 1);
    Item invalidBottom = Item(category : 'Bottom', label : 'Mine', weather : ['Hot'], url : 'fake', id : 2, timesWorn : 1);
    final bottomData = {
        'category': 'Bottom',
        'label' : 'My Shoes',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 33,
        'timesWorn' : 0
    };
    Item shoe = Item(category : 'Shoes', label : 'Mine', weather : ['Hot'], url : 'fake', id : 34, timesWorn : 1);
    Item invalidShoe = Item(category : 'Shoes', label : 'Mine', weather : ['Hot'], url : 'fake', id : 3, timesWorn : 1);
    final shoeData = {
        'category': 'Shoes',
        'label' : 'My Shoes',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 34,
        'timesWorn' : 0
      };
    setUp(() {
      constants.kUsername = 'dummy';
      final outfit1 = {
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'id' : 32,
        'timesWorn' : 0,
        'bottomID' : 5,
        'topID' : 6,
        'shoesID' : 7
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(top.id.toString()).set(topData);
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(bottom.id.toString()).set(bottomData);
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(shoe.id.toString()).set(shoeData);
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').set(outfit1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(top.id.toString()).delete();
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(bottom.id.toString()).delete();
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(shoe.id.toString()).delete();
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').delete();
    });
    test('Expects Argument Error because top Item does not exist', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, invalidTop, bottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because bottom Item does not exist', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, invalidBottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because shoe Item does not exist', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, invalidBottom, invalidShoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because outfit top does not have the Top category in database', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, bottom, bottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because outfit bottom does not have the bottom category in database', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, shoe, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because outfit shoes does not have the shoes category in database', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, bottom, top,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because outfit ID already exists', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 32, top, bottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>()));
    });
    test('Successful upload', () async{
      await FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, bottom, shoe,5, ['Hot']);
      var doc = fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('15');
      var docRef = await doc.get();
      expect(docRef.exists, true);
    });
  });
  group('removeFirestoreOutfits', (){
    String originalUsername = constants.kUsername;
    FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
    Item top = Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 32, timesWorn : 1);
    Item bottom = Item(category : 'Bottom', label : 'Mine', weather : ['Hot'], url : 'fake', id : 33, timesWorn : 1);
    Item shoe = Item(category : 'Shoes', label : 'Mine', weather : ['Hot'], url : 'fake', id : 34, timesWorn : 1);
    setUp(() {
      constants.kUsername = 'dummy';
      final outfit1 = {
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'id' : 32,
        'timesWorn' : 0,
        'bottomID' : 5,
        'topID' : 6,
        'shoesID' : 7
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').set(outfit1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32').delete();
    });
    test('Expects ArgumentError due to invalid ID', (){
      expect(() => FirebaseService.removeFirestoreOutfit(fakeFirestore, Outfit(id: -1, label : 'hello', topItem: top,  bottomItem : bottom, shoeItem : shoe, timesWorn : 5, weather : ['Hot'])),
      throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError due to item not existing', (){
      expect(() => FirebaseService.removeFirestoreOutfit(fakeFirestore, Outfit(id: -1, label : 'hello', topItem: top,  bottomItem : bottom, shoeItem : shoe, timesWorn : 5, weather : ['Hot'])),
      throwsA(isA<ArgumentError>()));
    });
    test('Successful removal', () async{
      await FirebaseService.removeFirestoreOutfit(fakeFirestore, Outfit(id: 32, label : 'hello', topItem: top,  bottomItem : bottom, shoeItem : shoe, timesWorn : 5, weather : ['Hot']));
      var doc = fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('32');
      var docRef = await doc.get();
      expect(docRef.exists, false);
    });


  }); 
  group('addFirestoreItems', () {
    final fakeFirestore = FakeFirebaseFirestore();
    String originalUsername = constants.kUsername;
    setUp((){
      constants.kUsername = 'dummy';
      final item1 = {
        'category': 'Top',
        'label' : 'Good Label',
        'weather' : ['Hot'],
        'url' : 'fake',
        'id' : 33,
        'timesWorn' : 0
      };
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('33').set(item1);
    });
    tearDown((){
      constants.kUsername = originalUsername;
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('33').delete();
    });
    test('ArgumentError should be thrown due to empty category', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : '', label : 'Mine', weather : ['Hot'], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to  invalid value for category', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Groovy Headgear', label : 'Mine', weather : [], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to empty label', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : '', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'This is a reallyreallyreally long label', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to empty weather string list', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : [], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to weather list containing invalid values', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot', 'HotCrossBuns'], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid timesWorn', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : -1)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid ID', (){
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 1)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown because item already exists', () {
      expect(() => FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 33, timesWorn : 1)), 
      throwsA(isA<ArgumentError>()));
    });
    test('Successful upload', () async {
      await FirebaseService.addFirestoreItem(fakeFirestore, Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 32, timesWorn : 1));
      var docRef = await fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc(32.toString()).get();
      expect(docRef.exists, true);
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('33').delete();
    });

  });
  /*
  group('editFirestoreItems', () {
    final fakeFirestore = FakeFirebaseFirestore();
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'This is a reallyreallyreally long label', 
        'Top', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid category', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'test item', 
        'AppleBottom', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid list for weather', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'test item', 
        'Top', 
        ['ColdNuggets']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to all args being empty', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        '', 
        '', 
        []), throwsA(isA<ArgumentError>()));
    });

  });  
  */
}