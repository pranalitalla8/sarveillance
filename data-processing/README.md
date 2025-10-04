# NASA SAR Data Processing Pipeline

This directory contains Python scripts for processing SAR data, calculating vegetation and water quality indices, and preparing data for the Flutter app.

## 🚀 Quick Start

### 1. Setup Environment
```bash
cd data-processing
python setup_environment.py
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Process SAR Data
```bash
python scripts/pipeline.py --sar data/sar_image.tif --red data/red.tif --nir data/nir.tif
```

## 📁 Directory Structure

```
data-processing/
├── requirements.txt          # Python dependencies
├── setup_environment.py     # Environment setup script
├── scripts/
│   ├── data_converter.py     # TIFF to CSV conversion
│   ├── index_calculator.py   # NDVI, NDCI, WQI calculation
│   └── pipeline.py           # Complete processing pipeline
├── data/                     # Input data directory
├── output/                   # Processed data output
└── temp/                     # Temporary files
```

## 🔧 Scripts Overview

### Data Converter (`data_converter.py`)
Converts TIFF rasters to CSV format and extracts pixel values with coordinates.

**Features:**
- Convert TIFF to CSV with pixel coordinates
- Batch process multiple TIFF files
- Convert shapefiles to GeoJSON
- Configurable sampling rate

**Usage:**
```bash
# Convert single TIFF
python scripts/data_converter.py --tiff data/sar_image.tif

# Batch convert all TIFFs
python scripts/data_converter.py --batch-tiff --sample-rate 0.05

# Convert shapefile
python scripts/data_converter.py --shapefile data/chesapeake_bay.shp
```

### Index Calculator (`index_calculator.py`)
Calculates vegetation and water quality indices from satellite imagery.

**Indices Calculated:**
- **NDVI** (Normalized Difference Vegetation Index): `(NIR - Red) / (NIR + Red)`
- **NDCI** (Normalized Difference Chlorophyll Index): `(Red - Green) / (Red + Green)`
- **WQI** (Water Quality Index): Composite index based on SAR backscatter and vegetation

**Usage:**
```bash
# Calculate all indices
python scripts/index_calculator.py --sar data/sar.tif --red data/red.tif --nir data/nir.tif --green data/green.tif

# Calculate only NDVI
python scripts/index_calculator.py --sar data/sar.tif --red data/red.tif --nir data/nir.tif --ndvi-only
```

### Processing Pipeline (`pipeline.py`)
Complete pipeline for processing SAR data and preparing Flutter-compatible outputs.

**Pipeline Steps:**
1. Convert SAR data to CSV format
2. Calculate vegetation and water quality indices
3. Convert indices to CSV format
4. Generate Flutter-compatible data files
5. Create processing summary

**Usage:**
```bash
# Complete pipeline
python scripts/pipeline.py --sar data/sar.tif --red data/red.tif --nir data/nir.tif --green data/green.tif

# Process shapefiles
python scripts/pipeline.py --process-shapefiles
```

## 📊 Output Files

The pipeline generates several output files:

### CSV Files
- `sar_pixels.csv`: SAR backscatter values with coordinates
- `ndvi_pixels.csv`: NDVI values with coordinates
- `ndci_pixels.csv`: NDCI values with coordinates
- `water_quality_index_pixels.csv`: WQI values with coordinates

### Flutter-Compatible Files
- `flutter_sar_csv`: Simplified SAR data for Flutter
- `flutter_ndvi_csv`: Simplified NDVI data for Flutter
- `flutter_ndci_csv`: Simplified NDCI data for Flutter
- `flutter_wqi_csv`: Simplified WQI data for Flutter

### Raster Files
- `ndvi.tif`: NDVI raster
- `ndci.tif`: NDCI raster
- `water_quality_index.tif`: WQI raster

### Summary Files
- `pipeline_summary.json`: Complete processing summary
- `conversion_summary.json`: Data conversion summary
- `indices_summary.json`: Index calculation summary

## 🌊 Data Integration with Flutter

The processed data can be integrated into the Flutter app:

1. **Copy CSV files** to `lib/data/` directory
2. **Update data models** in `lib/models/`
3. **Modify data services** in `lib/services/`
4. **Create visualization widgets** in `lib/widgets/`

## 📈 Index Interpretation

### NDVI Values
- **-1 to 0**: Water, clouds, snow
- **0 to 0.2**: Barren or sparse vegetation
- **0.2 to 0.5**: Moderate vegetation
- **0.5 to 1.0**: Dense vegetation

### NDCI Values
- **-1 to 0**: Low chlorophyll content
- **0 to 0.5**: Moderate chlorophyll content
- **0.5 to 1.0**: High chlorophyll content

### Water Quality Index
- **0 to 0.3**: Poor water quality
- **0.3 to 0.6**: Moderate water quality
- **0.6 to 1.0**: Good water quality

## 🔍 Troubleshooting

### Common Issues
1. **Memory errors**: Reduce sample rate (e.g., `--sample-rate 0.05`)
2. **File not found**: Check file paths and ensure files exist
3. **CRS errors**: Ensure all raster files have compatible coordinate systems
4. **NoData values**: Scripts automatically handle NoData values

### Performance Tips
- Use smaller sample rates for large datasets
- Process files in batches for memory efficiency
- Use SSD storage for faster I/O operations

## 📚 Dependencies

- **rasterio**: Geospatial raster I/O
- **pandas**: Data manipulation
- **geopandas**: Geospatial data processing
- **numpy**: Numerical computing
- **scikit-learn**: Machine learning utilities
- **tqdm**: Progress bars
