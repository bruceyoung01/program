pro read_hdf_l2_cl33,path,FNAME           ;DPC RELEASE VERSION 3.2
;
; This is a simple read program for the CALIPSO Lidar Level 2
; Data Products, including assignments to variables contained in the
; Lidar Level 2 1/3km Cloud Column and Layer Common (L2_CL33_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 3.1 corresponds to the Data Products (DP) Catalog Release 3.1.
; The DP Catalog is available on the CALIPSO public web site:
;     http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 26, 27, and 28.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 2 1/3km Cloud Layer HDF file to be read.
;
; Also provided is a corresponding Checkit_CL33 program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
; August 18, 2010	Science Systems & Applications, Inc.        Data Release
;
; NOTE: Please modify lines in code that meet your system's requirements.

; For Unix and using IDLDE for Mac
; Include the full path before the L2_CL33_COMMON called routine.
; An example would be  @/full/path/L2_CL33_COMMON
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@L2_CL33_COMMON

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


;TABLE 27 PARAMETERS

if var eq 'Profile_ID' then HDF_SD_GETDATA,sds_id,C3_PROF_ID
if var eq 'Latitude' then HDF_SD_GETDATA,sds_id,C3_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id,C3_LON
if var eq 'Profile_Time' then HDF_SD_GETDATA,sds_id,C3_PROF_TIME
if var eq 'Profile_UTC_Time' then HDF_SD_GETDATA,sds_id,C3_PROF_UTC
if var eq 'Day_Night_Flag' then HDF_SD_GETDATA,sds_id,C3_DN_FLAG
if var eq 'Off_Nadir_Angle' then HDF_SD_GETDATA,sds_id,C3_OFF_NDR
if var eq 'Solar_Zenith_Angle' then HDF_SD_GETDATA,sds_id,C3_SOL_ZNTH
if var eq 'Solar_Azimuth_Angle' then HDF_SD_GETDATA,sds_id,C3_SOL_AZMTH
if var eq 'Scattering_Angle' then HDF_SD_GETDATA,sds_id,C3_SCATR
if var eq 'Spacecraft_Position' then HDF_SD_GETDATA,sds_id,C3_SPC_POS
if var eq 'Parallel_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,C3_PAR_REFL
if var eq 'Parallel_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C3_PAR_REFL_UNC
if var eq 'Perpendicular_Column_Reflectance_532' then HDF_SD_GETDATA,sds_id,C3_PER_REFL
if var eq 'Perpendicular_Column_Reflectance_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C3_PER_REFL_UNC
if var eq 'Column_Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C3_COL_IAB
if var eq 'Column_IAB_Cumulative_Probability' then HDF_SD_GETDATA,sds_id,C3_COL_IAB_PROB
if var eq 'Tropopause_Height' then HDF_SD_GETDATA,sds_id,C3_TROP_HGT
if var eq 'Tropopause_Temperature' then HDF_SD_GETDATA,sds_id,C3_TROP_TEMP
if var eq 'IGBP_Surface_Type' then HDF_SD_GETDATA,sds_id,C3_IGBP_TYPE
if var eq 'NSIDC_Surface_Type' then HDF_SD_GETDATA,sds_id,C3_NSIDC_TYPE
if var eq 'Lidar_Surface_Elevation' then HDF_SD_GETDATA,sds_id,C3_LID_ELEV
if var eq 'DEM_Surface_Elevation' then HDF_SD_GETDATA,sds_id,C3_DEM_ELEV
if var eq 'Number_Layers_Found' then HDF_SD_GETDATA,sds_id,C3_NUM_LAYR

;TABLE 28 PARAMETERS

if var eq 'Layer_Top_Altitude' then HDF_SD_GETDATA,sds_id, C3_TOP_ALT
if var eq 'Layer_Base_Altitude' then HDF_SD_GETDATA,sds_id,C3_BASE_ALT
if var eq 'Layer_Top_Pressure' then HDF_SD_GETDATA,sds_id,C3_LAY_TOP_PRES
if var eq 'Midlayer_Pressure' then HDF_SD_GETDATA,sds_id,C3_MIDLAY_PRES
if var eq 'Layer_Base_Pressure' then HDF_SD_GETDATA,sds_id,C3_LAY_BASE_PRES
if var eq 'Layer_Top_Temperature' then HDF_SD_GETDATA,sds_id,C3_LAY_TOP_TEMP
if var eq 'Midlayer_Temperature' then HDF_SD_GETDATA,sds_id,C3_MIDL_TEMP
if var eq 'Layer_Base_Temperature' then HDF_SD_GETDATA,sds_id,C3_LAY_BASE_TEMP
if var eq 'Attenuated_Backscatter_Statistics_532' then HDF_SD_GETDATA,sds_id,C3_BKS_STAT_532
if var eq 'Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C3_BKS_532
if var eq 'Integrated_Attenuated_Backscatter_Uncertainty_532' then HDF_SD_GETDATA,sds_id,C3_BKS_532_UNC
if var eq 'Attenuated_Backscatter_Statistics_1064' then HDF_SD_GETDATA,sds_id,C3_BKS_STAT_1064
if var eq 'Integrated_Attenuated_Backscatter_1064' then HDF_SD_GETDATA,sds_id,C3_BKS_1064
if var eq 'Integrated_Attenuated_Backscatter_Uncertainty_1064' then HDF_SD_GETDATA,sds_id,C3_BKS_1064_UNC
if var eq 'Volume_Depolarization_Ratio_Statistics' then HDF_SD_GETDATA,sds_id,C3_VOL_DPR_STAT
if var eq 'Integrated_Volume_Depolarization_Ratio' then HDF_SD_GETDATA,sds_id,C3_VOL_DPR
if var eq 'Integrated_Volume_Depolarization_Ratio_Uncertainty' then HDF_SD_GETDATA,sds_id,C3_VOL_DPR_UNC
if var eq 'Attenuated_Total_Color_Ratio_Statistics' then HDF_SD_GETDATA,sds_id,C3_TOT_CLR_STAT
if var eq 'Integrated_Attenuated_Total_Color_Ratio' then HDF_SD_GETDATA,sds_id,C3_TOT_CLR
if var eq 'Integrated_Attenuated_Total_Color_Ratio_Uncertainty' then HDF_SD_GETDATA,sds_id,C3_TOT_CLR_UNC
if var eq 'Overlying_Integrated_Attenuated_Backscatter_532' then HDF_SD_GETDATA,sds_id,C3_OVR_IAB
if var eq 'Layer_IAB_QA_Factor' then HDF_SD_GETDATA,sds_id,C3_IAB_QA
if var eq 'Feature_Classification_Flags' then HDF_SD_GETDATA,sds_id,C3_FC_FLG


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds


;TABLE 26 PARAMETERS

nrec = HDF_VD_READ(vdata_id,C3_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id,C3_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C3_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,C3_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id,C3_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
nrec = HDF_VD_READ(vdata_id,C3_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
nrec = HDF_VD_READ(vdata_id,C3_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,C3_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,C3_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,C3_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,C3_ORB_NUM_GRAN_STRT,fields='Orbit_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C3_ORB_NUM_GRAN_END,fields='Orbit_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,C3_ORB_NUM_CHNG_TIM,fields='Orbit_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,C3_PATH_NUM_GRAN_STRT,fields='Path_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,C3_PATH_NUM_GRAN_END,fields='Path_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,C3_PATH_NUM_CHNG_TIM,fields='Path_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,C3_L1_PROD_DAT_TIM,fields='Lidar_L1_Production_Date_Time')
nrec = HDF_VD_READ(vdata_id,C3_NUM_SSHT_RECS,fields='Number_of_Single_Shot_Records_in_File')
nrec = HDF_VD_READ(vdata_id,C3_NUM_AV_RECS,fields='Number_of_Average_Records_in_File')
nrec = HDF_VD_READ(vdata_id,C3_NUM_FTRS_FND,fields='Number_of_Features_Found')
nrec = HDF_VD_READ(vdata_id,C3_NUM_CLD_FTRS,fields='Number_of_Cloud_Features_Found')
nrec = HDF_VD_READ(vdata_id,C3_NUM_AER_FTRS,fields='Number_of_Aerosol_Features_Found')
nrec = HDF_VD_READ(vdata_id,C3_NUM_INDT_FTRS,fields='Number_of_Indeterminate_Features_Found')
nrec = HDF_VD_READ(vdata_id,C3_LID_ALTS,fields='Lidar_Data_Altitudes')
nrec = HDF_VD_READ(vdata_id,C3_GEOS_VER,fields='GEOS_Version')
nrec = HDF_VD_READ(vdata_id,C3_CLASS_COEF_VER_NUM,fields='Classifier_Coefficients_Version_Number')
nrec = HDF_VD_READ(vdata_id,C3_CLASS_COEF_VER_DAT,fields='Classifier_Coefficients_Version_Date')
nrec = HDF_VD_READ(vdata_id,C3_PROD_SCRPT,fields='Production_Script')


HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_CL33 called routine.
; An example would be
; @/full/path/Checkit_CL33
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@Checkit_CL33

; Below are examples of printing out the parameters from a data file.
; Uncomment the lines of code to print out selected data parameters.

; The print statement below prints out the file name whic is: FNAME, the
; C3_PROD_ID which is: Product_ID, and the C3_DAT_TIM_PROD which is the Date_Time_of_Production.
;product_id = string(C3_PROD_ID)
;datetimeproduction = string(C3_DAT_TIM_PROD)
;print,FNAME,'     ',product_id,'    ',datetimeproduction

; The print statement below prints out the latitude and longitude.
;print,'Latitude = ', C3_LAT
;print,'Longitude = ', C3_LON

; The print statement below prints out the C3_CLASS_COEF_VER_NUM which is: Classifier_Coefficients_Version_Number
;c3classcoefvernum = string(C3_CLASS_COEF_VER_NUM)
;print,'C3_CLASS_COEF_VER_NUM = ',c3classcoefvernum

; The print statement below prints out the C3_CLASS_COEF_VER_NUM which is: Classifier_Coefficients_Version_Number
;c3prodscrpt = string(C3_PROD_SCRPT)
;print,'C3_PROD_SCRPT = ',c3prodscrpt

;close,/all

;stop

end
