#!/bin/bash
#SBATCH --job-name=contour_grid_seviri_cot.ncl
#SBATCH --output=slurm_d.out
#SBATCH --error=slurm_d.err
#SBATCH --partition=develop
#SBATCH --time=00:25:00
#SBATCH --constraint=hpcf2013
##SBATCH --mem=50000

ncl contour_grid_seviri_cot.ncl
rm source_grid_file.nc destination_grid_file.nc weights_file.nc
