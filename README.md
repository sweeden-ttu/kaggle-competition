<<<<<<< HEAD
# IRIS Medical Imaging Framework

## Intracranial Aneurysm Detection Using Multimodal Deep Learning

This repository contains the IRIS framework for detecting intracranial aneurysms from medical imaging data using multimodal deep learning approaches.

## Database Schema

### memory_bank.db

**Status**: Currently empty (0 bytes)

The `memory_bank.db` SQLite database file exists in the repository but has not been initialized with any schema or data yet. This database is likely intended for:

- Caching processed medical imaging data
- Storing intermediate results from model training
- Maintaining experiment metadata and results
- Tracking data pipeline state

To be implemented as the project develops.

## Project Structure

- `aneurysm-mm-keras/` - Keras-based multimodal aneurysm detection implementation
- `merged_medical_data.csv` - Medical imaging dataset metadata
- `spatial_ordering.py` - Utilities for spatial ordering of medical images
- `start_hpc_session.sh` - HPC cluster job submission script
- `Claude.md` - AI assistant instructions for project development
- `AGENTS.md` - Agent-based architecture documentation

## HPC Environment

The project is configured to run on HPC clusters with the following modules:
- SQLite 3.46.0 (for database operations when implemented)

## Development Status

This project is actively under development. The memory_bank.db database schema will be defined and implemented as part of the data pipeline development phase.
=======
# MONAI for Intracranial Aneurysm Detection and Localization

This project uses the Medical Open Network for AI (MONAI) to build a deep learning pipeline for intracranial aneurysm detection and localization. The goal is to create a robust, high-sensitivity 3D model that can work with heterogeneous medical image inputs (CTA, MRA, T1/T2 MRI).

## Project Structure

- `monai-aneurysm/`: Contains the core Python scripts for the project.
  - `data_preparation.py`: Scripts for data loading, preprocessing, and augmentation.
  - `model.py`: The deep learning model architecture (e.g., 3D U-Net).
  - `train.py`: The training script.
  - `evaluate.py`: The evaluation script.
  - `utils.py`: Utility functions.
- `requirements.txt`: A list of required Python packages.

## Approach

The project is divided into three main phases:

1.  **Data Preparation**: Standardizing heterogeneous inputs (DICOM, NIfTI) using tools like `pydicom`, `dicom2nifti`, and `nibabel`. MONAI transforms are used for resampling, normalization, and other preprocessing steps.
2.  **Model Training**: A 3D segmentation model (like U-Net) is trained on the prepared data. The training process uses a weighted loss function to handle class imbalance and focuses on detecting small, clinically challenging aneurysms.
3.  **Evaluation**: The model is evaluated using the weighted columnwise AUC ROC metric, as specified in the competition requirements. Cross-validation is used to ensure the model's robustness and generalizability.

## Usage

1.  Install the required packages: `pip install -r requirements.txt`
2.  Run the data preparation script: `python monai-aneurysm/data_preparation.py`
3.  Run the training script: `python monai-aneurysm/train.py`
4.  Run the evaluation script: `python monai-aneurysm/evaluate.py`
>>>>>>> 1535b0c34cc30caad6c2b2b2397961592b328ed6
