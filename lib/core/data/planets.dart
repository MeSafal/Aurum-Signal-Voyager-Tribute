class Planet {
  final String name;
  final double diameterKm;
  final double distanceAu;
  final int color;
  final String? imageAsset;
  final String note;

  const Planet({
    required this.name,
    required this.diameterKm,
    required this.distanceAu,
    required this.color,
    this.imageAsset,
    this.note = '',
  });
}

const List<Planet> kPlanetLineup = [
  Planet(
    name: 'Sun',
    diameterKm: 1391400,
    distanceAu: 0,
    color: 0xFFF2C14E,
    note: 'Vector disc · no Voyager image',
  ),
  Planet(
    name: 'Mercury',
    diameterKm: 4879,
    distanceAu: 0.387,
    color: 0xFF9A8C7A,
    note: 'Vector disc · no Voyager image',
  ),
  Planet(
    name: 'Venus',
    diameterKm: 12104,
    distanceAu: 0.723,
    color: 0xFFE4C27A,
    note: 'Vector disc · no Voyager image',
  ),
  Planet(
    name: 'Earth',
    diameterKm: 12742,
    distanceAu: 1.0,
    color: 0xFF4C8FD6,
    note: 'Vector disc · no Voyager image',
  ),
  Planet(
    name: 'Mars',
    diameterKm: 6779,
    distanceAu: 1.524,
    color: 0xFFC0522F,
    note: 'Vector disc · no Voyager image',
  ),
  Planet(
    name: 'Jupiter',
    diameterKm: 139820,
    distanceAu: 5.203,
    color: 0xFFC89A6A,
    imageAsset: 'assets/images/jupiter_v1.jpg',
    note: 'Voyager 1 image',
  ),
  Planet(
    name: 'Saturn',
    diameterKm: 116460,
    distanceAu: 9.537,
    color: 0xFFD9C184,
    imageAsset: 'assets/images/saturn_v1.jpg',
    note: 'Voyager 1 image',
  ),
  Planet(
    name: 'Uranus',
    diameterKm: 50724,
    distanceAu: 19.19,
    color: 0xFF8FD3D8,
    imageAsset: 'assets/images/uranus_v2.jpg',
    note: 'Voyager 2 image',
  ),
  Planet(
    name: 'Neptune',
    diameterKm: 49244,
    distanceAu: 30.07,
    color: 0xFF5C7FD1,
    imageAsset: 'assets/images/neptune_v2.jpg',
    note: 'Voyager 2 image',
  ),
];

const List<Planet> kLadderBodies = [
  Planet(name: 'Sun', diameterKm: 1391400, distanceAu: 0, color: 0xFFF2C14E),
  Planet(name: 'Earth', diameterKm: 12742, distanceAu: 1, color: 0xFF4C8FD6),
  Planet(
    name: 'Jupiter',
    diameterKm: 139820,
    distanceAu: 5.203,
    color: 0xFFC89A6A,
  ),
  Planet(
    name: 'Saturn',
    diameterKm: 116460,
    distanceAu: 9.537,
    color: 0xFFD9C184,
  ),
  Planet(
    name: 'Neptune',
    diameterKm: 49244,
    distanceAu: 30.07,
    color: 0xFF5C7FD1,
  ),
];
