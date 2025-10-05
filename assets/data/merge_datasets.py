import pandas as pd

# Load both datasets
chesapeake = pd.read_csv('Chesapeake_SAR_Envi_Multi_Date_548_dates.csv')
ais_nasa = pd.read_csv('SAR_envi_oil_with_AIS.csv')

print(f"Chesapeake rows: {len(chesapeake)}")
print(f"AIS+NASA rows: {len(ais_nasa)}")

# Get all columns from AIS dataset
all_cols = list(ais_nasa.columns)

# Add missing columns to Chesapeake with None
for col in all_cols:
    if col not in chesapeake.columns:
        chesapeake[col] = None

# Concatenate both datasets
merged = pd.concat([chesapeake, ais_nasa], ignore_index=True)

# Fill NaN with None for optional columns
merged = merged.fillna('')

# Save merged dataset
merged.to_csv('merged_complete_data.csv', index=False)
print(f"Merged dataset saved: {len(merged)} rows")
print(f"Total columns: {len(merged.columns)}")
print(f"Water points (oil_candidate=0): {len(merged[merged['oil_candidate']==0])}")
print(f"Oil points (oil_candidate=1): {len(merged[merged['oil_candidate']==1])}")
