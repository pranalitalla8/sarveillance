import ee
import json
from datetime import datetime
import os

class GEEService:
    def __init__(self):
        """Initialize Earth Engine with service account"""
        self.initialized = False
        try:
            # Check if running in service account mode or local development
            service_account_file = 'gee-service-account.json'

            if os.path.exists(service_account_file):
                # Production: Use service account
                with open(service_account_file, 'r') as f:
                    key_data = json.load(f)
                    service_account_email = key_data['client_email']

                credentials = ee.ServiceAccountCredentials(
                    email=service_account_email,
                    key_file=service_account_file
                )
                ee.Initialize(credentials)
                print(f"✓ Earth Engine initialized with service account: {service_account_email}")
            else:
                # Development: Use default credentials with Cloud Project
                # Project ID from Google Cloud: SARveillance (sarveillance-474215)
                ee.Initialize(project='sarveillance-474215')
                print("✓ Earth Engine initialized with Cloud Project: sarveillance-474215")

            self.initialized = True
        except Exception as e:
            print(f"✗ Earth Engine initialization failed: {str(e)}")
            print("  Please run: earthengine authenticate")
            print("  Or provide gee-service-account.json for service account auth")
            raise

    def is_initialized(self):
        """Check if GEE is properly initialized"""
        return self.initialized

    def get_sar_tiles(self, start_date, end_date, bounds):
        """Generate Sentinel-1 SAR tile URL

        Args:
            start_date: Start date string (YYYY-MM-DD)
            end_date: End date string (YYYY-MM-DD)
            bounds: Comma-separated bounds "west,south,east,north"

        Returns:
            Tile URL string for use in mapping applications
        """
        # Parse bounds: "west,south,east,north"
        coords = [float(x) for x in bounds.split(',')]
        roi = ee.Geometry.Rectangle(coords)

        # Load Sentinel-1 SAR data
        sar = (ee.ImageCollection('COPERNICUS/S1_GRD')
            .filterBounds(roi)
            .filterDate(start_date, end_date)
            .filter(ee.Filter.eq('instrumentMode', 'IW'))
            .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
            .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VH'))
            .select(['VV', 'VH'])
            .median())  # Median composite to reduce noise

        # Visualization parameters for SAR backscatter
        vis_params = {
            'bands': ['VV'],
            'min': -25,
            'max': 0,
            'palette': ['000000', '0000FF', '00FFFF', 'FFFF00', 'FF0000']  # Black to red
        }

        # Get map ID for tiles
        map_id = sar.getMapId(vis_params)
        return map_id['tile_fetcher'].url_format

    def get_oil_detection_tiles(self, start_date, end_date, bounds):
        """Generate oil detection overlay tiles

        Uses VV backscatter threshold method:
        - VV < -22 dB indicates potential oil slicks
        - Low backscatter = smooth surface = potential oil

        Args:
            start_date: Start date string (YYYY-MM-DD)
            end_date: End date string (YYYY-MM-DD)
            bounds: Comma-separated bounds "west,south,east,north"

        Returns:
            Tile URL for oil detection overlay
        """
        coords = [float(x) for x in bounds.split(',')]
        roi = ee.Geometry.Rectangle(coords)

        # Load SAR and detect oil (VV < -22 dB threshold)
        sar = (ee.ImageCollection('COPERNICUS/S1_GRD')
            .filterBounds(roi)
            .filterDate(start_date, end_date)
            .filter(ee.Filter.eq('instrumentMode', 'IW'))
            .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
            .select('VV')
            .median())

        # Oil detection mask (low backscatter = potential oil)
        oil_threshold = -22  # dB
        oil_mask = sar.lt(oil_threshold)

        # Visualization: Red for detected oil
        vis_params = {
            'palette': ['FF0000'],  # Red
            'opacity': 0.7
        }

        # Self mask to only show detected oil areas
        map_id = oil_mask.selfMask().getMapId(vis_params)
        return map_id['tile_fetcher'].url_format

    def get_available_dates(self, bounds):
        """Get list of available Sentinel-1 acquisition dates

        Args:
            bounds: Comma-separated bounds "west,south,east,north"

        Returns:
            List of date strings (YYYY-MM-DD) sorted chronologically
        """
        coords = [float(x) for x in bounds.split(',')]
        roi = ee.Geometry.Rectangle(coords)

        # Get Sentinel-1 collection for the region
        collection = (ee.ImageCollection('COPERNICUS/S1_GRD')
            .filterBounds(roi)
            .filter(ee.Filter.eq('instrumentMode', 'IW')))

        # Get acquisition dates
        dates = collection.aggregate_array('system:time_start').getInfo()

        # Convert milliseconds to datetime strings
        date_strings = [
            datetime.fromtimestamp(d/1000).strftime('%Y-%m-%d')
            for d in sorted(set(dates))  # Remove duplicates and sort
        ]

        return date_strings

    def get_teammate_oil_detection_tiles(self, start_date, end_date, bounds):
        """Generate oil detection tiles using teammate's JRC Water Mask method

        This implementation uses:
        - JRC Global Surface Water (permanent water areas)
        - VV < -22 dB threshold (same as our method)
        - Only detects oil in areas with historical water presence

        Args:
            start_date: Start date string (YYYY-MM-DD)
            end_date: End date string (YYYY-MM-DD)
            bounds: Comma-separated bounds "west,south,east,north"

        Returns:
            Tile URL for oil detection with JRC water masking
        """
        coords = [float(x) for x in bounds.split(',')]
        roi = ee.Geometry.Rectangle(coords)

        # Load JRC Global Surface Water (2021 as baseline year)
        # waterClass >= 3 means permanent/seasonal water
        jrc_water = (ee.ImageCollection('JRC/GSW1_4/YearlyHistory')
            .filterDate('2021-01-01', '2021-12-31')
            .select('waterClass')
            .mosaic()
            .clip(roi)
            .gte(3))  # Permanent/seasonal water areas

        # Load Sentinel-1 SAR data
        sar_col = (ee.ImageCollection('COPERNICUS/S1_GRD')
            .filterBounds(roi)
            .filterDate(start_date, end_date)
            .filter(ee.Filter.eq('instrumentMode', 'IW'))
            .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
            .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VH')))

        # Get median composite
        sar = sar_col.select('VV').median()

        # Oil detection: VV < -22 dB AND in water areas
        # This reduces false positives on land
        oil_threshold = -22  # dB
        oil_mask = sar.lt(oil_threshold).And(jrc_water)

        # Visualization: Red for detected oil
        vis_params = {
            'palette': ['FF0000'],  # Red
            'opacity': 0.7
        }

        # Generate tiles
        map_id = oil_mask.selfMask().getMapId(vis_params)
        return map_id['tile_fetcher'].url_format
