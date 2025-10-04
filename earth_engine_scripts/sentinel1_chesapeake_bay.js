// Google Earth Engine Script for Chesapeake Bay Sentinel-1 SAR Data Collection
// This script collects 10 years of Sentinel-1 SAR data (2014-2024) for Chesapeake Bay region

// Define Chesapeake Bay region of interest
var chesapeakeBay = ee.Geometry.Polygon([
  [-77.5, 36.5],
  [-75.0, 36.5],
  [-75.0, 39.8],
  [-77.5, 39.8]
]);

// Define date range for 10-year collection
var startDate = '2014-01-01';
var endDate = '2024-12-31';

// Load Sentinel-1 SAR collection
var sentinel1 = ee.ImageCollection('COPERNICUS/S1_GRD')
  .filterBounds(chesapeakeBay)
  .filterDate(startDate, endDate)
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VH'));

print('Total Sentinel-1 images found:', sentinel1.size());

// Function to add SAR indices and preprocessing
function preprocessSAR(image) {
  // Convert to dB scale
  var db = ee.Image(image).log10().multiply(10);
  
  // Calculate VV/VH ratio
  var vv = db.select('VV');
  var vh = db.select('VH');
  var ratio = vv.divide(vh).rename('VV_VH_ratio');
  
  // Calculate cross-polarization ratio
  var crossPol = vh.divide(vv).rename('VH_VV_ratio');
  
  // Add normalized difference
  var nd = vv.subtract(vh).divide(vv.add(vh)).rename('ND');
  
  return image.addBands([
    db.select('VV').rename('VV_db'),
    db.select('VH').rename('VH_db'),
    ratio,
    crossPol,
    nd
  ]);
}

// Process the collection
var processedSAR = sentinel1.map(preprocessSAR);

// Create annual composites
var years = ee.List.sequence(2014, 2024);
var annualComposites = years.map(function(year) {
  var yearStart = ee.Date.fromYMD(year, 1, 1);
  var yearEnd = ee.Date.fromYMD(year, 12, 31);
  
  var yearCollection = processedSAR.filterDate(yearStart, yearEnd);
  
  // Create median composite for each year
  var medianComposite = yearCollection.median();
  
  // Add year as property
  return medianComposite.set('year', year).set('system:time_start', yearStart.millis());
});

// Convert to ImageCollection
var annualCollection = ee.ImageCollection.fromImages(annualComposites);

// Export function for Google Drive
function exportToDrive(image, year, description) {
  Export.image.toDrive({
    image: image,
    description: description,
    folder: 'Chesapeake_Bay_SAR',
    fileNamePrefix: 'Chesapeake_Bay_SAR_' + year,
    region: chesapeakeBay,
    scale: 10,
    crs: 'EPSG:4326',
    maxPixels: 1e13
  });
}

// Export each annual composite
annualCollection.evaluate(function(collection) {
  collection.features.forEach(function(image) {
    var year = image.get('year');
    var description = 'Chesapeake_Bay_SAR_' + year;
    exportToDrive(image, year, description);
  });
});

// Create monthly composites for more detailed analysis
var months = ee.List.sequence(1, 12);
var monthlyComposites = years.map(function(year) {
  return months.map(function(month) {
    var monthStart = ee.Date.fromYMD(year, month, 1);
    var monthEnd = monthStart.advance(1, 'month');
    
    var monthCollection = processedSAR.filterDate(monthStart, monthEnd);
    var medianComposite = monthCollection.median();
    
    return medianComposite.set('year', year).set('month', month);
  });
}).flatten();

var monthlyCollection = ee.ImageCollection.fromImages(monthlyComposites);

// Export monthly composites
monthlyCollection.evaluate(function(collection) {
  collection.features.forEach(function(image) {
    var year = image.get('year');
    var month = image.get('month');
    var description = 'Chesapeake_Bay_SAR_' + year + '_' + month;
    
    Export.image.toDrive({
      image: image,
      description: description,
      folder: 'Chesapeake_Bay_SAR_Monthly',
      fileNamePrefix: 'Chesapeake_Bay_SAR_' + year + '_' + month,
      region: chesapeakeBay,
      scale: 10,
      crs: 'EPSG:4326',
      maxPixels: 1e13
    });
  });
});

// Create oil spill detection specific composites
// Focus on summer months when oil spills are more common
var summerMonths = [6, 7, 8]; // June, July, August
var summerComposites = years.map(function(year) {
  return summerMonths.map(function(month) {
    var monthStart = ee.Date.fromYMD(year, month, 1);
    var monthEnd = monthStart.advance(1, 'month');
    
    var monthCollection = processedSAR.filterDate(monthStart, monthEnd);
    var medianComposite = monthCollection.median();
    
    return medianComposite.set('year', year).set('month', month).set('season', 'summer');
  });
}).flatten();

var summerCollection = ee.ImageCollection.fromImages(summerComposites);

// Export summer composites for oil spill analysis
summerCollection.evaluate(function(collection) {
  collection.features.forEach(function(image) {
    var year = image.get('year');
    var month = image.get('month');
    var description = 'Chesapeake_Bay_Summer_SAR_' + year + '_' + month;
    
    Export.image.toDrive({
      image: image,
      description: description,
      folder: 'Chesapeake_Bay_Summer_SAR',
      fileNamePrefix: 'Chesapeake_Bay_Summer_SAR_' + year + '_' + month,
      region: chesapeakeBay,
      scale: 10,
      crs: 'EPSG:4326',
      maxPixels: 1e13
    });
  });
});

// Print summary statistics
print('Annual composites created:', annualCollection.size());
print('Monthly composites created:', monthlyCollection.size());
print('Summer composites created:', summerCollection.size());

// Display the most recent composite for visualization
var recentComposite = annualCollection.filter(ee.Filter.eq('year', 2024)).first();
Map.addLayer(recentComposite.select(['VV_db', 'VH_db', 'VV_VH_ratio']), 
             {min: -20, max: 5, bands: ['VV_db', 'VH_db', 'VV_VH_ratio']}, 
             'Chesapeake Bay SAR 2024');

Map.centerObject(chesapeakeBay, 8);
