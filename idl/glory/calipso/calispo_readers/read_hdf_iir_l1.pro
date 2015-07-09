pro read_hdf_iir_l1,path,FNAME          ;DPC RELEASE VERSION 2.4
;
;This is a simple read program for the CALIPSO Infrared Imaging Radiometer (IIR)
; Level 1 Data Products, including assignments to variables contained in the
; IIR Level 1 Science Common (IIR_L1_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 2.4 corresponds to the Data Products Catalog Release 2.4.
; The DP Catalog is available on the CALIPSO public web site:
;     http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 12, 13 and 14.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the IIR Level 1 Science HDF file to be read.
;
; Also provided is a corresponding Checkit_IIR program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
; December 8, 2006  PLL (Science Systems & Applications, Inc.)  Data Release
; August 16, 2007	PLL (Science Systems & Applications, Inc.)  Interim Release
; December 3, 2007	PLL (Science Systems & Applications, Inc.)  Data Release
; March 16, 2010        PTD (Science Systems & Applications, Inc.)  Read Software update only
;
; NOTE: Pease modify lines in code that meet your system's requirements.

; For Unix and using the IDLDE for Mac
; Include the full path before the IIR_L1_COMMON called routine.
; An example would be @/full/path/IIR_L1_COMMON
; Otherwise, if routine in same working directory as main routine, full 
; path is not needed.
@IIR_L1_COMMON

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


;TABLE 14 PARAMETERS

if var eq 'Latitude' then HDF_SD_GETDATA,sds_id,IIR_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id,IIR_LONif var eq 'Lidar_Shot_Time' then HDF_SD_GETDATA,sds_id,IIR_LIDAR_SHOT_TIME
if var eq 'Lidar_Shot_UTC_Time' then HDF_SD_GETDATA,sds_id,IIR_LIDAR_SHOT_UTC
if var eq 'Image_Time_8.65' then HDF_SD_GETDATA,sds_id,IIR_IMG_TIME_8
if var eq 'Image_UTC_Time_8.65' then HDF_SD_GETDATA,sds_id,IIR_IMG_UTC_8if var eq 'Viewing_Zenith_Angle_8.65' then HDF_SD_GETDATA,sds_id,IIR_ZNTH_8
if var eq 'Viewing_Azimuth_Angle_8.65' then HDF_SD_GETDATA,sds_id,IIR_AZMTH_8
if var eq 'Sequence_Number_8.65' then HDF_SD_GETDATA,sds_id,IIR_SEQNUM_8
if var eq 'Calibrated_Radiances_8.65' then HDF_SD_GETDATA,sds_id,IIR_CAL_RAD_8if var eq 'Image_Time_12.05' then HDF_SD_GETDATA,sds_id,IIR_IMG_TIME_12
if var eq 'Image_UTC_Time_12.05' then HDF_SD_GETDATA,sds_id,IIR_IMG_UTC_12
if var eq 'Viewing_Zenith_Angle_12.05' then HDF_SD_GETDATA,sds_id,IIR_ZNTH_12
if var eq 'Viewing_Azimuth_Angle_12.05' then HDF_SD_GETDATA,sds_id,IIR_AZMTH_12
if var eq 'Sequence_Number_12.05' then HDF_SD_GETDATA,sds_id,IIR_SEQNUM_12
if var eq 'Calibrated_Radiances_12.05' then HDF_SD_GETDATA,sds_id,IIR_CAL_RAD_12
if var eq 'Image_Time_10.6' then HDF_SD_GETDATA,sds_id,IIR_IMG_TIME_10
if var eq 'Image_UTC_Time_10.6' then HDF_SD_GETDATA,sds_id,IIR_IMG_UTC_10
if var eq 'Viewing_Zenith_Angle_10.6' then HDF_SD_GETDATA,sds_id,IIR_ZNTH_10
if var eq 'Viewing_Azimuth_Angle_10.6' then HDF_SD_GETDATA,sds_id,IIR_AZMTH_10
if var eq 'Sequence_Number_10.6' then HDF_SD_GETDATA,sds_id,IIR_SEQNUM_10if var eq 'Calibrated_Radiances_10.6' then HDF_SD_GETDATA,sds_id,IIR_CAL_RAD_10
if var eq 'Pixel_Quality_Index' then HDF_SD_GETDATA,sds_id,IIR_PXL_QLTY

;TABLE 13 PARAMETERS

if var eq 'Time_TAI_8.65' then HDF_SD_GETDATA,sds_id,IIR_TAI_8if var eq 'Time_UTC_8.65' then HDF_SD_GETDATA,sds_id,IIR_UTC_8
if var eq 'Spacecraft_Position_8.65' then HDF_SD_GETDATA,sds_id,IIR_SPC_POS_8if var eq 'Spacecraft_Velocity_8.65' then HDF_SD_GETDATA,sds_id,IIR_SPC_VEL_8
if var eq 'Spacecraft_Attitude_8.65' then HDF_SD_GETDATA,sds_id,IIR_SPC_ATT_8
if var eq 'Spacecraft_Attitude_Rate_8.65' then HDF_SD_GETDATA,sds_id,IIR_ATT_RAT_8
if var eq 'Subsatellite_Latitude_8.65' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LAT_8
if var eq 'Subsatellite_Longitude_8.65' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LON_8
if var eq 'Time_TAI_12.05' then HDF_SD_GETDATA,sds_id,IIR_TAI_12
if var eq 'Time_UTC_12.05' then HDF_SD_GETDATA,sds_id,IIR_UTC_12
if var eq 'Spacecraft_Position_12.05' then HDF_SD_GETDATA,sds_id,IIR_SPC_POS_12
if var eq 'Spacecraft_Velocity_12.05' then HDF_SD_GETDATA,sds_id,IIR_SPC_VEL_12
if var eq 'Spacecraft_Attitude_12.05' then HDF_SD_GETDATA,sds_id,IIR_SPC_ATT_12
if var eq 'Spacecraft_Attitude_Rate_12.05' then HDF_SD_GETDATA,sds_id,IIR_ATT_RAT_12
if var eq 'Subsatellite_Latitude_12.05' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LAT_12
if var eq 'Subsatellite_Longitude_12.05' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LON_12
if var eq 'Time_TAI_10.6' then HDF_SD_GETDATA,sds_id,IIR_TAI_10
if var eq 'Time_UTC_10.6' then HDF_SD_GETDATA,sds_id,IIR_UTC_10
if var eq 'Spacecraft_Position_10.6' then HDF_SD_GETDATA,sds_id,IIR_SPC_POS_10
if var eq 'Spacecraft_Velocity_10.6' then HDF_SD_GETDATA,sds_id,IIR_SPC_VEL_10
if var eq 'Spacecraft_Attitude_10.6' then HDF_SD_GETDATA,sds_id,IIR_SPC_ATT_10
if var eq 'Spacecraft_Attitude_Rate_10.6' then HDF_SD_GETDATA,sds_id,IIR_ATT_RAT_10
if var eq 'Subsatellite_Latitude_10.6' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LAT_10
if var eq 'Subsatellite_Longitude_10.6' then HDF_SD_GETDATA,sds_id,IIR_SUBSAT_LON_10


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds


;TABLE 12 PARAMETERS

nrec = HDF_VD_READ(vdata_id,IIR_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id,IIR_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,IIR_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,IIR_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id,IIR_GRD_LINE_REC,fields='Number_of_IIR_Grid_Line_Records')
nrec = HDF_VD_READ(vdata_id,IIR_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,IIR_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,IIR_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,IIR_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,IIR_EPHM_FILES_USED,fields='Ephemeris_Files_Used')
nrec = HDF_VD_READ(vdata_id,IIR_ATT_FILES_USED,fields='Attitude_Files_Used')
nrec = HDF_VD_READ(vdata_id,IIR_L0_FILES_USED,fields='Level_0_Files_Used')
nrec = HDF_VD_READ(vdata_id,IIR_L1_VER_USED,fields='Level_1_code_version_Used')
nrec = HDF_VD_READ(vdata_id,IIR_PAR_VER_RADIO,fields='Input_parameter_version_number_used_Radiometry')
nrec = HDF_VD_READ(vdata_id,IIR_PAR_DATE_RADIO,fields='Input_parameter_date_of_application_Radiometry')
nrec = HDF_VD_READ(vdata_id,IIR_PAR_VER_GEO,fields='Input_parameter_version_number_used_Geometry')
nrec = HDF_VD_READ(vdata_id,IIR_PAR_DATE_GEO,fields='Input_parameter_date_of_application_Geometry')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_GD_PXL_8,fields='Percentage_of_8.65_Good_Pixels')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_GD_PXL_12,fields='Percentage_of_12.05_Good_Pixels')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_GD_PXL_10,fields='Percentage_of_10.6_Good_Pixels')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_GD_PXL_ALL,fields='Percentage_of_Good_Pixels_3_Channels')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_MISS_PXL,fields='Percentage_of_Missing_Pixels')
nrec = HDF_VD_READ(vdata_id,IIR_NUM_IMG_PROC,fields='Number_of_Images_Processed')
nrec = HDF_VD_READ(vdata_id,IIR_PCNT_MISS_IMG,fields='Percentage_of_Missing_Images')
nrec = HDF_VD_READ(vdata_id,IIR_NUM_EQUAL_MODE,fields='Number_of_Equalization_mode')
nrec = HDF_VD_READ(vdata_id,IIR_ALT_PROJ,fields='Altitude_of_Projection')
nrec = HDF_VD_READ(vdata_id,IIR_INIT_ABS_SEQ,fields='Initial_Absolute_Sequence')
nrec = HDF_VD_READ(vdata_id,IIR_FINAL_ABS_SEQ,fields='Final_Absolute_Sequence')
nrec = HDF_VD_READ(vdata_id,IIR_GRID_LINE_DELTA,fields='Grid_Line_Delta_Time')
nrec = HDF_VD_READ(vdata_id,IIR_SCALE_FACT_RAD,fields='Scale_Factor_for_Radiance')
nrec = HDF_VD_READ(vdata_id,IIR_RAD_OFFSET,fields='Radiance_Offset')
nrec = HDF_VD_READ(vdata_id,IIR_SCALE_FACT_VW_ANGLE,fields='Scale_Factor_for_Viewing_Angle')
nrec = HDF_VD_READ(vdata_id,IIR_VW_ANGLE_OFFSET,fields='Viewing_Angle_Offset')

HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_IIR called routine.
; An example would be
; @/full/path/Checkit_IIR
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@Checkit_IIR.pro

; Below are two examples of printing out the parameters from a data file.

; The print statement below prints out the file name which is: FNAME, the
; IIR_PROD_ID which is the Product_ID, and the IIR_DAT_TIM_PROD which is the Date_Time_of_Production.
product_id = string(IIR_PROD_ID)
iirprodtim = string(IIR_DAT_TIM_PROD)
print,FNAME,'     ',product_id,'     ',iirprodtim

; The print statement below prints ou the IIR_CAL_RAD_8 which is the Calibrated_Radiances_8.65
print,'IIR_CAL_RAD_8 = ',IIR_CAL_RAD_8


;close,/all

;stop

end
