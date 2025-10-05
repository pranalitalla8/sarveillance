import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/time_series_data.dart';
import '../services/time_series_service.dart';
import '../widgets/trend_analysis_card.dart';
import '../widgets/seasonal_pattern_card.dart';
import '../widgets/weather_correlation_card.dart';

class TimeSeriesScreen extends StatefulWidget {
  const TimeSeriesScreen({super.key});

  @override
  State<TimeSeriesScreen> createState() => _TimeSeriesScreenState();
}

class _TimeSeriesScreenState extends State<TimeSeriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _timeSeriesService = TimeSeriesService();
  late OilDetectionTimeSeries _timeSeries;
  bool _isLoading = true;
  String _selectedView = 'daily'; // daily, weekly, monthly

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _timeSeries = _timeSeriesService.generateTimeSeriesData(dataPoints: 548);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Series Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Timeline'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Seasonal'),
            Tab(icon: Icon(Icons.cloud), text: 'Weather'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() => _selectedView = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'daily', child: Text('Daily View')),
              const PopupMenuItem(value: 'weekly', child: Text('Weekly View')),
              const PopupMenuItem(value: 'monthly', child: Text('Monthly View')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildTrendsTab(),
                _buildSeasonalTab(),
                _buildWeatherTab(),
              ],
            ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(),
          const SizedBox(height: 24),
          _buildMainTimeSeriesChart(),
          const SizedBox(height: 24),
          _buildDetectionAreaChart(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview (${_timeSeries.dataPoints.length} days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Detections',
                    '${_timeSeries.totalDetections}',
                    Icons.warning_amber,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Daily Average',
                    _timeSeries.averageDetectionsPerDay.toStringAsFixed(1),
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Peak Day',
                    '${_timeSeries.maxDetections}',
                    Icons.trending_up,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Date Range',
                    '${DateFormat('MMM d').format(_timeSeries.startDate)} - ${DateFormat('MMM d').format(_timeSeries.endDate)}',
                    Icons.date_range,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimeSeriesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oil Detections Over Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Daily detection counts showing temporal patterns',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                _createMainChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createMainChartData() {
    // Sample every N points for performance
    final sampleRate = _selectedView == 'monthly' ? 30 : _selectedView == 'weekly' ? 7 : 1;
    final sampledData = <FlSpot>[];
    
    for (int i = 0; i < _timeSeries.dataPoints.length; i += sampleRate) {
      if (_selectedView == 'daily') {
        sampledData.add(FlSpot(
          i.toDouble(),
          _timeSeries.dataPoints[i].detectionCount.toDouble(),
        ));
      } else {
        // Average over the period
        final endIdx = (i + sampleRate).clamp(0, _timeSeries.dataPoints.length);
        final periodData = _timeSeries.dataPoints.sublist(i, endIdx);
        final avg = periodData.fold(0, (sum, p) => sum + p.detectionCount) / periodData.length;
        sampledData.add(FlSpot(i.toDouble(), avg));
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: _timeSeries.dataPoints.length / 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _timeSeries.dataPoints.length / 6,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _timeSeries.dataPoints.length) {
                final date = _timeSeries.dataPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM\nyy').format(date),
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: sampledData,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < _timeSeries.dataPoints.length) {
                final point = _timeSeries.dataPoints[index];
                return LineTooltipItem(
                  '${DateFormat('MMM d, y').format(point.date)}\n${point.detectionCount} detections',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildDetectionAreaChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cumulative Detection Area',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total area affected by oil spills (km²)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                _createAreaChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createAreaChartData() {
    final spots = <FlSpot>[];
    double cumulativeArea = 0;
    
    for (int i = 0; i < _timeSeries.dataPoints.length; i++) {
      cumulativeArea += _timeSeries.dataPoints[i].totalAreaKm2;
      spots.add(FlSpot(i.toDouble(), cumulativeArea));
    }

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toStringAsFixed(1)}k',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _timeSeries.dataPoints.length / 6,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _timeSeries.dataPoints.length) {
                return Text(
                  DateFormat('MMM').format(_timeSeries.dataPoints[index].date),
                  style: const TextStyle(fontSize: 9),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TrendAnalysisCard(trendAnalysis: _timeSeries.trendAnalysis),
          const SizedBox(height: 16),
          _buildTrendChart(),
          const SizedBox(height: 16),
          _buildMovingAverageChart(),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Linear trend line with confidence interval',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                _createTrendChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createTrendChartData() {
    // Calculate trend line
    final n = _timeSeries.dataPoints.length;
    final actualSpots = <FlSpot>[];
    final trendSpots = <FlSpot>[];
    
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = _timeSeries.dataPoints[i].detectionCount.toDouble();
      actualSpots.add(FlSpot(x, y));
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    for (int i = 0; i < n; i += 10) {
      trendSpots.add(FlSpot(i.toDouble(), slope * i + intercept));
    }

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: n / 6,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < n) {
                return Text(
                  DateFormat('MMM').format(_timeSeries.dataPoints[index].date),
                  style: const TextStyle(fontSize: 9),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        // Actual data (semi-transparent)
        LineChartBarData(
          spots: actualSpots.where((s) => s.x.toInt() % 5 == 0).toList(),
          isCurved: false,
          color: Colors.grey.withValues(alpha: 0.3),
          barWidth: 1,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2,
                color: Colors.grey.withValues(alpha: 0.5),
              );
            },
          ),
        ),
        // Trend line
        LineChartBarData(
          spots: trendSpots,
          isCurved: false,
          color: Colors.red,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
      ],
    );
  }

  Widget _buildMovingAverageChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day & 30-Day Moving Averages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Smoothed trends showing short and long-term patterns',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                _createMovingAverageChartData(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('7-Day MA', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('30-Day MA', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  LineChartData _createMovingAverageChartData() {
    final ma7Spots = _calculateMovingAverage(7);
    final ma30Spots = _calculateMovingAverage(30);

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _timeSeries.dataPoints.length / 6,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _timeSeries.dataPoints.length) {
                return Text(
                  DateFormat('MMM').format(_timeSeries.dataPoints[index].date),
                  style: const TextStyle(fontSize: 9),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: ma7Spots,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: ma30Spots,
          isCurved: true,
          color: Colors.purple,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  List<FlSpot> _calculateMovingAverage(int window) {
    final spots = <FlSpot>[];
    
    for (int i = window - 1; i < _timeSeries.dataPoints.length; i++) {
      final windowData = _timeSeries.dataPoints.sublist(i - window + 1, i + 1);
      final avg = windowData.fold(0, (sum, p) => sum + p.detectionCount) / window;
      spots.add(FlSpot(i.toDouble(), avg));
    }
    
    return spots;
  }

  Widget _buildSeasonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SeasonalPatternCard(seasonalAnalysis: _timeSeries.seasonalAnalysis),
          const SizedBox(height: 16),
          _buildMonthlyBarChart(),
          const SizedBox(height: 16),
          _buildSeasonalComparisonChart(),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Detection Averages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                _createMonthlyBarChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createMonthlyBarChartData() {
    final monthlyAverages = _timeSeries.seasonalAnalysis.monthlyAverages;
    
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: monthlyAverages.values.reduce((a, b) => a > b ? a : b) * 1.2,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final month = value.toInt() + 1;
              if (month >= 1 && month <= 12) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM').format(DateTime(2024, month)),
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(12, (index) {
        final month = index + 1;
        final value = monthlyAverages[month] ?? 0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: _getSeasonColor(month),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getSeasonColor(int month) {
    if (month >= 3 && month <= 5) return Colors.green; // Spring
    if (month >= 6 && month <= 8) return Colors.orange; // Summer
    if (month >= 9 && month <= 11) return Colors.brown; // Fall
    return Colors.blue; // Winter
  }

  Widget _buildSeasonalComparisonChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seasonal Comparison',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: _buildSeasonalPieChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalPieChart() {
    final patterns = _timeSeries.seasonalAnalysis.patterns;
    
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: patterns[Season.spring]!.averageDetections,
            title: 'Spring\n${patterns[Season.spring]!.averageDetections.toStringAsFixed(1)}',
            color: Colors.green,
            radius: 100,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: patterns[Season.summer]!.averageDetections,
            title: 'Summer\n${patterns[Season.summer]!.averageDetections.toStringAsFixed(1)}',
            color: Colors.orange,
            radius: 100,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: patterns[Season.fall]!.averageDetections,
            title: 'Fall\n${patterns[Season.fall]!.averageDetections.toStringAsFixed(1)}',
            color: Colors.brown,
            radius: 100,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: patterns[Season.winter]!.averageDetections,
            title: 'Winter\n${patterns[Season.winter]!.averageDetections.toStringAsFixed(1)}',
            color: Colors.blue,
            radius: 100,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          WeatherCorrelationCard(correlations: _timeSeries.weatherCorrelations),
          const SizedBox(height: 16),
          ...WeatherParameter.values.take(3).map((param) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildWeatherScatterPlot(param),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherScatterPlot(WeatherParameter parameter) {
    final correlation = _timeSeries.weatherCorrelations.firstWhere(
      (c) => c.parameter == parameter,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detections vs ${parameter.displayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Correlation: ${(correlation.correlationCoefficient * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getCorrelationColor(correlation.correlationCoefficient.abs()),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: ScatterChart(
                _createWeatherScatterChartData(parameter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScatterChartData _createWeatherScatterChartData(WeatherParameter parameter) {
    final spots = <ScatterSpot>[];
    
    for (final point in _timeSeries.dataPoints) {
      if (point.weather != null) {
        spots.add(ScatterSpot(
          point.weather!.getParameter(parameter),
          point.detectionCount.toDouble(),
        ));
      }
    }

    return ScatterChartData(
      scatterSpots: spots.where((s) => spots.indexOf(s) % 10 == 0).toList(), // Sample for performance
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(
            parameter.unit,
            style: const TextStyle(fontSize: 10),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 9));
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      gridData: const FlGridData(show: true),
      scatterTouchData: ScatterTouchData(
        touchTooltipData: ScatterTouchTooltipData(
          getTooltipItems: (ScatterSpot spot) {
            return ScatterTooltipItem(
              '${parameter.displayName}: ${spot.x.toStringAsFixed(1)} ${parameter.unit}\n'
              'Detections: ${spot.y.toInt()}',
              textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            );
          },
        ),
      ),
    );
  }

  Color _getCorrelationColor(double absCorrelation) {
    if (absCorrelation >= 0.6) return Colors.green;
    if (absCorrelation >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

