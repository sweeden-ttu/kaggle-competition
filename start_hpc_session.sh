#!/bin/bash

# Start interactive session on TTU HPC
echo "Starting interactive session..."
salloc -p matador -N 1 -c 10 --mem=80G --gres=gpu:2 -t 12:00:00 << 'EOF'

# Load modules
echo "Loading modules..."
module load gcc/11.2.0
module load python/3.11.0
module load cuda/12.1
module load cudnn/8.9.0

# Check Python version
python --version

# Install required packages
echo "Installing Python packages..."
pip install --user tensorflow>=2.15.0
pip install --user keras>=3.0.0
pip install --user nibabel>=5.0.0
pip install --user pydicom>=2.4.0
pip install --user numpy>=1.24.0
pip install --user pandas>=2.0.0
pip install --user scikit-learn>=1.3.0
pip install --user matplotlib>=3.7.0
pip install --user seaborn>=0.12.0
pip install --user pyyaml>=6.0
pip install --user tqdm>=4.65.0

echo "Setup complete. Interactive session ready."
echo "Current directory: $(pwd)"
echo "Available GPUs:"
nvidia-smi

# Keep session alive
bash

EOF
