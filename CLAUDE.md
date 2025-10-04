# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kaggle competition project for intracranial aneurysm detection and localization using MONAI (Medical Open Network for AI). The goal is to build a high-sensitivity 3D deep learning model that works with heterogeneous medical imaging inputs (CTA, MRA, T1/T2 MRI) to detect and localize aneurysms in brain scans.

## Key Commands

### Setup
```bash
pip install -r requirements.txt
```

### Running the Pipeline
```bash
# Data preparation (preprocessing, normalization, augmentation)
python monai-aneurysm/data_preparation.py

# Model training
python monai-aneurysm/train.py

# Evaluation (using weighted columnwise AUC ROC metric)
python monai-aneurysm/evaluate.py
```

## Architecture Overview

### Three-Phase Pipeline
1. **Data Preparation** (`data_preparation.py`): Handles heterogeneous medical image formats (DICOM, NIfTI) using `pydicom`, `dicom2nifti`, and `nibabel`. MONAI transforms standardize images through resampling, normalization, and preprocessing.

2. **Model Training** (`train.py`): Implements 3D segmentation architecture (e.g., U-Net) with weighted loss function to handle class imbalance and prioritize detection of small, clinically challenging aneurysms.

3. **Evaluation** (`evaluate.py`): Calculates weighted columnwise AUC ROC metric as specified by competition requirements. Uses cross-validation for robustness assessment.

### Data Structure
- **`merged_medical_data.csv`**: Large (1.3MB) consolidated dataset containing patient metadata, DICOM metadata, and aneurysm annotations with 3D coordinates (x_coord, y_coord, z_coord) and anatomical locations (e.g., Basilar Tip, Anterior Communicating Artery, ICA).

  Key columns: SeriesInstanceUID, PatientAge, PatientSex, Modality, location, ImagePositionPatient, PixelSpacing, SliceThickness, x_coord, y_coord, z_coord

- **`monai-aneurysm/`**: Core implementation directory containing empty placeholder scripts ready for development

- **`aneurysm-mm-keras/`**: Empty legacy directory (previous Keras implementation)

### Medical Imaging Specifics
- **Input modalities**: CTA (Computed Tomography Angiography), MRA (Magnetic Resonance Angiography), T1/T2 MRI
- **Key challenge**: Small aneurysm detection with high sensitivity while managing class imbalance
- **Anatomical targets**: Multiple intracranial locations including Basilar Tip, Anterior/Posterior Communicating Arteries, ICA (Internal Carotid Artery)
- **3D spatial data**: Models must handle volumetric data with varying slice thickness and spacing

## Development Notes

- The project uses MONAI framework specifically for medical imaging tasks
- All core Python scripts in `monai-aneurysm/` are currently placeholders awaiting implementation
- The pipeline follows competition requirements focusing on weighted columnwise AUC ROC as the primary metric
- Cross-validation strategy should be implemented to ensure model generalizability across different imaging protocols
