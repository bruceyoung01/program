#!/bin/bash
#SBATCH --job-name=contour_grid_amsre_caliop
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --qos=normal

ncl contour_grid_amsre_caliop.ncl
