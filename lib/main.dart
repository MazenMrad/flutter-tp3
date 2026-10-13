import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'queue_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QueueProvider(),
      child: const WaitingRoomApp(),
    ),
  );
}

// Alias kept so old tests pumping MyApp() still work.
typedef MyApp = WaitingRoomApp;

class WaitingRoomApp extends StatelessWidget {
  const WaitingRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Waiting Room',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WaitingRoomScreen(),
    );
  }
}

// Make WaitingRoomScreen a StatelessWidget — no local state,
// QueueProvider handles it.
class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use context.watch() to listen for state changes.
    final queueProvider = context.watch<QueueProvider>();
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Waiting Room'),
        actions: [
          IconButton(
            key: const Key('nextClientButton'),
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              // Use context.read() to call a method without listening.
              context.read<QueueProvider>().nextClient();
            },
            tooltip: 'Next Client',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(labelText: 'Client Name'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      context
                          .read<QueueProvider>()
                          .addClient(controller.text);
                      controller.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Clients in Queue: ${queueProvider.clients.length}'),
            Expanded(
              child: ListView.builder(
                itemCount: queueProvider.clients.length,
                itemBuilder: (context, index) {
                  final clientName = queueProvider.clients[index];
                  return Card(
                    child: ListTile(
                      title: Text(clientName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context
                              .read<QueueProvider>()
                              .removeClient(clientName);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
