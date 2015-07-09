#!/bin/bash
#SBATCH --job-name=calipso_contour_ec.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=develop
#SBATCH --time=00:25:00

ncl calipso_contour_ec.ncl
