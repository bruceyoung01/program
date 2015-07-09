; $ID: calculate_calipso_frequency.ncl V01 01/26/2012 17:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_calipso_frequency IS USED TO CALCULATE AEROSOL AND 
;  CLOUD FREQUENCY IN EACH LAYER.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) sdata      (float)   : SELECTED CALIPSO AOD DATA                 [---]
;  (2 ) idata      (integer) : SELECTED CALIPSO DATA OF AEROSOL AND CLOUD 
;                              DISTINGUISHER.                            [---]
;  (3 )n_new_layer (integer) : # OF NEW DEFINED LAYER                    [---]
;  (4 )tssdim      (integer) : TOTAL SELECTED PIXELS                     [---]
;  (5 )bv1         (float)   : BAD VALUE FOR FLOAT                       [---]
;  (6 )avgsdata    (float)   : LAYER AVERAGE OF SELECTED CALIPSO AOD DATA[---]
;  (7 )stdsdata    (float)   : LAYER STANDARD DEVIATION OF SELECTED CALIPSO
;                              AOD DATA                                  [---]
;  (8 )freidata_aer(float)   : LAYER AEROSOL FREQUENCY OF SELECTED CALISPO
;                              DATA                                      [---]
;  (9 )freidata_cld(float)   : LAYER CLOUD FREQUENCY OF SELECTED CALIPSO 
;                              DATA                                      [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/26/2012)
;******************************************************************************

undef("calculate_calipso_frequency")
procedure calculate_calipso_frequency(sdata   :float,  idata  :integer,  \ ; INPUT
                                      n_new_layer:integer,tssdim:integer,\ ; INPUT
                                      bv1     :float,                    \ ; INPUT
                                      avgsdata:float,                    \ ; OUTPUT
                                      stdsdata:float,                    \ ; OUTPUT
                                      freidata_aer:float,                \ ; OUTPUT
                                      freidata_cld:float)                  ; OUTPUT

begin

;  CALCULATE EC AVERAGE AND FREQUENCY IN EACH LAYER
   do i = 0, tssdim-1
    do j = 0, n_new_layer-1
     if(ismissing(sdata(i,j)) .or. \
        sdata(i,j) .lt. 0.0) then
      sdata(i,j) = bv1
     end if
    end do
   end do

   do i = 0, n_new_layer-1
    if(all(ismissing(sdata(0:(tssdim-1), i))) .and. \
       all(ismissing(idata(0:(tssdim-1), i)))) then
     avgsdata(i)     = bv1
     stdsdata(i)     = bv1
    else 
     avgsdata(i)     = avg(sdata(0:(tssdim-1), i))
     stdsdata(i)     = stddev(sdata(0:(tssdim-1), i))
     freidata_aer(i) = num(idata(0:(tssdim-1), i) .eq. 1)/int2flt(tssdim)
     freidata_cld(i) = num(idata(0:(tssdim-1), i) .eq. 2)/int2flt(tssdim)
     if (.not.ismissing(freidata_cld(i)) .and. \
         freidata_cld(i) .gt. 0.0) then
         avgsdata(i) = 0.4
         stdsdata(i) = 0.0
     end if
    end if
   end do
return
end
