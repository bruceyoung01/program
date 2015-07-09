#!/bin/bash
#SBATCH --job-name=contour_grid_modis_mod08_caliop
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=develop
#SBATCH --time=00:25:00

ncl contour_grid_modis_mod08_caliop.ncl
