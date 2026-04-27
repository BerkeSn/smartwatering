import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoistureChart extends StatelessWidget {
  final List<FlSpot> moistureData;

  const MoistureChart({
    super.key,
    required this.moistureData,
  });

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}sn';
    } else if (totalSeconds < 3600) {
      int m = totalSeconds ~/ 60;
      int s = totalSeconds % 60;
      return s == 0
          ? '${m}dk'
          : '${m}dk ${s}sn';
    } else {
      int h = totalSeconds ~/ 3600;
      int m = (totalSeconds % 3600) ~/ 60;
      return m == 0
          ? '${h}sa'
          : '${h}sa ${m}dk';
    }
  }

  @override
  Widget build(BuildContext context) {
    double chartWidth =
        moistureData.length * 50.0;
    double minWidth =
        MediaQuery.of(context).size.width -
        40; 
    double finalWidth = chartWidth < minWidth
        ? minWidth
        : chartWidth;

    double dynamicMinX = moistureData.isEmpty
        ? 0
        : moistureData.first.x;
    double dynamicMaxX = moistureData.isEmpty
        ? 10
        : moistureData.last.x + 2;

    double timeDifference =
        dynamicMaxX - dynamicMinX;
    double dynamicInterval = timeDifference > 120
        ? 15
        : 5;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // ÜST BAŞLIK KISMI
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
                  'SOIL MOISTURE',
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
              reverse:
                  true,
              child: Container(
                width:
                    finalWidth,
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 10,
                  bottom: 10,
                ),
                child: LineChart(
                  LineChartData(
                    minX: dynamicMinX,
                    maxX: dynamicMaxX,
                    minY: 0,
                    maxY: 100,
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
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
                          reservedSize: 30,
                          getTitlesWidget:
                              (
                                value,
                                meta,
                              ) => Text(
                                value
                                    .toInt()
                                    .toString(),
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
                              dynamicInterval,
                          getTitlesWidget:
                              (
                                value,
                                meta,
                              ) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                      top: 8.0,
                                    ),
                                child: Text(
                                  _formatTime(
                                    value.toInt(),
                                  ),
                                  style: const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
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
                            ? const [FlSpot(0, 0)]
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
                          ),
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
