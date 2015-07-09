function solarzen,year,month,day,hour,min,sec,ilmm=ilmm,ijmm=ijmm
;
; This routine is to calculate solar zenith angle for entire globe 
; So I assume that the time would be the GMT which is local time 
; at 0 degree in longitude.
;
 
if n_elements(ilmm) eq 0 then ilmm=72
if n_elements(ijmm) eq 0 then ijmm=46
if n_elements(min)  eq 0 then min = 0.
if n_elements(sec)  eq 0 then sec = 0.
if n_elements(hour) eq 0 then return, 0
if n_elements(day)  eq 0 then return, 0

nloop = ilmm*ijmm

; variable definition

 xlat     = fltarr(ilmm,ijmm)
 xlon     = xlat
 sinxlat  = xlat
 cosxlat  = xlat
 zenrat   = xlat
 zenangle = xlat
 tzdif    = xlat
 dmeridut = xlat
 xlonut   = xlat
 ldmonth  = fltarr(12)


 onepi = 3.1415926536
 SCDAY = 86400.0

 SWLONDC  = -180.0     
 SWLATDC  = -90.0
 DXLONG = 360./ilmm 
 DYLAT =  180./(ijmm-1)

 TWOPI	  = 2.	* ONEPI
 PID2 	  = ONEPI	/ 2.
 THRPI2	  = ONEPI	+ PID2
 PID180	  = ONEPI	/ 180.
 HALF 	  = 0.5
 HALFDAY	  = HALF	* SCDAY

 TWPISC	  = TWOPI / SCDAY
 SCTWOPI	  = SCDAY / TWOPI
 SMAL1	  = 1.0E-06

 DYRAD	  = DYLAT	* PID180 
 DXRAD	  = DXLONG  * PID180 
 XLATRCEN	  = SWLATDC * PID180
 XLONRCEN	  = SWLONDC * PID180


 for m1 = 0, ijmm-1 do begin
 for m2 = 0, ilmm-1 do begin
  xlat(m2,m1) = xlatrcen+dyrad*float(m1)
  xlon(m2,m1) = xlonrcen+dxrad*float(m2)
 end
 end

;
; *********************************************************************
; ***    CALCULATE DAY OF THE YEAR BASED ON THE INPUT DAY, MONTH,   *** 
; ***      AND YEAR OF THE RUN. LEAP YEARS ARE ACCOUNTED FOR.       ***  
; *********************************************************************
; DTSART      = LOCAL HOUR ANGLE IN UNIVERSAL TIME SECONDS  
; SCTWOP      = SCDAY / TWOPI
; SIN,COSXLAT = CONSTANTS USED IN ZENITH ANGLE EQUATION (RADTRAN.F)
; SIDTOUT     = CONVERTS SIDEREAL TIME (SEC) TO UNIVERSAL TIME (SEC)
; XU0         = LOCAL HOUR ANGLE (UNIVERSAL TIME RADIANS) OF MODEL RUN.
;               AT SOLAR NOON, THE HOUR ANGLE, XU0 = -XLON. THUS, AT
;               GREENWICH, XU0 = 0 AT NOON.
; IDAYR       = DAY OF RUN, STARTING WITH 1
; IHOUR       = INIT STANDARD TIME HOUR OF MODEL RUN (IHOUR = 0 = MIDNIGHT; 
;               23 = 11 P.M.)
; UTSEC       = CONVERTS SIDEREAL TIME (RADIANS) TO UNIVERSAL TIME (SEC)
;
;
; *********************************************************************
; * DETERMINE # DAYS IN EACH MONTH AND WHETHER THIS IS A LEAP YEAR    *
; *********************************************************************

 LEAP         = 0.
 IF ( (YEAR MOD 4.) EQ 0) then LEAP = 1.

 for  K  = 0, 11 do begin
   LDMONTH(K) = 31.
   IF (K EQ 4 OR K EQ 6 OR K EQ 9 OR K EQ 11) then LDMONTH(K) = 30.
 end
  LDMONTH(1)   = 28. + LEAP

 RSCALE	 = 1. / 1.0137
 SIDTOUT	 = 0.997269566 
 UTSEC	 = SIDTOUT * SCTWOPI
 UTSECY	 = UTSEC / RSCALE

 TMIDPST     = (HOUR * 3600. + MIN * 60. + SEC) MOD SCDAY

 GDAY0       = FLOAT(DAY)
 for  K  = 0, MONTH - 2 do begin
   GDAY0 = GDAY0 + LDMONTH(K)
 end

 IDAYR       = 1
 GDAY        = FLOAT(DAY)
 for K  = 0, MONTH - 2 do begin
   GDAY = GDAY + LDMONTH(K)
 end

