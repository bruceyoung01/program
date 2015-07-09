; $ID: point_wrfchem_hourly.ncl V01 06/13/2013 09:25 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE point_wrfchem_hourly SELECTS THE SPECIFIC POINTS FROM WRFCHEM 
;  OUTPUT DEPENDING ON THE SITE LOCATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wdir1     (string)  : WRFCHEM INPUT FILE DIRECTORY               [---]
;  (2 ) wdir2     (string)  : WRFCHEM OUTPUT FILE DIRECTORY              [---]
;  (3 ) sfile1    (string)  : WRFCHEM INPUT FILE NAME                    [---]
;  (4 ) sfile2    (string)  : WRFCHEM OUTPUT FILE NAME                   [---]
;  (5 ) longitude (float)   : SITE LONGITUDE                             [deg]
;  (6 ) latitude  (float)   : SITE LATITUDE                              [deg]
;  (7 ) wyear     (integer) : THE YEAR OF DATA                           [---]
;  (8 ) wmonth    (integer) : THE MONTH OF DATA                          [---]
;  (9 ) wday      (integer) : THE DAY OF DATA                            [---]
;  (10) whour     (integer) : THE HOUR OF DATA                           [---]
;  (11) wrh       (float)   : RELATIVE HUMILITY                          [---]
;  (12) wu        (float)   : WIND SPEED                                 [m/s]
;  (13) wv        (float)   : WIND SPEED                                 [m/s]
;  (14) wpblh     (float)   : PBL HEIGHT                                 [m  ]
;  (15) wpsfc     (float)   : SURFACE PRESSURE                           [pa ]
;  (16) wtau400   (float)   : AOD at 400nm                               [---] 
;  (17) wtau600   (float)   : AOD at 600nm                               [---]
;  (18) wpm25     (float)   : PM2.5                                    [ug/m3]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;  (2 ) MODIFY FOR DAILY AVERAGE BY BRUCE. (02/20/2012)
;  (3 ) ADD TO CALCULATE STANDARD DEVIATION BY BRUCE. (02/21/2012)
;  (4 ) ADD TO CALCULATE MONTHLY AVERAGE BY BRUCE. (03/11/2012)
;  (5 ) MODIFIED FROM point_wrfchem_aeronet_daily.ncl. (06/13/2013)
;  (6 ) ADD tau400/tau600/pm25. (07/18/2013)
;******************************************************************************

undef("point_wrfchem_hourly")
procedure point_wrfchem_hourly \
         (wdir1             :string,  wdir2            :string,  \ ; INPUT
          sfile1            :string,  sfile2           :string,  \ ; INPUT
          latitude          :float,   longitude        :float,   \ ; INPUT
          wyear             :integer, wmonth           :integer, \ ; OUTPUT
          wday              :integer, whour            :integer, \ ; OUTPUT
          wrh               :float,   wu               :float,   \ ; OUTPUT
          wv                :float,   wpblh            :float,   \ ; OUTPUT
          wpsfc             :float,   wtau400          :float,   \ ; OUTPUT
          wtau600           :float,   wpm25            :float)     ; OUTPUT


begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt  = systemfunc("date")

   factor1= 1.8
   factor2= 1.5

;  READ WRFCHEM INPUT (met_em)
   fname1 = asciiread(wdir1 + sfile1, -1, "string")

;  READ WRFCHEM OUTPUT (wrfout)
   fname2 = asciiread(wdir2 + sfile2, -1, "string")
   nfiles = dimsizes(fname1)

;  DO FILE LOOP TO READ FILE NAME
   do ifile = 0, nfiles-1
    a1        = addfile(wdir1 + fname1(ifile) + ".nc", "r")
    a2        = addfile(wdir2 + fname2(ifile) + ".nc", "r")
    wtime      = a2->Times(0,:)
    system("date")
    print("Now Processing : " + wtime)
    wlat       = a2->XLAT(0, :, :)
    wlon       = a2->XLONG(0, :, :)
    rh         = a1->RH(0, 0, :, :)
    u          = a2->U(0, 0, :, :)
    v          = a2->V(0, 0, :, :)
    pblh       = a2->PBLH(0, :, :)
    psfc       = a2->PSFC(0, :, :)
    tau400     = a2->TAUAER2(0, :, :, :)
    tau600     = a2->TAUAER3(0, :, :, :)
    pm25       = a2->PM2_5_DRY(0, 0, :, :)
;  wtime(0) IS # OF WRFCHEM FILES
;  wtime(1) IS # OF TIME STRING
    ncount     = dimsizes(wtime)
    dim        = dimsizes(wlat)
    nlat       = dim(0)
    nlon       = dim(1)

;  EXTRACT YEAR, MONTH, DAY, AND HOUR FROM WRFCHEM FILENAME
;  SELECT WRFCHEM DATA POINT DEPENDING ON AERONET SITES
    wyear(ifile)  = stringtoint(str_get_cols(charactertostring(wtime), 0, 3))
    wmonth(ifile) = stringtoint(str_get_cols(charactertostring(wtime), 5, 6))
    wday(ifile)   = stringtoint(str_get_cols(charactertostring(wtime), 8, 9))
    whour(ifile)  = stringtoint(str_get_cols(charactertostring(wtime), 11, 12))
    if (ifile .eq. 0) then
     do i = 0, nlat-2
      do j = 0, nlon-2
       if (longitude .gt. wlon(i, j)     .and. \
           longitude .lt. wlon(i+1, j+1) .and. \
           latitude  .gt. wlat(i, j)     .and. \
           latitude  .lt. wlat(i+1, j+1)) then
        x = i
        y = j
       end if
      end do ; END OF J LOOP
     end do  ; END OF I LOOP
    end if 
print(x + "===" + y)
     wrh(ifile)     = rh(x, y)
     wu(ifile)      = u(x, y)
     wv(ifile)      = v(x, y)
     wpblh(ifile)   = pblh(x, y)
     wpsfc(ifile)   = psfc(x, y)
     wtau400(ifile) = sum(tau400(:, x, y))*factor1
     wtau600(ifile) = sum(tau600(:, x, y))*factor1
     wpm25(ifile)   = pm25(x, y)*factor2
    end do   ; END OF IFILE LOOP

;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "point_wrfchem_hourly.ncl", 0)

return
end
