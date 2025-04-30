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
    test('ArgumentError should be thrown due to invalid value for category', (){
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
    test('ArgumentError should be thrown due to weather list containing duplicates', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Cold','Cold'], url : 'fake', id : 26, timesWorn : 0)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to invalid timesWorn', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Cool'], url : 'fake', id : 26, timesWorn : -1)), 
      isFalse);
    });
    test('ArgumentError should be thrown due to invalid id', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 0)), 
      isFalse);
    });
    test('Item is valid', (){
      expect(FirebaseService.isValidItem(Item(category : 'Top', label : 'Mine', weather : ['Hot', 'Cold', 'Cool', 'Warm'], url : 'fake', id : 1, timesWorn : 0)), 
      isTrue);
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
  group('removeLocalItems', (){
    Item item1 = Item(category: 'Top', id: 1, label : 'Favorite Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item2 = Item(category: 'Bottom', id: 2, label : 'Favorite Bottom', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item3 = Item(category: 'Shoes', id: 3, label : 'Favorite Shoes', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item4 = Item(category: 'Top', id: 4, label : 'Second Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item5 = Item(category: 'Top', id: 5, label : 'Third Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item6 = Item(category: 'Shoes', id: 6, label : 'Second shoes', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Outfit favOutfit = Outfit(id: 1, label : 'Favorite Outfit', topItem : item1, bottomItem : item2, shoeItem: item3, timesWorn: 3, weather: ['Cool','Warm']);
    Outfit outfit2 = Outfit(id: 2, label : 'Second Outfit', topItem : item5, bottomItem : item2, shoeItem: item6, timesWorn: 3, weather: ['Cool','Warm']);
    Outfit outfit3 = Outfit(id: 3, label : 'Third outfit', topItem : item5, bottomItem : item2, shoeItem: item3, timesWorn: 3, weather: ['Cool','Warm']);
    setUp(() {
      Item.itemList.add(item1);
      Item.itemList.add(item2);
      Item.itemList.add(item3);
      Item.itemList.add(item4);
      Item.itemList.add(item5);
      Item.itemList.add(item6);
      Outfit.outfitList.add(favOutfit);
      Outfit.outfitList.add(outfit2);
      Outfit.outfitList.add(outfit3);
    });
    tearDown(() {
      Item.itemList.remove(item1);
      Item.itemList.remove(item2);
      Item.itemList.remove(item3);
      Item.itemList.remove(item4);
      Outfit.outfitList.remove(favOutfit);
      Outfit.outfitList.remove(outfit2);
      Outfit.outfitList.remove(outfit3);
    });
    test('ArgumentError should be thrown due to invalid ID', (){
      expect(() => FirebaseService.removeLocalItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : -1, timesWorn : 1)), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to item not existing in itemList', (){
      expect(() => FirebaseService.removeLocalItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 1, timesWorn : 1)), throwsA(isA<ArgumentError>()));
    });
    test('Expects only a single item to be removed', (){
      FirebaseService.removeLocalItem(item4);
      expect(Item.itemList.contains(item1), true);
      expect(Item.itemList.contains(item2), true);
      expect(Item.itemList.contains(item3), true);
      expect(Item.itemList.contains(item4), false);
      expect(Item.itemList.contains(item5), true);
      expect(Item.itemList.contains(item6), true);
      expect(Outfit.outfitList.contains(favOutfit), true);
      expect(Outfit.outfitList.contains(outfit2), true);
      expect(Outfit.outfitList.contains(outfit3), true);
    });
    test('Expect item and related outfits to not exist', (){
      FirebaseService.removeLocalItem(item1);
      expect(Item.itemList.contains(item1), false);
      expect(Item.itemList.contains(item2), true);
      expect(Item.itemList.contains(item3), true);
      expect(Item.itemList.contains(item4), true);
      expect(Item.itemList.contains(item5), true);
      expect(Item.itemList.contains(item6), true);
      expect(Outfit.outfitList.contains(favOutfit), false);
      expect(Outfit.outfitList.contains(outfit2), true);
      expect(Outfit.outfitList.contains(outfit3), true);
    });
    test('Expects only a single item and 2 related outfits to be removed', (){
      FirebaseService.removeLocalItem(item5);
      expect(Item.itemList.contains(item1), true);
      expect(Item.itemList.contains(item2), true);
      expect(Item.itemList.contains(item3), true);
      expect(Item.itemList.contains(item4), true);
      expect(Item.itemList.contains(item5), false);
      expect(Item.itemList.contains(item6), true);
      expect(Outfit.outfitList.contains(favOutfit), true);
      expect(Outfit.outfitList.contains(outfit2), false);
      expect(Outfit.outfitList.contains(outfit3), false);
    });
  });
  group('editLocalItemDetails', (){
    Item item = Item(category: 'Top', id: 1, label : 'Favorite Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item invalidItem = Item(category: 'Top', id: 2, label : 'bad Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);

    setUp((){
      item = Item(category: 'Top', id: 1, label : 'Favorite Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
      Item.itemList.add(item);
    });
    tearDown(() {
      Item.itemList.removeAt(0);
    });
    test('Expect ArgumentError when item does not exist in item list', (){
      expect(() => FirebaseService.editLocalItemDetails(invalidItem, 'label', 'Top', ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('Expect ArgumentError b/c label exceeds 15 chars', (){
      expect(() => FirebaseService.editLocalItemDetails(item, 'label that is toooooooo loooong', 'Top', ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('Expect ArgumentError b/c invalid value for category', (){
      expect(() => FirebaseService.editLocalItemDetails(item, 'label', 'groovy headgear', ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('Expect ArgumentError b/c weather list contains invalid values', (){
      expect(() => FirebaseService.editLocalItemDetails(item, 'label', 'Bottom', ['Hot', 'ColdNuggets']), throwsA(isA<ArgumentError>()));
    });
    test('Expect ArgumentError b/c weather list contains duplicates', (){
      expect(() => FirebaseService.editLocalItemDetails(item, 'label', 'Bottom', ['Hot', 'Hot', 'Cold']), throwsA(isA<ArgumentError>()));
    });
    test('Expect ArgumentError b/c all values are empty', (){
      expect(() => FirebaseService.editLocalItemDetails(item, '', '', []), throwsA(isA<ArgumentError>()));
    });
    test('Successful editing 3 values', (){
      FirebaseService.editLocalItemDetails(item, 'label', 'Bottom', ['Cold']);
      expect(item.category, 'Bottom');
      expect(item.label, 'label');
      expect(item.weather, ['Cold']);
    });
    test('Successful editing 1 value', (){
      FirebaseService.editLocalItemDetails(item, '', 'Bottom', []);
      expect(item.category, 'Bottom');
      expect(item.label, 'Favorite Top');
      expect(item.weather, ['Hot','Cool', 'Warm']);
    });
    test('Successful editing 2 values', (){
      FirebaseService.editLocalItemDetails(item, 'MyShoes', '', ['Cool', 'Cold']);
      expect(item.category, 'Top');
      expect(item.label, 'MyShoes');
      expect(item.weather, ['Cool', 'Cold']);
    });
  });
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
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Outfits').doc('15').delete();
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
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'hello', 15, top, bottom, invalidShoe,5, ['Hot']),
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
    test('Expects Argument Error because label exceeds 15 chars', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'reallllllllllly loooooooong labeel', 15, top, bottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because id is < 0 ', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'label', -1, top, bottom, shoe,5, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because timesWorn is < 0 ', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'label', 15, top, bottom, shoe,-1, ['Hot']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because weatherList is empty', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'label', 15, top, bottom, shoe, 5, []),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because weatherList contains invalid values', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'label', 15, top, bottom, shoe, 5, ['HotCrossBuns']),
      throwsA(isA<ArgumentError>())); 
    });
    test('Expects Argument Error because weatherList contains duplicate values', (){
      expect(() => FirebaseService.addFirestoreOutfit(fakeFirestore, 'label', 15, top, bottom, shoe, 5, ['Hot', 'Warm', 'Warm', 'Cool']),
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
  group('addLocalOutfits', (){
    Item item1 = Item(category: 'Top', id: 1, label : 'Favorite Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item2 = Item(category: 'Bottom', id: 2, label : 'Favorite Bottom', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item3 = Item(category: 'Shoes', id: 3, label : 'Favorite Shoes', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item4 = Item(category: 'Top', id: 4, label : 'Second Top', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item5 = Item(category: 'Bottom', id: 5, label : 'Second Bottom', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    Item item6 = Item(category: 'Shoes', id: 6, label : 'Second shoes', weather : ['Hot','Cool', 'Warm'], url : 'fake', timesWorn: 5);
    setUp((){
      Item.itemList.add(item1);
      Item.itemList.add(item2);
      Item.itemList.add(item3);
    });
    tearDown(() {
      Item.itemList.remove(item1);
      Item.itemList.remove(item2);
      Item.itemList.remove(item3);
    });
    test('Expects ArgumentError b/c top item does not exist', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item4, item2, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c bottom item does not exist', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item1, item5, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c bottom item does not exist', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item1, item2, item6, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c top item is not in the top category', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item2, item1, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c bottom item is not in the bottom category', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item1, item1, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c shoe item is not in the shoes category', (){
      expect(() => FirebaseService.addLocalOutfit('Label', 1, item1, item2, item2, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c empty label', (){
      expect(() => FirebaseService.addLocalOutfit('', 1, item4, item2, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c label exceeds 15 chars', (){
      expect(() => FirebaseService.addLocalOutfit('Reallly really really long label', 1, item1, item2, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c id < 0', (){
      expect(() => FirebaseService.addLocalOutfit('label', -1, item1, item2, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c outfit Id already exists', (){
      FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 3, ['Hot','Warm']);
      expect(() => FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
      Outfit.outfitList.remove(Outfit.outfitList.first);
    });
    test('Expects ArgumentError b/c times worn < 0', (){
      expect(() => FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, -3, ['Hot','Warm']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c weather is empty', (){
      expect(() => FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 1, []), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c weather contains invalid values', (){
      expect(() => FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 1, ['HotDog', 'Cool']), throwsA(isA<ArgumentError>()));
    });
    test('Expects ArgumentError b/c weather contains duplicates', (){
      expect(() => FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 1, ['Hot', 'Hot']), throwsA(isA<ArgumentError>()));
    });
    test('Success adding local outfit', (){
      FirebaseService.addLocalOutfit('label', 2, item1, item2, item3, 1, ['Hot', 'Cool']);
      Outfit result = Outfit.outfitList.firstWhere((o) => o.id == 2);
      expect(result.label, 'label');
      expect(result.id, 2);
      expect(result.topItem, item1);
      expect(result.bottomItem, item2);
      expect(result.shoeItem, item3);
      expect(result.timesWorn, 1);
      expect(result.weather, ['Hot', 'Cool']);
      Outfit.outfitList.remove(result);
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
  group('removeLocalOutfits', (){

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
  group('editFirestoreItems', () {
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
      fakeFirestore.collection('users').doc(constants.kUsername).collection('Clothes').doc('26').delete();
    });
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'This is a reallyreallyreally long label', weather : ['Hot'], url : 'fake', id : 33, timesWorn : 5), 
        'This is a reallyreallyreally long label', 
        'Top', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid category', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Groovy Headgear', label : 'Mine', weather : ['Hot'], url : 'fake', id : 33, timesWorn : 5), 
        'test item', 
        'AppleBottom', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid list for weather', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['HotCrossBuns'], url : 'fake', id : 33, timesWorn : 5), 
        'test item', 
        'Top', 
        ['ColdNuggets']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to weather containing duplicate values', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : [], url : 'fake', id : 33, timesWorn : 5), 
        'test item', 
        'Top', 
        ['Cold']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to empty weather', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot','Warm','Cool','Cold','Cold'], url : 'fake', id : 33, timesWorn : 5), 
        'test item', 
        'Top', 
        ['Cold']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to id < 0', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot','Warm','Cold'], url : 'fake', id : -1, timesWorn : 5), 
        'test item', 
        'Top', 
        ['Cold']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to id not existing', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        fakeFirestore,
        Item(category : 'Top', label : 'Mine', weather : ['Hot','Warm','Cold'], url : 'fake', id : 15, timesWorn : 5), 
        'test item', 
        'Top', 
        ['Cold']), throwsA(isA<ArgumentError>()));
    });

  });  
}