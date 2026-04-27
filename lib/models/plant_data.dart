class PlantData {
  final int batteryLevel; // Pil %
  final int waterLevel; // Depodaki su %
  final int soilMoisture; // Toprak nemi %
  final bool isPumping; // O an su veriliyor mu?

  PlantData({
    required this.batteryLevel,
    required this.waterLevel,
    required this.soilMoisture,
    required this.isPumping,
  });

  PlantData copyWith({
    int? batteryLevel,
    int? waterLevel,
    int? soilMoisture,
    bool? isPumping,
  }) {
    return PlantData(
      batteryLevel:
          batteryLevel ?? this.batteryLevel,
      waterLevel: waterLevel ?? this.waterLevel,
      soilMoisture:
          soilMoisture ?? this.soilMoisture,
      isPumping: isPumping ?? this.isPumping,
    );
  }
  
  factory PlantData.fromJson(
    Map<String, dynamic> json,
  ) {
    return PlantData(
      batteryLevel: json['batteryLevel'] ?? 0,
      waterLevel: json['waterLevel'] ?? 0,
      soilMoisture: json['soilMoisture'] ?? 0,
      isPumping:
          json['isPumping'] == 1 ||
          json['isPumping'] == true,
    );
  }
}
