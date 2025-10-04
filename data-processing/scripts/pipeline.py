#!/usr/bin/env python3
"""
Data Processing Pipeline for NASA SAR App
Complete pipeline for processing SAR data, calculating indices, and preparing for Flutter
"""

import os
import sys
import subprocess
from pathlib import Path
import json
import argparse
from datetime import datetime

# Add scripts directory to path
sys.path.append(str(Path(__file__).parent))

from data_converter import DataConverter
from index_calculator import IndexCalculator

class DataProcessingPipeline:
    def __init__(self, base_dir="data-processing"):
        self.base_dir = Path(base_dir)
        self.data_dir = self.base_dir / "data"
        self.output_dir = self.base_dir / "output"
        self.scripts_dir = self.base_dir / "scripts"
        
        # Create directories
        for dir_path in [self.data_dir, self.output_dir, self.scripts_dir]:
            dir_path.mkdir(exist_ok=True)
        
        # Initialize converters
        self.converter = DataConverter(self.data_dir, self.output_dir)
        self.calculator = IndexCalculator(self.data_dir, self.output_dir)
        
    def setup_environment(self):
        """Set up Python environment and install dependencies"""
        print("🚀 Setting up data processing environment...")
        
        requirements_file = self.base_dir / "requirements.txt"
        if requirements_file.exists():
            try:
                subprocess.check_call([
                    sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
                ])
                print("✅ Dependencies installed successfully")
                return True
            except subprocess.CalledProcessError as e:
                print(f"❌ Error installing dependencies: {e}")
                return False
        else:
            print("❌ Requirements file not found")
            return False
    
    def process_sar_data(self, sar_file, red_file=None, nir_file=None, green_file=None, sample_rate=0.1):
        """
        Complete SAR data processing pipeline
        
        Args:
            sar_file: Path to SAR data file
            red_file: Path to red band (optional)
            nir_file: Path to NIR band (optional)
            green_file: Path to green band (optional)
            sample_rate: Sampling rate for CSV conversion
        """
        print("🌍 Starting SAR data processing pipeline...")
        print(f"   📁 Input SAR file: {sar_file}")
        
        pipeline_results = {
            'timestamp': datetime.now().isoformat(),
            'input_files': {
                'sar': str(sar_file),
                'red': str(red_file) if red_file else None,
                'nir': str(nir_file) if nir_file else None,
                'green': str(green_file) if green_file else None
            },
            'output_files': {},
            'statistics': {}
        }
        
        # Step 1: Convert SAR data to CSV
        print("\n📊 Step 1: Converting SAR data to CSV...")
        try:
            sar_df, sar_csv = self.converter.tiff_to_csv(sar_file, sample_rate=sample_rate)
            pipeline_results['output_files']['sar_csv'] = str(sar_csv)
            pipeline_results['statistics']['sar_pixels'] = len(sar_df)
            print(f"   ✅ SAR data converted: {len(sar_df)} pixels")
        except Exception as e:
            print(f"   ❌ Error converting SAR data: {e}")
            return None
        
        # Step 2: Calculate indices
        print("\n🧮 Step 2: Calculating indices...")
        try:
            indices_results = self.calculator.calculate_all_indices(
                sar_file, red_file, nir_file, green_file
            )
            
            for index_name, index_data in indices_results.items():
                pipeline_results['output_files'][f'{index_name}_raster'] = index_data['path']
                
                # Convert index raster to CSV
                index_csv = self.output_dir / f"{index_name}_pixels.csv"
                try:
                    index_df, _ = self.converter.tiff_to_csv(
                        index_data['path'], 
                        output_csv=index_csv,
                        sample_rate=sample_rate
                    )
                    pipeline_results['output_files'][f'{index_name}_csv'] = str(index_csv)
                    pipeline_results['statistics'][f'{index_name}_pixels'] = len(index_df)
                    print(f"   ✅ {index_name.upper()} converted to CSV: {len(index_df)} pixels")
                except Exception as e:
                    print(f"   ⚠️  Warning: Could not convert {index_name} to CSV: {e}")
            
        except Exception as e:
            print(f"   ❌ Error calculating indices: {e}")
            return None
        
        # Step 3: Generate Flutter-compatible data
        print("\n📱 Step 3: Preparing Flutter-compatible data...")
        try:
            flutter_data = self.prepare_flutter_data(pipeline_results)
            pipeline_results['flutter_data'] = flutter_data
            print("   ✅ Flutter data prepared")
        except Exception as e:
            print(f"   ❌ Error preparing Flutter data: {e}")
            return None
        
        # Step 4: Save pipeline summary
        summary_path = self.output_dir / "pipeline_summary.json"
        with open(summary_path, 'w') as f:
            json.dump(pipeline_results, f, indent=2)
        
        print(f"\n🎉 Pipeline completed successfully!")
        print(f"   📄 Summary saved to: {summary_path}")
        print(f"   📊 Total output files: {len(pipeline_results['output_files'])}")
        
        return pipeline_results
    
    def prepare_flutter_data(self, pipeline_results):
        """Prepare data in formats suitable for Flutter app"""
        flutter_data = {
            'metadata': {
                'processing_date': pipeline_results['timestamp'],
                'data_types': list(pipeline_results['output_files'].keys())
            },
            'files': {},
            'statistics': pipeline_results['statistics']
        }
        
        # Create simplified CSV files for Flutter
        for file_type, file_path in pipeline_results['output_files'].items():
            if file_path.endswith('.csv'):
                try:
                    df = pd.read_csv(file_path)
                    
                    # Create simplified version for Flutter
                    simplified_path = self.output_dir / f"flutter_{file_type}"
                    
                    if 'sar' in file_type:
                        # SAR data: keep coordinates and main band
                        simplified_df = df[['longitude', 'latitude', 'band_1']].copy()
                        simplified_df.columns = ['lng', 'lat', 'sar_value']
                    elif 'ndvi' in file_type:
                        # NDVI data: keep coordinates and NDVI values
                        simplified_df = df[['longitude', 'latitude', 'band_1']].copy()
                        simplified_df.columns = ['lng', 'lat', 'ndvi_value']
                    elif 'ndci' in file_type:
                        # NDCI data: keep coordinates and NDCI values
                        simplified_df = df[['longitude', 'latitude', 'band_1']].copy()
                        simplified_df.columns = ['lng', 'lat', 'ndci_value']
                    elif 'wqi' in file_type:
                        # WQI data: keep coordinates and WQI values
                        simplified_df = df[['longitude', 'latitude', 'band_1']].copy()
                        simplified_df.columns = ['lng', 'lat', 'wqi_value']
                    
                    # Save simplified CSV
                    simplified_df.to_csv(simplified_path, index=False)
                    flutter_data['files'][file_type] = str(simplified_path)
                    
                except Exception as e:
                    print(f"   ⚠️  Warning: Could not simplify {file_type}: {e}")
        
        return flutter_data
    
    def process_shapefiles(self, shapefile_pattern="*.shp"):
        """Process shapefiles to GeoJSON format"""
        print("🗺️  Processing shapefiles...")
        
        shapefiles = list(self.data_dir.glob(shapefile_pattern))
        if not shapefiles:
            print(f"   ⚠️  No shapefiles found matching pattern: {shapefile_pattern}")
            return
        
        results = []
        for shapefile in shapefiles:
            try:
                gdf, geojson_path = self.converter.shapefile_to_geojson(shapefile)
                results.append({
                    'input': str(shapefile),
                    'output': str(geojson_path),
                    'features': len(gdf)
                })
                print(f"   ✅ Converted {shapefile.name}: {len(gdf)} features")
            except Exception as e:
                print(f"   ❌ Error converting {shapefile}: {e}")
        
        return results

