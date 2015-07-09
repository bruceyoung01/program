#!/bin/bash
#SBATCH --job-name=calipso_contour_ec.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --qos=normal
#SBATCH --constraint=hpcf2013
##SBATCH --time=04:00:00

ncl calipso_contour_ec.ncl
