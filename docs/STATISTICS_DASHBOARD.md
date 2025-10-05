# Statistics Dashboard

## Overview

The Statistics Dashboard provides comprehensive analytics and insights for oil spill detection data, helping users identify patterns, hotspots, and correlations with environmental factors.

## Features

### 1. Overview Tab

**Summary Cards:**
- Total Oil Candidates Detected
- Total Data Points
- Ship-Related Spills
- Ship Correlation Percentage

**Charts:**
- **Yearly Breakdown**: Bar chart showing oil detections by year
- **Monthly Distribution**: Line chart with seasonal patterns
- **12-Month Trend**: Dual-line chart comparing total vs ship-related spills

### 2. Hotspots Tab

**High-Risk Area Identification:**
- Automatically clusters oil spills by geographic proximity
- Ranks areas by risk level: Critical, High, Medium, Low
- Shows detailed information for each hotspot:
  - Location coordinates
  - Number of spills detected
  - Risk assessment
  - Characteristics (e.g., shipping traffic, monitoring needs)

**Risk Levels:**
- **Critical** (≥100 spills): Immediate attention required
- **High** (≥50 spills): Frequent spills, high risk
- **Medium** (≥20 spills): Moderate concern
- **Low** (<20 spills): Occasional activity

### 3. Ships Tab

**Ship Correlation Analysis:**
- Total ship-related spills
- Correlation strength percentage
- Average distance to nearest ship

**Spills by Ship Type:**
- Interactive pie chart showing distribution:
  - Cargo vessels
  - Tankers
  - Fishing vessels
  - Other vessel types

**Top Violation Areas:**
- Ranked list of areas with highest ship-related spills
- Shipping lanes and port approach zones
- Major maritime routes

### 4. Weather Tab

**Weather Correlation Analysis:**
- Correlation coefficients for each weather parameter:
  - Wind Speed
  - Wave Height
  - Temperature
  - Precipitation
  - Visibility

**Common Weather Patterns:**
- High Wind Conditions
- Calm Seas
- Storm Events
- Frequency and associated spill counts for each pattern

## How to Access

1. Open the app and navigate to the **Analyze** screen
2. Tap the **Analytics** button (📊) in the floating action buttons
3. The Statistics Dashboard will open with 4 tabs

## Understanding the Data

### Ship Correlation

The **Ship Correlation Percentage** indicates what portion of detected oil spills are associated with nearby ships. Higher percentages suggest:
- Potential illegal dumping
- Accidental spills from vessels
- Areas requiring increased maritime enforcement

### Seasonal Patterns

Monthly distribution charts reveal:
- **Winter peaks**: Higher detection rates due to storm conditions
- **Summer valleys**: Calmer seas, lower spill activity
- **Seasonal trends**: Helps predict high-risk periods

### Hotspot Clustering

Hotspots are identified using proximity-based clustering:
- Spills within ~55km are grouped together
- Only significant clusters (10+ spills) are shown
- Top 5 hotspots are displayed by severity

## Key Metrics

| Metric | Description | Use Case |
|--------|-------------|----------|
| Total Oil Candidates | All detected potential oil spills | Overall impact assessment |
| Ship Correlation | % of spills near vessels | Identify illegal dumping |
| Average Confidence | Detection reliability | Data quality measure |
| Hotspot Count | High-density spill areas | Resource allocation |
| Weather Correlation | Environmental factors | Predictive modeling |

## Color Coding

### Risk Levels
- 🔴 **Critical**: Red - Immediate action needed
- 🟠 **High**: Orange - High priority monitoring
- 🟡 **Medium**: Yellow - Regular monitoring
- 🟢 **Low**: Green - Occasional checks

### Correlation Strength
- 🟢 **Strong** (>60%): Green - Significant relationship
- 🟠 **Moderate** (40-60%): Orange - Notable correlation
- 🔴 **Weak** (<40%): Red - Limited relationship

## Data Sources

The statistics are calculated from:
- SAR (Synthetic Aperture Radar) satellite imagery
- AIS (Automatic Identification System) ship tracking
- Weather observation data
- Historical spill records

## Technical Details

### Statistics Calculation

**Hotspot Identification:**
```dart
- Clustering radius: 0.5° (~55km)
- Minimum cluster size: 10 spills
- Maximum hotspots shown: 5
- Sorted by: Spill count (descending)
```

**Correlation Analysis:**
```dart
- Method: Pearson correlation coefficient
- Range: -1 (negative) to +1 (positive)
- Threshold for significance: ±0.4
```

**Trend Analysis:**
```dart
- Time period: 12 months
- Smoothing: Linear regression
- Confidence level: 85%
```

### Performance

- Handles datasets up to 10,000+ data points
- Real-time calculation (<500ms)
- Optimized chart rendering
- Responsive UI updates

## Best Practices

### For Environmental Monitoring

1. **Regular Reviews**: Check hotspots weekly
2. **Trend Analysis**: Compare month-over-month changes
3. **Weather Integration**: Plan monitoring during calm periods
4. **Ship Tracking**: Focus on high-correlation areas

### For Research

1. **Export Data**: Use statistics for reports
2. **Temporal Analysis**: Study seasonal patterns
3. **Correlation Studies**: Link weather to spill frequency
4. **Hotspot Mapping**: Create risk assessment maps

### For Response Teams

1. **Priority Zones**: Focus on critical hotspots
2. **Resource Allocation**: Deploy to high-risk areas
3. **Prevention**: Target ship-related violation zones
4. **Preparedness**: Stock resources near hotspots

## Limitations

- **Data Quality**: Depends on satellite coverage and resolution
- **Weather Data**: Simulated correlations (can be improved with real weather APIs)
- **Ship Identification**: Based on proximity, not confirmed cause
- **Temporal Gaps**: Limited by satellite revisit frequency

## Future Enhancements

Potential improvements include:
- Real-time weather data integration
- Machine learning predictions
- Historical baseline comparisons
- Export functionality (PDF, CSV)
- Custom date range selection
- Advanced filtering options
- Multi-region comparison
- Integration with regulatory databases

## Support & Feedback

For questions or feature requests related to the Statistics Dashboard, please refer to the main project documentation or contact the development team.

## See Also

- [Time Series Analysis](TIME_SERIES_ANALYSIS.md)
- [Interactive Region Selection](INTERACTIVE_REGION_SELECTION.md)
- [Implementation Summary](../IMPLEMENTATION_SUMMARY.md)

