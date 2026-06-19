import 'piece.dart';
import 'player.dart';

class Team {
  final int teamNumber;
  final List<Piece> pieces = [];
  final List<Player> players = [];

  Team({
    required this.teamNumber,
  }) {
    for (int i = 1; i <= 4; i++) {
      pieces.add(
        Piece(
          id: i,
          teamNumber: teamNumber,
        ),
      );
    }
  }

  @override
  String toString() {
    return 'Team(teamNumber: $teamNumber, players: ${players.length}, pieces: ${pieces.length})';
  }
}