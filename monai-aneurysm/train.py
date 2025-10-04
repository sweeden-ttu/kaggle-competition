import os
import torch
from tqdm import tqdm
from monai.losses import DiceLoss
from monai.metrics import DiceMetric
from monai.data import decollate_batch
from monai.transforms import AsDiscrete
from monai.utils import set_determinism

from model import create_model
from data_preparation import get_data_dicts, create_dataloaders

# Define paths
CSV_PATH = 'merged_medical_data.csv'
NIFTI_DIR = 'nifti_files'
CHECKPOINT_DIR = './checkpoints'
os.makedirs(CHECKPOINT_DIR, exist_ok=True)

# Set determinism for reproducibility
set_determinism(seed=42)

def train_model(max_epochs=10, batch_size=1, learning_rate=1e-4):
    """
    Main training function.
    """
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Create model, loss function, and optimizer
    model = create_model().to(device)
    loss_function = DiceLoss(to_onehot_y=True, softmax=True)
    optimizer = torch.optim.Adam(model.parameters(), learning_rate)

    # Metric for validation
    dice_metric = DiceMetric(include_background=False, reduction="mean")

    # Prepare data
    data_dicts = get_data_dicts(CSV_PATH, NIFTI_DIR)
    if not data_dicts:
        print("No data found. Please run data_preparation.py first to convert DICOM to NIfTI.")
        return

    train_loader, val_loader = create_dataloaders(data_dicts, batch_size=batch_size)

    # Post-processing for metric calculation
    post_pred = AsDiscrete(argmax=True, to_onehot=2)
    post_label = AsDiscrete(to_onehot=2)

    best_metric = -1
    best_metric_epoch = -1

    print("Starting training...")
    for epoch in range(max_epochs):
        print("-" * 10)
        print(f"Epoch {epoch + 1}/{max_epochs}")

        model.train()
        epoch_loss = 0
        step = 0

        # Training loop
        for batch_data in tqdm(train_loader, desc="Training"):
            step += 1
            inputs, labels = batch_data["image"].to(device), batch_data["label"].to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = loss_function(outputs, labels.unsqueeze(1))
            loss.backward()
            optimizer.step()
            epoch_loss += loss.item()

        epoch_loss /= step
        print(f"Epoch {epoch + 1} average loss: {epoch_loss:.4f}")

        # Validation loop
        model.eval()
        with torch.no_grad():
            for val_data in tqdm(val_loader, desc="Validation"):
                val_inputs, val_labels = val_data["image"].to(device), val_data["label"].to(device)
                val_outputs = model(val_inputs)

                # Convert outputs and labels to one-hot format for metric calculation
                val_outputs = [post_pred(i) for i in decollate_batch(val_outputs)]
                val_labels = [post_label(i) for i in decollate_batch(val_labels.unsqueeze(1))]

                dice_metric(y_pred=val_outputs, y=val_labels)

            metric = dice_metric.aggregate().item()
            dice_metric.reset()

            print(f"Current epoch: {epoch + 1}, current mean dice: {metric:.4f}")

            if metric > best_metric:
                best_metric = metric
                best_metric_epoch = epoch + 1
                torch.save(model.state_dict(), os.path.join(CHECKPOINT_DIR, "best_metric_model.pth"))
                print("Saved new best metric model")

    print(f"Training complete. Best metric: {best_metric:.4f} at epoch: {best_metric_epoch}")

if __name__ == '__main__':
    # Before running training, make sure the data preparation step has been completed.
    # The data_preparation.py script should be run to convert DICOM files to NIfTI format.
    # We can't run it here due to the potential long processing time.

    # Check if NIfTI files exist
    if not os.listdir(NIFTI_DIR):
        print("NIfTI directory is empty. Please run `python monai-aneurysm/data_preparation.py` first.")
    else:
        train_model()