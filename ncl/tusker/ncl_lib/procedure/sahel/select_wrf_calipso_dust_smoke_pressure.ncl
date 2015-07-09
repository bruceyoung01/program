; $ID: select_wrf_calipso_dust_smoke_pressure.ncl V01 02/03/2012 16:30 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_wrf_calipso_dust_smoke_pressure SELECTS WRF VERTICAL DATA 
;  DEPENDING ON CALIPSO TRACK PATH.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dirn    (string) : DIRECTORY OF WRFCHEM DATA FILE               [---]
;  (2 ) namen   (string) : WRFCHEM DATA FILE NAMES                      [---]
;  (3 ) dateh   (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                          i.e. 2008-02-26)                             [---]
;  (4 ) timeh   (string) : CALIPSO TIME (FORMAT : TIME, 01)             [---]
;  (5 ) daten   (string) : WRFCHEM FILE DATE (FORMAT : YEAR-MONTH-DAY, 
;                          i.e. 2008-02-26)                             [---]
;  (6 ) timen   (string) : WRFCHEM FILE TIME (FORMAT : TIME, 01)        [---]
;  (7 ) height  (float)  : HEIGHT ARRAY FROM 0-15km WITH NEW # OF LEVELS[km ]
;  (8 ) bv2     (float)  : MISSING VALUE FOR FLOAT                      [---]
;  (9 ) kmtom   (float)  : CONVERT km TO m(1000.)                       [---]
;  (10) inth    (integer): # OF VERTICAL LELVELS                        [---]
;  (11) sstart  (integer): START GRID INDEX OF CALIPSO DATA             [---]
;  (12) send    (integer): END GRID INDEX OF CALIPSO DATA               [---]
;  (13) lathh   (float)  : CALIPSO LATITUDE DATA(1-D)                   [deg]
;  (14) lonhh   (float)  : CALIPSO LONGITUDE DATA(1-D)                  [deg]
;  (15) aspm25h1(float)  : SELECTED WRFCHEM PM2.5 DATA                  [um/m3]
;  (16) aspth1  (float)  : SELECTED WRFCHEM TEMPERATURE                 [C  ]
;  (17) aspblh1 (float)  : SELECTED WRFCHEM PLANET BOUNDARY LAYER HEIGHT[m  ]
;  (18) slatn   (float)  : SELECTED WRFCHEM LATITUDE DATA               [deg]
;  (19) aslonn1 (float)  : SELECTED WRFCHEM LONGITUDE DATA              [deg]
;  (20) in      (integer): TOTAL # OF SELECTED WRFCHEM GRIDS            [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/03/2012)
;******************************************************************************

undef("select_wrf_calipso_dust_smoke_pressure")
procedure select_wrf_calipso_dust_smoke_pressure \
         (dirn1    :string,                  \ ; INPUT
          dirn     :string, namen   :string, \ ; INPUT
          dateh    :string, timeh   :string, \ ; INPUT
          daten    :string, timen   :string, \ ; INPUT
          pressure :float,  bv2     :float,  \ ; INPUT
          intpres  :integer,sn      :integer,\ ; INPUT
          sstart   :integer,send    :integer,\ ; INPUT
          lathh    :float,  lonhh   :float,  \ ; INPUT
          adust    :float,                   \ ; OUTPUT
          aspm25h1 :float,  aspth1  :float,  \ ; OUTPUT
          aspblh1  :float,                   \ ; OUTPUT
          asvh1    :float,  aswh1   :float,  \ ; OUTPUT
          slatn    :float,  aslonn1 :float,  \ ; OUTPUT
          in       :integer ) ; OUTPUT

begin

;  READ WRFCHEM DATA 1
   index       = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn1         = addfile(dirn1 + namen(index) + ".nc", "r")
   fn          = addfile(dirn  + namen(index) + ".nc", "r")
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   dust1       = getvar(fn1, "DUST_1", 0)
   dust2       = getvar(fn1, "DUST_2", 0)
   dust3       = getvar(fn1, "DUST_3", 0)
   dust4       = getvar(fn1, "DUST_4", 0)
   dust5       = getvar(fn1, "DUST_5", 0)
   dustn       = getvar(fn1, "DUST_1", 0)
   aird        = getvar(fn,  "ALT",    0)
   dustn       = (dust1 + dust2 + dust3 + dust4 + dust5)*aird
   pm25n       = getvar(fn, "PM2_5_DRY", 0) 
   pblhn       = getvar(fn, "PBLH", 0)
   ptn         = getvar(fn, "T", 0)
   tcn         = getvar(fn, "tc", 0)
   un          = getvar(fn, "U", 0)
   vn          = getvar(fn, "V", 0)
   wn          = getvar(fn, "W", 0)
   latn        = getvar(fn, "XLAT", 0)
   lonn        = getvar(fn, "XLONG", 0)
   pb          = getvar(fn, "PB", 0)
   pm25n@lat2d = latn
   pm25n@lon2d = lonn
   dimpm25n    = dimsizes(pm25n)
   pblhn@lat2d = latn
   pblhn@lon2d = lonn
   nleveln     = dimpm25n(0)
   nlatn       = dimpm25n(1)
   nlonn       = dimpm25n(2)

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
   dusth       = new((/intpres, nlatn, nlonn/), float, bv2)
   pm25h       = new((/intpres, nlatn, nlonn/), float, bv2)
   pth         = new((/intpres, nlatn, nlonn/), float, bv2)
   uh          = new((/intpres, nlatn, nlonn/), float, bv2)
   vh          = new((/intpres, nlatn, nlonn/), float, bv2)
   wh          = new((/intpres, nlatn, nlonn/), float, bv2)

