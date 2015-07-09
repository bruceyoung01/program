pro read_hdf_l2_aerprf,path,FNAME,lat, lon, alt, aod, kext_532,tbks;DPC RELEASE VERSION 3.2

;
;This is a simple read program for the CALIPSO Lidar Level 2
; Data Products, including assignments to variables contained in the
; Lidar Level 2 5km Aerosol Profile Common (L2_AERPRF_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 2.4 corresponds to the Data Products Catalog Release 2.4.
; The DP Catalog is available on the CALIPSO public website:
;		http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 36 and 37.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 2 5km Aerosol Profile HDF file to be read.
;
; Also provided is a corresponding Checkit_AERPRF program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
;
; March 17, 2010	Science Systems & Applications, Inc.           Data Release
;
; NOTE: Pease modify lines in code that meet your system's requirements.

; For Unix and using the IDLDE for Mac
; Include the full path before the L2_AERPRF_COMMON called routine.
; An example would be @/full/path/L2_AERPRF_COMMON
; Otherwise, if routine in same working directory as main routine, full 
; path is not needed.
@L2_AERPRF_COMMON

dsets=0
attrs=0

; Uncomment/comment out the correct lines to ensure that the paths are 
; interpreted correctly for your computer system.

; For Windows
;print,'opening ',path + '\' + FNAME
; For Unix
print,'opening ',path + '/' + FNAME

; For Windows
;fid=hdf_open(path + '\' + FNAME,/read)
; For Unix
fid=hdf_open(path + '/' + FNAME,/read)

; For Windows
;SDinterface_id = HDF_SD_START( path + '\' + FNAME , /READ  )
; For Unix
SDinterface_id = HDF_SD_START( path + '/' + FNAME , /READ  )

HDF_SD_Fileinfo,SDinterface_id,dsets,attrs

; Retrieve the names of the sds variables
for k=0,dsets-1 do begin
    sds_id=HDF_SD_SELECT(SDinterface_id,k)
    HDF_SD_GETINFO,sds_id,name=var,dims=dimx,format=formx,hdf_type=hdft,unit=unitx;,range=xrng
    print,'sds_id=',sds_id,'   var=',var,'   dimx=',dimx,'   formx=',formx,'   hdft=',hdft,'   unitx=',unitx


;TABLE 37 PARAMETERS

if var eq 'Latitude' then HDF_SD_GETDATA,sds_id, AP_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id, AP_LON
if var eq 'Profile_Time' then HDF_SD_GETDATA,sds_id, AP_TIME
if var eq 'Profile_UTC_Time' then HDF_SD_GETDATA,sds_id, AP_UTC
if var eq 'Day_Night_Flag' then HDF_SD_GETDATA,sds_id, AP_DAYNIT_FLG
if var eq 'Column_Optical_Depth_Cloud_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_CLD_532
if var eq 'Column_Optical_Depth_Cloud_Uncertainty_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_CLD_UNC_532
if var eq 'Column_Optical_Depth_Aerosols_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_AER_532
if var eq 'Column_Optical_Depth_Aerosols_Uncertainty_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_AER_UNC_532
if var eq 'Column_Optical_Depth_Stratospheric_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_STRAT_532
if var eq 'Column_Optical_Depth_Stratosheric_Uncertainty_532' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_STRAT_UNC_532
if var eq 'Column_Optical_Depth_Aerosols_1064' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_AER_1064
if var eq 'Column_Optical_Depth_Aerosols_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_AER_UNC_1064
if var eq 'Column_Optical_Depth_Stratospheric_1064' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_STRAT_1064
if var eq 'Column_Optical_Depth_Stratospheric_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,AP_COL_OPT_DEP_STRAT_UNC_1064
if var eq 'Column_Feature_Fraction' then HDF_SD_GETDATA,sds_id,AP_COL_FEAT_FRAC
if var eq 'Column_Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,AP_COL_IAB
if var eq 'Column_IAB_Cumulative_Probability' then HDF_SD_GETDATA,sds_id,AP_COL_IAB_PROB
if var eq 'Tropopause_Height' then HDF_SD_GETDATA,sds_id, AP_TROP_HEIGHT
if var eq 'Tropopause_Temperature' then HDF_SD_GETDATA,sds_id, AP_TROP_TEMP
if var eq 'Temperature' then HDF_SD_GETDATA,sds_id, AP_TEMP
if var eq 'Pressure' then HDF_SD_GETDATA,sds_id, AP_PRESS
if var eq 'Molecular_Number_Density' then HDF_SD_GETDATA,sds_id, AP_MOL_NUM_DEN
if var eq 'Relative_Humidity' then HDF_SD_GETDATA,sds_id, AP_REL_HUM
if var eq 'Surface_Elevation_Statistics' then HDF_SD_GETDATA,sds_id, AP_SURF_ELEV_STAT
if var eq 'Surface_Winds' then HDF_SD_GETDATA,sds_id, AP_SFC_WIND
if var eq 'Samples_Averaged' then HDF_SD_GETDATA,sds_id, AP_SAMP_AVG
if var eq 'Aerosol_Layer_Fraction' then HDF_SD_GETDATA,sds_id, AP_AER_LAY_FRAC
if var eq 'Cloud_Layer_Fraction' then HDF_SD_GETDATA,sds_id, AP_CLD_LAY_FRAC
if var eq 'Atmospheric_Volume_Description' then HDF_SD_GETDATA,sds_id, AP_ATM_VOL_DESC
if var eq 'Extinction_QC_Flag_532' then HDF_SD_GETDATA,sds_id, AP_EXTINC_QC_FLAG_532
if var eq 'Extinction_QC_Flag_1064' then HDF_SD_GETDATA,sds_id, AP_EXTINC_QC_FLAG_1064
if var eq 'CAD_Score' then begin
                HDF_SD_GETDATA,sds_id,HOLDER
                aq = where(HOLDER gt 127)
                AP_CAD_SCORE =long(HOLDER)
                if (aq(0) ne -1) then AP_CAD_SCORE(aq) = AP_CAD_SCORE(aq) - 256L
                endif
if var eq 'Total_Backscatter_Coefficient_532' then HDF_SD_GETDATA,sds_id, AP_TOT_BKS_COEF
if var eq 'Total_Backscatter_Coefficient_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AP_TOT_BKS_COEF_UNC
if var eq 'Perpendicular_Backscatter_Coefficient_532' then HDF_SD_GETDATA,sds_id, AP_PER_BKS_COEF
if var eq 'Perpendicular_Backscatter_Coefficient_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AP_PER_BKS_COEF_UNC
if var eq 'Particulate_Depolarization_Ratio_Profile_532' then HDF_SD_GETDATA,sds_id, AP_PART_DPR_PROF
if var eq 'Particulate_Depolarization_Ratio_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AP_PART_DPR_UNC
if var eq 'Extinction_Coefficient_532' then HDF_SD_GETDATA,sds_id, AP_EXT_COEF_532
if var eq 'Extinction_Coefficient_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AP_EXT_COEF_UNC_532
if var eq 'Aerosol_Multiple_Scattering_Profile_532' then HDF_SD_GETDATA,sds_id, AP_AER_MULT_SCAT_532
if var eq 'Backscatter_Coefficient_1064' then HDF_SD_GETDATA,sds_id, AP_BKS_COEF_1064
if var eq 'Backscatter_Coefficient_Uncertainty_1064' then HDF_SD_GETDATA,sds_id, AP_BKS_COEF_UNC_1064
if var eq 'Extinction_Coefficient_1064' then HDF_SD_GETDATA,sds_id, AP_EXT_COEF_1064
if var eq 'Extinction_Coefficient_Uncertainty_1064' then HDF_SD_GETDATA,sds_id, AP_EXT_COEF_UNC_1064
if var eq 'Aerosol_Multiple_Scattering_Profile_1064' then HDF_SD_GETDATA,sds_id, AP_AER_MULT_SCAT_1064


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds



;TABLE 36 PARAMETERS

nrec = HDF_VD_READ(vdata_id, AP_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id, AP_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id, AP_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id, AP_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id, AP_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
nrec = HDF_VD_READ(vdata_id, AP_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
nrec = HDF_VD_READ(vdata_id, AP_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id, AP_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id, AP_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id, AP_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,AP_ORB_NUM_GRAN_STRT,fields='Orbit_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,AP_ORB_NUM_GRAN_END,fields='Orbit_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,AP_ORB_NUM_CHNG_TIM,fields='Orbit_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,AP_PATH_NUM_GRAN_STRT,fields='Path_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,AP_PATH_NUM_GRAN_END,fields='Path_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,AP_PATH_NUM_CHNG_TIM,fields='Path_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id, AP_RAY_EXT_532,fields='Rayleigh_Extinction_Cross-section_532')
nrec = HDF_VD_READ(vdata_id, AP_RAY_EXT_1064,fields='Rayleigh_Extinction_Cross-section_1064')
nrec = HDF_VD_READ(vdata_id, AP_RAY_BKS_532,fields='Rayleigh_Backscatter_Cross-section_532')
nrec = HDF_VD_READ(vdata_id, AP_RAY_BKS_1064,fields='Rayleigh_Backscatter_Cross-section_1064')
nrec = HDF_VD_READ(vdata_id, AP_L1_PROD_DAT_TIM,fields='Lidar_L1_Production_Date_Time')
nrec = HDF_VD_READ(vdata_id, AP_LID_ALTS,fields='Lidar_Data_Altitudes')
nrec = HDF_VD_READ(vdata_id, AP_INIT_LID_AER_532,fields='Initial_Lidar_Ratio_Aerosols_532')
nrec = HDF_VD_READ(vdata_id, AP_INIT_LID_STRAT_532,fields='Initial_Lidar_Ratio_Stratosphere_532')
nrec = HDF_VD_READ(vdata_id, AP_INIT_LID_AER_1064,fields='Initial_Lidar_Ratio_Aerosols_1064')
nrec = HDF_VD_READ(vdata_id, AP_INIT_LID_STRAT_1064,fields='Initial_Lidar_Ratio_Stratosphere_1064')
nrec = HDF_VD_READ(vdata_id, AP_GEOS_VER,fields='GEOS_Version')
nrec = HDF_VD_READ(vdata_id,AP_CLASS_COEF_VER_NUM,fields='Classifier_Coefficients_Version_Number')
nrec = HDF_VD_READ(vdata_id,AP_CLASS_COEF_VER_DAT,fields='Classifier_Coefficients_Version_Date')
nrec = HDF_VD_READ(vdata_id, AP_PROD_SCRPT,fields='Production_Script')


HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_AERPRF called routine.
; An example would be
; @/full/path/Checkit_AERPRF
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@Checkit_AERPRF

; Below are examples of printing out the parameters from a data file.
; Uncomment the lines of code to print selected parameters.

; The print statement below prints out the file name which is: FNAME, the
; AP_PROD_ID which is the Product_ID, and the AP_DAT_TIM_PROD which is the Date_Time_of_Production.
;product_id = string(AP_PROD_ID)
;approdtim = string(AP_DAT_TIM_PROD)
;print,FNAME,'     ',product_id,'     ',approdtim

; The print statement below prints ou the AP_CAD_SCORE which is the CAD_Score
;print,'AP_CAD_SCORE = ',AP_CAD_SCORE

; The print statement below prints out the AP_UTC which is the Profile_UTC
; print,'AP_UTC = ',AP_UTC


; output variables
aod = AP_COL_OPT_DEP_AER_532
kext_532 = AP_EXT_COEF_532
tbks = AP_TOT_BKS_COEF
lat = AP_LAT
lon = AP_LON
alt = AP_LID_ALTS
;close,/all

;stop

end
