#!/bin/bash
#SBATCH --job-name=contour_grid_seviri_cot_aca_ESMF.ncl
#SBATCH --output=slurm_b_ESMF.out
#SBATCH --error=slurm_b_ESMF.err
#SBATCH --partition=batch
#SBATCH --qos=medium
#SBATCH --time=24:00:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl contour_grid_seviri_cot_aca_ESMF.ncl
rm source_grid_file.nc destination_grid_file.nc weights_file.nc
