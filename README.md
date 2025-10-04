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