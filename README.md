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