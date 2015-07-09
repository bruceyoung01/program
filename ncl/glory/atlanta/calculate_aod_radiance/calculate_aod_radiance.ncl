;  $ID: calculate_aod_radiance.ncl V01 01/21/2013 10:15 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calculate_aod_radiance CALCULATES RADIANCE I0 AND AOD USING 
;  BEER'S LAW, BASED ON SATELLITE ZENITH ANGLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/21/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; FOR LARGE
TAU1    = 0.35
COSSZA1 = 0.797578
I1      = 0.68
; FOR SMALL
TAU1    = 0.35
COSSZA1 = 0.7974517
I1      = 2.0
I0      = I1*exp(TAU1/COSSZA1)

; SETUP DIRECTORY AND FILENAME
dir     = "/home/bruce/sshfs/th/program/ncl/atlanta/viirs_dnb_pm/data/"
I2list  = "rad_small.txt"
COSSZA2list = "cossza_small.txt"
output_tau  = "aod_small.txt"

sI2     = asciiread(dir + I2list,      -1, "string")
sCOSSZA2= asciiread(dir + COSSZA2list, -1, "string")
ndim    = dimsizes(sI2)
TAU2    = new(ndim, float)
print(sI2)
print(sCOSSZA2)
I2      = stringtofloat(sI2)
I2      = I2*10^7
COSSZA2 = stringtofloat(sCOSSZA2)

TAU2    = COSSZA2*log(I0/I2)
asciiwrite(output_tau, TAU2)
print(TAU2)
end
