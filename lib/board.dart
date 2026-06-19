import 'station.dart';

class Board {
  static const int stationCount = 29;
  static const int startStation = 1;
  static const int finishStation = 1;

  final List<Station> stations;

  Board() : stations = _createStations() {
    validate();
  }

  static List<Station> _createStations() {
    return const [
      Station(id: 1, nextStations: [2]),
      Station(id: 2, nextStations: [3]),
      Station(id: 3, nextStations: [4]),
      Station(id: 4, nextStations: [5]),
      Station(id: 5, nextStations: [6]),

      // Upper-right corner shortcut.
      Station(id: 6, nextStations: [7, 21]),

      Station(id: 7, nextStations: [8]),
      Station(id: 8, nextStations: [9]),
      Station(id: 9, nextStations: [10]),
      Station(id: 10, nextStations: [11]),

      // Upper-left corner shortcut.
      Station(id: 11, nextStations: [12, 26]),

      Station(id: 12, nextStations: [13]),
      Station(id: 13, nextStations: [14]),
      Station(id: 14, nextStations: [15]),
      Station(id: 15, nextStations: [16]),
      Station(id: 16, nextStations: [17]),
      Station(id: 17, nextStations: [18]),
      Station(id: 18, nextStations: [19]),
      Station(id: 19, nextStations: [20]),
      Station(id: 20, nextStations: [1]),

      // Shortcut path from station 6.
      Station(id: 21, nextStations: [22]),
      Station(id: 22, nextStations: [23]),

      // Center station gives two possible paths.
      Station(id: 23, nextStations: [24, 28]),

      // Center path toward station 16.
      Station(id: 24, nextStations: [25]),
      Station(id: 25, nextStations: [16]),

      // Shortcut path from station 11.
      Station(id: 26, nextStations: [27]),
      Station(id: 27, nextStations: [23]),

      // Center path toward finish.
      Station(id: 28, nextStations: [29]),
      Station(id: 29, nextStations: [1]),
    ];
  }

  bool isValidStation(int position) {
    return position >= 1 && position <= stationCount;
  }

  Station getStation(int position) {
    if (!isValidStation(position)) {
      throw ArgumentError('Invalid station: $position');
    }

    return stations.firstWhere(
      (station) => station.id == position,
    );
  }

  int getNextStation(
    int position, {
    bool useShortcut = false,
  }) {
    final Station station = getStation(position);

    if (station.nextStations.isEmpty) {
      throw StateError('Station $position has no next station.');
    }

    if (useShortcut && station.nextStations.length > 1) {
      return station.nextStations[1];
    }

    return station.nextStations[0];
  }

  int getPreviousStation(int position) {
    if (!isValidStation(position)) {
      throw ArgumentError('Invalid station: $position');
    }

    final List<Station> previousStations = stations
        .where((station) => station.nextStations.contains(position))
        .toList();

    if (previousStations.isEmpty) {
      throw StateError('Station $position has no previous station.');
    }

    return previousStations.first.id;
  }

  bool hasShortcut(int position) {
    final Station station = getStation(position);
    return station.nextStations.length > 1;
  }

  void validate() {
    if (stations.length != stationCount) {
      throw StateError('Board must have exactly $stationCount stations.');
    }

    final Set<int> ids = {};

    for (final Station station in stations) {
      if (!isValidStation(station.id)) {
        throw StateError('Invalid station id: ${station.id}');
      }

      if (ids.contains(station.id)) {
        throw StateError('Duplicate station id: ${station.id}');
      }

      ids.add(station.id);

      if (station.nextStations.isEmpty) {
        throw StateError('Station ${station.id} must have a next station.');
      }

      for (final int next in station.nextStations) {
        if (!isValidStation(next)) {
          throw StateError(
            'Station ${station.id} points to invalid station $next.',
          );
        }
      }
    }
  }
}