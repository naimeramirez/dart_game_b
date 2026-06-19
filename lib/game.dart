import 'dart:math';

import 'board.dart';
import 'game_engine.dart';
import 'game_state.dart';
import 'piece.dart';
import 'piece_status.dart';
import 'player.dart';
import 'team.dart';

class Game implements GameEngine {
  static const Set<int> validMoveValues = {-1, 0, 1, 2, 3, 5};

  final Random _random;
  late final GameState _state;

  Game({
    Random? random,
  }) : _random = random ?? Random() {
    final Board board = Board();

    final Team team1 = Team(teamNumber: 1);
    final Team team2 = Team(teamNumber: 2);

    final Player player1 = Player(
      id: 1,
      displayName: 'Team 1 Player 1',
      team: team1,
    );

    final Player player2 = Player(
      id: 2,
      displayName: 'Team 2 Player 1',
      team: team2,
    );

    final Player player3 = Player(
      id: 3,
      displayName: 'Team 1 Player 2',
      team: team1,
    );

    final Player player4 = Player(
      id: 4,
      displayName: 'Team 2 Player 2',
      team: team2,
    );

    team1.players.addAll([player1, player3]);
    team2.players.addAll([player2, player4]);

    _state = GameState(
      board: board,
      teams: [team1, team2],
      players: [player1, player2, player3, player4],
    );

    validateInvariants();
  }

  @override
  GameState get state => _state;

  @override
  Player? get currentPlayer => _state.currentPlayer;

  @override
  int throwSticks() {
    final int flatSideCount = _random.nextInt(5);

    final bool xSymbolIsShowing = flatSideCount > 0 && _random.nextBool();

    final int result;

    if (flatSideCount == 0) {
      result = 0;
    } else if (flatSideCount == 1 && xSymbolIsShowing) {
      result = -1;
    } else if (flatSideCount == 4) {
      result = 5;
    } else {
      result = flatSideCount;
    }

    _state.lastThrow = result;
    validateInvariants();

    return result;
  }

  @override
  void movePiece(Piece piece, int moveValue) {
    movePieceWithShortcut(
      piece,
      moveValue,
      useShortcut: false,
    );
  }

  void movePieceWithShortcut(
    Piece piece,
    int moveValue, {
    bool useShortcut = false,
  }) {
    _validateMoveValue(moveValue);
    _validatePieceBelongsToCurrentTeam(piece);

    if (moveValue == 0) {
      _finishTurn(moveValue);
      validateInvariants();
      return;
    }

    if (moveValue == -1) {
      _moveBackward(piece);
      _finishTurn(moveValue);
      validateInvariants();
      return;
    }

    _moveForward(
      piece,
      moveValue,
      useShortcut: useShortcut,
    );

    _finishTurn(moveValue);
    validateInvariants();
  }

  bool canUseShortcut(Piece piece) {
    if (piece.status != PieceStatus.active || piece.position == null) {
      return false;
    }

    return _state.board.hasShortcut(piece.position!);
  }

  List<Piece> movablePiecesForCurrentPlayer(int moveValue) {
    _validateMoveValue(moveValue);

    final Player player = _requireCurrentPlayer();
    final List<Piece> teamPieces = player.team.pieces;

    if (moveValue == 0) {
      return [];
    }

    if (moveValue == -1) {
      return teamPieces
          .where((piece) => piece.status == PieceStatus.active)
          .toList();
    }

    return teamPieces
        .where((piece) => piece.status != PieceStatus.completed)
        .toList();
  }

  void _moveForward(
    Piece piece,
    int spaces, {
    required bool useShortcut,
  }) {
    if (spaces <= 0) {
      throw ArgumentError('Forward movement must be positive.');
    }

    if (piece.status == PieceStatus.completed) {
      throw StateError('Completed pieces cannot move.');
    }

    if (piece.status == PieceStatus.inactive) {
      piece.status = PieceStatus.active;
      piece.position = Board.startStation;

      if (spaces == 1) {
        return;
      }

      spaces--;
    }

    if (piece.position == null) {
      throw StateError('Active piece must have a position.');
    }

    for (int i = 0; i < spaces; i++) {
      final bool shouldUseShortcut = i == 0 && useShortcut;

      if (shouldUseShortcut && !canUseShortcut(piece)) {
        throw StateError(
          'Cannot use shortcut from station ${piece.position}.',
        );
      }

      final int currentPosition = piece.position!;
      final int nextPosition = _state.board.getNextStation(
        currentPosition,
        useShortcut: shouldUseShortcut,
      );

      piece.position = nextPosition;

      if (currentPosition != Board.startStation &&
          nextPosition == Board.finishStation) {
        piece.status = PieceStatus.completed;
        piece.position = null;
        return;
      }
    }
  }