def main():
    parser = argparse.ArgumentParser(description="NASA SAR Data Processing Pipeline")
    parser.add_argument("--setup", action="store_true", help="Set up environment")
    parser.add_argument("--sar", help="SAR data file")
    parser.add_argument("--red", help="Red band file")
    parser.add_argument("--nir", help="NIR band file")
    parser.add_argument("--green", help="Green band file")
    parser.add_argument("--sample-rate", type=float, default=0.1, help="Sampling rate")
    parser.add_argument("--process-shapefiles", action="store_true", help="Process shapefiles")
    parser.add_argument("--base-dir", default="data-processing", help="Base directory")
    
    args = parser.parse_args()
    
    pipeline = DataProcessingPipeline(args.base_dir)
    
    if args.setup:
        pipeline.setup_environment()
    elif args.sar:
        pipeline.process_sar_data(
            args.sar, args.red, args.nir, args.green, args.sample_rate
        )
    elif args.process_shapefiles:
        pipeline.process_shapefiles()
    else:
        print("🌍 NASA SAR Data Processing Pipeline")
        print("=" * 50)
        print("Usage examples:")
        print("  python pipeline.py --setup")
        print("  python pipeline.py --sar data/sar_image.tif --red data/red.tif --nir data/nir.tif")
        print("  python pipeline.py --process-shapefiles")

if __name__ == "__main__":
    main()
