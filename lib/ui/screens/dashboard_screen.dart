import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwatering/services/blynk_api_service.dart';
import 'package:smartwatering/ui/screens/calibration_screen.dart';
import 'package:smartwatering/ui/widgets/moisture_chart.dart';

import '../../models/plant_data.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  final BlynkApiService _plantService =
      BlynkApiService();

  List<FlSpot> liveMoistureData = [];
  DateTime? _startTime;

  StreamSubscription<PlantData>?
  _plantDataSubscription;
  PlantData? _currentData;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _updateTimer;
  bool _isWatering = false;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    _plantDataSubscription = _plantService
        .listenToPlantData()
        .listen(
          (data) {
            if (!mounted) return;
            setState(() {
              _currentData = data;
              _isLoading = false;

              // _addPointToChart(data.soilMoisture);
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        );

    _updateTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (_currentData != null && mounted) {
          _addPointToChart(
            _currentData!.soilMoisture,
          );
        }
      },
    );
  }

  void _addPointToChart(int moistureValue) {
    double secondsElapsed = DateTime.now()
        .difference(_startTime!)
        .inSeconds
        .toDouble();

    setState(() {
      liveMoistureData.add(
        FlSpot(
          secondsElapsed,
          moistureValue.toDouble(),
        ),
      );

      if (liveMoistureData.length > 500) {
        liveMoistureData.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _plantDataSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1ABC9C),
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.energy_savings_leaf,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Flaura',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        /*
        actions: [
          IconButton(
            icon: Icon(
              _isWatering ? Icons.opacity : Icons.water_drop,
              color: Colors.white,
            ),
            onPressed: _isWatering
                ? null
                : () async {
                    setState(() {
                      _isWatering = true;
                    });

                    try {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int waterAmount = prefs.getInt('water_amount') ?? 250;

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sisteme $waterAmount mL su verme emri gönderildi!'),
                            backgroundColor: const Color(0xFF1ABC9C),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }

                      await _plantService.sendWaterCommand(waterAmount);

                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isWatering = false;
                        });
                      }
                    }
                  },
          ),
        ],
          */
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1ABC9C),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab(
                  context,
                  'DISPLAY',
                  isActive: true,
                  targetPage:
                      const DashboardScreen(),
                ),
                _buildTab(
                  context,
                  'SETTINGS',
                  targetPage:
                      const SettingsScreen(),
                ),
                _buildTab(
                  context,
                  'CALIBRATION',
                  targetPage:
                      const CalibrationScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1ABC9C),
        ),
      );
    }

    if (_hasError || _currentData == null) {
      return const Center(
        child: Text(
          'Sunucuya bağlanılamadı!\nAyarlardan Token\'ı kontrol et.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final data = _currentData!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            _buildGauge(
              'BATTERY LEVEL',
              data.batteryLevel,
              Colors.redAccent,
            ),
            _buildGauge(
              'WATER LEVEL',
              data.waterLevel,
              Colors.indigoAccent,
            ),
          ],
        ),
        const SizedBox(height: 40),

        MoistureChart(
          moistureData: liveMoistureData,
        ),

        const SizedBox(height: 10),

        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: Center(
            child: Text(
              'Toprak Nemi: %${data.soilMoisture}\nPompa: ${data.isPumping ? "ÇALIŞIYOR" : "KAPALI"}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isWatering
                ? Colors.grey
                : const Color(0xFF1ABC9C),
            padding: const EdgeInsets.all(15),
          ),
          onPressed: _isWatering
              ? null // Eğer zaten sulanıyorsa butonu devre dışı bırak
              : () async {
                  setState(() {
                    _isWatering = true;
                  });

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  int waterAmount =
                      prefs.getInt(
                        'water_amount',
                      ) ??
                      250;

                  // Snackbar'ı hemen göster
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sisteme $waterAmount mL su verme emri gönderildi!',
                        ),
                        backgroundColor:
                            const Color(
                              0xFF1ABC9C,
                            ),
                        duration: const Duration(
                          seconds: 3,
                        ),
                      ),
                    );
                  }

                  // Sulama simülasyonunu başlat
                  await _plantService
                      .sendWaterCommand(
                        waterAmount,
                      );

                  // İşlem bitince butonu tekrar aktif et
                  if (context.mounted) {
                    setState(() {
                      _isWatering = false;
                    });
                  }
                },
          child: Text(
            _isWatering
                ? 'SULANIYOR...'
                : 'BİTKİYİ SULA',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title, {
    bool isActive = false,
    Widget? targetPage,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        if (!isActive && targetPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => targetPage,
            ),
          );
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(
                top: 5,
              ),
              height: 2,
              width: 50,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  Widget _buildGauge(
    String title,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 10,
                backgroundColor:
                    Colors.grey.shade300,
                color: color,
              ),
            ),
            Text(
              '%$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
