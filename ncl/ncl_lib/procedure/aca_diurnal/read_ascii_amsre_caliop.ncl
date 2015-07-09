;  $ID: read_ascii_amsre_caliop.ncl V01 06/23/2015 15:01 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_ascii_amsre_caliop READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_amsre_sum_aca.ncl. THE FILE FORMAT IS LIKE:
;     -89.125     0.875   100.000     0.000     1.175     2.007
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (a string):DATA DIRECTORY                               [   ]
;  (2 ) filename  (a string):FILE NAME                                    [   ]
;  (3 ) lat       (1-D)     :SELECTED AMSR-E LATITUDE                     [DEG]
;  (4 ) lon       (1-D)     :SELECTED AMSR-E LONGITUDE                    [DEG]
;  (5 ) lwp       (1-D)     :SELECTED AMSR-E LIQUID WATER PATH          [g/m^2]
;  (6 ) rr        (1-D)     :SELECTED AMSR-E RAIN RATE                    [mm ]
;  (7 ) aba       (1-D)     :SELECTED CALIOP AEROSOL BASE ALTITUDE        [km ]
;  (8 ) cta       (1-D)     :SELECTED CALIOP CLOUD TOP ALTITUDE           [km ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/23/2015)
;******************************************************************************
undef("read_ascii_amsre_caliop")
procedure read_ascii_amsre_caliop \
          (dir              :string, filename      :string,     \;INPUT
           lat              :float,  lon           :float,      \;OUTPUT
           lwp              :float,  rr            :float,      \;OUTPUT
           aba              :float,  cta           :float)       ;OUTPUT

begin

;  READ THE WHOLE FILE AS STRING
   sdata = asciiread(dir + filename, -1, "string")
   nline = dimsizes(sdata)
   nfield= 6

;  FIELD DELIMITER
   delimiter = " "

;  READ ALL THE DATA AS IT IS
   lat(0:nline-1) = stringtofloat(str_get_field(sdata, 1, delimiter))
   lon(0:nline-1) = stringtofloat(str_get_field(sdata, 2, delimiter))
   lwp(0:nline-1) = stringtofloat(str_get_field(sdata, 3, delimiter))
   rr(0:nline-1)  = stringtofloat(str_get_field(sdata, 4, delimiter))
   aba(0:nline-1) = stringtofloat(str_get_field(sdata, 5, delimiter))
   cta(0:nline-1) = stringtofloat(str_get_field(sdata, 6, delimiter))

return
end
