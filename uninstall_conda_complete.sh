#!/bin/bash

# Complete Conda/Miniconda/Mamba Uninstallation Script
# This script will remove all traces of conda, miniconda, mamba, and conda-forge from your system

echo "=================================================="
echo "Complete Conda/Miniconda/Mamba Uninstallation Script"
echo "=================================================="
echo ""
echo "This script will remove:"
echo "  - Anaconda/Miniconda installations"
echo "  - Mamba installations"
echo "  - All conda environments"
echo "  - Configuration files"
echo "  - Cache and package files"
echo "  - Shell initialization scripts"
echo ""
read -p "Are you sure you want to continue? This cannot be undone! (yes/no): " confirm

if [[ $confirm != "yes" ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Starting uninstallation process..."
echo ""

# Function to remove a directory with confirmation
remove_directory() {
    if [ -d "$1" ]; then
        echo "Found directory: $1"
        echo "  Size: $(du -sh "$1" 2>/dev/null | cut -f1)"
        read -p "  Remove this directory? (y/n): " choice
        if [[ $choice == "y" || $choice == "Y" ]]; then
            echo "  Removing $1..."
            rm -rf "$1"
            echo "  Removed successfully."
        else
            echo "  Skipped $1"
        fi
    fi
}

# Function to remove a file with confirmation
remove_file() {
    if [ -f "$1" ]; then
        echo "Found file: $1"
        read -p "  Remove this file? (y/n): " choice
        if [[ $choice == "y" || $choice == "Y" ]]; then
            rm -f "$1"
            echo "  Removed successfully."
        else
            echo "  Skipped $1"
        fi
    fi
}

# 1. Deactivate any active conda environment
echo "Step 1: Deactivating conda environments..."
conda deactivate 2>/dev/null || true
conda deactivate 2>/dev/null || true  # Run twice in case of nested environments

# 2. Remove anaconda-clean if it exists and use it
echo ""
echo "Step 2: Running anaconda-clean if available..."
if command -v anaconda-clean &> /dev/null; then
    echo "Running anaconda-clean..."
    anaconda-clean --yes
else
    echo "anaconda-clean not found, skipping..."
fi

# 3. Remove main installation directories
echo ""
echo "Step 3: Removing main installation directories..."

# Common installation paths
COMMON_PATHS=(
    "$HOME/anaconda"
    "$HOME/anaconda2"
    "$HOME/anaconda3"
    "$HOME/miniconda"
    "$HOME/miniconda2"
    "$HOME/miniconda3"
    "$HOME/mambaforge"
    "$HOME/miniforge"
    "$HOME/miniforge3"
    "/home/sweeden/anaconda"
    "/home/sweeden/anaconda2"
    "/home/sweeden/anaconda3"
    "/home/sweeden/miniconda"
    "/home/sweeden/miniconda2"
    "/home/sweeden/miniconda3"
    "/home/sweeden/mambaforge"
    "/home/sweeden/miniforge"
    "/home/sweeden/miniforge3"
    "/opt/anaconda"
    "/opt/anaconda2"
    "/opt/anaconda3"
    "/opt/miniconda"
    "/opt/miniconda2"
    "/opt/miniconda3"
    "/opt/mambaforge"
    "/opt/miniforge"
    "/opt/miniforge3"
    "/usr/local/anaconda"
    "/usr/local/anaconda2"
    "/usr/local/anaconda3"
    "/usr/local/miniconda"
    "/usr/local/miniconda2"
    "/usr/local/miniconda3"
    "/usr/local/mambaforge"
    "/usr/local/miniforge"
    "/usr/local/miniforge3"
)

for path in "${COMMON_PATHS[@]}"; do
    remove_directory "$path"
done

# Check for custom conda installation path from environment variable
if [ ! -z "$CONDA_PREFIX" ]; then
    echo ""
    echo "Found CONDA_PREFIX: $CONDA_PREFIX"
    remove_directory "$CONDA_PREFIX"
fi

# 4. Remove conda configuration and cache directories
echo ""
echo "Step 4: Removing conda configuration and cache files..."

# Remove dot directories from home directory (including /home/sweeden if that's $HOME)
remove_directory "$HOME/.conda"
remove_file "$HOME/.condarc"  # .condarc is a file, not directory
remove_directory "$HOME/.continuum"
remove_directory "$HOME/.mamba"
remove_file "$HOME/.mambarc"  # .mambarc is a file, not directory

# Remove any other conda/mamba related dot directories in /home/sweeden
if [ -d "/home/sweeden" ]; then
    echo "Checking /home/sweeden for conda-related dot directories..."
    remove_directory "/home/sweeden/.conda"
    remove_file "/home/sweeden/.condarc"
    remove_directory "/home/sweeden/.continuum"
    remove_directory "/home/sweeden/.mamba"
    remove_file "/home/sweeden/.mambarc"
    remove_directory "/home/sweeden/.anaconda"
    remove_directory "/home/sweeden/.miniconda"
    remove_directory "/home/sweeden/.miniconda2"
    remove_directory "/home/sweeden/.miniconda3"
    remove_directory "/home/sweeden/.miniforge"
    remove_directory "/home/sweeden/.miniforge3"
    remove_directory "/home/sweeden/.mambaforge"
    
    # Remove cache directories from /home/sweeden
    remove_directory "/home/sweeden/.cache/conda"
    remove_directory "/home/sweeden/.cache/mamba"
    remove_directory "/home/sweeden/.cache/pip"  # Optional - pip cache might be used by conda
    
    # Remove any conda environments that might be in .local
    remove_directory "/home/sweeden/.local/share/conda"
    remove_directory "/home/sweeden/.local/share/mamba"
fi

# Remove cache directories from current user
remove_directory "$HOME/.cache/conda"
remove_directory "$HOME/.cache/mamba"
remove_directory "$HOME/.cache/pip"  # Optional - pip cache might be used by conda

# 5. Clean up shell configuration files
echo ""
echo "Step 5: Cleaning shell configuration files..."

# Function to clean shell config file
clean_shell_config() {
    local file=$1
    if [ -f "$file" ]; then
        echo "Cleaning $file..."
        # Create backup
        cp "$file" "${file}.backup_before_conda_removal_$(date +%Y%m%d_%H%M%S)"
        
        # Remove conda initialization block
        sed -i.bak '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' "$file"
        
        # Remove mamba initialization block
        sed -i.bak '/# >>> mamba initialize >>>/,/# <<< mamba initialize <<</d' "$file"
        
        # Remove conda/mamba related exports and aliases
        sed -i.bak '/export.*[Cc][Oo][Nn][Dd][Aa]/d' "$file"
        sed -i.bak '/export.*[Mm][Aa][Mm][Bb][Aa]/d' "$file"
        sed -i.bak '/alias.*conda/d' "$file"
        sed -i.bak '/alias.*mamba/d' "$file"
        
        # Remove conda from PATH
        sed -i.bak 's|[^:]*conda[^:]*:||g' "$file"
        sed -i.bak 's|[^:]*miniconda[^:]*:||g' "$file"
        sed -i.bak 's|[^:]*anaconda[^:]*:||g' "$file"
        sed -i.bak 's|[^:]*mamba[^:]*:||g' "$file"
        sed -i.bak 's|[^:]*miniforge[^:]*:||g' "$file"
        
        # Clean up any double colons that might remain
        sed -i.bak 's|::*|:|g' "$file"
        sed -i.bak 's|:$||' "$file"
        
        echo "  Cleaned $file (backup created)"
    fi
}

# Clean various shell configuration files
clean_shell_config "$HOME/.bashrc"
clean_shell_config "$HOME/.bash_profile"
clean_shell_config "$HOME/.zshrc"
clean_shell_config "$HOME/.zprofile"
clean_shell_config "$HOME/.profile"
clean_shell_config "$HOME/.config/fish/config.fish"

# 6. Remove conda/mamba from PATH in current session
echo ""
echo "Step 6: Removing conda/mamba from current PATH..."
export PATH=$(echo $PATH | tr ':' '\n' | grep -v conda | grep -v mamba | grep -v miniconda | grep -v anaconda | grep -v miniforge | tr '\n' ':' | sed 's/:$//')

# 7. Remove any remaining conda-related environment variables
echo ""
echo "Step 7: Unsetting conda environment variables..."
unset CONDA_DEFAULT_ENV
unset CONDA_PREFIX
unset CONDA_PROMPT_MODIFIER
unset CONDA_SHLVL
unset CONDA_EXE
unset CONDA_PYTHON_EXE
unset _CE_M
unset _CE_CONDA
unset MAMBA_EXE
unset MAMBA_ROOT_PREFIX
unset MAMBA_NO_BANNER

# 8. Remove conda/mamba related temporary files
echo ""
echo "Step 8: Removing temporary files..."
remove_directory "/tmp/conda-*"
remove_directory "/tmp/mamba-*"

# 9. Check for and remove any conda packages in system Python (if user has sudo)
echo ""
echo "Step 9: Checking for system-wide installations..."
if [ "$EUID" -eq 0 ]; then
    # Running as root
    remove_directory "/usr/local/conda"
    remove_directory "/usr/local/mamba"
else
    echo "Not running as root. To remove system-wide installations, run this script with sudo."
    echo "System paths that might need manual removal:"
    [ -d "/usr/local/conda" ] && echo "  - /usr/local/conda"
    [ -d "/usr/local/mamba" ] && echo "  - /usr/local/mamba"
fi

# 10. Remove conda/mamba related symbolic links
echo ""
echo "Step 10: Removing symbolic links..."
for link in $(find $HOME/bin $HOME/.local/bin /usr/local/bin /usr/bin -type l 2>/dev/null | xargs ls -la 2>/dev/null | grep -E "(conda|mamba|anaconda|miniconda|miniforge)" | awk '{print $9}' 2>/dev/null); do
    if [ -L "$link" ]; then
        echo "Found symbolic link: $link"
        read -p "  Remove this link? (y/n): " choice
        if [[ $choice == "y" || $choice == "Y" ]]; then
            rm -f "$link"
            echo "  Removed successfully."
        fi
    fi
done

# 11. Final verification
echo ""
echo "=================================================="
echo "Step 11: Verification"
echo "=================================================="

# Check if conda command still exists
if command -v conda &> /dev/null; then
    echo "WARNING: conda command still found at: $(which conda)"
    echo "You may need to restart your shell or manually remove this."
else
    echo "✓ conda command not found (good)"
fi

# Check if mamba command still exists
if command -v mamba &> /dev/null; then
    echo "WARNING: mamba command still found at: $(which mamba)"
    echo "You may need to restart your shell or manually remove this."
else
    echo "✓ mamba command not found (good)"
fi

# Check for remaining directories
echo ""
echo "Checking for remaining directories..."
remaining_dirs=0
for dir in "${COMMON_PATHS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  Still exists: $dir"
        remaining_dirs=$((remaining_dirs + 1))
    fi
done

if [ $remaining