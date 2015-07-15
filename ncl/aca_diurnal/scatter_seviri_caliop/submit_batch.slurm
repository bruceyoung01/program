#!/bin/bash
#SBATCH --job-name=scatter_seviri_caliop.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --qos=long
#SBATCH --time=120:00:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl scatter_seviri_caliop.ncl
