;  ID: calculate_fre_cot_ctp.ncl V01 07/13/2015 08:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calculate_fre_cot_ctp.ncl CALCULATES THE FREQUENCY OF THE 
;  HAPPENNESS OF COT AND CTP IN THE SPECIFIC BINS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/13/2015)
;******************************************************************************
undef("calculate_fre_cot_ctp")
procedure calculate_fre_cot_ctp \
          (cot_boundary        :integer, ctp_boundary        :integer, \; INPUT
           seviri_data         :float,                                 \; INPUT
           seviri_count        :integer, seviri_fre          :float)   \; OUTPUT

begin

;  GET # OF cot_boundary AND ctp_boundary
   ncot_boundary = dimsizes(cot_boundary)
   nctp_boundary = dimsizes(ctp_boundary)

;  ivariable = 3 FOR CLOUD OPTICAL THICKNESS
;  ivariable = 12 FOR CLOUD TOP PRESSURE
   seviri_cot_oned = ndtooned(seviri_data(3, :, :))
   seviri_ctp_oned = ndtooned(seviri_data(12, :, :))

;  DO cot_boundary AND ctp_boundary LOOP TO CALCULATE THE COUNT AND FREQUENCY
   do icot_boundary = 0, ncot_boundary-2
      do ictp_boundary = 0, nctp_boundary-2
         if (ictp_boundary .ge. 8) then
            if (isdefined("index")) then
               delete([/index/])
            end if
            index = ind(seviri_cot_oned .ge. cot_boundary(icot_boundary)   .and. \
                        seviri_cot_oned .lt. cot_boundary(icot_boundary+1) .and. \
                        seviri_ctp_oned .ge. ctp_boundary(ictp_boundary)   .and. \
                        seviri_ctp_oned .lt. ctp_boundary(ictp_boundary+1))
            if (.not.all(ismissing(index))) then
               ncount = num(.not.ismissing(index))
               seviri_count(ictp_boundary, icot_boundary) = ncount
;print("cot_boundary(icot_boundary) = " + cot_boundary(icot_boundary) + " " + \
;      "ctp_boundary(ictp_boundary) = " + ctp_boundary(ictp_boundary) + " " + \
;      "ncount                      = " + ncount)
            end if
         end if
      end do
   end do

;  CALCULATE THE TOTAL # AND FREQUENCY
   ntotal = int2flt(sum(seviri_count))
   seviri_fre = seviri_count/ntotal

return
end
