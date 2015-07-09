;  $ID: read_ncep_wind_daily.ncl V01 04/11/2013 10:52 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_ncep_wind_monthly READS NCEP DAILY WIND DATABASE. THE DATA 
;  CAN BE DOWNLOADED FROM :
;  http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/11/2013)
;******************************************************************************
undef("read_ncep_wind_daily")
procedure read_ncep_wind_daily \
          (dir       :string,    ufilename    :string,  \; INPUT
           vfilename :string,                           \; INPUT
           uwind     :float,     vwind        :float)    ; OUTPUT

begin

;  READ NCEP MONTHLY WIND DATA
   uwinda     = addfile(dir + ufilename, "r")
   vwinda     = addfile(dir + vfilename, "r")
   uwind1     = uwinda->uwnd
   uoffset    = uwind1@add_offset
   uscale     = uwind1@scale_factor
   uwind      = (uwind1*uscale) + uoffset
   vwind1     = vwinda->vwnd
   voffset    = vwind1@add_offset
   vscale     = vwind1@scale_factor
   vwind      = (vwind1*uscale) + uoffset
   lat        = uwinda->lat
   lon        = uwinda->lon
;  CONVERT LATITUDE AND LONGITUDE TO 2D
   nlata      = dimsizes(lat)
   nlona      = dimsizes(lon)
   new_lata   = new((/nlata, nlona/), float)
   new_lona   = new((/nlata, nlona/), float)
   do i = 0, nlata-1
    do j = 0, nlona-1
     new_lata(i, j) = lat(i)
     new_lona(i, j) = lon(j)
    end do
   end do
   uwind@lat2d = new_lata
   uwind@lon2d = new_lona
   vwind@lat2d = new_lata
   vwind@lon2d = new_lona
return
end
