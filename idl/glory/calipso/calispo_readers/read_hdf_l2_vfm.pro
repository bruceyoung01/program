pro read_hdf_l2_vfm,path,FNAME            ;DPC RELEASE VERSION 3.2
;
; This is a simple read program for the CALIPSO Lidar Level 2
; Data Products, including assignments to variables contained in the
; Lidar Level 2 Vertical Feature Mask Common (L2_VFM_COMMON.pro)
; The user can comment out any assignments not required for their application.
; This Reader Version 3.1 corresponds to the Data Products Catalog Release 3.1.
; The DP Catalog is available on the CALIPSO public website:
;     http://www-calipso.larc.nasa.gov/resources/project_documentation.php
; This reader corresponds to DPC Tables 42 and 43.
;
; There are 2 string inputs to this program:
;   1) the path (i.e. 'C:\') containing the data
;   2) the filename of the Lidar Level 2 Vertical Feature Mask HDF file to be read.
;
; Also provided is a corresponding Checkit_VFM program to verify that all variables
;   have been read and assigned. It is called at the end of this program.
;
;
; August 18, 2010	Science Systems & Applications, Inc.      Data Release
;
; NOTE: Please modify lines in code that meet your system's requirements.

; For Unix and using the IDLDE for Mac
; Include the full path before the L2_VFM_COMMON called routine.
; An example would be @/full/path/L2_VFM_COMMON
; Otherwise, if routine in same working directory as main routine, full
; path is not needed.
@L2_VFM_COMMON

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
    print,sds_id,'   ',var,'   ',dimx,'   ',formx,'   ',hdft,'   ',unitx,'   '


;TABLE 43 PARAMETERS

if var eq 'Latitude' then HDF_SD_GETDATA,sds_id,VF_LAT
if var eq 'Longitude' then HDF_SD_GETDATA,sds_id,VF_LON
if var eq 'Profile_Time' then HDF_SD_GETDATA,sds_id,VF_PROF_TIME
if var eq 'Profile_UTC_Time' then HDF_SD_GETDATA,sds_id,VF_PROF_UTC
if var eq 'Day_Night_Flag' then HDF_SD_GETDATA,sds_id,VF_DN_FLAG
if var eq 'Land_Water_Mask' then HDF_SD_GETDATA,sds_id,VF_LW_MASK
if var eq 'Spacecraft_Position' then HDF_SD_GETDATA,sds_id,VF_SPC_POS
if var eq 'Feature_Classification_Flags' then HDF_SD_GETDATA,sds_id,VF_FC_FLAG


HDF_SD_ENDACCESS,sds_id

endfor

HDF_SD_END,SDinterface_id

;Retrieve the Vdata information
vds_id = HDF_VD_LONE(fid)
vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

HDF_VD_GET,vdata_id,name=var,count=cnt,fields=flds,size=sze,nfields=nflds
print,flds


;TABLE 42 PARAMETERS

nrec = HDF_VD_READ(vdata_id,VF_PROD_ID,fields='Product_ID')
nrec = HDF_VD_READ(vdata_id,VF_DAT_TIM_START,fields='Date_Time_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,VF_DAT_TIM_END,fields='Date_Time_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,VF_DAT_TIM_PROD,fields='Date_Time_of_Production')
nrec = HDF_VD_READ(vdata_id,VF_L1_PROD_DAT_TIM,fields='Lidar_L1_Production_Date_Time')
nrec = HDF_VD_READ(vdata_id,VF_NUM_GOOD_PROF,fields='Number_of_Good_Profiles')
nrec = HDF_VD_READ(vdata_id,VF_NUM_BAD_PROF,fields='Number_of_Bad_Profiles')
nrec = HDF_VD_READ(vdata_id,VF_INIT_SUBSAT_LAT,fields='Initial_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,VF_INIT_SUBSAT_LON,fields='Initial_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,VF_FINAL_SUBSAT_LAT,fields='Final_Subsatellite_Latitude')
nrec = HDF_VD_READ(vdata_id,VF_FINAL_SUBSAT_LON,fields='Final_Subsatellite_Longitude')
nrec = HDF_VD_READ(vdata_id,VF_ORB_NUM_GRAN_START,fields='Orbit_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,VF_ORB_NUM_GRAN_END,fields='Orbit_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,VF_ORB_NUM_CHANG_TIM,fields='Orbit_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,VF_PATH_NUM_GRAN_START,fields='Path_Number_at_Granule_Start')
nrec = HDF_VD_READ(vdata_id,VF_PATH_NUM_GRAN_END,fields='Path_Number_at_Granule_End')
nrec = HDF_VD_READ(vdata_id,VF_PATH_NUM_CHANG_TIM,fields='Path_Number_Change_Time')
nrec = HDF_VD_READ(vdata_id,VF_LID_ALTS,fields='Lidar_Data_Altitudes')
nrec = HDF_VD_READ(vdata_id,VF_GEOS_VER,fields='GEOS_Version')
nrec = HDF_VD_READ(vdata_id,VF_CLASS_COEF_VER_NUM,fields='Classifier_Coefficients_Version_Number')
nrec = HDF_VD_READ(vdata_id,VF_CLASS_COEF_VER_DAT,fields='Classifier_Coefficients_Version_Date')
nrec = HDF_VD_READ(vdata_id,VF_PROD_SCRPT,fields='Production_Script')


HDF_VD_DETACH,vdata_id

HDF_CLOSE,fid

; For Unix and using IDLDE for Mac
; Include the full path before the Checkit_VFM called routine.
; An example would be 
; @/full/path/Checkit_VFM
; Otherwise, if routine in same working directory as main routine, full 
; path is not needed.
@Checkit_VFM

; Below are examples of printing out the parameters from a data file.
; Uncomment the lines of code to print out selected data parameters.

; The print statement below prints out the file name which is: FNAME, the 
; VF_PROD_ID which is the Product_ID, and the VF_L1_PROD_DAT_TIM which is the Date_Time_of_Production.
;product_id = string(VF_PROD_ID)
;vfl1prodtim = string(VF_L1_PROD_DAT_TIM)
;print,FNAME,'     ',product_id,'     ',vfl1prodtim

; The print statement below prints ou tthe VF_LID_ALTS which is the Lidar_Data_Altitudes
;print,'VF_LID_ALTS = ',VF_LID_ALTS

;close,/all

;stop

end
