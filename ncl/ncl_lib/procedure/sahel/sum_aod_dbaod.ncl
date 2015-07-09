;  $ID: sum_aod_dbaod.ncl V01 23:31 04/02/2013 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE sum_aod_dbaod CALCULATES TOTAL AOD, INCLUDING AOD (LAND AND OCEAN) 
;  AND DEEP BLUE AOD.
;  ALGRITHM : IF AOD (LAND AND OCEAN ) IS AVAILABLE, THEN USE IT, EVEN DEEP 
;             AOD IS ALSO AVAILABLE OR NOT. IF AOD (LAND AND OCEAN ) IS 
;             UNAVAILABLE, THEN USE DEEP BLUE AOD.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/02/2013)
;******************************************************************************
undef("sum_aod_dbaod")
procedure sum_aod_dbaod \
          (bv2      :float,                    \; INPUT
           aod      :float,   dbaod    :float, \; INPUT
           taod     :float)                     ; OUTPUT
begin
   ndim       = dimsizes(aod)

;  CONVERT N-DIMENSIONAL ARRAY TO ONE-DIMENSIONAL ARRAY
   oned_aod   = ndtooned(aod)
   oned_dbaod = ndtooned(dbaod)

;  GET THE INDEX WHERE oned_aod IS MISSING VALUE
   index1 = ind(ismissing(oned_aod) .and. \
                oned_dbaod .ge. 0.0 .and. \
                .not.ismissing(oned_dbaod))
   if (.not.all(ismissing(index1))) then
    oned_aod(index1) = oned_dbaod(index1)
   end if
   aod = onedtond(oned_aod, dimsizes(aod))
   taod = aod
   delete([/index1/])
return
end
