;  $ID: read_ascii_modis_seviri.ncl V01 07/21/2015 20:55 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_ascii_modis_seviri.ncl READS OUTPUT ASCII FILE OF MODIS AND 
;  SEVIRI. THE FILE FORMAT IS LIKE:
;  Latitude Longitude Above_Cloud_Water_Vapor_094 Cloud_Optical_Thickness_37 
;  Cloud_Effective_Radius_37 Cloud_Water_Path_37 cloud_top_pressure_1km 
;  cloud_top_height_1km cloud_top_temperature_1km Above_Cloud_Water_Vapor 
;  Cloud_Optical_Thickness_38 Cloud_Effective_Radius_38 Cloud_Water_Path_38 
;  Cloud_Top_Pressure Cloud_Top_Height Cloud_Top_Temperature
;  -30.125     16.125      0.549     13.394     24.587    214.375    621.781   
;  3972.674    -36.658      0.402      0.747      4.860      9.122    778.362   
;  2199.289    -27.009
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir           (a string):DATA DIRECTORY                           [   ]
;  (2 ) filename      (a string):FILE NAME                                [   ]
;  (3 ) nvariable     (integer) :# OF VARIABLES RECORDED IN THE TEXT FILE [   ]
;  (4 ) variable_name (1-D)     :VARIABLE NAMES                           [   ]
;  (5 ) modis_seviri  (2-D)     :SELECTED MODIS AND SEVIRI DATA           [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/21/2015)
;******************************************************************************
undef("read_ascii_modis_seviri")
procedure read_ascii_modis_seviri \
          (dir              :string,  filename      :string, \;INPUT
           nvariable        :integer,                        \;INPUT
           variable_name    :string,  modis_seviri  :float)   ;OUTPUT

begin

;  READ THE WHOLE FILE AS STRING
   sdata = asciiread(dir + filename, -1, "string")
   nline = dimsizes(sdata)

;  FIELD DELIMITER
   delimiter = " "

;  READ VARIABLE NAMES FROM TITLE
   name      = sdata(0)
   data      = sdata(1::)
;  READ ALL THE DATA AS IT IS
;  DO LOOP TO READ VARIABLES ONE BY ONE
   do iv = 0, nvariable-1
      variable_name(iv)           = str_get_field(name, iv+1, delimiter)
      modis_seviri(iv, 0:nline-2) = stringtofloat(str_get_field(data, iv+1, delimiter))
   end do

return
end
