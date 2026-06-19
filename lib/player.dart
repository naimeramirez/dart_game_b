import 'team.dart';

class Player {
  final int id;
  final String displayName;
  final Team team;

  Player({
    required this.id,
    required this.displayName,
    required this.team,
  });

  @override
  String toString() {
    return 'Player(id: $id, displayName: $displayName, team: ${team.teamNumber})';
  }
}