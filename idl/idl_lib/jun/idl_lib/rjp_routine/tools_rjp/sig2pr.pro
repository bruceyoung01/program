FUNCTION SIG2PR,CONC,AIRD,PRESS,TEMP,POUT,GAS=GAS,TOUT=TOUT,ADOUT=ADOUT,UNDEF=UNDEF

;+
; NAME:
;   SIG2PRESS
;
; PURPOSE :
;   INTERPOLATE GAS CONCENTRATION FROM SIGMA TO PRESSURE COORDINATE
;
;IF N_ELEMENTS(POUT) EQ 0 THEN POUT = [100.,150.,200.,300.,500.,700.,800.,900.,1000.]
;-

IF N_ELEMENTS(CONC)  EQ 0 THEN RETURN, 0
IF N_ELEMENTS(AIRD)  EQ 0 THEN RETURN, 0
IF N_ELEMENTS(PRESS) EQ 0 THEN RETURN, 0
IF N_ELEMENTS(UNDEF) EQ 0 THEN UNDEF = 'NaN'
IF N_ELEMENTS(GAS)   EQ 0 THEN GAS = ['NO','NO2','HNO3','O3','CO','CH3CO3NO2','ISOP','OH']
IF N_ELEMENTS(POUT)  EQ 0 THEN POUT = [100.,150.,200.,300.,500.,700.,800.,900.,1000.]

 DIM = SIZE(CONC) & NDIM = SIZE(CONC,/N_DIMENSIONS)
 GAS  = STRUPCASE(GAS)
 NZ   = N_ELEMENTS(POUT)
 NC   = N_ELEMENTS(GAS)

 IF NDIM LT 3 THEN BEGIN
  PRINT, 'WRONG NUMBER OF DIMENSION OF CONC', NDIM
  RETURN, 0
 END

 ILMM = DIM(1) & IJMM = DIM(2) & IKMM = DIM(3) & NCON = DIM(4)
 CONCOUT = FLTARR(ILMM,IJMM,NZ,NC)

 DATA = FLTARR(IKMM) & PIN = DATA
 TOUT = FLTARR(ILMM,IJMM,NZ)
 ADOUT = FLTARR(ILMM,IJMM,NZ)
   OH  = FLTARR(ILMM,IJMM,NZ)

 PLOG = ALOG(POUT)
 ISPEC = SPEC(GAS,NCON=NCON)


 FOR IY = 0 , IJMM-1 DO BEGIN
 FOR IX = 0 , ILMM-1 DO BEGIN

   pin(*) = press(ix,iy,*) 
   
  FOR IC = 0 , NC-1   DO BEGIN
  NSPEC = ISPEC(IC)

   DATA(*) = CONC(IX,IY,*,NSPEC) / AIRD(IX,IY,*)
;   concout(ix,iy,*,ic) = hydro_interp(data,pin=pin,pout=pout,/Bdv)
   concout(ix,iy,*,ic) = hydro_interp(data,pin=pin,pout=pout,undef=undef)
  END

   DATA(*) = TEMP(IX,IY,*)

;   tout(ix,iy,*) = hydro_interp(data,pin=pin,pout=pout,/Bdv)
   tout(ix,iy,*) = hydro_interp(data,pin=pin,pout=pout,undef=undef)
   
   DATA(*) = AIRD(IX,IY,*)
;   adout(ix,iy,*) = hydro_interp(data,pin=pin,pout=pout,/Bdv)   
   adout(ix,iy,*) = hydro_interp(data,pin=pin,pout=pout,undef=undef)       

 END
 END
 
 
 RETURN, CONCOUT

 END 
