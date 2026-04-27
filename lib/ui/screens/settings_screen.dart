import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwatering/services/blynk_api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final TextEditingController _tokenController =
      TextEditingController();
  final TextEditingController
  _waterAmountController =
      TextEditingController();
  final TextEditingController
  _sleepDurationController =
      TextEditingController();
  final BlynkApiService _apiService =
      BlynkApiService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _tokenController.text =
          prefs.getString('blynk_token') ?? '';
      _waterAmountController.text =
          prefs
              .getInt('water_amount')
              ?.toString() ??
          '250';
      _sleepDurationController.text =
          prefs
              .getInt('sleep_duration')
              ?.toString() ??
          '60';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    await prefs.setString(
      'blynk_token',
      _tokenController.text,
    );

    int waterAmount = int.parse(
      _waterAmountController.text,
    );
    int sleepDuration = int.parse(
      _sleepDurationController.text,
    );

    await prefs.setInt(
      'water_amount',
      waterAmount,
    );
    await prefs.setInt(
      'sleep_duration',
      sleepDuration,
    );
    await _apiService.updatePin(
      'V107',
      waterAmount,
    );
    await _apiService.updatePin(
      'V105',
      sleepDuration,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ayarlar başarıyla kaydedildi ve ESP32\'ye iletildi!',
        ),
        backgroundColor: Color(0xFF1ABC9C),
      ),
    );
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
          'Ayarlar',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "CİHAZ BAĞLANTI AYARLARI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _tokenController,
              "Blynk Auth Token",
              "Token'ı buraya yapıştır",
              Icons.vpn_key,
            ),

            const SizedBox(height: 30),

            const Text(
              "SULAMA VE UYKU AYARLARI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _waterAmountController,
              "Su Miktarı (mL)",
              "Örn: 250",
              Icons.water_drop,
              isNumber: true,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _sleepDurationController,
              "Uyku Süresi (Dakika)",
              "Örn: 60",
              Icons.timer,
              isNumber: true,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1ABC9C,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  "AYARLARI KAYDET",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1ABC9C),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
