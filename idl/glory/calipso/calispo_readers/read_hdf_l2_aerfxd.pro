pro read_hdf_l2_aerfxd,path,FNAME			;DPC RELEASE VERSION 2.4
;
;This is a simple read program for the CALIPSO Lidar Level 2
; Data Products, including assignments to variables contained in the
; Lidar Level 2 40km Aerosol Profile, Fixed Lidar Ratio Common (L2_AERFXD_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 2.4 corresponds to the Data Products (DP) Catalog Release 2.4.
; The DP Catalog is available on the CALIPSO public web site:
;		http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 36 and 38.
;
; NOTE: THIS IS THE LAST VERSION OF THIS DATA SET. IT WILL NO LONGER BE
; PRODUCED.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 2 40km Aerosol Profile, Fixed Lidar Ratio
;        HDF file to be read.
;
; Also provided is a corresponding Checkit_AERFXD program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
;
; December 3, 2007	        PLL (Science Systems & Applications, Inc.)  Data Release
; March 17, 2010        	PTD (Science Systems & Applications, Inc.)  Update to this Code Only
;
;
;
; NOTE: Pease modify lines in code that meet your system's requirements.

; For Unix and using the IDLDE for Mac
; Include the full path before the L2_AERFXD_COMMON called routine.
; An example would be @/full/path/L2_AERFXD_COMMON
; Otherwise, if routine in same working directory as main routine, full 
; path is not needed.
@L2_AERFXD_COMMON

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


;TABLE 38 PARAMETERS

if var eq 'Latitude_Start' then HDF_SD_GETDATA,sds_id, AF_START_LAT
if var eq 'Latitude_Stop' then HDF_SD_GETDATA,sds_id, AF_STOP_LAT
if var eq 'Longitude_Start' then HDF_SD_GETDATA,sds_id, AF_START_LON
if var eq 'Longitude_Stop' then HDF_SD_GETDATA,sds_id, AF_STOP_LON
if var eq 'Profile_Time_Start' then HDF_SD_GETDATA,sds_id, AF_START_TIME
if var eq 'Profile_Time_Stop' then HDF_SD_GETDATA,sds_id, AF_STOP_TIME
if var eq 'Profile_UTC_Start' then HDF_SD_GETDATA,sds_id, AF_UTC_START
if var eq 'Profile_UTC_Stop' then HDF_SD_GETDATA,sds_id, AF_UTC_STOP
if var eq 'Tropopause_Height' then HDF_SD_GETDATA,sds_id, AF_TROP_HEIGHT
if var eq 'Tropopause_Temperature' then HDF_SD_GETDATA,sds_id, AF_TROP_TEMP
if var eq 'Temperature' then HDF_SD_GETDATA,sds_id, AF_TEMP
if var eq 'Pressure' then HDF_SD_GETDATA,sds_id, AF_PRESS
if var eq 'Molecular_Number_Density' then HDF_SD_GETDATA,sds_id, AF_MOL_NUM_DEN
if var eq 'Relative_Humidity' then HDF_SD_GETDATA,sds_id, AF_REL_HUM
if var eq 'Profile_QA_Flag' then HDF_SD_GETDATA,sds_id, AF_QA_FLAG
if var eq 'Surface_Elevation_Statistics' then HDF_SD_GETDATA,sds_id, AF_SURF_ELEV_STAT
if var eq 'Surface_Winds' then HDF_SD_GETDATA,sds_id, AF_SFC_WIND
if var eq 'Samples_Averaged' then HDF_SD_GETDATA,sds_id, AF_SAMP_AVG
if var eq 'Aerosol_Layer_Fraction' then HDF_SD_GETDATA,sds_id, AF_AER_LAY_FRAC
if var eq 'Atmospheric_Volume_Description' then HDF_SD_GETDATA,sds_id, AF_ATM_VOL_DESC
if var eq 'Total_Backscatter_Coefficient_532' then HDF_SD_GETDATA,sds_id, AF_TOT_BKS_COEF
if var eq 'Total_Backscatter_Coefficient_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AF_TOT_BKS_COEF_UNC
if var eq 'Extinction_Coefficient_532' then HDF_SD_GETDATA,sds_id, AF_EXT_COEF_532
if var eq 'Extinction_Coefficient_Uncertainty_532' then HDF_SD_GETDATA,sds_id, AF_EXT_COEF_UNC_532


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds



;TABLE 36 PARAMETERS

nrec = HDF_VD_READ(vdata_id, AF_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id, AF_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id, AF_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id, AF_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id, AF_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
nrec = HDF_VD_READ(vdata_id, AF_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
nrec = HDF_VD_READ(vdata_id, AF_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id, AF_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id, AF_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id, AF_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id, AF_RAY_EXT_532,fields='Rayleigh_Extinction_Cross-section_532')
nrec = HDF_VD_READ(vdata_id, AF_RAY_EXT_1064,fields='Rayleigh_Extinction_Cross-section_1064')
nrec = HDF_VD_READ(vdata_id, AF_RAY_BKS_532,fields='Rayleigh_Backscatter_Cross-section_532')
nrec = HDF_VD_READ(vdata_id, AF_RAY_BKS_1064,fields='Rayleigh_Backscatter_Cross-section_1064')
nrec = HDF_VD_READ(vdata_id, AF_L1_PROD_DAT_TIM,fields='Lidar_L1_Production_Date_Time')
nrec = HDF_VD_READ(vdata_id, AF_LID_ALTS,fields='Lidar_Data_Altitudes')
nrec = HDF_VD_READ(vdata_id, AF_GEOS_VER,fields='GEOS_Version')
nrec = HDF_VD_READ(vdata_id, AF_PROD_SCRPT,fields='Production_Script')


HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_AERFXD called routine.
; An example would be
; @/full/path/Checkit_AERFXD
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@Checkit_AERFXD

; Below are examples of printing out the parameters from a data file.
; Uncomment the lines for printing specific parameters.

; The print statement below prints out the file name which is: FNAME, the
; AF_PROD_ID which is the Product_ID, and the AF_DAT_TIM_PROD which is the Date_Time_of_Production.
;product_id = string(AF_PROD_ID)
;afprodtim = string(AF_DAT_TIM_PROD)
;print,FNAME,'     ',product_id,'     ',afprodtim

; The print statement below prints ou tthe AF_TROP_HEIGHT which is the Tropospheric_Height
;print,'AF_TROP_HEIGHT = ',AF_TROP_HEIGHT

;close,/all

;stop

end
