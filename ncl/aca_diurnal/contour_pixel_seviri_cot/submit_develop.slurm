#!/bin/bash
#SBATCH --job-name=contour_seviri_cot.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=develop
#SBATCH --time=00:25:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl contour_seviri_cot.ncl
