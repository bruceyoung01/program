;  $ID: read_ncep_wind_monthly.ncl V01 04/11/2013 09:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_ncep_wind_monthly READS NCEP MONTHLY WIND DATABASE. THE DATA 
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
undef("read_ncep_wind_monthly")
procedure read_ncep_wind_monthly \
          (dir       :string,    ufilename    :string,  \; INPUT
           vfilename :string,                           \; INPUT
           year      :integer,   month        :integer, \; INPUT
           uwind     :float,     vwind        :float)    ; OUTPUT

begin

;  NCEP MONTHLY MEANS FROM 1948/01 TO PRESENT(NOW 2012/04)
   start_year = 1948
   start_month= 1
   start_day  = 1
   nhour      = 24

;  READ NCEP MONTHLY WIND DATA
   uwinda     = addfile(dir + ufilename, "r")
   vwinda     = addfile(dir + vfilename, "r")
   uwind1     = uwinda->uwnd
   uoffset    = uwind1@add_offset
   uscale     = uwind1@scale_factor
   uwind2     = (uwind1*uscale) + uoffset
   vwind1     = vwinda->vwnd
   voffset    = vwind1@add_offset
   vscale     = vwind1@scale_factor
   vwind2     = (vwind1*uscale) + uoffset
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
   uwind2@lat2d= new_lata
   uwind2@lon2d= new_lona
   vwind2@lat2d= new_lata
   vwind2@lon2d= new_lona
   time        = uwinda->time
   new_time    = (time-time(0))/nhour + \
                 greg2jul(start_year, start_month, start_day, -1)
   greg_time   = jul2greg(new_time)

   index       = ind(greg_time(:, 0) .eq. year .and. \
                     greg_time(:, 1) .eq. month)
   uwind       = uwind2(index, :, :)
   vwind       = vwind2(index, :, :)
   uwind@lat2d = new_lata
   uwind@lon2d = new_lona
   vwind@lat2d = new_lata
   vwind@lon2d = new_lona
return
end
