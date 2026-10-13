# Compte rendu TP3 — Salle d'attente avec Provider

## 1. Ce que fait le projet

App Flutter « Local Waiting Room » : une file d'attente partagée.
- Ajouter un client via TextField + bouton Add
- Supprimer un client via icône poubelle
- Faire passer le suivant via bouton Next Client (`skip_next` dans l'AppBar)
- Compteur `Clients in Queue: N` + `ListView` synchronisés partout

Fichiers :
1. `lib/queue_provider.dart` — l'état partagé
2. `lib/main.dart` — l'UI + câblage Provider
3. `lib/waiting_room_manager.dart` — alias legacy (anciens noms)
4. `test/` — 3 fichiers de preuve

## 2. Où vit l'état

Dans `QueueProvider extends ChangeNotifier` (`lib/queue_provider.dart:3`).

```dart
final List<String> _clients = [];
List<String> get clients => List.unmodifiable(_clients);
```

- `_clients` : liste privée, seule source de vérité.
- Getter `clients` : copie non modifiable → l'UI ne peut pas tricher, elle doit passer par `addClient` / `removeClient` / `nextClient`.
- Helpers : `waitingCount`, `isEmpty`, `isNotEmpty`.

État unique au-dessus de l'app, partagé par tous les widgets.

## 3. Comment le changement se propage

Chaque mutation appelle `notifyListeners()` :

1. `addClient(name)` → trim, ignore vide, `_clients.add`, notifie
2. `removeClient(name)` → `remove`, notifie seulement si succès
3. `nextClient()` → `removeAt(0)` FIFO, notifie si liste non vide
4. `clear()` → vide tout, notifie si non vide avant

`notifyListeners()` = ChangeNotifier prévient tous les `watch`. Sans cet appel, la liste change mais l'écran ne bouge pas.

## 4. watch vs read

Dans `lib/main.dart:41-52` :

- `context.watch<QueueProvider>()` → écoute. Rebuild le widget à chaque `notifyListeners`. Utilisé pour afficher (`clients.length`, `ListView`).
- `context.read<QueueProvider>()` → appel unique, sans écoute. Utilisé dans `onPressed` (Add, delete, Next Client).

Règle : `watch` dans `build` pour afficher, `read` dans les callbacks pour agir.

## 5. Câblage de l'app

Dans `lib/main.dart:7-13` :

```dart
runApp(
  ChangeNotifierProvider(
    create: (context) => QueueProvider(),
    child: const WaitingRoomApp(),
  ),
);
```

- `ChangeNotifierProvider` crée UNE instance au-dessus de tout.
- `WaitingRoomScreen` devient `StatelessWidget` — plus de `setState`, Provider gère tout.
- Le bouton Next Client a `Key('nextClientButton')` pour être retrouvé en test.

## 6. Prédiction des 3 actions

1. Tap Add avec « Client A » → `read.addClient` → `notifyListeners` → compteur 0→1, carte « Client A » apparaît, champ vidé.
2. Tap poubelle sur « Client A » → `read.removeClient('Client A')` → notifie → carte disparaît, compteur -1.
3. Tap Next Client → `read.nextClient()` → `removeAt(0)` → le premier disparaît. Si liste vide : rien ne se passe, pas de crash, pas de notif.

Add vide / espaces → ignoré, 0 notif.

## 7. Preuves par les tests

Lance : `flutter test` (environ 30 secondes).

- `test/waiting_room_manager_test.dart` : 7 tests unitaires — liste vide au départ, add notifie 1x, blank ignore (0 notif), remove notifie, nextClient enlève le premier (FIFO), next sur vide = no-op, liste externe non modifiable (`throwsUnsupportedError`).
- `test/waiting_room_widget_test.dart` : test widget Next Client — ajoute A + B via UI, tape Next, vérifie A parti, B reste, compteur = 1.
- `test/widget_test.dart` : flux complet add + next via Provider — 0 → 1 → 0.

## 8. État actuel

Ça marche : `flutter test` passe, Add / delete / Next synchronisés, code legacy isolé dans `waiting_room_manager.dart`.
