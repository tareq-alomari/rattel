class Athan {
  final String id;
  final String name;
  final String muezzin;
  final String location;
  final String audioUrl;

  Athan({
    required this.id,
    required this.name,
    required this.muezzin,
    required this.location,
    required this.audioUrl,
  });

  factory Athan.fromMap(Map<String, dynamic> map) {
    return Athan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      muezzin: map['muezzin'] ?? '',
      location: map['location'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }
}
