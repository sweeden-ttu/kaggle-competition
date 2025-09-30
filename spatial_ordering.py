#!/usr/bin/env python3
import pandas as pd
import numpy as np
from scipy.spatial.distance import pdist, squareform
import ast

def parse_image_position(pos_str):
    """Extract z-coordinate from ImagePositionPatient string"""
    if pd.isna(pos_str) or pos_str == '':
        return np.nan
    try:
        pos_list = ast.literal_eval(pos_str)
        return float(pos_list[2])  # z-coordinate is third element
    except:
        return np.nan

def create_z_coordinate(df):
    """Create z-coordinate using SliceThickness and InstanceNumber"""
    # Method 1: Use ImagePositionPatient z-coordinate if available
    df['z_from_position'] = df['ImagePositionPatient'].apply(parse_image_position)
    
    # Method 2: Calculate z using SliceThickness * InstanceNumber
    df['z_from_slice'] = df['SliceThickness'] * df['InstanceNumber']
    
    # Use ImagePositionPatient z if available, otherwise use calculated z
    df['z_coord'] = df['z_from_position'].fillna(df['z_from_slice'])
    
    return df

def calculate_3d_distances(df):
    """Calculate pairwise 3D distances between all points"""
    # Get coordinates, handling NaN values
    coords = df[['x_coord', 'y_coord', 'z_coord']].fillna(0).values
    
    # Calculate pairwise distances
    distances = pdist(coords, metric='euclidean')
    distance_matrix = squareform(distances)
    
    return distance_matrix

def order_by_spatial_proximity(df):
    """Order rows by 3D spatial distance using nearest neighbor approach"""
    distance_matrix = calculate_3d_distances(df)
    
    # Start with first point
    ordered_indices = [0]
    remaining_indices = set(range(1, len(df)))
    
    # Greedy nearest neighbor ordering
    while remaining_indices:
        current_idx = ordered_indices[-1]
        # Find nearest unvisited point
        distances_from_current = distance_matrix[current_idx]
        nearest_idx = min(remaining_indices, 
                         key=lambda i: distances_from_current[i])
        ordered_indices.append(nearest_idx)
        remaining_indices.remove(nearest_idx)
    
    return df.iloc[ordered_indices].reset_index(drop=True)

def main():
    # Load data
    df = pd.read_csv('/Users/owner/kaggle-competition/merged_medical_data.csv')
    print(f"Loaded {len(df)} rows")
    
    # Create z-coordinates
    df = create_z_coordinate(df)
    print(f"Created z-coordinates. Using ImagePositionPatient for {df['z_from_position'].notna().sum()} rows")
    
    # Order by spatial proximity
    df_ordered = order_by_spatial_proximity(df)
    
    # Add distance to next point for verification
    coords = df_ordered[['x_coord', 'y_coord', 'z_coord']].fillna(0).values
    distances_to_next = []
    for i in range(len(coords)-1):
        dist = np.linalg.norm(coords[i+1] - coords[i])
        distances_to_next.append(dist)
    distances_to_next.append(0)  # Last point has no next
    
    df_ordered['distance_to_next'] = distances_to_next
    
    # Save result
    output_path = '/Users/owner/kaggle-competition/merged_medical_data_spatial_ordered.csv'
    df_ordered.to_csv(output_path, index=False)
    print(f"Saved spatially ordered data to {output_path}")
    
    # Print summary statistics
    print(f"\nSpatial ordering summary:")
    print(f"Total distance traveled: {df_ordered['distance_to_next'].sum():.2f}")
    print(f"Average distance between consecutive points: {df_ordered['distance_to_next'][:-1].mean():.2f}")
    print(f"Z-coordinate range: {df_ordered['z_coord'].min():.2f} to {df_ordered['z_coord'].max():.2f}")
    
    return df_ordered

if __name__ == "__main__":
    df_ordered = main()