  void _moveBackward(Piece piece) {
    if (piece.status != PieceStatus.active || piece.position == null) {
      throw StateError('Only active pieces can move backward.');
    }

    piece.position = _state.board.getPreviousStation(piece.position!);
  }

  void _finishTurn(int moveValue) {
    if (moveValue == 0 || moveValue == 5) {
      return;
    }

    _state.currentPlayerIndex =
        (_state.currentPlayerIndex + 1) % _state.players.length;
  }

  Player _requireCurrentPlayer() {
    final Player? player = currentPlayer;

    if (player == null) {
      throw StateError('There is no current player.');
    }

    return player;
  }

  void _validateMoveValue(int moveValue) {
    if (!validMoveValues.contains(moveValue)) {
      throw ArgumentError(
        'Invalid move value $moveValue. Expected one of $validMoveValues.',
      );
    }
  }

  void _validatePieceBelongsToCurrentTeam(Piece piece) {
    final Player player = _requireCurrentPlayer();

    if (!player.team.pieces.contains(piece)) {
      throw StateError(
        'The selected piece does not belong to the current player team.',
      );
    }
  }

  void validateInvariants() {
    _validateStructuralInvariant();
    _validatePieceStateInvariant();
    _validateTurnStateInvariant();
    _validatePlayerStateInvariant();
  }

  void _validateStructuralInvariant() {
    _state.board.validate();
  }

  void _validatePieceStateInvariant() {
    for (final Team team in _state.teams) {
      for (final Piece piece in team.pieces) {
        if (piece.status == PieceStatus.inactive && piece.position != null) {
          throw StateError(
            'Inactive piece ${piece.id} on team ${team.teamNumber} must not have a position.',
          );
        }

        if (piece.status == PieceStatus.completed && piece.position != null) {
          throw StateError(
            'Completed piece ${piece.id} on team ${team.teamNumber} must not have a position.',
          );
        }

        if (piece.status == PieceStatus.active) {
          if (piece.position == null) {
            throw StateError(
              'Active piece ${piece.id} on team ${team.teamNumber} must have a position.',
            );
          }

          if (!_state.board.isValidStation(piece.position!)) {
            throw StateError(
              'Piece ${piece.id} on team ${team.teamNumber} has invalid position ${piece.position}.',
            );
          }
        }
      }
    }
  }

  void _validateTurnStateInvariant() {
    if (_state.players.isEmpty) {
      throw StateError('Game must have players.');
    }

    if (_state.currentPlayerIndex < 0 ||
        _state.currentPlayerIndex >= _state.players.length) {
      throw StateError(
        'Current player index ${_state.currentPlayerIndex} is out of range.',
      );
    }

    if (_state.lastThrow != null &&
        !validMoveValues.contains(_state.lastThrow)) {
      throw StateError('Invalid last throw value: ${_state.lastThrow}.');
    }
  }

  void _validatePlayerStateInvariant() {
    if (_state.teams.length != 2) {
      throw StateError('Game must have exactly 2 teams.');
    }

    if (_state.players.length != 4) {
      throw StateError('Game must have exactly 4 players.');
    }

    for (final Team team in _state.teams) {
      if (team.players.length != 2) {
        throw StateError(
          'Team ${team.teamNumber} must have exactly 2 players.',
        );
      }

      if (team.pieces.length != 4) {
        throw StateError(
          'Team ${team.teamNumber} must have exactly 4 pieces.',
        );
      }

      for (final Player player in team.players) {
        if (player.team != team) {
          throw StateError(
            'Player ${player.displayName} is assigned to the wrong team.',
          );
        }
      }

      for (final Piece piece in team.pieces) {
        if (piece.teamNumber != team.teamNumber) {
          throw StateError(
            'Piece ${piece.id} has wrong team number ${piece.teamNumber}.',
          );
        }
      }
    }
  }
}