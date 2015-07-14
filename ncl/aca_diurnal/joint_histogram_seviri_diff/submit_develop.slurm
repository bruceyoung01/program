#!/bin/bash
#SBATCH --job-name=joint_histogram_seviri_diff.ncl
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --partition=develop
#SBATCH --qos=long
#SBATCH --time=00:25:00
#SBATCH --constraint=hpcf2013
##SBATCH --mem=50000

ncl joint_histogram_seviri_diff.ncl
