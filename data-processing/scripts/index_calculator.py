#!/usr/bin/env python3
"""
Index Calculator for NASA SAR App
Calculates NDVI, NDCI, and Water Quality Index from satellite imagery
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

class IndexCalculator:
    def __init__(self, input_dir="data", output_dir="output"):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def calculate_ndvi(self, red_band, nir_band, output_path=None):
        """
        Calculate Normalized Difference Vegetation Index (NDVI)
        NDVI = (NIR - Red) / (NIR + Red)
        
        Args:
            red_band: Red band data (numpy array or path to TIFF)
            nir_band: Near-infrared band data (numpy array or path to TIFF)
            output_path: Output path for NDVI raster
        """
        print("🌱 Calculating NDVI...")
        
        # Load data if paths provided
        if isinstance(red_band, (str, Path)):
            with rasterio.open(red_band) as src:
                red_data = src.read(1)
                profile = src.profile
                transform = src.transform
                crs = src.crs
        else:
            red_data = red_band
            
        if isinstance(nir_band, (str, Path)):
            with rasterio.open(nir_band) as src:
                nir_data = src.read(1)
                if isinstance(red_band, (str, Path)):
                    profile = src.profile
                    transform = src.transform
                    crs = src.crs
        else:
            nir_data = nir_band
        
        # Calculate NDVI
        # Avoid division by zero
        denominator = nir_data + red_data
        ndvi = np.where(denominator != 0, (nir_data - red_data) / denominator, 0)
        
        # Clip values to valid range [-1, 1]
        ndvi = np.clip(ndvi, -1, 1)
        
        print(f"   📊 NDVI range: {ndvi.min():.3f} to {ndvi.max():.3f}")
        print(f"   📈 Mean NDVI: {ndvi.mean():.3f}")
        
        # Save if output path provided
        if output_path:
            output_path = Path(output_path)
            profile.update(dtype=rasterio.float32, count=1, nodata=-9999)
            
            with rasterio.open(output_path, 'w', **profile) as dst:
                dst.write(ndvi.astype(rasterio.float32), 1)
                dst.set_band_description(1, 'NDVI')
            
            print(f"   ✅ NDVI saved to {output_path}")
        
        return ndvi
    
    def calculate_ndci(self, green_band, red_band, output_path=None):
        """
        Calculate Normalized Difference Chlorophyll Index (NDCI)
        NDCI = (Red - Green) / (Red + Green)
        
        Args:
            green_band: Green band data (numpy array or path to TIFF)
            red_band: Red band data (numpy array or path to TIFF)
            output_path: Output path for NDCI raster
        """
        print("🌊 Calculating NDCI (Chlorophyll Index)...")
        
        # Load data if paths provided
        if isinstance(green_band, (str, Path)):
            with rasterio.open(green_band) as src:
                green_data = src.read(1)
                profile = src.profile
                transform = src.transform
                crs = src.crs
        else:
            green_data = green_band
            
        if isinstance(red_band, (str, Path)):
            with rasterio.open(red_band) as src:
                red_data = src.read(1)
                if isinstance(green_band, (str, Path)):
                    profile = src.profile
                    transform = src.transform
                    crs = src.crs
        else:
            red_data = red_band
        
        # Calculate NDCI
        denominator = red_data + green_data
        ndci = np.where(denominator != 0, (red_data - green_data) / denominator, 0)
        
        # Clip values to valid range [-1, 1]
        ndci = np.clip(ndci, -1, 1)
        
        print(f"   📊 NDCI range: {ndci.min():.3f} to {ndci.max():.3f}")
        print(f"   📈 Mean NDCI: {ndci.mean():.3f}")
        
        # Save if output path provided
        if output_path:
            output_path = Path(output_path)
            profile.update(dtype=rasterio.float32, count=1, nodata=-9999)
            
            with rasterio.open(output_path, 'w', **profile) as dst:
                dst.write(ndci.astype(rasterio.float32), 1)
                dst.set_band_description(1, 'NDCI')
            
            print(f"   ✅ NDCI saved to {output_path}")
        
        return ndci
    
    def calculate_water_quality_index(self, sar_data, ndvi_data=None, ndci_data=None, output_path=None):
        """
        Calculate Water Quality Index based on SAR backscatter and vegetation indices
        
        Args:
            sar_data: SAR backscatter data (numpy array or path to TIFF)
            ndvi_data: NDVI data (optional)
            ndci_data: NDCI data (optional)
            output_path: Output path for WQI raster
        """
        print("💧 Calculating Water Quality Index...")
        
        # Load SAR data if path provided
        if isinstance(sar_data, (str, Path)):
            with rasterio.open(sar_data) as src:
                sar_values = src.read(1)
                profile = src.profile
                transform = src.transform
                crs = src.crs
        else:
            sar_values = sar_data
        
        # Normalize SAR values to 0-1 range
        sar_min, sar_max = sar_values.min(), sar_values.max()
        sar_normalized = (sar_values - sar_min) / (sar_max - sar_min)
        
        # Initialize WQI with SAR component
        wqi = sar_normalized.copy()
        
        # Add NDVI component if available
        if ndvi_data is not None:
            if isinstance(ndvi_data, (str, Path)):
                with rasterio.open(ndvi_data) as src:
                    ndvi_values = src.read(1)
            else:
                ndvi_values = ndvi_data
            
            # NDVI contribution (higher NDVI = better water quality)
            ndvi_normalized = (ndvi_values + 1) / 2  # Convert [-1,1] to [0,1]
            wqi = 0.6 * wqi + 0.4 * ndvi_normalized
            print(f"   📊 Added NDVI component to WQI")
        
        # Add NDCI component if available
        if ndci_data is not None:
            if isinstance(ndci_data, (str, Path)):
                with rasterio.open(ndci_data) as src:
                    ndci_values = src.read(1)
            else:
                ndci_values = ndci_data
            
            # NDCI contribution (higher NDCI = better water quality)
            ndci_normalized = (ndci_values + 1) / 2  # Convert [-1,1] to [0,1]
            wqi = 0.7 * wqi + 0.3 * ndci_normalized
            print(f"   📊 Added NDCI component to WQI")
        
        # Ensure WQI is in valid range [0, 1]
        wqi = np.clip(wqi, 0, 1)
        
        print(f"   📊 WQI range: {wqi.min():.3f} to {wqi.max():.3f}")
        print(f"   📈 Mean WQI: {wqi.mean():.3f}")
        
        # Save if output path provided
        if output_path:
            output_path = Path(output_path)
            profile.update(dtype=rasterio.float32, count=1, nodata=-9999)
            
            with rasterio.open(output_path, 'w', **profile) as dst:
                dst.write(wqi.astype(rasterio.float32), 1)
                dst.set_band_description(1, 'Water Quality Index')
            
            print(f"   ✅ WQI saved to {output_path}")
        
        return wqi
    
    def calculate_all_indices(self, sar_path, red_path=None, nir_path=None, green_path=None):
        """
        Calculate all indices from available data
        
        Args:
            sar_path: Path to SAR data
            red_path: Path to red band (optional)
            nir_path: Path to NIR band (optional)
            green_path: Path to green band (optional)
        """
        print("🌍 Calculating all indices...")
        
        results = {}
        
        # Calculate NDVI if red and NIR bands available
        if red_path and nir_path:
            ndvi_path = self.output_dir / "ndvi.tif"
            ndvi = self.calculate_ndvi(red_path, nir_path, ndvi_path)
            results['ndvi'] = {'path': str(ndvi_path), 'data': ndvi}
        
        # Calculate NDCI if green and red bands available
        if green_path and red_path:
            ndci_path = self.output_dir / "ndci.tif"
            ndci = self.calculate_ndci(green_path, red_path, ndci_path)
            results['ndci'] = {'path': str(ndci_path), 'data': ndci}
        
        # Calculate WQI
        wqi_path = self.output_dir / "water_quality_index.tif"
        wqi = self.calculate_water_quality_index(
            sar_path, 
            results.get('ndvi', {}).get('data'),
            results.get('ndci', {}).get('data'),
            wqi_path
        )
        results['wqi'] = {'path': str(wqi_path), 'data': wqi}
        
        # Save summary
        summary = {
            'sar_file': str(sar_path),
            'indices_calculated': list(results.keys()),
            'output_files': {k: v['path'] for k, v in results.items()}
        }
        
        summary_path = self.output_dir / "indices_summary.json"
        with open(summary_path, 'w') as f:
            json.dump(summary, f, indent=2)
        
        print(f"✅ All indices calculated! Summary saved to {summary_path}")
        return results

def main():
    parser = argparse.ArgumentParser(description="Calculate vegetation and water quality indices")
    parser.add_argument("--input-dir", default="data", help="Input directory")
    parser.add_argument("--output-dir", default="output", help="Output directory")
    parser.add_argument("--sar", required=True, help="SAR data file")
    parser.add_argument("--red", help="Red band file for NDVI")
    parser.add_argument("--nir", help="NIR band file for NDVI")
    parser.add_argument("--green", help="Green band file for NDCI")
    parser.add_argument("--ndvi-only", action="store_true", help="Calculate only NDVI")
    parser.add_argument("--ndci-only", action="store_true", help="Calculate only NDCI")
    parser.add_argument("--wqi-only", action="store_true", help="Calculate only WQI")
    
    args = parser.parse_args()
    
    calculator = IndexCalculator(args.input_dir, args.output_dir)
    
    if args.ndvi_only:
        if not args.red or not args.nir:
            print("❌ Red and NIR bands required for NDVI calculation")
            return
        calculator.calculate_ndvi(args.red, args.nir)
    elif args.ndci_only:
        if not args.green or not args.red:
            print("❌ Green and Red bands required for NDCI calculation")
            return
        calculator.calculate_ndci(args.green, args.red)
    elif args.wqi_only:
        calculator.calculate_water_quality_index(args.sar)
    else:
        calculator.calculate_all_indices(args.sar, args.red, args.nir, args.green)

if __name__ == "__main__":
    main()
