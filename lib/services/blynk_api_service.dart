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
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    print(
      "💧 [SİMÜLASYON] Sulama komutu tetiklendi: $amount mL",
    );

    // 1. Önce güncel durumu okuyalım (Sanki sensörden okuyormuşuz gibi)
    int currentMoisture = await _getPinValue(
      token,
      "V100",
    );
    int currentWaterLevel = await _getPinValue(
      token,
      "V101",
    );

    if (currentWaterLevel < 10) {
      // %10'un altındaysa
      print(
        "❌ [HATA] Su seviyesi çok düşük (%$currentWaterLevel), sulama yapılamaz!",
      );
      // Burada bir hata fırlatabiliriz ki UI tarafında SnackBar ile gösterelim
      throw Exception(
        "Yetersiz su seviyesi! Lütfen tankı doldur.",
      );
    }

    // 2. Pompayı aç (V103 = 1) ve verilecek su miktarını yolla (V107)
    await updatePin("V103", 1);
    await updatePin("V107", amount);

    // Sulama işlemi için 3 saniyelik bir gecikme simüle edelim (Pompa çalışıyor hissi)
    await Future.delayed(
      const Duration(seconds: 3),
    );

    // 3. MATEMATİKSEL SİMÜLASYON (Burası işin kalbi)
    // Formül: Her 10 mL su, tankı %1 azaltsın ve toprağı %2 nemlendirsin.
    // (Bu oranları kendi saksına göre ayarlayabilirsin kanka)
    int waterDecrease = (amount / 10).round();
    int moistureIncrease = (amount / 5).round();

    // Yeni seviyeleri hesapla ve sınırları koru (0-100 arası)
    int newWaterLevel =
        currentWaterLevel - waterDecrease;
    if (newWaterLevel < 0) newWaterLevel = 0;

    int newMoisture =
        currentMoisture + moistureIncrease;
    if (newMoisture > 100) newMoisture = 100;

    // 4. Yeni hesaplanan değerleri Blynk veri tabanına yaz
    await updatePin("V101", newWaterLevel);
    await updatePin("V100", newMoisture);

    // 5. Pompayı kapat (V103 = 0)
    await updatePin("V103", 0);

    print(
      "✅ [SİMÜLASYON] Tamamlandı! Yeni Su Tankı: %$newWaterLevel, Yeni Nem: %$newMoisture",
    );
  }
}
