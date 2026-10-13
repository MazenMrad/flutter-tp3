import 'queue_provider.dart';

// Legacy compatibility: old code used WaitingRoomManager with
// joinWaitingList/waitingList/admitNext names.
// New canonical class is QueueProvider. This subclass keeps old
// tests/UI working while the workshop migrates to the new names.
class WaitingRoomManager extends QueueProvider {
  List<String> get waitingList => clients;
  @override
  int get waitingCount => clients.length;

  void joinWaitingList(String name) => addClient(name);

  // ignore: avoid_returning_null_for_void
  String? admitNext() {
    if (clients.isEmpty) return null;
    final first = clients.first;
    nextClient();
    return first;
  }
}
