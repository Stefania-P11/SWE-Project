import 'package:test/test.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/services/firebase_service.dart';
import 'package:dressify_app/models/item.dart';

void main(){
  group('addFirestoreItems', () {
    test('ArgumentError should be thrown due to empty category', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : '', label : 'Mine', weather : ['Hot'], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentE\rror should be thrown due to  invalid value for category', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Groovy Headgear', label : 'Mine', weather : [], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to empty label', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Top', label : '', weather : ['Hot'], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Top', label : 'This is a reallyreallyreally long label', weather : ['Hot'], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to empty weather string list', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Top', label : 'Mine', weather : [], url : 'fake', id : 26, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to weather list containing invalid values', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Top', label : 'Mine', weather : ['Hot', 'HotCrossBuns'], url : 'fake', id : 5, timesWorn : 0)), 
      throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid timesWorn', (){
      expect(() => FirebaseService.addFirestoreItem(Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : -1)), 
      throwsA(isA<ArgumentError>()));
    });
  });
  group('editFirestoreItems', () {
    test('ArgumentError should be thrown due to label exceeding 15 chars', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'This is a reallyreallyreally long label', 
        'Top', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid category', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'test item', 
        'AppleBottom', 
        ['Hot']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to invalid list for weather', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        'test item', 
        'Top', 
        ['ColdNuggets']), throwsA(isA<ArgumentError>()));
    });
    test('ArgumentError should be thrown due to all args being empty', (){
      expect(() => FirebaseService.editFirestoreItemDetails(
        Item(category : 'Top', label : 'Mine', weather : ['Hot'], url : 'fake', id : 26, timesWorn : 5), 
        '', 
        '', 
        []), throwsA(isA<ArgumentError>()));
    });
  });  

}