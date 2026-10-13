import 'package:flutter_test/flutter_test.dart';
import 'package:tp3/queue_provider.dart';

void main() {
  group('QueueProvider (ChangeNotifier)', () {
    test('starts with an empty client list', () {
      final provider = QueueProvider();
      expect(provider.clients, isEmpty);
      expect(provider.waitingCount, 0);
      expect(provider.isEmpty, isTrue);
    });

    test('addClient adds a client and notifies listeners', () {
      final provider = QueueProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.addClient('Client A');

      expect(provider.clients, contains('Client A'));
      expect(provider.waitingCount, 1);
      expect(notified, 1);
    });

    test('addClient ignores empty / blank names', () {
      final provider = QueueProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.addClient('   ');

      expect(provider.clients, isEmpty);
      expect(notified, 0);
    });

    test('removeClient removes a client and notifies listeners', () {
      final provider = QueueProvider()
        ..addClient('Client A')
        ..addClient('Client B');

      var notified = 0;
      provider.addListener(() => notified++);

      provider.removeClient('Client A');

      expect(provider.clients, ['Client B']);
      expect(notified, 1);
    });

    test('should remove the first client when nextClient() is called', () {
      // ARRANGE
      final manager = QueueProvider();
      manager.addClient('Client A');
      manager.addClient('Client B');
      // ACT
      manager.nextClient();
      // ASSERT
      expect(manager.clients.length, 1);
      expect(manager.clients.first, 'Client B');
    });

    test('nextClient does nothing when list is empty', () {
      final provider = QueueProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.nextClient();

      expect(provider.clients, isEmpty);
      expect(notified, 0);
    });

    test('clients list is unmodifiable from outside', () {
      final provider = QueueProvider()..addClient('Client A');
      expect(() => provider.clients.add('Hacker'), throwsUnsupportedError);
    });
  });
}