;
; *********************************************************************
; **  TRACK THE SUN. FORMULAS COME FROM THE "ASTRONOMICAL ALMANAC,"  **
; **       (1990), US GOVERNMENT PRINTING OFFICE, WASHINGTON         **
; *********************************************************************
;
; GMSTUT0  = GREENWICH MEAN SIDEREAL TIME AT 0h UNIVERSAL TIME;
; ANOMEAN  = MEAN ANOMALY;
; SUNLONG  = MEAN LONGITUDE OF THE SUN;
; OBLIQ    = OBLIQUITY OF THE ECLIPTIC;
; ECLIPLON = ECLIPTIC LONGITUDE.
; RASCEN   = RIGHT ASCENSION OF THE SUN.
; DECLIN   = DECLINATION OF THE SUN
; DIFJUL   = NUMBER OF DAYS FROM THE BEGINNING OF JULIAN YEAR 2000
; RAGSUT   = RIGHT ASCENSION - GMST0, ALL IN UNIVERSAL TIME SECONDS
; SIDTOUT  = CONVERTS SIDEREAL TIME TO UNIVERSAL (SOLAR = REAL) TIME

 DAYJ        = GDAY
 JYEAR       = YEAR
 
 IF (JYEAR LT 1989L) then DIFJUL = -4384.5 - (1988 -JYEAR)* 365.+ DAYJ 
 IF (JYEAR GE 1989L) then DIFJUL = -4018.5 + (JYEAR-1989) * 365.+ DAYJ  
 IF (JYEAR GE 1993L) then DIFJUL = -2557.5 - (JYEAR-1993) * 365.+ DAYJ 
 IF (JYEAR GE 1997L) then DIFJUL = -1096.5 - (JYEAR-1997) * 365.+ DAYJ 
 IF (JYEAR GE 2001L) then DIFJUL =   364.5 - (JYEAR-2001) * 365.+ DAYJ 

 TUJUL      = DIFJUL / 36525.
 GMSTUT0    = 24110.54841 + TUJUL * (8640184.812866 + $
                            TUJUL * (0.093104       + $
                            TUJUL * (6.2E-06))) 
 IADDAYS    = FIX(1 - GMSTUT0 / SCDAY)
 GMSTUT0    = (GMSTUT0 + SCDAY * IADDAYS) * TWPISC
 IF (GMSTUT0 GT THRPI2) then GMSTUT0 = GMSTUT0 - ONEPI
 IF (GMSTUT0 LT PID2)   then GMSTUT0 = GMSTUT0 + ONEPI

 ANOMEAN  = (357.528 + 0.9856003 * DIFJUL) * PID180 
 SUNLONG  = (280.460 + 0.9856474 * DIFJUL) * PID180 
 OBLIQ    = (23.439  - 0.0000004 * DIFJUL) * PID180 
 ECLIPLON = SUNLONG  + PID180 * (1.915 * SIN(ANOMEAN) + 0.020  $
          * SIN(ANOMEAN+ANOMEAN)) 
 RASCEN  = 1.0013 * (ATAN(COS(OBLIQ) * TAN(ECLIPLON)) + TWOPI) 
 DECLIN  = ASIN(SIN(OBLIQ) * SIN(ECLIPLON))
 RAGSUT  = (RASCEN - GMSTUT0) * UTSEC 
 SINDEC  = SIN(DECLIN)
 COSDEC  = COS(DECLIN)

;
; *********************************************************************
; *                   CONSTANTS FOR ZENITH ANGLE                      *
; *********************************************************************
; TZSEC       = LONGITUDINAL DISTANCE BETWEEN GREENWICH AND BEGINNING
;               OF THE MODEL TIME ZONE 
; SWLONDC = LONGITUDE OF CENTER OF WESTERNMOST GRID CELL (DEGREES)
; XLON    = LONGITUDE AT CENTER OF A GRID CELL (RADIANS)
; ITZONE  = -5 IF SWLONDC=-90; = 0 IF SWLONDC=0: = +5 IF SWLONDC=+90
;
 IF (SWLONDC GE 0.) THEN begin
  ITZONE	     = fix((SWLONDC - 0.001) / 15.)
 endif ELSE begin
  ITZONE	     = FIX((SWLONDC + 0.001) / 15. - 1)
 ENDelse

 TZSECORIG       = ITZONE * 3600.  
 RLATLIM		= 89.9999 * PID180

 for m1 = 0, ijmm-1 do begin
 for m2 = 0, ilmm-1 do begin
  XLATEFF         = XLAT(m2,m1) < RLATLIM
  XLATEFF		= XLATEFF > (-1.*RLATLIM)
  SINXLAT(m2,m1)  = SIN(XLATEFF)	  
  COSXLAT(m2,m1)  = COS(XLATEFF)	  

  IF (XLON(m2,m1) GE 0.) THEN begin
   ITZONE		= (XLON(m2,m1)/PID180 - 0.0001) / 15. 
  endif ELSE begin
   ITZONE		= (XLON(m2,m1)/PID180 + 0.0001) / 15. - 1
  ENDelse

  TZSEC		= ITZONE	   * 3600  
  TZDIF(m2,m1)	= TZSEC	   - TZSECORIG 
  DMERIDUT(m2,m1) = TZSEC	   - XLON(m2,m1) * SCTWOPI
  XLONUT(m2,m1)	= XLON(m2,m1)  * RSCALE    
 end
 end

 DSTART		= (-1.*RAGSUT) + TMIDPST - TZSECORIG
 XU0  		=  DSTART	 * TWPISC  * RSCALE 

 for m1 = 0, ijmm-1 do begin
 for m2 = 0, ilmm-1 do begin
   S1CON		= SINXLAT(m2,m1) * SINDEC
   S2CON		= COSXLAT(m2,m1) * COSDEC
   ZENITH		= S1CON + S2CON  * COS(XU0 + XLONUT(m2,m1))
   ZENRAT(m2,m1)  = ZENITH > 0.
   ZENANGLE(m2,m1)= ACOS(ZENITH)/PID180
;   if(ZENANGLE(m2,m1) ge 90.) then ZENANGLE(m2,m1) = 0.
 end
 end

 return, zenrat
 
 end
