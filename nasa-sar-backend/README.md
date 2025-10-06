# NASA SAR Tile Server

Backend server for serving Google Earth Engine SAR imagery tiles to the Flutter app.

## 📋 For Judges/Reviewers

**The mobile app works without running this backend!** The app includes 15,267 pre-processed oil detection points from CSV data and will function fully for browsing detections, viewing statistics, and exploring study areas.

This backend is **optional** and only provides:
- Live SAR imagery overlay tiles from Google Earth Engine
- Real-time oil detection visualization layers

If you want to see the live SAR imagery overlays, follow the setup instructions below (approximately 10 minutes to set up).

## Setup Instructions

### 1. Create Google Earth Engine Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing project
3. Enable the **Earth Engine API**:
   - Go to "APIs & Services" → "Enable APIs and Services"
   - Search for "Earth Engine API" → Enable
4. Create Service Account:
   - Go to "IAM & Admin" → "Service Accounts"
   - Click "Create Service Account"
   - Name: `sar-tile-server`
   - Grant role: **"Earth Engine Resource Writer"**
   - Click "Done"
5. Create JSON Key:
   - Click on the service account you just created
   - Go to "Keys" tab
   - Click "Add Key" → "Create New Key" → "JSON"
   - Save the downloaded file as `gee-service-account.json` in this directory

### 2. Install Dependencies

```bash
cd nasa-sar-backend
pip install -r requirements.txt
```

### 3. Alternative: Local Development (No Service Account)

If you don't want to set up a service account, you can use your personal Earth Engine account:

```bash
earthengine authenticate
```

This will open a browser for you to authorize Earth Engine. The server will automatically use these credentials if no service account JSON is found.

### 4. Run the Server

```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Server will be available at: `http://localhost:8000`

### 5. Test the API

Open in browser:
- **Server status**: http://localhost:8000/
- **SAR tiles**: http://localhost:8000/tiles/sar
- **Oil detection**: http://localhost:8000/tiles/oil-detection
- **Available dates**: http://localhost:8000/dates/available

## API Endpoints

### GET `/tiles/sar`

Get Sentinel-1 SAR imagery tiles.

**Query Parameters:**
- `start_date` (optional): Start date in YYYY-MM-DD format (default: 2024-01-01)
- `end_date` (optional): End date in YYYY-MM-DD format (default: 2024-12-31)
- `bounds` (optional): Bounding box as "west,south,east,north" (default: Chesapeake Bay)

**Example:**
```
http://localhost:8000/tiles/sar?start_date=2024-06-01&end_date=2024-06-30
```

### GET `/tiles/oil-detection`

Get oil spill detection overlay.

Uses VV backscatter threshold (< -22 dB) to detect potential oil spills.

**Query Parameters:**
- Same as `/tiles/sar`

### GET `/dates/available`

Get list of available SAR acquisition dates for the region.

**Query Parameters:**
- `bounds` (optional): Bounding box

## Deployment to Google Cloud Run

1. **Build Docker image:**
```bash
docker build -t gcr.io/YOUR_PROJECT_ID/sar-backend .
```

2. **Push to Container Registry:**
```bash
docker push gcr.io/YOUR_PROJECT_ID/sar-backend
```

3. **Deploy to Cloud Run:**
```bash
gcloud run deploy sar-backend \
  --image gcr.io/YOUR_PROJECT_ID/sar-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

4. **Update Flutter app:**
Update the `baseUrl` in `lib/services/gee_tile_service.dart` to your Cloud Run URL.

## Troubleshooting

### "Earth Engine initialization failed"
- Make sure you have either:
  - A valid `gee-service-account.json` file in this directory, OR
  - Run `earthengine authenticate` for local development

### "Permission denied"
- Check that your service account has "Earth Engine Resource Writer" role
- Verify the service account JSON file is valid

### "No data returned"
- Check your date range - Sentinel-1 data may not be available for all dates
- Verify bounds are correct (west, south, east, north)
- Chesapeake Bay bounds: `-76.5,37.5,-75.5,39.5`

## Integration with Teammates' GEE Scripts

To add custom GEE layers from your teammates:

1. Add their GEE code to `gee_service.py`
2. Create a new endpoint in `main.py`
3. The Flutter app will automatically be able to consume it

Example:
```python
# In gee_service.py
def get_custom_layer(self, params):
    # Your teammate's GEE code here
    image = ee.Image(...)
    map_id = image.getMapId(vis_params)
    return map_id['tile_fetcher'].url_format

# In main.py
@app.get("/tiles/custom-layer")
def get_custom_layer(param: str):
    tile_url = gee.get_custom_layer(param)
    return {"tile_url": tile_url}
```
