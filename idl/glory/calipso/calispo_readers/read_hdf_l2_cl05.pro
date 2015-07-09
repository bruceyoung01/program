pro read_hdf_l2_cl05,path,FNAME           ;DPC RELEASE VERSION 3.2
;
;This is a simple read program for the CALIPSO Lidar Level 2
; Data Products, including assignments to variables contained in the
; Lidar Level 2 5km Cloud Column and Layer Common (L2_CL05_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 3.1 corresponds to the Data Products (DP) Catalog Release 3.1.
; The DP Catalog is available on the CALIPSO public website:
;     http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 26, 31, and 32.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 2 5km Cloud Layer HDF file to be read.
;
; Also provided is a corresponding Checkit_CL05 program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
; August 18, 2010     Science Systems & Applications, Inc.      Data Release
;
; NOTE: Please modify lines in code that meet your system's requirements.

; For Unix and using IDLDE for Mac
; Include the full path before the L2_CL05_COMMON called routine.
; An example would be  @/full/path/L2_CL05_COMMON
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@L2_CL05_COMMON

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
    print,'sds_id=',sds_id,'   var=',var,'   dimx=',dimx,'   formx=',formx,'   hdft=',hdft,'   unitx=',unitx


;TABLE 31 PARAMETERS

if var eq 'Profile_ID' then HDF_SD_GETDATA,sds_id,C5_PROF_ID
if var eq 'Latitude' then HDF_SD_GETDATA,sds_id,C5_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id,C5_LON
if var eq 'Profile_Time' then HDF_SD_GETDATA,sds_id,C5_PROF_TIME
if var eq 'Profile_UTC_Time' then HDF_SD_GETDATA,sds_id,C5_PROF_UTC
if var eq 'Day_Night_Flag' then HDF_SD_GETDATA,sds_id,C5_DN_FLAG
if var eq 'Off_Nadir_Angle' then HDF_SD_GETDATA,sds_id,C5_OFF_NDR
if var eq 'Solar_Zenith_Angle' then HDF_SD_GETDATA,sds_id,C5_SOL_ZNTH
if var eq 'Solar_Azimuth_Angle' then HDF_SD_GETDATA,sds_id,C5_SOL_AZMTH
if var eq 'Scattering_Angle' then HDF_SD_GETDATA,sds_id,C5_SCATR
if var eq 'Spacecraft_Position' then HDF_SD_GETDATA,sds_id,C5_SPC_POS
if var eq 'Parallel_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,C5_PAR_REFL
if var eq 'Parallel_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_PAR_REFL_UNC
if var eq 'Parallel_Column_Reflectance_RMS_Variation_532' then HDF_SD_GETDATA,sds_id,C5_PAR_REFL_RMS
if var eq 'Perpendicular_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,C5_PER_REFL
if var eq 'Perpendicular_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_PER_REFL_UNC
if var eq 'Perpendicular_Column_Reflectance_RMS_Variation_532' then HDF_SD_GETDATA,sds_id,C5_PER_REFL_RMS
if var eq 'Column_Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C5_COL_IAB
if var eq 'Column_IAB_Cumulative_Probability' then HDF_SD_GETDATA,sds_id,C5_COL_IAB_PROB
if var eq 'Column_Optical_Depth_Cloud_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_CLD_532
if var eq 'Column_Optical_Depth_Cloud_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_CLD_UNC_532
if var eq 'Column_Optical_Depth_Aerosols_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_AER_532
if var eq 'Column_Optical_Depth_Aerosols_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_AER_UNC_532
if var eq 'Column_Optical_Depth_Stratospheric_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_STRAT_532
if var eq 'Column_Optical_Depth_Stratospheric_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_STRAT_UNC_532
if var eq 'Column_Optical_Depth_Aerosols_1064' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_AER_1064
if var eq 'Column_Optical_Depth_Aerosols_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_AER_UNC_1064
if var eq 'Column_Optical_Depth_Stratospheric_1064' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_STRAT_1064
if var eq 'Column_Optical_Depth_Stratospheric_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,C5_COL_OPT_DEP_STRAT_UNC_1064
if var eq 'Column_Feature_Fraction' then HDF_SD_GETDATA,sds_id,C5_COL_FEA_FRAC
if var eq 'Tropopause_Height' then HDF_SD_GETDATA,sds_id,C5_TROP_HGT
if var eq 'Tropopause_Temperature' then HDF_SD_GETDATA,sds_id,C5_TROP_TEMP
if var eq 'IGBP_Surface_Type' then HDF_SD_GETDATA,sds_id,C5_IGBP_TYPE
if var eq 'NSIDC_Surface_Type' then HDF_SD_GETDATA,sds_id,C5_NSIDC_TYPE
if var eq 'Lidar_Surface_Elevation' then HDF_SD_GETDATA,sds_id,C5_LID_ELEV
if var eq 'DEM_Surface_Elevation' then HDF_SD_GETDATA,sds_id,C5_DEM_ELEV
if var eq 'Surface_Elevation_Detection_Frequency' then HDF_SD_GETDATA,sds_id,C5_ELEV_DET_FRQ
if var eq 'Normalization_Constant_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_NORM_CNST_UNC
if var eq 'FeatureFinderQC' then HDF_SD_GETDATA,sds_id,C5_FF_QC
if var eq 'Calibration_Altitude_532' then HDF_SD_GETDATA,sds_id,C5_CAL_ALT_532
if var eq 'Number_Layers_Found' then HDF_SD_GETDATA,sds_id,C5_NUM_LAYR

;TABLE 32 PARAMETERS

if var eq 'Layer_Top_Altitude' then HDF_SD_GETDATA,sds_id, C5_TOP_ALT
if var eq 'Layer_Base_Altitude' then HDF_SD_GETDATA,sds_id,C5_BASE_ALT
if var eq 'Layer_Base_Extended' then HDF_SD_GETDATA,sds_id,C5_BASE_EXT
if var eq 'Layer_Top_Pressure' then HDF_SD_GETDATA,sds_id,C5_TOP_PRES
if var eq 'Midlayer_Pressure' then HDF_SD_GETDATA,sds_id,C5_MID_PRES
if var eq 'Layer_Base_Presure' then HDF_SD_GETDATA,sds_id,C5_BASE_PRES
if var eq 'Layer_Top_Temperature' then HDF_SD_GETDATA,sds_id,C5_TOP_TEMP
if var eq 'Midlayer_Temperature' then HDF_SD_GETDATA,sds_id,C5_MID_TEMP
if var eq 'Layer_Base_Temperature' then HDF_SD_GETDATA,sds_id,C5_BASE_TEMP
if var eq 'Opacity_Flag' then HDF_SD_GETDATA,sds_id,C5_OPC_FLAG
if var eq 'Horizontal_Averaging'  then HDF_SD_GETDATA,sds_id,C5_HORZ_AVG
if var eq 'Single_Shot_Cloud_Cleared_Fraction'  then HDF_SD_GETDATA,sds_id,C5_SING_SHOT_CLD_CLRD_FRAC
if var eq 'Attenuated_Backscatter_Statistics_532' then HDF_SD_GETDATA,sds_id,C5_BKS_STAT_532
if var eq 'Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C5_BKS_532
if var eq 'Integrated_Attenuated_Backscatter_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_BKS_532_UNC
if var eq 'Attenuated_Backscatter_Statistics_1064' then HDF_SD_GETDATA,sds_id,C5_BKS_STAT_1064
if var eq 'Integrated_Attenuated_Backscatter_1064' then HDF_SD_GETDATA,sds_id,C5_BKS_1064
if var eq 'Integrated_Attenuated_Backscatter_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,C5_BKS_1064_UNC
if var eq 'Volume_Depolarization_Ratio_Statistics' then HDF_SD_GETDATA,sds_id,C5_VOL_DPR_STAT
if var eq 'Integrated_Volume_Depolarization_Ratio' then HDF_SD_GETDATA,sds_id,C5_VOL_DPR
if var eq 'Integrated_Volume_Depolarization_Ratio_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_VOL_DPR_UNC
if var eq 'Attenuated_Total_Color_Ratio_Statistics' then HDF_SD_GETDATA,sds_id,C5_TOT_CLR_STAT
if var eq 'Integrated_Attenuated_Total_Color_Ratio' then HDF_SD_GETDATA,sds_id,C5_TOT_CLR
if var eq 'Integrated_Attenuated_Total_Color_Ratio_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_TOT_CLR_UNC
if var eq 'Overlying_Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C5_OVR_IAB
if var eq 'Layer_IAB_QA_Factor' then HDF_SD_GETDATA,sds_id,C5_IAB_QA
if var eq 'Feature_Classification_Flags' then HDF_SD_GETDATA,sds_id,C5_FC_FLG
if var eq 'ExtinctionQC_532' then HDF_SD_GETDATA,sds_id,C5_EXT_QC_532
if var eq 'CAD_Score' then begin
		HDF_SD_GETDATA,sds_id,HOLDER
                aq=where(HOLDER gt 127)
                C5_CAD_SCR=long(HOLDER)
		if (aq(0) ne -1) then C5_CAD_SCR(aq)  = C5_CAD_SCR(aq) - 256L
		endif
if var eq 'Measured_Two_Way_Transmittance_532' then HDF_SD_GETDATA,sds_id,C5_TWW_TRNSM_532
if var eq 'Measured_Two_Way_Transmittance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_TWW_TRNSM_532_UNC
if var eq 'Two_Way_Transmittance_Measurement_Region' then HDF_SD_GETDATA,sds_id,C5_TWW_REG
if var eq 'Feature_Optical_Depth_532' then HDF_SD_GETDATA,sds_id,C5_FOD_532
if var eq 'Feature_Optical_Depth_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C5_FOD_532_UNC
if var eq 'Initial_532_Lidar_Ratio' then HDF_SD_GETDATA,sds_id,C5_INIT_RATIO
if var eq 'Final_532_Lidar_Ratio' then HDF_SD_GETDATA,sds_id,C5_FINAL_RATIO
if var eq 'Lidar_Ratio_532_Selection_Method' then HDF_SD_GETDATA,sds_id,C5_RATIO_SLCT
if var eq 'Layer_Effective_532_Multiple_Scattering_Factor' then HDF_SD_GETDATA,sds_id,C5_LAYR_MSF
if var eq 'Integrated_Particulate_Depolarization_Ratio' then HDF_SD_GETDATA,sds_id,C5_PART_DPR
if var eq 'Integrated_Particulate_Depolarization_Ratio_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_PART_DPR_UNC
if var eq 'Particulate_Depolarization_Ratio_Statistics' then HDF_SD_GETDATA,sds_id,C5_PART_DPR_STAT
if var eq 'Midlayer_Temperature' then HDF_SD_GETDATA,sds_id,C5_MIDL_TEMP
if var eq 'Cirrus_Shape_Parameter' then HDF_SD_GETDATA,sds_id,C5_CIRRUS_SHP
if var eq 'Cirrus_Shape_Parameter_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_CIRRUS_SHP_UNC
if var eq 'Cirrus_Shape_Parameter_Invalid_Points' then HDF_SD_GETDATA,sds_id,C5_CIRRUS_SHP_NVLD_PTS
if var eq 'Ice_Water_Path' then HDF_SD_GETDATA,sds_id,C5_ICEWATR_PTH
if var eq 'Ice_Water_Path_Uncertainty' then HDF_SD_GETDATA,sds_id,C5_ICEWATR_PTH_UNC


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds


;TABLE 26 PARAMETERS

nrec = HDF_VD_READ(vdata_id,C5_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id,C5_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C5_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,C5_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id,C5_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
nrec = HDF_VD_READ(vdata_id,C5_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
nrec = HDF_VD_READ(vdata_id,C5_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,C5_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,C5_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,C5_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,C5_ORB_NUM_GRN_STRT,fields='Orbit_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C5_ORB_NUM_GRN_END,fields='Orbit_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C5_ORB_NUM_CHNG_TIM,fields='Orbit_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,C5_PATH_NUM_GRN_STRT,fields='Path_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C5_PATH_NUM_GRN_END,fields='Path_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C5_PATH_NUM_CHNG_TIM,fields='Path_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,C5_L1_PROD_DAT_TIM,fields='Lidar_L1_Production_Date_Time')
nrec = HDF_VD_READ(vdata_id,C5_NUM_SSHT_RECS,fields='Number_of_Single_Shot_Records_in_File')
nrec = HDF_VD_READ(vdata_id,C5_NUM_AV_RECS,fields='Number_of_Average_Records_in_File')
nrec = HDF_VD_READ(vdata_id,C5_NUM_FTRS_FND,fields='Number_of_Features_Found')
nrec = HDF_VD_READ(vdata_id,C5_NUM_CLD_FTRS,fields='Number_of_Cloud_Features_Found')
nrec = HDF_VD_READ(vdata_id,C5_NUM_AER_FTRS,fields='Number_of_Aerosol_Features_Found')
nrec = HDF_VD_READ(vdata_id,C5_NUM_INDT_FTRS,fields='Number_of_Indeterminate_Features_Found')
nrec = HDF_VD_READ(vdata_id,C5_LID_ALTS,fields='Lidar_Data_Altitudes')
nrec = HDF_VD_READ(vdata_id,C5_GEOS_VER,fields='GEOS_Version')
nrec = HDF_VD_READ(vdata_id,C5_CLASS_COEF_VER_NUM,fields='Classifier_Coefficients_Version_Number')
nrec = HDF_VD_READ(vdata_id,C5_CLASS_COEF_VER_DAT,fields='Classifier_Coefficients_Version_Date')
nrec = HDF_VD_READ(vdata_id,C5_PROD_SCRPT,fields='Production_Script')


HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_CL05 called routine.
; An example would be
; @/full/path/Checkit_CL05
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@Checkit_CL05

; Below are examples of printing out the parameters from a data file.
; Uncomment the lines of code that prints out selected data parameters.

; The print statement below prints out the file name which is: FNAME, the
; C5_PROD_ID which is the Product_ID, and the C5_DAT_TIM_PROD which is the Date_Time_of_Production.
;product_id = string(C5_PROD_ID)
;c5prodtim = string(C5_DAT_TIM_PROD)
;print,FNAME,'     ',product_id,'     ',c5prodtim

; The print statement below prints out both the latitude and longitude
;c5lat = string(C5_LAT)
;c5lon = string(C5_LON)
;print,'LATITUDE = ',c5lat
;print,'LONGITUDE = ',c5lon

; The print statement below prints ou tthe C5_CAD_SCR which is the CAD_SCORE
;print,'C5_CAD_SCR = ',C5_CAD_SCR


;print,'C5_DN_FLAG = ',C5_DN_FLAG

;close,/all

;stop

end
