;  $ID: read_ascii_modis_caliop.ncl V01 07/02/2015 11:45 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_ascii_amsre_caliop READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_amsre_sum_aca_ESMF.ncl. THE FILE FORMAT IS LIKE:
;  Latitude Longitude Above_Cloud_Water_Vapor 
;  Cloud_Optical_Thickness_38 Cloud_Optical_Thickness_38_PCL 
;  Cloud_Effective_Radius_38 Cloud_Effective_Radius_38_PCL 
;  Cloud_Water_Path_38 Cloud_Water_Path_38_PCL Cloud_Phase_Optical_Properties 
;  Cloud_Top_Temperature Cloud_Top_Height Cloud_Top_Pressure 
;  Cloud_Phase_Infrared Aerosol_Base_Altitude Cloud_Top_Altitude
;  -8.125    -6.125     2.586     0.236     4.236     0.607    11.402     1.928  
;  33.866     2.000    -5.391     0.741   930.249     1.000 -9999.000     1.400
;  VARIABLES:
;  ============================================================================
;  (1 ) dir           (a string):DATA DIRECTORY                           [   ]
;  (2 ) filename      (a string):FILE NAME                                [   ]
;  (3 ) nvariable     (integer) :# OF VARIABLES RECORDED IN THE TEXT FILE [   ]
;  (4 ) variable_name (1-D)     :VARIABLE NAMES                           [   ]
;  (5 ) modis_data   (2-D)     :SELECTED MODIS DATA                     [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/01/2015)
;  (2 ) MODIFIED FROM read_ascii_seviri_caliop.ncl BY ADDING THE CAPACITY TO 
;       READ MORE VARIABLES AND TITLE. (BRUCE, 07/02/2015)
;******************************************************************************
undef("read_ascii_modis_caliop")
procedure read_ascii_modis_caliop \
          (filename         :string, nvariable    :integer,    \;INPUT
           variable_name    :string, modis_data   :float)       ;OUTPUT

begin

;  READ THE WHOLE FILE AS STRING
   sdata = asciiread(filename, -1, "string")
   nline = dimsizes(sdata)

;  FIELD DELIMITER
   delimiter = " "

;  READ VARIABLE NAMES FROM TITLE
   name      = sdata(0)
   data      = sdata(1::)
;  READ ALL THE DATA AS IT IS
;  DO LOOP TO READ VARIABLES ONE BY ONE
   do iv = 0, nvariable-1
      variable_name(iv)          = str_get_field(name, iv+1, delimiter)
      modis_data(iv, 0:nline-2) = stringtofloat(str_get_field(data, iv+1, delimiter))
   end do

return
end
