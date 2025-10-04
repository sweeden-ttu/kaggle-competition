import os
import torch
import numpy as np
from sklearn.metrics import roc_auc_score
from tqdm import tqdm
from monai.data import decollate_batch
from monai.transforms import AsDiscrete, Activations

from model import create_model
from data_preparation import get_data_dicts, create_dataloaders

# Define paths
CSV_PATH = 'merged_medical_data.csv'
NIFTI_DIR = 'nifti_files'
CHECKPOINT_PATH = './checkpoints/best_metric_model.pth'

def evaluate_model():
    """
    Evaluates the trained model using the AUC ROC metric.
    """
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Create model and load saved weights
    model = create_model().to(device)
    if not os.path.exists(CHECKPOINT_PATH):
        print("Checkpoint not found. Please train the model first.")
        return

    model.load_state_dict(torch.load(CHECKPOINT_PATH, map_location=device))
    model.eval()

    # Prepare data
    data_dicts = get_data_dicts(CSV_PATH, NIFTI_DIR)
    if not data_dicts:
        print("No data found. Please ensure NIfTI files are available.")
        return

    _, val_loader = create_dataloaders(data_dicts, batch_size=1)

    y_true = []
    y_pred = []

    # Post-processing for activation maps
    # We apply softmax to get probabilities
    post_act = Activations(softmax=True)

    print("Starting evaluation...")
    with torch.no_grad():
        for val_data in tqdm(val_loader, desc="Evaluating"):
            val_inputs, val_labels = val_data["image"].to(device), val_data["label"].to(device)
            val_outputs = model(val_inputs)

            # Apply activation to get probability scores for the positive class (aneurysm)
            val_outputs = post_act(val_outputs)

            # We take the probability of the aneurysm class (channel 1)
            # and average it over all voxels to get a single score per scan.
            # This is a simplification; a more advanced approach might use max probability.
            pred_score = torch.mean(val_outputs[:, 1, ...]).item()

            y_pred.append(pred_score)
            y_true.append(val_labels.item())

    # Calculate AUC ROC
    # Ensure there are both classes present in the true labels for AUC calculation
    if len(np.unique(y_true)) > 1:
        auc_roc = roc_auc_score(y_true, y_pred)
        print(f"Column-wise AUC ROC: {auc_roc:.4f}")
    else:
        print("Only one class present in the validation set, cannot calculate AUC ROC.")
        print("True labels:", y_true)
        print("Predicted scores:", y_pred)


if __name__ == '__main__':
    # Ensure NIfTI files exist before running evaluation
    if not os.listdir(NIFTI_DIR):
        print("NIfTI directory is empty. Please run data preparation and training first.")
    else:
        evaluate_model()