import 'board.dart';
import 'player.dart';
import 'team.dart';

class GameState {
  final Board board;
  final List<Team> teams;
  final List<Player> players;

  int currentPlayerIndex;
  int? lastThrow;

  GameState({
    required this.board,
    required this.teams,
    required this.players,
    this.currentPlayerIndex = 0,
    this.lastThrow,
  });

  Player? get currentPlayer {
    if (players.isEmpty) {
      return null;
    }

    return players[currentPlayerIndex];
  }
}