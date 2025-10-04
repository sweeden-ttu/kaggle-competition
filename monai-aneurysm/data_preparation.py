import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from monai.transforms import (
    Compose,
    LoadImaged,
    EnsureChannelFirstd,
    Spacingd,
    ScaleIntensityRanged,
    CropForegroundd,
    Resized,
    RandFlipd,
    RandRotated,
    RandZoomd,
    EnsureTyped,
)
from monai.data import Dataset, DataLoader
import nibabel as nib
import dicom2nifti
import pydicom

# Define paths
CSV_PATH = 'merged_medical_data.csv'
# Assuming the DICOM files are in a directory named 'train'
DICOM_DIR = 'aneurysm-mm-keras/train'
NIFTI_DIR = 'nifti_files'

# Create NIfTI directory if it doesn't exist
os.makedirs(NIFTI_DIR, exist_ok=True)

def convert_dicom_to_nifti(patient_id, dicom_dir, nifti_dir):
    """
    Converts DICOM series to NIfTI format.
    """
    dicom_path = os.path.join(dicom_dir, patient_id)
    nifti_path = os.path.join(nifti_dir, f"{patient_id}.nii.gz")

    if not os.path.exists(nifti_path):
        try:
            dicom2nifti.dicom_series_to_nifti(dicom_path, nifti_path, reorient_nifti=True)
        except Exception as e:
            print(f"Could not convert {patient_id}: {e}")
            return None
    return nifti_path

def get_data_dicts(csv_path, nifti_dir):
    """
    Prepares data dictionaries for MONAI Dataset.
    """
    df = pd.read_csv(csv_path)
    # The 'Aneurysm Present' column is our label
    df = df[['SeriesInstanceUID', 'Aneurysm Present']].drop_duplicates()

    data_dicts = []
    for _, row in df.iterrows():
        patient_id = row['SeriesInstanceUID']
        nifti_path = os.path.join(nifti_dir, f"{patient_id}.nii.gz")
        if os.path.exists(nifti_path):
            data_dicts.append({
                'image': nifti_path,
                'label': np.int64(row['Aneurysm Present'])
            })
    return data_dicts

def create_dataloaders(data_dicts, batch_size=1, validation_split=0.2):
    """
    Creates training and validation dataloaders.
    """
    train_files, val_files = train_test_split(data_dicts, test_size=validation_split, random_state=42)

    # Define transforms
    train_transforms = Compose([
        LoadImaged(keys=['image']),
        EnsureChannelFirstd(keys=['image']),
        Spacingd(keys=['image'], pixdim=(1.0, 1.0, 1.0), mode='bilinear'),
        ScaleIntensityRanged(keys=['image'], a_min=-1000, a_max=1000, b_min=0.0, b_max=1.0, clip=True),
        CropForegroundd(keys=['image'], source_key='image'),
        Resized(keys=['image'], spatial_size=(128, 128, 128)),
        RandFlipd(keys=['image'], prob=0.5, spatial_axis=0),
        RandRotated(keys=['image'], prob=0.5, range_x=0.1, range_y=0.1, range_z=0.1),
        RandZoomd(keys=['image'], prob=0.5, min_zoom=0.9, max_zoom=1.1),
        EnsureTyped(keys=['image', 'label']),
    ])

    val_transforms = Compose([
        LoadImaged(keys=['image']),
        EnsureChannelFirstd(keys=['image']),
        Spacingd(keys=['image'], pixdim=(1.0, 1.0, 1.0), mode='bilinear'),
        ScaleIntensityRanged(keys=['image'], a_min=-1000, a_max=1000, b_min=0.0, b_max=1.0, clip=True),
        CropForegroundd(keys=['image'], source_key='image'),
        Resized(keys=['image'], spatial_size=(128, 128, 128)),
        EnsureTyped(keys=['image', 'label']),
    ])

    # Create datasets and dataloaders
    train_ds = Dataset(data=train_files, transform=train_transforms)
    train_loader = DataLoader(train_ds, batch_size=batch_size, shuffle=True, num_workers=4)

    val_ds = Dataset(data=val_files, transform=val_transforms)
    val_loader = DataLoader(val_ds, batch_size=batch_size, num_workers=4)

    return train_loader, val_loader

if __name__ == '__main__':
    # First, we need to convert DICOM to NIfTI
    # This part needs to be run once.
    df = pd.read_csv(CSV_PATH)
    patient_ids = df['SeriesInstanceUID'].unique()

    print("Converting DICOM to NIfTI...")
    for patient_id in patient_ids:
        # Assuming the DICOMs are in subdirectories named by SeriesInstanceUID
        # under the main DICOM_DIR
        patient_dicom_path = os.path.join(DICOM_DIR, patient_id)
        if os.path.isdir(patient_dicom_path):
             convert_dicom_to_nifti(patient_id, DICOM_DIR, NIFTI_DIR)

    # Now, prepare the data dictionaries
    data_dicts = get_data_dicts(CSV_PATH, NIFTI_DIR)

    if not data_dicts:
        print("No NIfTI files were found or generated. Exiting.")
    else:
        # Create the dataloaders
        train_loader, val_loader = create_dataloaders(data_dicts)

        print(f"Data preparation complete.")
        print(f"Number of training samples: {len(train_loader.dataset)}")
        print(f"Number of validation samples: {len(val_loader.dataset)}")

    # Example of how to iterate through the dataloader
    # for batch_data in train_loader:
    #     images, labels = batch_data['image'], batch_data['label']
    #     print(images.shape, labels.shape)
    #     break