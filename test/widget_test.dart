import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tp3/main.dart';
import 'package:tp3/queue_provider.dart';

void main() {
  testWidgets('Waiting room: add + next client flow via Provider',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QueueProvider(),
        child: const WaitingRoomApp(),
      ),
    );

    // Starts empty.
    expect(find.text('Clients in Queue: 0'), findsOneWidget);

    // Add a client.
    await tester.enterText(find.byType(TextField), 'Client A');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Clients in Queue: 1'), findsOneWidget);
    expect(find.text('Client A'), findsOneWidget);

    // Next client removes them (FIFO).
    await tester.tap(find.byKey(const Key('nextClientButton')));
    await tester.pump();

    expect(find.text('Clients in Queue: 0'), findsOneWidget);
    expect(find.text('Client A'), findsNothing);
  });
}
