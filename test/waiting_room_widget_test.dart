import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tp3/main.dart';
import 'package:tp3/queue_provider.dart';

void main() {
  testWidgets(
      'should remove the first client from the list when "Next Client" is tapped',
      (WidgetTester tester) async {
    // ARRANGE
    // We need to provide the QueueProvider to our widget tree for the test.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => QueueProvider(),
        child: const WaitingRoomApp(),
      ),
    );
    // Add two clients to the list first
    await tester.enterText(find.byType(TextField), 'Client A');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Client B');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // ACT
    await tester.tap(
        find.byKey(const Key('nextClientButton'))); // Find and tap the new button
    await tester.pump();
    // ASSERT
    expect(find.text('Client A'), findsNothing);
    expect(find.text('Client B'), findsOneWidget);
    expect(find.text('Clients in Queue: 1'), findsOneWidget);
  });
}
