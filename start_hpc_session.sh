#!/bin/bash

# Load modules
echo "Loading modules..."

module load gcc/14.2.0
module load openmpi/5.0.5
module load python/3.12.5
module load sqlite/3.46.0
# module load cuda/12.1
#module load cudnn/8.9.0

# Check Python version
python --version

# Install required packages
echo "Installing Python packages..."
pipx install tensorflow;   #2.15.0
pipx install keras;   #3.0.0
pipx install nibabel;   #5.0.0
pipx install pydicom;   #2.4.0
pipx install numpy;   #1.24.0
pipx install pandas;   #2.0.0
pipx install scikit-learn;   #1.3.0
pipx install matplotlib;   #3.7.0
pipx install seaborn;   #0.12.0
pipx install pyyaml;   #6.0
pipx install tqdm;   #4.65.0

echo "Setup complete. Interactive session ready."
echo "Current directory: $(pwd)"
echo "Available GPUs:"
nvidia-smi

