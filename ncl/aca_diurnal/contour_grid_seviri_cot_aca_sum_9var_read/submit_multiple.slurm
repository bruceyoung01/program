#!/bin/bash
#SBATCH --job-name=contour_grid_seviri_cot_aca_sum_9var_read.ncl
#SBATCH --output=slurm_multiple.out
#SBATCH --error=slurm_multiple.err
#SBATCH --partition=batch
#SBATCH --qos=medium
#SBATCH --time=24:00:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl icase=0 imethod=0 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=1 imethod=0 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=2 imethod=0 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=3 imethod=0 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=4 imethod=0 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=0 imethod=1 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=1 imethod=1 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=2 imethod=1 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=3 imethod=1 contour_grid_seviri_cot_aca_sum_9var_read.ncl;
ncl icase=4 imethod=1 contour_grid_seviri_cot_aca_sum_9var_read.ncl


###############################################################################
##THIS SLURM SCRIPT SUBMITS SEVERAL JOBS ONE BY ONE, AND SPECIFY PARAMETER 
##VALUES EVERY STEP.
###############################################################################
