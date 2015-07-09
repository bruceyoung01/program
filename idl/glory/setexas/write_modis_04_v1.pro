@/home/bruce/program/idl/arslab4/sub_read_mod04.pro
@/home/bruce/program/idl/arslab4/plot_emission_subroutine.pro
@/home/bruce/program/idl/arslab4/sub_LST_grid.pro
@/home/bruce/program/idl/arslab4/process_day_aod.pro


; purpose of this program : change the MODIS Land Surface Temperature Product spatial resolution.
  
  filedir     = '/mnt/sdc/data/modis/setexas/2009/2009terra/'
  filedirres  = '/mnt/sdc/data/modis/setexas/results/2010/'
  filelist    = '2009taodlist'

  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

  n = n_elements(Allfilename)
  FOR i = 0L, n-1 DO BEGIN
    OPENW, lun, filedirres + Allfilename(i) + '.txt', /get_lun
    sub_read_mod04, filedir, Allfilename(i), rlat, rlon, raod, np, nl
    PRINT, 'OPEN HDF FILE : ', Allfilename(i)
    FOR k = 0, np-1 DO BEGIN
      FOR j = 0, nl-1 DO BEGIN
        PRINTF, lun, rlat(k,j), rlon(k,j), raod(k,j), FORMAT = '(f10.5, f12.5, f15.5)'
      ENDFOR
    ENDFOR
  FREE_LUN, lun
  ENDFOR
END
