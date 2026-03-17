class WaterEntry {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String? containerName;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    this.containerName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountMl': amountMl,
        'timestamp': timestamp.toIso8601String(),
        'containerName': containerName,
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        id: json['id'] as String,
        amountMl: json['amountMl'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        containerName: json['containerName'] as String?,
      );
}

class DrinkContainer {
  final String name;
  final int amountMl;
  final String icon;

  const DrinkContainer({
    required this.name,
    required this.amountMl,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amountMl': amountMl,
        'icon': icon,
      };

  factory DrinkContainer.fromJson(Map<String, dynamic> json) => DrinkContainer(
        name: json['name'] as String,
        amountMl: json['amountMl'] as int,
        icon: json['icon'] as String,
      );

  static const defaults = [
    DrinkContainer(name: 'Glass', amountMl: 250, icon: '🥛'),
    DrinkContainer(name: 'Bottle', amountMl: 500, icon: '🍶'),
    DrinkContainer(name: 'Large Bottle', amountMl: 750, icon: '🧴'),
    DrinkContainer(name: 'Mug', amountMl: 350, icon: '☕'),
  ];
}
