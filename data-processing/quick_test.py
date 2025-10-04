#!/usr/bin/env python3
"""
Quick Test Script for NASA SAR Data Processing
Tests the basic functionality without requiring actual data files
"""

import sys
import os
from pathlib import Path
import numpy as np
import pandas as pd

def test_environment():
    """Test if the environment is set up correctly"""
    print("🧪 Testing NASA SAR Data Processing Environment...")
    
    try:
        # Test basic imports
        import numpy as np
        import pandas as pd
        print("✅ Basic packages (numpy, pandas) imported successfully")
        
        # Test geospatial packages
        try:
            import rasterio
            print("✅ Rasterio imported successfully")
        except ImportError:
            print("⚠️  Rasterio not installed - run: pip install rasterio")
        
        try:
            import geopandas as gpd
            print("✅ GeoPandas imported successfully")
        except ImportError:
            print("⚠️  GeoPandas not installed - run: pip install geopandas")
        
        try:
            import sklearn
            print("✅ Scikit-learn imported successfully")
        except ImportError:
            print("⚠️  Scikit-learn not installed - run: pip install scikit-learn")
        
        return True
        
    except Exception as e:
        print(f"❌ Error testing environment: {e}")
        return False

def create_sample_data():
    """Create sample data for testing"""
    print("\n📊 Creating sample data for testing...")
    
    # Create sample directory structure
    data_dir = Path("data")
    output_dir = Path("output")
    
    data_dir.mkdir(exist_ok=True)
    output_dir.mkdir(exist_ok=True)
    
    print(f"✅ Created directories: {data_dir}, {output_dir}")
    
    # Create sample CSV data
    sample_data = {
        'longitude': np.random.uniform(-76.5, -76.0, 1000),
        'latitude': np.random.uniform(38.0, 39.0, 1000),
        'sar_value': np.random.uniform(0, 1, 1000),
        'ndvi_value': np.random.uniform(-1, 1, 1000),
        'ndci_value': np.random.uniform(-1, 1, 1000),
        'wqi_value': np.random.uniform(0, 1, 1000)
    }
    
    df = pd.DataFrame(sample_data)
    sample_csv = output_dir / "sample_sar_data.csv"
    df.to_csv(sample_csv, index=False)
    
    print(f"✅ Created sample data: {sample_csv}")
    print(f"   📈 Sample data shape: {df.shape}")
    print(f"   📊 Data range:")
    print(f"      SAR: {df['sar_value'].min():.3f} to {df['sar_value'].max():.3f}")
    print(f"      NDVI: {df['ndvi_value'].min():.3f} to {df['ndvi_value'].max():.3f}")
    print(f"      NDCI: {df['ndci_value'].min():.3f} to {df['ndci_value'].max():.3f}")
    print(f"      WQI: {df['wqi_value'].min():.3f} to {df['wqi_value'].max():.3f}")
    
    return sample_csv

def test_index_calculations():
    """Test index calculation functions"""
    print("\n🧮 Testing index calculations...")
    
    # Create sample arrays
    red = np.random.uniform(0, 1, (100, 100))
    nir = np.random.uniform(0, 1, (100, 100))
    green = np.random.uniform(0, 1, (100, 100))
    sar = np.random.uniform(0, 1, (100, 100))
    
    # Test NDVI calculation
    denominator = nir + red
    ndvi = np.where(denominator != 0, (nir - red) / denominator, 0)
    ndvi = np.clip(ndvi, -1, 1)
    
    print(f"✅ NDVI calculated: range {ndvi.min():.3f} to {ndvi.max():.3f}")
    
    # Test NDCI calculation
    denominator = red + green
    ndci = np.where(denominator != 0, (red - green) / denominator, 0)
    ndci = np.clip(ndci, -1, 1)
    
    print(f"✅ NDCI calculated: range {ndci.min():.3f} to {ndci.max():.3f}")
    
    # Test WQI calculation
    sar_normalized = (sar - sar.min()) / (sar.max() - sar.min())
    ndvi_normalized = (ndvi + 1) / 2
    wqi = 0.6 * sar_normalized + 0.4 * ndvi_normalized
    wqi = np.clip(wqi, 0, 1)
    
    print(f"✅ WQI calculated: range {wqi.min():.3f} to {wqi.max():.3f}")
    
    return True

def main():
    print("🚀 NASA SAR Data Processing - Quick Start Test")
    print("=" * 50)
    
    # Test environment
    env_ok = test_environment()
    
    if env_ok:
        # Create sample data
        sample_file = create_sample_data()
        
        # Test calculations
        calc_ok = test_index_calculations()
        
        if calc_ok:
            print("\n🎉 Quick start test completed successfully!")
            print("\n📋 Next steps:")
            print("1. Place your SAR data files in the 'data' directory")
            print("2. Run: python scripts/pipeline.py --sar data/your_sar_file.tif")
            print("3. Check the 'output' directory for processed files")
            print(f"4. Sample data created at: {sample_file}")
        else:
            print("\n❌ Index calculation test failed")
    else:
        print("\n❌ Environment test failed")
        print("\n🔧 To fix:")
        print("1. Install Python packages: pip install -r requirements.txt")
        print("2. Run this test again: python quick_test.py")

if __name__ == "__main__":
    main()
