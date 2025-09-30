# Miniforge3 Installation Guide for TTU HPC

## Prerequisites
- SSH access to login.hpcc.ttu.edu
- Access to /home/sweeden directory (500GB quota)

## Installation Steps

### 1. Login and Start Interactive Session
```bash
ssh sweeden@login.hpcc.ttu.edu
igm  # Start interactive session with GPU access
```

### 2. Download Miniforge3 Installer
```bash
cd /home/sweeden
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
```

### 3. Install Miniforge3
```bash
bash Miniforge3-Linux-x86_64.sh -b -p /home/sweeden/miniforge3
```

### 4. Initialize Conda
```bash
/home/sweeden/miniforge3/bin/conda init bash
source ~/.bashrc
```

### 5. Create Environment for Deep Learning
```bash
conda create -n aneurysm python=3.11 -y
conda activate aneurysm
```

### 6. Install Required Packages
```bash
# Install TensorFlow for GPU
conda install -c conda-forge tensorflow-gpu=2.15 -y

# Install other ML packages
conda install -c conda-forge keras nibabel pydicom numpy pandas scikit-learn matplotlib seaborn pyyaml tqdm -y

# Install additional packages if needed
pip install tensorflow-io
```

### 7. Verify Installation
```bash
python -c "import tensorflow as tf; print('TensorFlow version:', tf.__version__); print('GPU available:', tf.config.list_physical_devices('GPU'))"
```

### 8. Set Up Environment for Future Sessions
Add to ~/.bashrc:
```bash
echo 'export PATH="/home/sweeden/miniforge3/bin:$PATH"' >> ~/.bashrc
echo 'conda activate aneurysm' >> ~/.bashrc
```

## Usage Notes

### Starting Work Sessions
1. SSH to HPC: `ssh sweeden@login.hpcc.ttu.edu`
2. Start interactive session: `igm` (with GPU) or `icm` (CPU only)
3. Environment should auto-activate, or run: `conda activate aneurysm`
4. Navigate to work directory: `cd /lustre/work/sweeden`

### Storage Locations
- **Home**: `/home/sweeden` (500GB, backed up) - Use for conda environments and source code
- **Work**: `/lustre/work/sweeden` (1500GB, not backed up) - Use for datasets and temporary files
- **Scratch**: `/lustre/scratch/sweeden` (temporary, auto-deleted)

### Interactive Session Commands
- `igm`: Interactive session with GPU (recommended for ML work)
- `icm`: Interactive session with CPU only
- Default allocation: 10 CPUs, 2 GPUs, 12 hours

### Environment Management
```bash
# List environments
conda env list

# Create new environment
conda create -n myenv python=3.11

# Activate environment
conda activate myenv

# Deactivate environment
conda deactivate

# Remove environment
conda env remove -n myenv
```

## Troubleshooting

### If conda command not found:
```bash
export PATH="/home/sweeden/miniforge3/bin:$PATH"
source ~/.bashrc
```

### If TensorFlow GPU not working:
```bash
# Check CUDA availability
nvidia-smi
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

### If packages conflict:
```bash
conda clean --all
conda update --all
```

## Architecture Notes
- TTU HPC uses x86_64 architecture (not aarch64)
- Use standard TensorFlow packages, not aarch64 variants
- GPU nodes have NVIDIA GPUs with CUDA support
