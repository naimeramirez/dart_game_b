import 'piece_status.dart';

class Piece {
  final int id;
  final int teamNumber;

  PieceStatus status;
  int? position;

  Piece({
    required this.id,
    required this.teamNumber,
    this.status = PieceStatus.inactive,
    this.position,
  });

  bool get isInactive => status == PieceStatus.inactive;

  bool get isActive => status == PieceStatus.active;

  bool get isCompleted => status == PieceStatus.completed;

  @override
  String toString() {
    return 'Piece(id: $id, team: $teamNumber, status: $status, position: $position)';
  }
}