#!/usr/bin/env python3
"""
Data Converter for NASA SAR App
Converts TIFF rasters to CSV format and extracts pixel values with coordinates
"""

import rasterio
import pandas as pd
import numpy as np
import geopandas as gpd
from pathlib import Path
import argparse
import json
from tqdm import tqdm
import warnings
warnings.filterwarnings('ignore')

class DataConverter:
    def __init__(self, input_dir="data", output_dir="output"):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def tiff_to_csv(self, tiff_path, output_csv=None, sample_rate=1.0):
        """
        Convert TIFF raster to CSV format with pixel values and coordinates
        
        Args:
            tiff_path: Path to input TIFF file
            output_csv: Output CSV path (optional)
            sample_rate: Fraction of pixels to sample (0.1 = 10% of pixels)
        """
        tiff_path = Path(tiff_path)
        if not tiff_path.exists():
            raise FileNotFoundError(f"TIFF file not found: {tiff_path}")
        
        print(f"🔄 Converting {tiff_path.name} to CSV...")
        
        with rasterio.open(tiff_path) as src:
            # Get raster metadata
            transform = src.transform
            crs = src.crs
            bands = src.count
            
            print(f"   📊 Raster info: {src.width}x{src.height}, {bands} bands, CRS: {crs}")
            
            # Read all bands
            data = src.read()
            
            # Create coordinate arrays
            rows, cols = np.meshgrid(
                np.arange(src.height), 
                np.arange(src.width), 
                indexing='ij'
            )
            
            # Convert pixel coordinates to geographic coordinates
            x_coords, y_coords = rasterio.transform.xy(transform, rows, cols)
            
            # Sample data if sample_rate < 1.0
            if sample_rate < 1.0:
                total_pixels = src.width * src.height
                sample_size = int(total_pixels * sample_rate)
                indices = np.random.choice(total_pixels, sample_size, replace=False)
                
                # Flatten arrays and sample
                flat_rows = rows.flatten()[indices]
                flat_cols = cols.flatten()[indices]
                flat_x = np.array(x_coords).flatten()[indices]
                flat_y = np.array(y_coords).flatten()[indices]
                
                # Sample band data
                sampled_data = {}
                for band_idx in range(bands):
                    band_data = data[band_idx].flatten()[indices]
                    sampled_data[f'band_{band_idx + 1}'] = band_data
            else:
                # Use all pixels
                flat_rows = rows.flatten()
                flat_cols = cols.flatten()
                flat_x = np.array(x_coords).flatten()
                flat_y = np.array(y_coords).flatten()
                
                sampled_data = {}
                for band_idx in range(bands):
                    band_data = data[band_idx].flatten()
                    sampled_data[f'band_{band_idx + 1}'] = band_data
            
            # Create DataFrame
            df_data = {
                'row': flat_rows,
                'col': flat_cols,
                'longitude': flat_x,
                'latitude': flat_y,
                **sampled_data
            }
            
            df = pd.DataFrame(df_data)
            
            # Remove NoData values
            df = df.replace(src.nodata, np.nan)
            df = df.dropna()
            
            # Generate output filename if not provided
            if output_csv is None:
                output_csv = self.output_dir / f"{tiff_path.stem}_pixels.csv"
            else:
                output_csv = Path(output_csv)
            
            # Save to CSV
            df.to_csv(output_csv, index=False)
            
            print(f"   ✅ Saved {len(df)} pixels to {output_csv}")
            print(f"   📈 Data shape: {df.shape}")
            
            return df, output_csv
    
    def shapefile_to_geojson(self, shapefile_path, output_geojson=None):
        """
        Convert shapefile to GeoJSON format for Flutter compatibility
        
        Args:
            shapefile_path: Path to input shapefile
            output_geojson: Output GeoJSON path (optional)
        """
        shapefile_path = Path(shapefile_path)
        if not shapefile_path.exists():
            raise FileNotFoundError(f"Shapefile not found: {shapefile_path}")
        
        print(f"🔄 Converting {shapefile_path.name} to GeoJSON...")
        
        # Read shapefile
        gdf = gpd.read_file(shapefile_path)
        
        print(f"   📊 Shapefile info: {len(gdf)} features, CRS: {gdf.crs}")
        
        # Convert to WGS84 if needed
        if gdf.crs != 'EPSG:4326':
            print(f"   🔄 Converting CRS from {gdf.crs} to EPSG:4326")
            gdf = gdf.to_crs('EPSG:4326')
        
        # Generate output filename if not provided
        if output_geojson is None:
            output_geojson = self.output_dir / f"{shapefile_path.stem}.geojson"
        else:
            output_geojson = Path(output_geojson)
        
        # Save to GeoJSON
        gdf.to_file(output_geojson, driver='GeoJSON')
        
        print(f"   ✅ Saved {len(gdf)} features to {output_geojson}")
        
        return gdf, output_geojson
    
    def batch_convert_tiffs(self, pattern="*.tif", sample_rate=0.1):
        """Convert multiple TIFF files to CSV"""
        tiff_files = list(self.input_dir.glob(pattern))
        
        if not tiff_files:
            print(f"❌ No TIFF files found matching pattern: {pattern}")
            return
        
        print(f"🔄 Converting {len(tiff_files)} TIFF files...")
        
        results = []
        for tiff_file in tqdm(tiff_files, desc="Converting TIFFs"):
            try:
                df, output_path = self.tiff_to_csv(tiff_file, sample_rate=sample_rate)
                results.append({
                    'input_file': str(tiff_file),
                    'output_file': str(output_path),
                    'pixel_count': len(df),
                    'bands': len([col for col in df.columns if col.startswith('band_')])
                })
            except Exception as e:
                print(f"❌ Error converting {tiff_file}: {e}")
        
        # Save conversion summary
        summary_path = self.output_dir / "conversion_summary.json"
        with open(summary_path, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"✅ Conversion complete! Summary saved to {summary_path}")
        return results

def main():
    parser = argparse.ArgumentParser(description="Convert SAR data formats for NASA SAR App")
    parser.add_argument("--input-dir", default="data", help="Input directory")
    parser.add_argument("--output-dir", default="output", help="Output directory")
    parser.add_argument("--tiff", help="Convert specific TIFF file to CSV")
    parser.add_argument("--shapefile", help="Convert specific shapefile to GeoJSON")
    parser.add_argument("--batch-tiff", action="store_true", help="Convert all TIFF files in input directory")
    parser.add_argument("--sample-rate", type=float, default=0.1, help="Sampling rate for TIFF conversion (0.1 = 10%)")
    parser.add_argument("--pattern", default="*.tif", help="File pattern for batch conversion")
    
    args = parser.parse_args()
    
    converter = DataConverter(args.input_dir, args.output_dir)
    
    if args.tiff:
        converter.tiff_to_csv(args.tiff, sample_rate=args.sample_rate)
    elif args.shapefile:
        converter.shapefile_to_geojson(args.shapefile)
    elif args.batch_tiff:
        converter.batch_convert_tiffs(args.pattern, args.sample_rate)
    else:
        print("🌍 NASA SAR Data Converter")
        print("=" * 40)
        print("Usage examples:")
        print("  python data_converter.py --tiff data/sar_image.tif")
        print("  python data_converter.py --shapefile data/chesapeake_bay.shp")
        print("  python data_converter.py --batch-tiff --sample-rate 0.05")

if __name__ == "__main__":
    main()
