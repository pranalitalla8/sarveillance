#!/usr/bin/env python3
"""
Simplified Quick Start for NASA SAR Data Processing
Works with basic Python libraries to demonstrate the concept
"""

import json
import csv
import os
from pathlib import Path
import random
import math

def create_sample_sar_data():
    """Create sample SAR data for demonstration"""
    print("📊 Creating sample SAR data...")
    
    # Create directories
    data_dir = Path("data")
    output_dir = Path("output")
    data_dir.mkdir(exist_ok=True)
    output_dir.mkdir(exist_ok=True)
    
    # Generate sample data points around Chesapeake Bay area
    sample_data = []
    for i in range(1000):
        # Chesapeake Bay coordinates
        lng = random.uniform(-76.5, -76.0)
        lat = random.uniform(38.0, 39.0)
        
        # Generate realistic SAR values
        sar_value = random.uniform(0.1, 0.9)
        
        # Generate NDVI values (higher near water)
        distance_from_center = math.sqrt((lng + 76.25)**2 + (lat - 38.5)**2)
        ndvi_value = max(-0.5, min(0.8, 0.3 - distance_from_center * 0.5))
        
        # Generate NDCI values
        ndci_value = random.uniform(-0.3, 0.6)
        
        # Generate Water Quality Index
        wqi_value = random.uniform(0.2, 0.9)
        
        sample_data.append({
            'longitude': round(lng, 6),
            'latitude': round(lat, 6),
            'sar_value': round(sar_value, 4),
            'ndvi_value': round(ndvi_value, 4),
            'ndci_value': round(ndci_value, 4),
            'wqi_value': round(wqi_value, 4)
        })
    
    # Save to CSV
    csv_file = output_dir / "sample_sar_data.csv"
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=sample_data[0].keys())
        writer.writeheader()
        writer.writerows(sample_data)
    
    print(f"✅ Sample data created: {csv_file}")
    print(f"   📈 Data points: {len(sample_data)}")
    
    return csv_file

def calculate_indices_sample():
    """Demonstrate index calculations with sample data"""
    print("\n🧮 Demonstrating index calculations...")
    
    # Sample band values
    red = 0.3
    nir = 0.7
    green = 0.4
    
    # Calculate NDVI
    ndvi = (nir - red) / (nir + red) if (nir + red) != 0 else 0
    print(f"✅ NDVI = (NIR - Red) / (NIR + Red) = ({nir} - {red}) / ({nir} + {red}) = {ndvi:.3f}")
    
    # Calculate NDCI
    ndci = (red - green) / (red + green) if (red + green) != 0 else 0
    print(f"✅ NDCI = (Red - Green) / (Red + Green) = ({red} - {green}) / ({red} + {green}) = {ndci:.3f}")
    
    # Calculate WQI (simplified)
    sar_value = 0.5
    wqi = 0.6 * sar_value + 0.4 * ndvi
    print(f"✅ WQI = 0.6 × SAR + 0.4 × NDVI = 0.6 × {sar_value} + 0.4 × {ndvi:.3f} = {wqi:.3f}")
    
    return {
        'ndvi': ndvi,
        'ndci': ndci,
        'wqi': wqi
    }

def create_flutter_data():
    """Create Flutter-compatible data format"""
    print("\n📱 Creating Flutter-compatible data...")
    
    # Read sample data
    csv_file = Path("output/sample_sar_data.csv")
    if not csv_file.exists():
        print("❌ Sample data not found. Run create_sample_sar_data() first.")
        return
    
    flutter_data = {
        'metadata': {
            'data_type': 'SAR Analysis',
            'location': 'Chesapeake Bay',
            'coordinates': {
                'min_lng': -76.5,
                'max_lng': -76.0,
                'min_lat': 38.0,
                'max_lat': 39.0
            },
            'indices': ['SAR', 'NDVI', 'NDCI', 'WQI']
        },
        'data_points': []
    }
    
    # Read and process data
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            flutter_data['data_points'].append({
                'lng': float(row['longitude']),
                'lat': float(row['latitude']),
                'sar': float(row['sar_value']),
                'ndvi': float(row['ndvi_value']),
                'ndci': float(row['ndci_value']),
                'wqi': float(row['wqi_value'])
            })
    
    # Save Flutter data
    flutter_file = Path("output/flutter_sar_data.json")
    with open(flutter_file, 'w') as f:
        json.dump(flutter_data, f, indent=2)
    
    print(f"✅ Flutter data created: {flutter_file}")
    print(f"   📊 Data points: {len(flutter_data['data_points'])}")
    
    return flutter_file

def create_processing_summary():
    """Create processing summary"""
    print("\n📋 Creating processing summary...")
    
    summary = {
        'processing_info': {
            'timestamp': '2024-01-01T00:00:00Z',
            'location': 'Chesapeake Bay',
            'data_type': 'SAR Analysis',
            'processing_method': 'Sample Data Generation'
        },
        'indices_calculated': {
            'NDVI': {
                'formula': '(NIR - Red) / (NIR + Red)',
                'range': '[-1, 1]',
                'interpretation': 'Vegetation health'
            },
            'NDCI': {
                'formula': '(Red - Green) / (Red + Green)',
                'range': '[-1, 1]',
                'interpretation': 'Chlorophyll content'
            },
            'WQI': {
                'formula': '0.6 × SAR + 0.4 × NDVI',
                'range': '[0, 1]',
                'interpretation': 'Water quality'
            }
        },
        'output_files': [
            'sample_sar_data.csv',
            'flutter_sar_data.json',
            'processing_summary.json'
        ],
        'statistics': {
            'total_points': 1000,
            'data_range': {
                'longitude': [-76.5, -76.0],
                'latitude': [38.0, 39.0]
            }
        }
    }
    
    summary_file = Path("output/processing_summary.json")
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print(f"✅ Processing summary created: {summary_file}")
    
    return summary_file

def main():
    print("🚀 NASA SAR Data Processing - Quick Start")
    print("=" * 50)
    print("This demo creates sample data and demonstrates the processing pipeline")
    print("without requiring external libraries.\n")
    
    try:
        # Step 1: Create sample data
        sample_file = create_sample_sar_data()
        
        # Step 2: Demonstrate calculations
        indices = calculate_indices_sample()
        
        # Step 3: Create Flutter data
        flutter_file = create_flutter_data()
        
        # Step 4: Create summary
        summary_file = create_processing_summary()
        
        print("\n🎉 Quick start completed successfully!")
        print("\n📁 Generated files:")
        print(f"   📊 Sample data: {sample_file}")
        print(f"   📱 Flutter data: {flutter_file}")
        print(f"   📋 Summary: {summary_file}")
        
        print("\n🎯 Next steps:")
        print("1. Install full dependencies: pip install -r requirements.txt")
        print("2. Process real SAR data: python scripts/pipeline.py --sar data/your_file.tif")
        print("3. Integrate with Flutter app using the generated JSON files")
        
    except Exception as e:
        print(f"\n❌ Error during quick start: {e}")
        print("Please check the error message and try again.")

if __name__ == "__main__":
    main()
