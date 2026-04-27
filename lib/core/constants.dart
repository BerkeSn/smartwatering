class AppConstants {
  // ESP32'den Bize Gelen Verilerin Anahtarları (Blynk Virtual Pins)
  static const String pinSoilMoisture =
      'V100'; // Toprak Nemi (%)
  static const String pinWaterLevel =
      'V101'; // Tanktaki Su Seviyesi (%)
  static const String pinBatteryLevel =
      'V102'; // Pil Yüzdesi (%)
  static const String pinIsPumping =
      'V103'; // Pompa çalışıyor mu? (1/0)

  // Bizden ESP32'ye Gidecek Ayarların Anahtarları
  static const String pinSleepDuration =
      'V105'; // Uyku süresi (dk)
  static const String pinCriticalMoisture =
      'V106'; // Pompanın çalışacağı kritik nem (%)
  static const String pinWaterAmount =
      'V107'; // Verilecek su (mL)
}