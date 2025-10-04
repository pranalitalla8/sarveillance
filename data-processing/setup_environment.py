#!/usr/bin/env python3
"""
Data Processing Setup Script for NASA SAR App
Sets up Python environment and installs required libraries
"""

import subprocess
import sys
import os
from pathlib import Path

def setup_python_environment():
    """Set up Python environment for data processing"""
    print("🐍 Setting up Python environment for NASA SAR data processing...")
    
    # Create data processing directory
    data_dir = Path("data-processing")
    data_dir.mkdir(exist_ok=True)
    
    # Create subdirectories
    subdirs = ["scripts", "data", "output", "temp"]
    for subdir in subdirs:
        (data_dir / subdir).mkdir(exist_ok=True)
    
    print(f"✅ Created data processing directory structure: {data_dir}")
    
    # Install required packages
    requirements_file = data_dir / "requirements.txt"
    if requirements_file.exists():
        print("📦 Installing required Python packages...")
        try:
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
            ])
            print("✅ Successfully installed all required packages")
        except subprocess.CalledProcessError as e:
            print(f"❌ Error installing packages: {e}")
            return False
    
    return True

def create_environment_script():
    """Create environment setup script"""
    script_content = '''#!/bin/bash
# Environment setup script for NASA SAR data processing

echo "🚀 Setting up NASA SAR Data Processing Environment..."

# Create virtual environment (optional)
if [ "$1" = "--venv" ]; then
    echo "Creating virtual environment..."
    python -m venv nasa_sar_env
    source nasa_sar_env/bin/activate
    echo "Virtual environment activated"
fi

# Install requirements
echo "Installing Python packages..."
pip install -r requirements.txt

# Verify installation
echo "Verifying installation..."
python -c "import rasterio, pandas, geopandas, sklearn; print('✅ All packages installed successfully')"

echo "🎉 Environment setup complete!"
echo "Run: python scripts/data_converter.py --help"
'''
    
    script_path = Path("data-processing/setup_env.sh")
    with open(script_path, 'w') as f:
        f.write(script_content)
    
    # Make executable on Unix systems
    if os.name != 'nt':
        os.chmod(script_path, 0o755)
    
    print(f"✅ Created environment setup script: {script_path}")

if __name__ == "__main__":
    print("🌍 NASA SAR Data Processing Environment Setup")
    print("=" * 50)
    
    success = setup_python_environment()
    if success:
        create_environment_script()
        print("\n🎯 Next steps:")
        print("1. Run: cd data-processing")
        print("2. Run: python scripts/data_converter.py --help")
        print("3. Run: python scripts/index_calculator.py --help")
    else:
        print("\n❌ Setup failed. Please check error messages above.")
