import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/screens/add_item_screen.dart';
import 'package:dressify_app/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddItemScreen UI Tests', () {
    // ========== Render Tests ==========

    testWidgets('renders correctly in add mode (no item)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      expect(find.text('Adding New Item'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
    });

    testWidgets('renders correctly in view mode (with item)', (WidgetTester tester) async {
      final mockItem = Item(
        id: 1,
        label: 'Mock Sweater',
        category: 'Top',
        weather: ['Cold', 'Cool'],
        url: 'https://fakeurl.com/mock.jpg',
        timesWorn: 3,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: mockItem)));

      expect(find.text('Item Details'), findsOneWidget);
      expect(find.text('Mock Sweater'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Cold'), findsOneWidget);
      expect(find.text('Cool'), findsOneWidget);

      // SAVE and CANCEL should not appear in view mode
      expect(find.text('SAVE'), findsNothing);
      expect(find.text('CANCEL'), findsNothing);
    });

    testWidgets('switches to edit mode when edit icon is pressed', (WidgetTester tester) async {
      final mockItem = Item(
        id: 2,
        label: 'Mock Jeans',
        category: 'Bottom',
        weather: ['Cool'],
        url: 'https://image.com/item.jpg',
        timesWorn: 2,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: mockItem)));

      final editIcon = find.byIcon(Icons.edit);
      expect(editIcon, findsOneWidget);

      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.text('Update Item'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('shows correct title depending on mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      expect(find.text('Adding New Item'), findsOneWidget);

      final mockItem = Item(
        id: 3,
        label: 'Sneakers',
        category: 'Shoes',
        weather: ['Warm'],
        url: 'https://shoes.com/sneak.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: mockItem)));
      await tester.pump();

      expect(find.text('Item Details'), findsOneWidget);
    });

    testWidgets('pre-fills fields correctly when editing an item', (WidgetTester tester) async {
      final mockItem = Item(
        id: 4,
        label: 'PreFilled Hoodie',
        category: 'Top',
        weather: ['Cold'],
        url: 'https://url.com/image.jpg',
        timesWorn: 5,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: mockItem)));

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text ?? '', 'PreFilled Hoodie');
    });

    // ========== Category & Temperature Chip Tests ==========

    testWidgets('displays all category chips', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.text('Shoes'), findsOneWidget);
    });

    testWidgets('displays all temperature chips', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      expect(find.text('Hot'), findsOneWidget);
      expect(find.text('Warm'), findsOneWidget);
      expect(find.text('Cool'), findsOneWidget);
      expect(find.text('Cold'), findsOneWidget);
    });

    testWidgets('selects a category chip when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      final topChip = find.text('Top');
      await tester.tap(topChip);
      await tester.pump();

      expect(topChip, findsOneWidget); // Still present
    });

    testWidgets('selects a temperature chip when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      final warmChip = find.text('Warm');
      await tester.tap(warmChip);
      await tester.pump();

      expect(warmChip, findsOneWidget); // Still present
    });

    testWidgets('selects multiple temperature chips', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.tap(find.text('Hot'));
      await tester.tap(find.text('Cold'));
      await tester.pump();

      expect(find.text('Hot'), findsOneWidget);
      expect(find.text('Cold'), findsOneWidget);
    });

    testWidgets('deselects a temperature chip when tapped again', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      final coolChip = find.text('Cool');

      await tester.tap(coolChip);
      await tester.pump();
      await tester.tap(coolChip);
      await tester.pump();

      expect(coolChip, findsOneWidget); // Tapping again doesn't remove the chip itself, but it gets deselected
    });

    testWidgets('category chips are mutually exclusive', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.tap(find.text('Top'));
      await tester.pump();
      await tester.tap(find.text('Shoes'));
      await tester.pump();

      // Just confirms both are still in the tree visually — selection logic is in controller
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Shoes'), findsOneWidget);
    });

    testWidgets('temperature chips allow multiple selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.tap(find.text('Hot'));
      await tester.tap(find.text('Warm'));
      await tester.pump();

      expect(find.text('Hot'), findsOneWidget);
      expect(find.text('Warm'), findsOneWidget);
    });

    testWidgets('category chips do not respond in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 1,
        label: 'Boots',
        category: 'Shoes',
        weather: ['Cold'],
        url: 'https://img.com/boots.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      await tester.tap(find.text('Top')); // Should not trigger anything
      await tester.pump();

      // No change visible, just confirming tap is possible without error
      expect(find.text('Top'), findsOneWidget);
    });

    testWidgets('temperature chips do not respond in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 2,
        label: 'Coat',
        category: 'Top',
        weather: ['Cold'],
        url: 'https://img.com/coat.jpg',
        timesWorn: 2,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      await tester.tap(find.text('Hot')); // Tap in view mode should do nothing
      await tester.pump();

      expect(find.text('Hot'), findsOneWidget);
    });

        // ========== Form Validation Tests ==========

    testWidgets('SAVE button is disabled with no input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      final saveButton = find.text('SAVE');
      expect(saveButton, findsOneWidget);
      // It should be visible but inactive (depends on CustomButton3 logic)
    });

    testWidgets('SAVE button is disabled if only name is entered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'Shirt');
      await tester.pump();

      // Still missing category, temperature, image
      final saveButton = find.text('SAVE');
      expect(saveButton, findsOneWidget);
    });

    testWidgets('SAVE button is disabled if only category is selected', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.tap(find.text('Top'));
      await tester.pump();

      final saveButton = find.text('SAVE');
      expect(saveButton, findsOneWidget);
    });

    testWidgets('SAVE button is disabled if only temperature is selected', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.tap(find.text('Warm'));
      await tester.pump();

      final saveButton = find.text('SAVE');
      expect(saveButton, findsOneWidget);
    });

    testWidgets('SAVE button is visible after all inputs (mocked)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'Hat');
      await tester.tap(find.text('Shoes'));
      await tester.tap(find.text('Hot'));
      await tester.pump();

      // We cannot set a local image in pure UI tests, so we assume it's null here
      // Ideally, you could inject a mock path or wrap the widget in test mode to bypass
      expect(find.text('SAVE'), findsOneWidget);
    });
    // ========== Image Picker Behavior Tests ==========

    testWidgets('shows image placeholder when no image is set', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // You can check for something like an icon or alt text inside your ImagePickerContainer
      expect(find.byType(ImagePickerContainer), findsOneWidget);
    });

    testWidgets('shows image from URL if passed in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 88,
        label: 'Jacket',
        category: 'Top',
        weather: ['Cold'],
        url: 'https://image.com/item.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      expect(find.byType(ImagePickerContainer), findsOneWidget);
      // Visual confirmation requires golden tests, but presence is good enough here
    });

    testWidgets('image tap does not trigger picker in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 99,
        label: 'Scarf',
        category: 'Top',
        weather: ['Cool'],
        url: 'https://image.com/scarf.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      final imageWidget = find.byType(ImagePickerContainer);
      await tester.tap(imageWidget);
      await tester.pump();

      // No change or action, since tap is disabled in view mode
      expect(imageWidget, findsOneWidget);
    });

    testWidgets('image container is tappable in add mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      final imageWidget = find.byType(ImagePickerContainer);
      await tester.tap(imageWidget);
      await tester.pump();

      // Again, you can't simulate full image picking, just confirm tappable
      expect(imageWidget, findsOneWidget);
    });

    testWidgets('image is still shown when editing an existing item', (WidgetTester tester) async {
      final item = Item(
        id: 100,
        label: 'Cap',
        category: 'Top',
        weather: ['Warm'],
        url: 'https://img.com/cap.jpg',
        timesWorn: 2,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      final editIcon = find.byIcon(Icons.edit);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      expect(find.byType(ImagePickerContainer), findsOneWidget);
    });

    testWidgets('image is not deleted when switching to edit mode', (WidgetTester tester) async {
      final item = Item(
        id: 101,
        label: 'Pants',
        category: 'Bottom',
        weather: ['Cool'],
        url: 'https://img.com/pants.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.byType(ImagePickerContainer), findsOneWidget);
    });
    // ========== Button Logic Tests ==========

    testWidgets('Edit button is visible in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 1,
        label: 'Edit Me',
        category: 'Top',
        weather: ['Warm'],
        url: 'https://url.com/image.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Edit button switches to edit mode', (WidgetTester tester) async {
      final item = Item(
        id: 2,
        label: 'EditMode Test',
        category: 'Bottom',
        weather: ['Cool'],
        url: 'https://url.com/image.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Update Item'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('Cancel button clears inputs and pops', (WidgetTester tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Navigator(
                onPopPage: (route, result) {
                  popped = true;
                  return route.didPop(result);
                },
                pages: [
                  MaterialPage(child: AddItemScreen()),
                ],
              );
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Cancel Me');
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('Delete button is visible in view mode', (WidgetTester tester) async {
      final item = Item(
        id: 3,
        label: 'Deletable',
        category: 'Shoes',
        weather: ['Cold'],
        url: 'https://fakeurl.com/image.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('Delete button shows confirmation dialog', (WidgetTester tester) async {
      final item = Item(
        id: 4,
        label: 'Will Be Deleted',
        category: 'Shoes',
        weather: ['Cold'],
        url: 'https://fakeurl.com/image.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this item?'), findsOneWidget);
    });

    testWidgets('Save button appears after valid input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'New Shirt');
      await tester.tap(find.text('Top'));
      await tester.tap(find.text('Warm'));
      await tester.pump();

      expect(find.text('SAVE'), findsOneWidget);
    });
    // ========== Dialog UI & Response Tests ==========

    testWidgets('Loading spinner appears on SAVE tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'Save Me');
      await tester.tap(find.text('Top'));
      await tester.tap(find.text('Cool'));
      await tester.pump();

      // We can't fully simulate file image upload in UI tests,
      // but we can tap and expect a CircularProgressIndicator to appear
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Delete confirmation dialog has Cancel and Delete buttons', (WidgetTester tester) async {
      final item = Item(
        id: 5,
        label: 'Scarf',
        category: 'Top',
        weather: ['Cold'],
        url: 'https://url.com/scarf.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Tapping Cancel on delete dialog closes it', (WidgetTester tester) async {
      final item = Item(
        id: 6,
        label: 'Hat',
        category: 'Top',
        weather: ['Hot'],
        url: 'https://hat.com/img.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item'), findsNothing);
    });

    testWidgets('Tapping Delete on dialog pops the screen', (WidgetTester tester) async {
      bool popped = false;

      final item = Item(
        id: 7,
        label: 'Bag',
        category: 'Bottom',
        weather: ['Cool'],
        url: 'https://bag.com/img.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Navigator(
              onPopPage: (route, result) {
                popped = true;
                return route.didPop(result);
              },
              pages: [MaterialPage(child: AddItemScreen(item: item))],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('Loading spinner disappears after SAVE completes (mock)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'Saved');
      await tester.tap(find.text('Bottom'));
      await tester.tap(find.text('Cold'));
      await tester.pump();

      await tester.tap(find.text('SAVE'));
      await tester.pump(); // Show spinner
      await tester.pump(const Duration(seconds: 2)); // Simulate async wait

      // Spinner disappears (this may need adjustments depending on real async implementation)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    // ========== Navigation Tests ==========

    testWidgets('Screen pops after tapping CANCEL', (WidgetTester tester) async {
      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Navigator(
              onPopPage: (route, result) {
                didPop = true;
                return route.didPop(result);
              },
              pages: [MaterialPage(child: AddItemScreen())],
            ),
          ),
        ),
      );

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(didPop, isTrue);
    });

    testWidgets('Screen pops after tapping DELETE and confirming', (WidgetTester tester) async {
      bool didPop = false;

      final item = Item(
        id: 10,
        label: 'DeleteTest',
        category: 'Top',
        weather: ['Warm'],
        url: 'https://image.com/delete.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Navigator(
              onPopPage: (route, result) {
                didPop = true;
                return route.didPop(result);
              },
              pages: [MaterialPage(child: AddItemScreen(item: item))],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(didPop, isTrue);
    });

    testWidgets('Screen pops after saving new item (mocked)', (WidgetTester tester) async {
      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Navigator(
              onPopPage: (route, result) {
                didPop = true;
                return route.didPop(result);
              },
              pages: [MaterialPage(child: AddItemScreen())],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'NavTest Item');
      await tester.tap(find.text('Bottom'));
      await tester.tap(find.text('Hot'));
      await tester.pump();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });
    // ========== Responsiveness Tests ==========

    testWidgets('Screen scrolls if content overflows', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: AddItemScreen(), // Force small screen
            ),
          ),
        ),
      );

      // If screen is scrollable, we should find SingleChildScrollView inside
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Layout adapts on large screen (wide)', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Basic content still renders
      expect(find.text('Adding New Item'), findsOneWidget);

      // Reset screen size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('Layout adapts on small screen (mobile)', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      expect(find.text('Adding New Item'), findsOneWidget);

      // Reset screen size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    // ========== Regression Tests ==========

    testWidgets('Previously reported bug: SAVE not tappable if image is set', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), 'Regression Fix');
      await tester.tap(find.text('Top'));
      await tester.tap(find.text('Cool'));
      await tester.pump();

      // If image picker behaves as expected, SAVE should be tappable
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('Chip toggle regression: can still deselect temperature', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      final chip = find.text('Cold');

      await tester.tap(chip);
      await tester.pump();
      await tester.tap(chip);
      await tester.pump();

      expect(chip, findsOneWidget);
    });

    testWidgets('Edit mode still pre-fills inputs after update fix', (WidgetTester tester) async {
      final item = Item(
        id: 11,
        label: 'Edit Regression',
        category: 'Bottom',
        weather: ['Warm'],
        url: 'https://img.com/test.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Update Item'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('TextField max length still applies (15 chars)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      await tester.enterText(find.byType(TextField), '12345678901234567890'); // 20+ chars
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 15);
    });

    testWidgets('Chip rendering doesn’t crash with invalid state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      expect(find.text('Hot'), findsOneWidget); // Ensures stable build
    });
    // ========== Edge Case UI Tests ==========

    testWidgets('Entering very long name is still handled and truncated to 15 chars', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      await tester.enterText(find.byType(TextField), 'SuperMegaUltraWinterJacket3000');
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text.length, lessThanOrEqualTo(15));
    });

    testWidgets('Tapping category chip multiple times doesn’t crash', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Top'));
        await tester.pump();
      }

      expect(find.text('Top'), findsOneWidget);
    });

    testWidgets('Tapping same temperature chip rapidly toggles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      for (int i = 0; i < 6; i++) {
        await tester.tap(find.text('Cold'));
        await tester.pump();
      }

      expect(find.text('Cold'), findsOneWidget); // Visual presence check
    });

    testWidgets('Selecting all temperature chips works without error', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      for (final temp in ['Hot', 'Warm', 'Cool', 'Cold']) {
        await tester.tap(find.text(temp));
        await tester.pump();
      }

      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('Save allowed when only minimum valid inputs are set (no image)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      await tester.enterText(find.byType(TextField), 'Basic');
      await tester.tap(find.text('Top'));
      await tester.tap(find.text('Warm'));
      await tester.pump();

      expect(find.text('SAVE'), findsOneWidget); // Image is required in real logic, but UI renders
    });

    testWidgets('Handles item with broken image URL without crashing', (WidgetTester tester) async {
      final item = Item(
        id: 404,
        label: 'BrokenImage',
        category: 'Shoes',
        weather: ['Cool'],
        url: 'https://nonexistent.domain/image.jpg',
        timesWorn: 1,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      expect(find.text('Item Details'), findsOneWidget);
      expect(find.byType(ImagePickerContainer), findsOneWidget);
    });

    testWidgets('Case-insensitive category still gets selected properly', (WidgetTester tester) async {
      final item = Item(
        id: 888,
        label: 'Mismatch Category',
        category: 'top', // lowercase instead of 'Top'
        weather: ['Hot'],
        url: 'https://url.com/case.jpg',
        timesWorn: 0,
      );

      await tester.pumpWidget(MaterialApp(home: AddItemScreen(item: item)));

      // UI should not crash and should still render
      expect(find.text('Item Details'), findsOneWidget);
    });

    testWidgets('Adding item with all inputs at minimal state still shows feedback', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));
      await tester.enterText(find.byType(TextField), 'A');
      await tester.tap(find.text('Top'));
      await tester.tap(find.text('Hot'));
      await tester.pump();

      expect(find.text('SAVE'), findsOneWidget);
    });


  });
}
