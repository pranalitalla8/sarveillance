# NASA SAR App - Data Sources Setup Guide

This guide provides step-by-step instructions for setting up data sources and collecting SAR data for the NASA SAR Visualization App.

## Overview

The app integrates multiple data sources for Chesapeake Bay SAR analysis:

1. **Shapefiles**: Chesapeake Bay watershed, fish habitat zones, SAV zones
2. **SAR Data**: 10-year Sentinel-1 data from Google Earth Engine
3. **Oil Spill Datasets**: Training datasets from Zenodo and M4D

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Google Earth Engine account
- Python 3.7+ (for data download scripts)
- Internet connection for data downloads

## Setup Instructions

### 1. Google Earth Engine Setup

1. **Create Account**: Visit [Google Earth Engine](https://earthengine.google.com/)
2. **Sign Up**: Use your Google account to sign up
3. **Request Access**: Submit access request (usually approved within 1-2 days)
4. **Access Code Editor**: Once approved, access the Earth Engine Code Editor

### 2. Data Sources Download

#### Option A: Using Flutter App
1. Open the NASA SAR app
2. Tap the "Data Sources" floating action button
3. Tap "Download All Sources" to download all data sources
4. Monitor download progress in the app

#### Option B: Using Python Script
1. Navigate to the `sar-data` directory
2. Run the Python download script:
   ```bash
   python download_data_sources.py
   ```

### 3. Earth Engine SAR Data Collection

1. **Open Code Editor**: Access Google Earth Engine Code Editor
2. **Copy Script**: Copy the contents of `earth_engine_scripts/sentinel1_chesapeake_bay.js`
3. **Paste and Run**: Paste the script in the Code Editor and run it
4. **Monitor Exports**: Check the Tasks tab for export progress
5. **Download Data**: Download exported files from Google Drive

## Data Sources Details

### Shapefiles

#### Chesapeake Bay Watershed
- **Source**: NOAA/EPA Chesapeake Bay Program
- **Format**: Shapefile
- **Description**: Chesapeake Bay watershed boundary
- **Area**: ~165,800 km²

#### Fish Habitat Zones
- **Source**: Chesapeake Bay Program
- **Format**: GeoJSON
- **Description**: Migratory fish spawning and nursery zones
- **Species**: Striped Bass, Blue Crab, etc.

#### SAV Zones
- **Source**: Chesapeake Bay Program
- **Format**: GeoJSON
- **Description**: Submerged aquatic vegetation zones
- **Species**: Eelgrass, Widgeon Grass, etc.

### SAR Data

#### Sentinel-1 Collection
- **Satellite**: Sentinel-1A/1B
- **Polarization**: VV, VH
- **Resolution**: 10m
- **Date Range**: 2014-2024 (10 years)
- **Composites**: Annual, Monthly, Summer
- **Processing**: dB conversion, ratios, indices

#### Earth Engine Script Features
- **Annual Composites**: Median composites for each year
- **Monthly Composites**: Monthly median composites
- **Summer Composites**: Focus on June-August for oil spill analysis
- **SAR Indices**: VV/VH ratio, cross-polarization ratio, normalized difference
- **Export**: TIFF files to Google Drive

### Oil Spill Datasets

#### Zenodo Dataset
- **Source**: Zenodo
- **Images**: 1,200 TIFF images
- **Format**: Sentinel-1 SAR
- **Resolution**: 10m
- **Purpose**: Oil spill detection training

#### M4D Dataset
- **Source**: M4D Research Group
- **Images**: 1,100 GeoTIFF images
- **Format**: Multi-temporal SAR
- **Resolution**: 10m
- **Purpose**: Oil spill detection research

## File Structure

```
sar-data/
├── shapefiles/
│   ├── chesapeake_bay/
│   ├── fish_habitat/
│   └── sav_zones/
├── datasets/
│   ├── zenodo_oil_spill/
│   └── m4d_oil_spill/
├── sar_data/
└── earth_engine_exports/

earth_engine_scripts/
└── sentinel1_chesapeake_bay.js
```

## Troubleshooting

### Common Issues

1. **Earth Engine Access Denied**
   - Ensure your account is approved
   - Check if you're signed in with the correct Google account

2. **Download Failures**
   - Check internet connection
   - Verify URLs are accessible
   - Try downloading individual sources

3. **Script Errors**
   - Ensure all required permissions are granted
   - Check if the region of interest is valid
   - Verify date ranges are correct

### Data Validation

1. **Check File Sizes**: Ensure downloaded files are not empty
2. **Verify Formats**: Check that shapefiles and datasets are in correct formats
3. **Test Integration**: Use the app's data management screen to verify data sources

## Next Steps

After completing the setup:

1. **Integrate Data**: Use the app's data management features
2. **Run Analysis**: Access SAR analysis tools in the app
3. **Visualize Results**: Use the comparison and visualization features
4. **Export Results**: Save analysis results and share findings

## Support

For issues or questions:
- Check the app's data management screen for status
- Review the Earth Engine script documentation
- Consult the troubleshooting section above

## Data Usage

Please ensure compliance with:
- Google Earth Engine Terms of Service
- NOAA/EPA data usage policies
- Zenodo and M4D dataset licenses
- Local data protection regulations
