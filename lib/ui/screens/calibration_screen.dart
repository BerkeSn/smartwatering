import 'package:flutter/material.dart';
import 'package:smartwatering/services/blynk_api_service.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() =>
      _CalibrationScreenState();
}

class _CalibrationScreenState
    extends State<CalibrationScreen> {
  bool _isCalibratingDry = false;
  bool _isCalibratingWet = false;

  final BlynkApiService _apiService =
      BlynkApiService();

  Future<void> _calibrateDry() async {
    setState(() => _isCalibratingDry = true);

    try {
      await _apiService.updatePin("V7", 1);
      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;
      setState(() => _isCalibratingDry = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kuru toprak (0%) komutu ESP32\'ye iletildi!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() => _isCalibratingDry = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bağlantı hatası! Token ayarlarınızı kontrol edin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _calibrateWet() async {
    setState(() => _isCalibratingWet = true);

    try {
      await _apiService.updatePin("V8", 1);

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;
      setState(() => _isCalibratingWet = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Su içi (100%) komutu ESP32\'ye iletildi!',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() => _isCalibratingWet = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bağlantı hatası! Token ayarlarınızı kontrol edin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1ABC9C),
        title: const Text(
          'Sensör Kalibrasyonu',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Sensörünüzün doğru nem yüzdesini gösterebilmesi için aşağıdaki iki adımı sırasıyla uygulayın.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // 1. ADIM: KURU KALİBRASYON
            _buildCalibrationCard(
              title: "ADIM 1: Kuru Sensör (0%)",
              description:
                  "Sensörü topraktan çıkarın, ucunu peçeteyle kurulayın ve havada tutarken aşağıdaki butona basın.",
              icon: Icons.air,
              iconColor: Colors.orange,
              isLoading: _isCalibratingDry,
              onTap: _calibrateDry,
              buttonText: "KURU DEĞERİ OKU",
            ),

            const SizedBox(height: 20),

            // 2. ADIM: ISLAK KALİBRASYON
            _buildCalibrationCard(
              title:
                  "ADIM 2: Islak Sensör (100%)",
              description:
                  "Sensörün okuyucu ucunu bir bardak suyun içine (veya çamura) daldırın ve aşağıdaki butona basın.",
              icon: Icons.water,
              iconColor: Colors.blue,
              isLoading: _isCalibratingWet,
              onTap: _calibrateWet,
              buttonText: "ISLAK DEĞERİ OKU",
            ),
          ],
        ),
      ),
    );
  }

  // Kartları çizen yardımcı fonksiyon
  Widget _buildCalibrationCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isLoading,
    required VoidCallback onTap,
    required String buttonText,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor,
                  child: Icon(
                    icon,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : onTap,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                      )
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
