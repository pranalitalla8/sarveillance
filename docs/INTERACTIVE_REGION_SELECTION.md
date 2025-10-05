# Interactive Region Selection - User Guide

## Overview
The interactive region selection feature allows users to click anywhere on the map to select a region and load SAR data, oil spill detections, ship tracking, and water quality information for that area.

## How to Use

### 1. **Select a Region**
- Navigate to the **Analyze** screen (bottom navigation)
- **Tap anywhere** on the map
- A blue circle will appear showing the selected region (10km radius)
- A pin marker shows the exact center point

### 2. **Load Data**
- After selecting a region, a **Region Info Panel** appears on the left
- Click the **"Load Data"** button
- Wait 2 seconds while the system fetches SAR data
- Data will be displayed automatically when ready

### 3. **View Region Data**

The Region Info Panel shows:

#### **SAR Data** 🛰️
- Satellite name (Sentinel-1A/B, NISAR, RADARSAT-2)
- Frequency band (C-band, L-band, X-band)
- Polarization (VV, VH, HH, HV)
- Resolution and coverage
- Acquisition date

#### **Oil Spills** ⚠️ (if detected)
- Number of spills detected
- Total area affected
- Confidence level
- Individual spill locations and severity

#### **Ship Traffic** 🚢
- Total number of ships
- Suspicious ship count (highlighted in red)
- Average speed
- Breakdown by ship type (Cargo, Fishing, Tanker, Passenger)

#### **Water Quality** 💧
- Quality rating (Excellent → Poor)
- Chlorophyll levels
- Turbidity
- Water temperature

### 4. **Close Selection**
- Click the **X** button in the panel header
- The region marker will disappear
- You can now select a new region

## Features

### Visual Feedback
- **Blue circle overlay** shows the selected region boundary
- **Pin marker** indicates the exact center
- **Color-coded indicators** for severity and quality

### Real-time Alerts
- **Orange alert** if oil spills are detected
- **Red indicators** for suspicious ships
- **Green confirmation** when no issues found

### Data Status
- **Loading state** shows a spinner
- **Error state** allows retry
- **Timestamp** shows when data was last updated

## Technical Details

### Region Types
Currently creates **circular regions** with:
- 10 km radius
- Center at tap location
- Automatic boundary calculation

### Data Sources
In production, this feature will connect to:
- NASA SAR data APIs
- AIS ship tracking systems
- Water quality monitoring services
- Oil spill detection algorithms

### Mock Data
For demonstration, the app generates realistic mock data including:
- Random oil spill occurrences
- Varied ship traffic patterns
- Suspicious ship flags
- Different water quality readings

## Tips

1. **Select areas of interest** like harbors, shipping lanes, or coastal zones
2. **Compare different regions** to understand variations
3. **Look for patterns** in oil spills and ship traffic
4. **Check suspicious ships** in the ship traffic data
5. **Monitor water quality** in different parts of the bay

## Future Enhancements

- Rectangle and polygon selection tools
- Multiple region comparison
- Time-series data loading
- Export region reports
- Saved region presets
- Real-time data streaming

