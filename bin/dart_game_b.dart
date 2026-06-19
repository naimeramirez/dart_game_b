import 'dart:io';

import 'package:dart_game_b/board.dart';
import 'package:dart_game_b/game.dart';
import 'package:dart_game_b/piece.dart';
import 'package:dart_game_b/piece_status.dart';
import 'package:dart_game_b/player.dart';

void main() {
  final Game game = Game();

  if (game.state.board.stations.length != Board.stationCount) {
    throw StateError('Board must have exactly 29 stations.');
  }

  print('Game B Engine Started');
  print('=====================');

  int turn = 1;
  bool keepPlaying = true;

  while (keepPlaying) {
    print('\nTurn $turn');

    final Player currentPlayer = game.currentPlayer!;

    print('Current Team: ${currentPlayer.team.teamNumber}');
    print('Current Player: ${currentPlayer.displayName}');

    final int moveValue = game.throwSticks();

    print('Throw result: $moveValue');

    final List<Piece> movablePieces = game.movablePiecesForCurrentPlayer(
      moveValue,
    );

    if (movablePieces.isEmpty) {
      if (moveValue == 0) {
        print('Player rolls again.');
      } else {
        print('No movable pieces.');
      }

      print('Moved piece: none');

      stdout.write('\nContinue? (y/n): ');
      final String? answer = stdin.readLineSync();
      keepPlaying = answer == null || answer.toLowerCase() != 'n';

      if (keepPlaying) {
        turn++;
      }

      continue;
    }

    final Piece piece = movablePieces.first;

    bool useShortcut = false;

    if (moveValue > 0 && game.canUseShortcut(piece)) {
      useShortcut = true;
      print('Shortcut available.');
      print('Taking shortcut: yes');
    }

    game.movePieceWithShortcut(
      piece,
      moveValue,
      useShortcut: useShortcut,
    );

    print('Moved piece: $piece');

    if (piece.status == PieceStatus.completed) {
      print('Piece completed.');
    } else {
      print('Current position: ${piece.position}');
    }

    if (moveValue == 0 || moveValue == 5) {
      print('Same player rolls again.');
    }

    stdout.write('\nContinue? (y/n): ');
    final String? answer = stdin.readLineSync();
    keepPlaying = answer == null || answer.toLowerCase() != 'n';

    if (keepPlaying) {
      turn++;
    }
  }

  print('\nGame stopped.');
}