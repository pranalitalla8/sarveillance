from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from gee_service import GEEService
import os

app = FastAPI(title="NASA SAR Tile Server")

# Allow Flutter app to access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Restrict in production
    allow_methods=["*"],
    allow_headers=["*"],
)

gee = GEEService()

@app.get("/")
def root():
    return {
        "status": "NASA SAR Tile Server Running",
        "version": "1.0.0",
        "endpoints": [
            "/tiles/sar",
            "/tiles/oil-detection",
            "/dates/available"
        ]
    }

@app.get("/tiles/sar")
def get_sar_tiles(
    start_date: str = "2024-01-01",
    end_date: str = "2024-12-31",
    bounds: str = "-76.5,37.5,-75.5,39.5"  # Chesapeake Bay default
):
    """Get SAR imagery tile URL from Earth Engine

    Args:
        start_date: Start date in YYYY-MM-DD format
        end_date: End date in YYYY-MM-DD format
        bounds: Bounding box as "west,south,east,north"

    Returns:
        Tile URL for Sentinel-1 SAR imagery
    """
    print(f"🛰️  SAR Tile Request: {start_date} to {end_date}, bounds={bounds}")
    try:
        tile_url = gee.get_sar_tiles(start_date, end_date, bounds)
        print(f"✅ Generated SAR tile URL: {tile_url[:100]}...")
        return {
            "tile_url": tile_url,
            "start_date": start_date,
            "end_date": end_date,
            "bounds": bounds
        }
    except Exception as e:
        print(f"❌ Error generating SAR tiles: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error generating SAR tiles: {str(e)}")

@app.get("/tiles/oil-detection")
def get_oil_detection_tiles(
    start_date: str = "2024-01-01",
    end_date: str = "2024-12-31",
    bounds: str = "-76.5,37.5,-75.5,39.5"
):
    """Get oil spill detection overlay from Earth Engine

    Uses VV backscatter threshold (< -22 dB) to detect potential oil spills
    """
    try:
        tile_url = gee.get_oil_detection_tiles(start_date, end_date, bounds)
        return {
            "tile_url": tile_url,
            "start_date": start_date,
            "end_date": end_date
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating oil detection tiles: {str(e)}")

@app.get("/tiles/teammate-oil-detection")
def get_teammate_oil_tiles(
    start_date: str = "2024-01-01",
    end_date: str = "2024-12-31",
    bounds: str = "-77.3,36.8,-75,39.7"  # Teammate's ROI
):
    """Get oil detection overlay using teammate's JRC Water Mask method

    Uses JRC Global Surface Water dataset to only detect oil in
    historically water-covered areas, reducing false positives on land.
    """
    print(f"🌊 Teammate Oil Detection Request: {start_date} to {end_date}")
    try:
        tile_url = gee.get_teammate_oil_detection_tiles(start_date, end_date, bounds)
        print(f"✅ Generated teammate oil detection tile URL")
        return {
            "tile_url": tile_url,
            "start_date": start_date,
            "end_date": end_date,
            "method": "JRC Water Mask + VV < -22 dB"
        }
    except Exception as e:
        print(f"❌ Error generating teammate oil detection: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error generating teammate oil detection: {str(e)}")

@app.get("/dates/available")
def get_available_dates(bounds: str = "-76.5,37.5,-75.5,39.5"):
    """Get list of available SAR image dates for the region"""
    try:
        dates = gee.get_available_dates(bounds)
        return {
            "dates": dates,
            "count": len(dates)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching available dates: {str(e)}")

@app.get("/health")
def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "gee_initialized": gee.is_initialized()}
