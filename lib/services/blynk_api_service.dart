import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_data.dart';

class BlynkApiService {
  final String _baseUrl =
      "https://blynk.cloud/external/api";

  Future<String?> _getToken() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getString('blynk_token');
  }

  Future<PlantData> fetchAllData() async {
    final token = await _getToken();

    print(
      "[DEBUG] fetchAllData tetiklendi. Okunan Token: '$token'",
    );

    if (token == null || token.isEmpty) {
      print(
        "[DEBUG] HATA: Token henüz kaydedilmemiş veya boş!",
      );
      throw Exception("Token bulunamadı!");
    }

    try {
      print(
        "🚨 [DEBUG] Blynk'ten V100 verisi isteniyor...",
      );
      final moisture = await _getPinValue(
        token,
        "V100",
      );
      final water = await _getPinValue(
        token,
        "V101",
      );
      final battery = await _getPinValue(
        token,
        "V102",
      );
      final pump = await _getPinValue(
        token,
        "V103",
      );

      print(
        "🚨 [DEBUG] Veriler başarıyla alındı! Nem: %$moisture",
      );

      return PlantData(
        soilMoisture: moisture,
        waterLevel: water,
        batteryLevel: battery,
        isPumping: pump == 1,
      );
    } catch (e) {
      print(
        "[DEBUG] Veri çekme sırasında KRİTİK HATA: $e",
      );
      rethrow;
    }
  }

  Future<int> _getPinValue(
    String token,
    String pin,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/get?token=$token&$pin",
        ),
      );
      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      }
    } catch (e) {
      print("Pin okuma hatası ($pin): $e");
    }
    return 0;
  }

  Future<void> updatePin(
    String pin,
    int value,
  ) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/update?token=$token&$pin=$value",
        ),
      );
      if (response.statusCode != 200) {
        print(
          "Blynk Güncelleme Hatası: ${response.body}",
        );
      }
    } catch (e) {
      print("Pin güncelleme hatası ($pin): $e");
    }
  }

  Stream<PlantData> listenToPlantData() async* {
    print(
      "RADAR AÇILDI: listenToPlantData başladı!",
    );
    while (true) {
      try {
        yield await fetchAllData();
      } catch (e) {
        print("Blynk Bağlantı Hatası: $e");
      }
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
  }

  Future<void> sendWaterCommand(
    int amount,
  ) async {
    await updatePin("V103", 1);
    await updatePin("V107", amount);
  }
}
