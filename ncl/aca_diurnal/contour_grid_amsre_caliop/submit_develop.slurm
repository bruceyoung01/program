#!/bin/bash
#SBATCH --job-name=contour_grid_amsre_caliop
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=develop
#SBATCH --time=00:25:00

ncl contour_grid_amsre_caliop.ncl
