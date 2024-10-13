import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_game/main.dart';

void main() {
  testWidgets('Card matching game initial state test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the initial number of cards are present (e.g., 8 pairs = 16 cards).
    expect(find.byType(GestureDetector), findsNWidgets(16));

    // Tap the first card and trigger a frame.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    // After tapping, verify that the card has been flipped by checking the image change.
    // You can use the image name or some other property to confirm the flip.
    // This assumes the front image is being displayed after the tap.
    expect(find.byType(Image), findsNWidgets(16)); // Adjust as necessary to match your UI logic
  });
}
