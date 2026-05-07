import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoistureChart extends StatelessWidget {
  final List<FlSpot> moistureData;

  const MoistureChart({
    super.key,
    required this.moistureData,
  });

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '0s';
    if (totalSeconds < 60)
      return '${totalSeconds}sn';

    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;

    // Sadece tam dakikalarda etiket basarsak çakışma azalır
    if (s == 0) return '${m}dk';
    return ''; // Saniyeli değerleri boş dönersek grafik daha temiz görünür
  }

  @override
  Widget build(BuildContext context) {
    // 1. GENİŞLİK HESABI (Her 60 saniye için 150 pixel yer ayırıyoruz)
    // Bu sayede grafik süre uzadıkça sağa doğru genişler ve kaydırılabilir olur.
    double dynamicMaxX = moistureData.isEmpty
        ? 60
        : moistureData.last.x;
    double pixelsPerSecond =
        150 / 60; // 60 saniye = 150 pixel
    double chartWidth =
        dynamicMaxX * pixelsPerSecond;

    double minWidth =
        MediaQuery.of(context).size.width - 40;
    double finalWidth = chartWidth < minWidth
        ? minWidth
        : chartWidth;

    // 2. X EKSENİ SINIRLARI
    double dynamicMinX =
        0; // Her zaman 0'dan başlasın ki geçmişi görebilelim
    // Sağ tarafa 30 saniyelik bir "nefes alma" boşluğu ekleyelim
    double maxXWithPadding = dynamicMaxX + 30;

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grass,
                  color: Color(0xFF1ABC9C),
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  'TOPRAK NEM GEÇMİŞİ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // reverse: true kalsın, böylece her zaman en yeni veriye (sağa) odaklanır
              reverse: true,
              child: Container(
                width: finalWidth,
                padding: const EdgeInsets.only(
                  right: 30,
                  left: 10,
                  bottom: 10,
                ),
                child: LineChart(
                  LineChartData(
                    minX: dynamicMinX,
                    maxX: maxXWithPadding,
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 25,
                      verticalInterval:
                          60, // Izgara çizgileri de dakikada bir olsun
                      getDrawingVerticalLine:
                          (value) => FlLine(
                            color: Colors.grey
                                .withOpacity(0.1),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          const AxisTitles(
                            sideTitles:
                                SideTitles(
                                  showTitles:
                                      false,
                                ),
                          ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 25,
                          reservedSize: 35,
                          getTitlesWidget:
                              (
                                value,
                                meta,
                              ) => Text(
                                '%${value.toInt()}',
                                style:
                                    const TextStyle(
                                      color: Colors
                                          .grey,
                                      fontSize:
                                          10,
                                    ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval:
                              60, // Sadece 60 saniyede bir etiket koy (1dk, 2dk...)
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 8.0,
                                  ),
                              child: Text(
                                _formatTime(
                                  value.toInt(),
                                ),
                                style:
                                    const TextStyle(
                                      color: Colors
                                          .grey,
                                      fontSize:
                                          10,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            moistureData.isEmpty
                            ? [const FlSpot(0, 0)]
                            : moistureData,
                        isCurved: true,
                        color: const Color(
                          0xFF1ABC9C,
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(
                          show: true,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(
                            0xFF1ABC9C,
                          ).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
