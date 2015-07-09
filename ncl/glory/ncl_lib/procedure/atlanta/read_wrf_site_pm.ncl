;  $ID:read_wrf_site_pm.ncl V01 11/08/2012 10:44 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_wrf_site_pm READS WRFCHEM DATA BASED ON THE AVAILABLE 
;  OBSERVATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/08/2012)
;******************************************************************************

undef ("read_wrf_site_pm")
procedure read_wrf_site_pm \
          (dir       :string,       filename   :string,     \ ;INPUT
           site_lat  :float,        site_lon   :float,      \ ;INPUT
           bv1       :integer,      bv2        :float,      \ ;INPUT
           start_jd  :integer,      end_jd     :integer,    \ ;INPUT
           start_hour:integer,      end_hour   :integer,    \ ;INPUT
           wdate     :integer,      wpm        :float)        ;OUTPUT

begin
;  READ WRFCHEM OUTPUT
   files = systemfunc("ls " + dir + filename)
   a     = addfiles(files + ".nc", "r")
   ndimf = dimsizes(files)
   nfiles= ndimf(0)
   delete(files)
   ListSetType(a, "join")

   wtime      = a[:]->Times(:,0,:)
   pm25       = a[:]->PM2_5_DRY(:, 0, 0, :, :)
   pm10       = a[:]->PM10(:, 0, 0, :, :)
   pm25@lat2d = a[:]->XLAT(:, 0, :, :)
   pm25@lon2d = a[:]->XLONG(:, 0, :, :)
   wlat       = a[0]->XLAT(0, 0, :, :)
   wlon       = a[0]->XLONG(0, 0, :, :)
   ndim       = dimsizes(wlat)
   nlat       = ndim(0)
   nlon       = ndim(1)
   wyear      = new((/nfiles/), integer)
   wmonth     = new((/nfiles/), integer)
   wday       = new((/nfiles/), integer)
   whour      = new((/nfiles/), integer)

   do i = 0, nfiles-1
    wyear(i)  = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 0, 3))
    wmonth(i) = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 5, 6))
    wday(i)   = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 8, 9))
    whour(i)  = stringtoint(str_get_cols(charactertostring(wtime(i, :)), 11, 12))
   end do

;  DO THE LOOP TO SELECT THE GRID BOX WHICH INCLUDES SITE LOCATION
      do ilat = 0, nlat-2
       do ilon = 0, nlon-2
        if (site_lat .ge. wlat(ilat, ilon)   .and. \
            site_lat .le. wlat(ilat+1, ilon) .and. \
            site_lon .ge. wlon(ilat, ilon)   .and. \
            site_lon .le. wlon(ilat, ilon+1)) then
         islat = ilat
         islon = ilon
        end if
       end do ; END OF ilon
      end do ; END OF ilat

;  REARRANGE THE DATE AND DATA INTO REGULAR DATE ORDER
   icount = 0
   do ijd = start_jd, end_jd
    greg_date = jul2greg(ijd)
    iyear     = greg_date(0)
    imonth    = greg_date(1)
    iday      = greg_date(2)
    do ihour = start_hour, end_hour
     index = ind(wyear  .eq. iyear  .and. \
                 wmonth .eq. imonth .and. \
                 wday   .eq. iday   .and. \
                 whour  .eq. ihour)
     if (.not.all(ismissing(index))) then
      wdate(icount, 0) = iyear
      wdate(icount, 1) = imonth
      wdate(icount, 2) = iday
      wdate(icount, 3) = ihour
      wpm(icount, 0)   = pm10(index, islat, islon)
      wpm(icount, 1)   = pm25(index, islat, islon)
     end if
     icount = icount + 1
    end do ; END OF ihour
   end do ; END OF ijd

return
end