;  DEFINE NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sdusth      = new((/intpres, sn/),float, bv2)
   sdusth1     = new((/intpres, sn/),float, bv2)
   spm25h      = new((/intpres, sn/),float, bv2)
   spm25h1     = new((/intpres, sn/),float, bv2)
   spth        = new((/intpres, sn/),float, bv2)
   spth1       = new((/intpres, sn/),float, bv2)
   suh         = new((/intpres, sn/),float, bv2)
   suh1        = new((/intpres, sn/),float, bv2)
   svh         = new((/intpres, sn/),float, bv2)
   svh1        = new((/intpres, sn/),float, bv2)
   swh         = new((/intpres, sn/),float, bv2)
   swh1        = new((/intpres, sn/),float, bv2)
   spblh       = new((/sn/),float, bv2)
   spblh1      = new((/sn/),float, bv2)
   slonn       = new((/sn/),float, bv2)
   slonn1      = new((/sn/),float, bv2)

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ip = 0, intpres-1
    dusth(ip,:,:)  = wrf_user_intrp3d(dustn,                 pb, "h", pressure(ip), 0., False)
    pm25h(ip,:,:)  = wrf_user_intrp3d(pm25n,                 pb, "h", pressure(ip), 0., False)
    pth(ip,:,:)    = wrf_user_intrp3d(ptn,                   pb, "h", pressure(ip), 0., False)
    uh(ip,:,:)     = wrf_user_intrp3d(un(:, :, 0:nlonn-1),   pb, "h", pressure(ip), 0., False)
    vh(ip,:,:)     = wrf_user_intrp3d(vn(:, 0:nlatn-1, :),   pb, "h", pressure(ip), 0., False)
    wh(ip,:,:)     = wrf_user_intrp3d(wn(0:nleveln-1, :, :), pb, "h", pressure(ip), 0., False)
   end do

;  CONVERT latn AND lonn TO 1-D ARRAY FOR CALIPSO SELECTION
   in        = 0
;  DO LATITUDE AND LONGITUDE LOOP OF CALIPSO
   do ilatn = nlatn-2, 0, 1
    do ilonn = nlonn-2, 0, 1
     index1 = ind(lathh .ge. latn(ilatn,   ilonn)   .and. \
                  lathh .le. latn(ilatn+1, ilonn+1) .and. \
                  lonhh .ge. lonn(ilatn,   ilonn)   .and. \
                  lonhh .le. lonn(ilatn+1, ilonn+1))
     if (.not.all(ismissing(index1))) then
      sdusth(:,in)   = dusth(:,ilatn,ilonn)
      sdusth1(:,in)  = dusth(:,ilatn,ilonn+1)
      adust(:,in)    = (sdusth(:,in)+sdusth1(:,in))/2.
      spm25h(:,in)   = pm25h(:,ilatn,ilonn)
      spm25h1(:,in)  = pm25h(:,ilatn,ilonn+1)
      aspm25h1(:,in) = (spm25h(:,in)+spm25h1(:,in))/2.
      spth(:,in)     = pth(:,ilatn,ilonn)
      spth1(:,in)    = pth(:,ilatn,ilonn+1)
      aspth1(:,in)   = (spth(:,in)+spth1(:,in))/2.
      suh(:,in)      = uh(:,ilatn,ilonn)
      suh1(:,in)     = uh(:,ilatn,ilonn+1)
;     asuh1(:,in)    = (suh(:,in)+suh1(:,in))/2.
      svh(:,in)      = vh(:,ilatn,ilonn)
      svh1(:,in)     = vh(:,ilatn,ilonn+1)
      asvh1(:,in)    = (svh(:,in)+svh1(:,in))/2.
      swh(:,in)      = wh(:,ilatn,ilonn)
      swh1(:,in)     = wh(:,ilatn,ilonn+1)
      aswh1(:,in)    = (swh(:,in)+swh1(:,in))/2.
      spblh(in)      = pblhn(ilatn,ilonn)
      spblh1(in)     = pblhn(ilatn,ilonn+1)
      aspblh1(in)    = (spblh(in)+spblh1(in))/2.
      slatn(in)      = latn(ilatn,ilonn)
      slonn(in)      = lonn(ilatn,ilonn)
      slonn1(in)     = lonn(ilatn,ilonn+1)
      aslonn1(in)    = (slonn(in)+slonn1(in))/2.
      in             = in+1
     end if
     delete([/index1/])
    end do ; ilonn
   end do ; ilatn

   print("THE NUMBER OF SELECTED WRF-CHEM GRID : "+in)
   sspm25h = new((/inth, in-1/),float, bv2)
   sspth   = new((/inth, in-1/),float, bv2)
   ssuh    = new((/inth, in-1/),float, bv2)
   ssvh    = new((/inth, in-1/),float, bv2)
   sspblh  = new((/in-1/),float, bv2)
   sspm25h = aspm25h1(:,0:in-2)
   sspth   = aspth1(:,0:in-2)
;  ssuh    = asuh1(:,0:in-2)
   ssvh    = asvh1(:,0:in-2)
   sswh    = aswh1(:,0:in-2)
   sspblh  = aspblh1(0:in-2)

return
end
