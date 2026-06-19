class Station {
  final int id;
  final List<int> nextStations;

  const Station({
    required this.id,
    required this.nextStations,
  });

  @override
  String toString() {
    return 'Station(id: $id, nextStations: $nextStations)';
  }
}