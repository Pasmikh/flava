import 'package:flava/models/player.dart';

extension PlayerListExtension on List<Player> {
  List<Player> updatePlayer(Player updatedPlayer) {
    return map((p) => p.id == updatedPlayer.id ? updatedPlayer : p).toList();
  }

  List<Player> updateAllPlayers(Player Function(Player) update) {
    return map(update).toList();
  }
}
