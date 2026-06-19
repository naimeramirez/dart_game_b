import 'game_state.dart';
import 'piece.dart';
import 'player.dart';

abstract class GameEngine {
  GameState get state;

  int throwSticks();

  void movePiece(Piece piece, int moveValue);

  Player? get currentPlayer;
}