# Time Series Analysis Feature

## Overview

The Time Series Analysis feature provides comprehensive visualization and analysis of oil spill detections over time. It includes 548 days of historical data with multiple analytical views to understand patterns, trends, and correlations.

## Features

### 1. **Timeline View**
- **Line Chart**: Shows daily oil detection counts over the entire 548-day period
- **Cumulative Area Chart**: Displays the total area affected by oil spills over time
- **Statistics Overview**: 
  - Total detections
  - Daily average
  - Peak detection day
  - Date range

### 2. **Trend Analysis**
- **Overall Trend**: Shows whether oil spills are increasing, decreasing, or stable
- **Trend Line**: Linear regression visualization with confidence intervals
- **Quarterly Breakdown**: Analyzes trends in 4 quarters showing detailed slope data
- **Moving Averages**: 
  - 7-day moving average (short-term trends)
  - 30-day moving average (long-term trends)

### 3. **Seasonal Patterns**
- **Seasonal Comparison**: Pie chart showing average detections per season
- **Monthly Breakdown**: Bar chart displaying detection averages for each month
- **Peak Season Analysis**: Identifies which season has the highest detection rates
- **Seasonal Characteristics**: 
  - Spring: Moderate detection rates, increasing shipping activity
  - Summer: Lower detection rates, calmer sea conditions
  - Fall: Increasing detection rates, more frequent storms
  - Winter: Highest detection rates, rough sea conditions

### 4. **Weather Correlation**
- **Correlation Analysis**: Statistical correlation between oil detections and weather parameters
- **Weather Parameters**:
  - Wind Speed (km/h)
  - Wave Height (m)
  - Temperature (°C)
  - Precipitation (mm)
  - Humidity (%)
  - Atmospheric Pressure (hPa)
- **Scatter Plots**: Visualize relationships between detections and weather conditions
- **Correlation Strength**: Color-coded indicators showing strong, moderate, or weak correlations

## How to Access

1. Navigate to the **Analyze** screen from the bottom navigation
2. Click the **chart icon** (📊) in the top right corner of the app bar
3. The Time Series Analysis screen will open with 4 tabs

## Navigation

The screen has 4 main tabs:

### Timeline Tab
Shows the raw time series data with detection counts and cumulative area charts.

### Trends Tab
Displays trend analysis including:
- Trend direction (increasing/decreasing/stable)
- Quarterly breakdown
- Moving averages

### Seasonal Tab
Provides seasonal pattern analysis:
- Monthly bar chart
- Seasonal comparison pie chart
- Detailed seasonal characteristics

### Weather Tab
Shows weather correlation data:
- Top correlations ranked by strength
- Scatter plots for each weather parameter
- Interpretation of correlation results

## View Options

Use the menu in the top right (⋮) to switch between:
- **Daily View**: Shows individual daily data points
- **Weekly View**: Averages data over 7-day periods
- **Monthly View**: Averages data over 30-day periods

## Data Insights

### Key Findings from the Analysis

1. **Temporal Patterns**: 
   - Detection rates vary significantly by season
   - Winter months show highest detection rates
   - Weekend reporting is typically lower

2. **Trend Analysis**:
   - Long-term trend shows slight increase in detections
   - Quarterly variations reveal important patterns
   - Moving averages smooth out daily fluctuations

3. **Weather Impact**:
   - Wind speed and wave height show correlation with detection rates
   - Temperature has inverse correlation in some cases
   - Weather conditions affect both actual spills and detection capability

## Technical Details

### Data Generation
- Uses `TimeSeriesService` to generate realistic synthetic data
- 548 data points (approximately 18 months)
- Includes realistic seasonal variations
- Weather data simulated with physical correlations

### Components
- **Models**: `OilDetectionTimeSeries`, `TrendAnalysis`, `SeasonalAnalysis`, `WeatherCorrelation`
- **Service**: `TimeSeriesService` for data generation and analysis
- **Widgets**: 
  - `TrendAnalysisCard`
  - `SeasonalPatternCard`
  - `WeatherCorrelationCard`

### Charts
Uses `fl_chart` library for visualization:
- Line charts for time series
- Bar charts for monthly data
- Pie charts for seasonal comparison
- Scatter plots for correlation analysis

## Future Enhancements

Potential improvements include:
- Real data integration from actual SAR satellites
- Export functionality for reports
- Custom date range selection
- Comparison with historical baselines
- Machine learning predictions
- Integration with real-time weather APIs

## Usage Example

```dart
// Navigate to time series screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const TimeSeriesScreen(),
  ),
);
```

## Performance Notes

- Data is sampled for performance in some views
- Scatter plots show every 10th data point to maintain responsiveness
- Charts are optimized for smooth scrolling and interaction

## Interpretation Guide

### Understanding Trends
- **Increasing**: Detection rate growing over time (concern indicator)
- **Decreasing**: Detection rate declining (positive sign)
- **Stable**: No significant change in detection rate

### Correlation Strength
- **Very Strong** (>80%): Clear relationship exists
- **Strong** (60-80%): Significant relationship
- **Moderate** (40-60%): Notable relationship
- **Weak** (20-40%): Minor relationship
- **Very Weak** (<20%): Minimal relationship

### Positive vs Negative Correlation
- **Positive** (↑): Detections increase with parameter value
- **Negative** (↓): Detections decrease with parameter value

## Contact & Support

For questions or issues with the time series feature, refer to the main project documentation or contact the development team.

