;  $ID: match_epa_highliht.ncl V01 01/24/2014 10:09 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_epa_highliht MATCHS THE EPA AND SELECTED HIGHLIGHT PIXEL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/24/2014)
;******************************************************************************

undef("match_epa_highliht")
procedure match_epa_highliht \
          (bv2           :float,                         \; INPUT
           date          :integer,  pdate      :integer, \; INPUT
           pm_data       :float,    prad       :float,   \; INPUT
           pm_data_match :float,    prad_match :float)    ; OUTPUT


begin

;  GET # OF TOTAL EPA DATA
   ndim  = dimsizes(date)
   ndata = ndim(0)

;  DO ndata LOOP TO MATCH EPA DATA AND VIIRS SELECTED HIGHLIGHT PIXEL
   do i = 0, ndata-1
      index1 = ind(pdate(:, 0) .eq. date(i, 0) .and. \
                   pdate(:, 1) .eq. date(i, 1) .and. \
                   pdate(:, 2) .eq. date(i, 2) .and. \
                   pdate(:, 3) .eq. date(i, 3))
      if (.not.all(ismissing(index1)) .and. \ 
          .not.all(ismissing(pm_data(i, :)))) then
         pm_data_match(i) = avg(pm_data(i, :))
         prad_match(i)    = max(prad(i, :))
      else
         pm_data_match(i) = bv2
         prad_match(i)    = bv2
      end if
      delete(index1)
   end do

print(date(:, 0) + " - " + date(:, 1) + " - " + date(:, 2) + " - " + date(:, 3) + " | " + pm_data_match + " | " + prad_match)
end
