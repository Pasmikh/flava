import 'package:flava/models/player.dart';

extension PlayerListExtension on List<Player> {
  List<Player> updatePlayer(Player updatedPlayer) {
    return map((p) => p.id == updatedPlayer.id ? updatedPlayer : p).toList();
  }

  List<Player> updatePlayers(List<Player> updatedPlayers) {
    return map((p) {
      final updatedPlayer =
          updatedPlayers.firstWhere((up) => up.id == p.id, orElse: () => p);
      return updatedPlayer;
    }).toList();
  }

  List<Player> updateAllPlayers(Player Function(Player) update) {
    return map(update).toList();
  }
}
