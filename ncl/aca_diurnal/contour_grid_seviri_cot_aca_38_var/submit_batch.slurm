#!/bin/bash
#SBATCH --job-name=contour_grid_seviri_cot_aca_38_var.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --qos=long
#SBATCH --time=120:00:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl contour_grid_seviri_cot_aca_38_var.ncl
rm source_grid_file.nc destination_grid_file.nc weights_file.nc
