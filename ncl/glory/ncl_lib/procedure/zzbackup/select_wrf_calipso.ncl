; $ID: select_wrf_calipso.ncl V01 02/03/2012 16:30 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_wrf_calipso IS USED TO SELECT WRF VERTICAL DATA  DEPENDING 
;  ON CALIPSO TRACK PATH.
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
;  (8 ) bv1     (float)  : MISSING VALUE FOR FLOAT                      [---]
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

undef("select_wrf_calipso")
procedure select_wrf_calipso( \
          dirn     :string, namen   :string, \ ; INPUT
          dateh    :string, timeh   :string, \ ; INPUT
          daten    :string, timen   :string, \ ; INPUT
          heiht    :float,  bv1     :float,  \ ; INPUT
          kmtom    :float,  inth    :integer,\ ; INPUT
          height   :float,                   \ ; INPUT
          sstart   :integer,send    :integer,\ ; INPUT
          lathh    :float,  lonhh   :float,  \ ; INPUT
          aspm25h1 :float,  aspth1  :float,  \ ; OUTPUT
          aspblh1  :float,  slatn   :float,  \ ; OUTPUT
          aslonn1  :float,  in      :integer ) ; OUTPUT

begin

;  READ WRFCHEM DATA 1
   index       = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn          = addfile(dirn+namen(index)+".nc", "r")
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   pm25n       = getvar(fn, "PM2_5_DRY", 0) 
   pblhn       = getvar(fn, "PBLH", 0)
   ptn         = getvar(fn, "T", 0)
   tcn         = getvar(fn, "tc", 0)
   latn        = getvar(fn, "XLAT", 0)
   lonn        = getvar(fn, "XLONG", 0)
   zn          = getvar(fn, "z", 0)
   pm25n@lat2d = latn
   pm25n@lon2d = lonn
   dimpm25n    = dimsizes(pm25n)
   pblhn@lat2d = latn
   pblhn@lon2d = lonn
   nleveln     = dimpm25n(0)
   nlatn       = dimpm25n(1)
   nlonn       = dimpm25n(2)

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
   pm25h       = new((/inth, nlatn,nlonn/),float, bv1)
   pth         = new((/inth, nlatn,nlonn/),float, bv1)

;  DEFINE NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sn          = 150 ; # OF SELECTED GRIDS
   spm25h      = new((/inth, sn/),float, bv1)
   spm25h1     = new((/inth, sn/),float, bv1)
   spth        = new((/inth, sn/),float, bv1)
   spth1       = new((/inth, sn/),float, bv1)
   spblh       = new((/sn/),float, bv1)
   spblh1      = new((/sn/),float, bv1)
   slonn       = new((/sn/),float, bv1)
   slonn1      = new((/sn/),float, bv1)

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ih = 0, inth-1
    pm25h(ih,:,:)  = wrf_user_intrp3d(pm25n, zn, "h", height(ih)*kmtom, 0., False)
    pth(ih,:,:)    = wrf_user_intrp3d(ptn, zn, "h", height(ih)*kmtom, 0., False)
   end do

   in = 0
;  DO LATITUDE AND LONGITUDE LOOP OF WRFCHEM
   do ilatn = nlatn-2, 0, 1
    do ilonn = nlonn-2, 0, 1
;  DO LATITUDE AND LONGITUDE LOOP OF CALIPSO
     k = 0
     do ilath = sstart, send
      if (lathh(ilath) .ge. latn(ilatn,ilonn)     .and. \
          lathh(ilath) .le. latn(ilatn+1,ilonn+1) .and. \
          lonhh(ilath) .ge. lonn(ilatn,ilonn)     .and. \
          lonhh(ilath) .le. lonn(ilatn+1,ilonn+1) .and. \
          k .eq. 0)then
       spm25h(:,in)   = pm25h(:,ilatn,ilonn)
       spm25h1(:,in)  = pm25h(:,ilatn,ilonn+1)
       aspm25h1(:,in) = (spm25h(:,in)+spm25h1(:,in))/2.
       spth(:,in)     = pth(:,ilatn,ilonn)
       spth1(:,in)    = pth(:,ilatn,ilonn+1)
       aspth1(:,in)   = (spth(:,in)+spth1(:,in))/2.
       spblh(in)      = pblhn(ilatn,ilonn)
       spblh1(in)     = pblhn(ilatn,ilonn+1)
       aspblh1(in)    = (spblh(in)+spblh1(in))/2.
       slatn(in)      = latn(ilatn,ilonn)
       slonn(in)      = lonn(ilatn,ilonn)
       slonn1(in)     = lonn(ilatn,ilonn+1)
       aslonn1(in)    = (slonn(in)+slonn1(in))/2.
       in             = in+1
       k              = k+1
      end if
     end do ; ilath
    end do ; ilonn
   end do ; ilatn
   print("THE NUMBER OF SELECTED POINTS : "+in)
   sspm25h = new((/inth, in-1/),float, bv1)
   sspth   = new((/inth, in-1/),float, bv1)
   sspblh  = new((/in-1/),float, bv1)
   sspm25h = aspm25h1(:,0:in-2)
   sspth   = aspth1(:,0:in-2)
   sspblh  = aspblh1(0:in-2)

return
end
