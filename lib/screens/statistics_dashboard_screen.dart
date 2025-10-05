import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/statistics_data.dart';
import '../models/oil_spill_data.dart';
import '../services/statistics_service.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  final List<OilSpillData> data;

  const StatisticsDashboardScreen({
    super.key,
    required this.data,
  });

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OilSpillStatistics _statistics;
  final _statisticsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _statistics = _statisticsService.generateStatistics(widget.data);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
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
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.place), text: 'Hotspots'),
            Tab(icon: Icon(Icons.directions_boat), text: 'Ships'),
            Tab(icon: Icon(Icons.cloud), text: 'Weather'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHotspotsTab(),
          _buildShipsTab(),
          _buildWeatherTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildYearlyBreakdownChart(),
          const SizedBox(height: 24),
          _buildMonthlyBreakdownChart(),
          const SizedBox(height: 24),
          _buildTrendChart(),
          const SizedBox(height: 24),
          // SAR Analysis Charts from Teammate's Research
          _buildChartCard(
            'VH vs VV Backscatter Analysis',
            'assets/charts/VHvsVVBackscatter.webp',
            'Scatter plot showing relationship between VH and VV polarization',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Oil Candidate SAR Signatures',
            'assets/charts/VHvsVVByOilCandidate.webp',
            'VH/VV backscatter patterns distinguish oil from water',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Backscatter Distributions',
            'assets/charts/DistributionOfVHBackscatter&DistributionOfVVBackscatter.webp',
            'Statistical distributions of VH and VV backscatter values',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Feature Correlation Matrix',
            'assets/charts/FeatureCorrelationHeatmap.webp',
            'Correlation heatmap of SAR and environmental features',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'VH/VV Ratio Analysis',
            'assets/charts/DistributionOfVHVVRatio&VHVVRatioByOilCandidate.webp',
            'VH/VV ratio distribution and oil detection patterns',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Oil Candidates',
                '${_statistics.totalOilCandidates}',
                Icons.water_drop,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Data Points',
                '${_statistics.totalDataPoints}',
                Icons.dataset,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Ship-Related',
                '${_statistics.shipRelatedSpills}',
                Icons.directions_boat,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Correlation',
                '${_statistics.shipCorrelationPercentage.toStringAsFixed(1)}%',
                Icons.link,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyBreakdownChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yearly Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Oil detections by year',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                _createYearlyChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createYearlyChartData() {
    final entries = _statistics.yearlyBreakdown.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: entries.fold<double>(0.0, (max, e) => e.value.toDouble() > max ? e.value.toDouble() : max) * 1.2,
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
              final index = value.toInt();
              if (index >= 0 && index < entries.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(entries[index].key, style: const TextStyle(fontSize: 10)),
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
      barGroups: List.generate(entries.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entries[index].value.toDouble(),
              color: Colors.blue,
              width: 40,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMonthlyBreakdownChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Detections per month (seasonal patterns)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                _createMonthlyChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createMonthlyChartData() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final spots = <FlSpot>[];
    
    for (int i = 0; i < months.length; i++) {
      final value = _statistics.monthlyBreakdown[months[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
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
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < months.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(months[index], style: const TextStyle(fontSize: 9)),
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
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
      ],
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
              '12-Month Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total vs ship-related detections',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                _createTrendChartData(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Total Spills', Colors.red),
                const SizedBox(width: 24),
                _buildLegendItem('Ship-Related', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createTrendChartData() {
    final totalSpots = <FlSpot>[];
    final shipSpots = <FlSpot>[];
    
    for (int i = 0; i < _statistics.trendData.length; i++) {
      final point = _statistics.trendData[i];
      totalSpots.add(FlSpot(i.toDouble(), point.spillCount.toDouble()));
      shipSpots.add(FlSpot(i.toDouble(), point.shipCount.toDouble()));
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
            interval: 2,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _statistics.trendData.length) {
                return Text(
                  DateFormat('MMM').format(_statistics.trendData[index].date),
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
          spots: totalSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: shipSpots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
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

  Widget _buildHotspotsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'High-Risk Areas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Top ${_statistics.hotspots.length} areas with highest oil detection density',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_statistics.hotspots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No significant hotspots detected'),
              ),
            )
          else
            ..._statistics.hotspots.map((hotspot) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHotspotCard(hotspot),
            )),
          const SizedBox(height: 24),
          // Spatial Analysis Charts from Teammate's Research
          _buildChartCard(
            'Oil Detection Spatial-Temporal Map',
            'assets/charts/OilDetectionPointsColoredByDate.webp',
            'Geographic distribution of oil detections over time with 5km movement buffers',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'PCA Oil Candidate Behavior',
            'assets/charts/OilCandidateBehaviorPCAProjection.webp',
            'Principal Component Analysis reveals distinct oil vs non-oil patterns',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Triple Correlation Analysis',
            'assets/charts/Pearson&Spearmen&KendallCorrelation.webp',
            'Pearson, Spearman, and Kendall correlation matrices for feature validation',
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotCard(HotspotArea hotspot) {
    final riskColor = _getRiskColor(hotspot.riskLevel);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.place, color: riskColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotspot.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        hotspot.riskDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${hotspot.spillCount}',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Location: ${hotspot.center.latitude.toStringAsFixed(4)}°, ${hotspot.center.longitude.toStringAsFixed(4)}°',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hotspot.characteristics.map((char) => Chip(
                label: Text(char, style: const TextStyle(fontSize: 11)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return Colors.red[700]!;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildShipsTab() {
    final shipStats = _statistics.shipStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShipCorrelationCard(shipStats),
          const SizedBox(height: 24),
          _buildShipTypesChart(shipStats),
          const SizedBox(height: 24),
          _buildViolationAreasCard(shipStats),
          const SizedBox(height: 24),
          // Environmental Correlation Charts from Teammate's Research
          _buildChartCard(
            'Wind Speed vs VH/VV Ratio',
            'assets/charts/WindSpeedvsVHVVRatioOilCandidateHighlight.webp',
            'Wind speed correlation with SAR signatures - oil candidates highlighted',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'VH/VV Ratio Temporal Patterns',
            'assets/charts/VHVVRatioByWeekdayOilvsNon-Oil.webp',
            'Weekday patterns reveal oil vs non-oil detection differences',
          ),
        ],
      ),
    );
  }

  Widget _buildShipCorrelationCard(ShipCorrelationStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_boat, size: 32, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ship Correlation Analysis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${stats.correlationStrengthDescription} correlation detected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildStatItem(
              'Ship-Related Spills',
              '${stats.totalShipRelatedSpills}',
              Icons.warning_amber,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Correlation Strength',
              '${(stats.correlationStrength * 100).toStringAsFixed(1)}%',
              Icons.link,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Avg. Distance to Ship',
              '${stats.averageDistanceToShip.toStringAsFixed(1)} km',
              Icons.straighten,
              Colors.green,
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipTypesChart(ShipCorrelationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spills by Ship Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                _createShipTypesPieChart(stats),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartData _createShipTypesPieChart(ShipCorrelationStats stats) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple];
    int colorIndex = 0;
    
    return PieChartData(
      sections: stats.spillsByShipType.entries.map((entry) {
        final color = colors[colorIndex++ % colors.length];
        return PieChartSectionData(
          value: entry.value.toDouble(),
          title: '${entry.key}\n${entry.value}',
          color: color,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  Widget _buildViolationAreasCard(ShipCorrelationStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Violation Areas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...stats.topViolationAreas.asMap().entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTab() {
    final weatherStats = _statistics.weatherStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherCorrelationCard(weatherStats),
          const SizedBox(height: 24),
          _buildWeatherPatternsCard(weatherStats),
          const SizedBox(height: 24),
          // Analysis Charts from Teammate's Research
          _buildChartCard(
            'Weather Clustering Analysis',
            'assets/charts/ClusteredWeatherPatternsTempvsPrecip.webp',
            'K-means clustering reveals three distinct weather regimes in Chesapeake Bay',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Daily SAR & Wind Speed Trends',
            'assets/charts/DailyMeanSAR&WindSpeed.webp',
            'Temporal analysis of SAR backscatter and environmental conditions',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Environmental Factors vs Oil Presence',
            'assets/charts/NASAPowerAirTemp2mvsOilPresence.webp',
            'Temperature correlation with oil detections',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Precipitation Impact',
            'assets/charts/NASAPowerPrecipiationMMvsOilPresence.webp',
            'Precipitation patterns affect SAR detection reliability',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Wind Speed Analysis',
            'assets/charts/NASAPowerWindSpeed2mmpersvsOilPresence.webp',
            'Wind speed correlation with surface roughness',
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Solar Radiation Effects',
            'assets/charts/NASAPowerSolarRadiationMJm2dayvsOilPresence.webp',
            'Solar radiation impact on oil detection conditions',
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCorrelationCard(WeatherCorrelationStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Correlation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Dominant factor: ${stats.dominantFactor}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...stats.parameterCorrelations.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getCorrelationColor(entry.value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value.abs(),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCorrelationColor(entry.value),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getCorrelationColor(double correlation) {
    final abs = correlation.abs();
    if (abs >= 0.6) return Colors.green;
    if (abs >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildWeatherPatternsCard(WeatherCorrelationStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common Weather Patterns',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...stats.patterns.map((pattern) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_cloudy, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pattern.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pattern.spillsAssociated} spills',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pattern.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Frequency: ${(pattern.frequency * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: pattern.frequency,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String assetPath, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Chart not available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

