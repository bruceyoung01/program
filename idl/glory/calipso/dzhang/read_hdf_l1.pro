pro read_hdf_L1,path,FNAME                 ;DPC RELEASE VERSION 3.3
;
; This is a simple read program for the CALIPSO Lidar Level 1
; Data Products, including assignments to variables contained in the
; Lidar Level 1 Common (L1_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 3.5 corresponds to the Data Products Catalog Release 3.3.
; The DP Catalog is available on the CALIPSO public website:
;     http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 7, 8, 9, and 10.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 1 HDF file to be read.
;
; Also provided is a corresponding Checkit_L1 program to verify that all variables
; have been read and assigned. It is called at the end of this program.
;
; Total and Perpendicular Attenuated Backscatter parameters are provided in the
; Lidar Level 1 HDF.  Parallel Attenuated Backscatter is derived (Total-Perpendicular)
; in this program and included in the Level 1 Common.  The number of data records is
; determined from the size of the data arrays as read from the HDF, and is also
; included in this common.
;
; March 16, 2010      Science Systems & Applications, Inc.          Data Release
; February 28, 2011   Science Systems & Applications, Inc.          Software Update
;
; NOTE: Please modify lines in code that meet your system's requirements.

; For Unix and using IDLDE for Mac
; Include the full path before the L1_COMMON called routine.
; An example would be  @/full/path/L1_COMMON
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@L1_COMMON

dsets=0
attrs=0

; Uncomment/comment out the correct lines to ensure that the
; paths are interpreted correctly for computer system.

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
    ;print,'sds_id=',sds_id,'   var=',var,'   dimx=',dimx,'   formx=',formx,'   hdft=',hdft,'   unitx=',unitx


;TABLE 10 PARAMETERS - Lidar Profile Science Record

if var eq 'Profile_Time' then HDF_SD_GETDATA,sds_id,L1_PROF_TIME
if var eq 'Profile_UTC_Time' then HDF_SD_GETDATA,sds_id,L1_PROF_UTC
if var eq 'Profile_ID' then HDF_SD_GETDATA,sds_id,L1_PROF_ID
if var eq 'Land_Water_Mask' then HDF_SD_GETDATA,sds_id,L1_LW_MASK
if var eq 'IGBP_Surface_Type' then HDF_SD_GETDATA,sds_id,L1_IGBP_TYPE
if var eq 'NSIDC_Surface_Type' then HDF_SD_GETDATA,sds_id,L1_NSIDC_TYPE
if var eq 'Day_Night_Flag' then HDF_SD_GETDATA,sds_id,L1_DN_FLAG
if var eq 'Frame_Number' then HDF_SD_GETDATA,sds_id,L1_FRM_NUM
if var eq 'Lidar_Mode' then HDF_SD_GETDATA,sds_id,L1_LID_MD
if var eq 'Lidar_Submode' then HDF_SD_GETDATA,sds_id,L1_LID_SBMD
if var eq 'Surface_Elevation' then HDF_SD_GETDATA,sds_id,L1_SURF_ELEV
if var eq 'Laser_Energy_532' then HDF_SD_GETDATA,sds_id,L1_LAS_EN_532
if var eq 'Perpendicular_Amplifier_Gain_532' then HDF_SD_GETDATA,sds_id,L1_PER_AMP_GN
if var eq 'Parallel_Amplifier_Gain_532' then HDF_SD_GETDATA,sds_id,L1_PAR_AMP_GN
if var eq 'Perpendicular_Background_Monitor_532' then HDF_SD_GETDATA,sds_id,L1_PER_BKG_MON
if var eq 'Parallel_Background_Monitor_532' then HDF_SD_GETDATA,sds_id,L1_PAR_BKG_MON
if var eq 'Depolarization_Gain_Ratio_532' then HDF_SD_GETDATA,sds_id,L1_DEP_GR
if var eq 'Depolarization_Gain_Ratio_Uncertainty_532' then HDF_SD_GETDATA,sds_id,L1_DEP_GR_UNC
if var eq 'Calibration_Constant_532' then HDF_SD_GETDATA,sds_id,L1_CAL_CNST_532
if var eq 'Calibration_Constant_Uncertainty_532' then HDF_SD_GETDATA,sds_id,L1_CAL_CNST_532_UNC
if var eq 'Total_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,L1_TOT_BKS_532
if var eq 'Perpendicular_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,L1_PER_BKS_532
if var eq 'Perpendicular_RMS_Baseline_532' then HDF_SD_GETDATA,sds_id,L1_PER_RMS_BL
if var eq 'Parallel_RMS_Baseline_532' then HDF_SD_GETDATA,sds_id,L1_PAR_RMS_BL
if var eq 'Laser_Energy_1064' then HDF_SD_GETDATA,sds_id,L1_LAS_EN_1064
if var eq 'Amplifier_Gain_1064' then HDF_SD_GETDATA,sds_id,L1_AMP_GN_1064
if var eq 'Calibration_Constant_1064' then HDF_SD_GETDATA,sds_id,L1_CAL_CNST_1064
if var eq 'Calibration_Constant_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,L1_CAL_CNST_1064_UNC
if var eq 'Attenuated_Backscatter_1064' then HDF_SD_GETDATA,sds_id,L1_BKS_1064
if var eq 'RMS_Baseline_1064' then HDF_SD_GETDATA,sds_id,L1_RMS_BL_1064
if var eq 'Molecular_Number_Density' then HDF_SD_GETDATA,sds_id,L1_MOL_NUM_DEN
if var eq 'Ozone_Number_Density' then HDF_SD_GETDATA,sds_id,L1_OZ_NUM_DEN
if var eq 'Temperature' then HDF_SD_GETDATA,sds_id,L1_TEMP
if var eq 'Pressure' then HDF_SD_GETDATA,sds_id,L1_PRESS
if var eq 'Relative_Humidity' then HDF_SD_GETDATA,sds_id,L1_REL_HUM
if var eq 'Surface_Wind_Speeds' then HDF_SD_GETDATA,sds_id,L1_SFC_WIND
if var eq 'Tropopause_Height' then HDF_SD_GETDATA,sds_id,L1_TROP_HEIGHT
if var eq 'Tropopause_Temperature' then HDF_SD_GETDATA,sds_id,L1_TROP_TEMP
if var eq 'Noise_Scale_Factor_532_Perpendicular' then HDF_SD_GETDATA,sds_id,L1_NSF_PER
if var eq 'Noise_Scale_Factor_532_Parallel' then HDF_SD_GETDATA,sds_id,L1_NSF_PAR
if var eq 'Noise_Scale_Factor_1064' then HDF_SD_GETDATA,sds_id,L1_NSF_1064
if var eq 'Perpendicular_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,L1_PER_REFL
if var eq 'Perpendicular_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,L1_PER_REFL_UNC
if var eq 'Parallel_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,L1_PAR_REFL
if var eq 'Parallel_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,L1_PAR_REFL_UNC
if var eq 'QC_Flag' then HDF_SD_GETDATA,sds_id,L1_QC_FLG
if var eq 'QC_Flag_2' then HDF_SD_GETDATA,sds_id,L1_QC_FLG_2

;TABLE 9 PARAMETERS - Lidar Proile Geolocation and Viewing Geometry

if var eq 'Latitude' then HDF_SD_GETDATA,sds_id,L1_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id,L1_LON
if var eq 'Off_Nadir_Angle' then HDF_SD_GETDATA,sds_id,L1_OFF_NDR
if var eq 'Viewing_Zenith_Angle' then HDF_SD_GETDATA,sds_id,L1_VW_ZNTH
if var eq 'Viewing_Azimuth_Angle' then HDF_SD_GETDATA,sds_id,L1_VW_AZMTH
if var eq 'Solar_Zenith_Angle' then HDF_SD_GETDATA,sds_id,L1_SOL_ZNTH
if var eq 'Solar_Azimuth_Angle' then HDF_SD_GETDATA,sds_id,L1_SOL_AZMTH
if var eq 'Scattering_Angle' then HDF_SD_GETDATA,sds_id,L1_SCATR
if var eq 'Surface_Altitude_Shift' then HDF_SD_GETDATA,sds_id,L1_SFC_ALT_SHFT
if var eq 'Number_Bins_Shift' then HDF_SD_GETDATA,sds_id,L1_NUM_BIN_SHFT


;TABLE 8 PARAMETERS - Lidar Spacecraft Position, Attitude, and Celestial Record

if var eq 'Spacecraft_Altitude' then HDF_SD_GETDATA,sds_id,L1_SPC_ALT
if var eq 'Spacecraft_Position' then HDF_SD_GETDATA,sds_id,L1_SPC_POS
if var eq 'Spacecraft_Velocity' then HDF_SD_GETDATA,sds_id,L1_SPC_VEL
if var eq 'Spacecraft_Attitude' then HDF_SD_GETDATA,sds_id,L1_SPC_ATT
if var eq 'Spacecraft_Attitude_Rate' then HDF_SD_GETDATA,sds_id,L1_SPC_ATT_RATE
if var eq 'Subsatellite_Latitude' then HDF_SD_GETDATA,sds_id,L1_SUBSAT_LAT
if var eq 'Subsatellite_Longitude' then HDF_SD_GETDATA,sds_id,L1_SUBSAT_LON
if var eq 'Earth-Sun_Distance' then HDF_SD_GETDATA,sds_id,L1_EARTH_SUN_DIST
if var eq 'Subsolar_Latitude' then HDF_SD_GETDATA,sds_id,L1_SSOL_LAT
if var eq 'Subsolar_Longitude' then HDF_SD_GETDATA,sds_id,L1_SSOL_LON

HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

L1_PAR_BKS_532 = L1_TOT_BKS_532 - L1_PER_BKS_532    ;Determine 532 Parallel Attenuated Backscatter

XX = SIZE(L1_PROF_TIME)                    ;Determine Number of Data Records
L1_NUM_RECS = XX(2)

;Retrieve the Vdata information
;vds_id = HDF_VD_LONE(fid)
;vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

;HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds
;print,flds

;TABLE 7 PARAMETERS

;nrec = HDF_VD_READ(vdata_id,L1_PROD_ID,fields='Product_ID')
;nrec = HDF_VD_READ(vdata_id,L1_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
;nrec = HDF_VD_READ(vdata_id,L1_DAT_TIM_END,fields='Date_Time_at_Granule_End')
;nrec = HDF_VD_READ(vdata_id,L1_DAT_TIM_PROD,fields='Date_Time_of_Production')
;nrec = HDF_VD_READ(vdata_id,L1_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
;nrec = HDF_VD_READ(vdata_id,L1_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
;nrec = HDF_VD_READ(vdata_id,L1_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
;nrec = HDF_VD_READ(vdata_id,L1_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
;nrec = HDF_VD_READ(vdata_id,L1_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
;nrec = HDF_VD_READ(vdata_id,L1_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
;nrec = HDF_VD_READ(vdata_id,L1_ORB_GRN_STRT,fields='Orbit_Number_at_Granule_Start')
;nrec = HDF_VD_READ(vdata_id,L1_ORB_GRN_END,fields='Orbit_Number_at_Granule_End')
;nrec = HDF_VD_READ(vdata_id,L1_ORB_CHNG_TIM,fields='Orbit_Number_Change_Time')
;nrec = HDF_VD_READ(vdata_id,L1_PATH_NUM_GRN_STRT,fields='Path_Number_at_Granule_Start')
;nrec = HDF_VD_READ(vdata_id,L1_PATH_NUM_GRN_END,fields='Path_Number_at_Granule_End')
;nrec = HDF_VD_READ(vdata_id,L1_PATH_NUM_CHNG_TIM,fields='Path_Number_Change_Time')
;nrec = HDF_VD_READ(vdata_id,L1_EPHM_FILES_USED,fields='Ephemeris_Files_Used')
;nrec = HDF_VD_READ(vdata_id,L1_ATT_FILES_USED,fields='Attitude_Files_Used')
;nrec = HDF_VD_READ(vdata_id,L1_GEOS_VER,fields='GEOS_Version')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_PAR_BAD,fields='Percent_532-parallel_Bad')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_PER_BAD,fields='Percent_532-perpendicular_Bad')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_1064_BAD,fields='Percent_1064_Bad')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_PAR_MISNG,fields='Percent_532-parallel_Missing')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_PER_MISNG,fields='Percent_532-perpendicular_Missing')
;nrec = HDF_VD_READ(vdata_id,L1_PCNT_1064_MISNG,fields='Percent_1064_Missing')
;nrec = HDF_VD_READ(vdata_id,L1_CALREG_TOP_ALT,fields='Cal_Region_Top_Altitude_532')
;nrec = HDF_VD_READ(vdata_id,L1_CALREG_BASE_ALT,fields='Cal_Region_Base_Altitude_532')
;nrec = HDF_VD_READ(vdata_id,L1_LID_ALTS,fields='Lidar_Data_Altitudes')
;nrec = HDF_VD_READ(vdata_id,L1_MET_ALTS,fields='Met_Data_Altitudes')
;nrec = HDF_VD_READ(vdata_id,L1_RAY_EXT_CROSS_532,fields='Rayleigh_Extinction_Cross-section_532')
;nrec = HDF_VD_READ(vdata_id,L1_RAY_EXT_CROSS_1064,fields='Rayleigh_Extinction_Cross-section_1064')
;nrec = HDF_VD_READ(vdata_id,L1_RAY_BACK_CROSS_532,fields='Rayleigh_Backscatter_Cross-section_532')
;nrec = HDF_VD_READ(vdata_id,L1_RAY_BACK_CROSS_1064,fields='Rayleigh_Backscatter_Cross-section_1064')
;nrec = HDF_VD_READ(vdata_id,L1_OZONE_ABS_CROSS_532,fields='Ozone_Absorption_Cross-section_532')
;nrec = HDF_VD_READ(vdata_id,L1_OZONE_ABS_CROSS_1064,fields='Ozone_Absorption_Cross-section_1064')


;HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the CheckitL1 called routine.
; An example would be
; @/full/path/Checkit_L1
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
;@Checkit_L1

; Below are two examples of printing out the parameters from a data file.

; The print statement below prints out the file name whic is: FNAME, the
; L1_PROD_ID which is: Product_ID, and the L1_DAT_TIM_PROD which is the Date_Time_of_Production.
;product_id = string(L1_PROD_ID)
;datetimeproduction = string(L1_DAT_TIM_PROD)
;print,FNAME,'     ',product_id,'    ',datetimeproduction

; The print statement below prints out the L1_MET_ALTS which is: Met_Data_Altitudes
;print,'L1_MET_ALTS = ',L1_MET_ALTS

;close,/all

;stop

end
