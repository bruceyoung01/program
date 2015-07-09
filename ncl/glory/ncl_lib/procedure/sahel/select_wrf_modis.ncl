; $ID: select_wrf_modis.ncl V01 08/13/2012 09:04 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_wrf_modis SELECTS WRF-CHEM DATA DEPENDING ON MODIS DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/13/2012)
;******************************************************************************

undef("select_wrf_modis")
procedure select_wrf_modis \
          (iday       :integer,    year      :integer, \ ; INPUT
           mon        :integer,    date      :integer, \ ; INPUT
           times      :string,     timee     :string,  \ ; INPUT
           wfilename  :string,                         \ ; INPUT
           wstartinx  :integer,    wendinx   :integer)   ; OUTPUT


begin
;  GET YEAR, MONTH, DAY, START TIME AND END TIME FOR SELECT DAY FROM MODIS
   smyear  = year(iday)
   smmon   = mon(iday)
   smdate  = date(iday)
   smtimes = str_get_cols(times(iday), 0, 1)
   smtimee = str_get_cols(timee(iday), 0, 1)

;  GET TOTAL # OF WRF-CHEM FILE NAME
   nwfilename = dimsizes(wfilename)
   wyear      = stringtoint(str_get_cols(wfilename, 11, 14))
   wmon       = stringtoint(str_get_cols(wfilename, 16, 17))
   wdate      = stringtoint(str_get_cols(wfilename, 19, 20))
   wtime      = str_get_cols(wfilename, 22, 23)
   wstartinx  = ind(wyear .eq. smyear .and. \
                    wmon  .eq. smmon  .and. \
                    wdate .eq. smdate .and. \
                    wtime .eq. smtimes)
   wendinx    = ind(wyear .eq. smyear .and. \
                    wmon  .eq. smmon  .and. \
                    wdate .eq. smdate .and. \
                    wtime .eq. smtimee)
   if (.not. all(ismissing(wstartinx)) .and. \
       .not. all(ismissing(wendinx))) then
    continue
   else
    exit
   end if

return
end
