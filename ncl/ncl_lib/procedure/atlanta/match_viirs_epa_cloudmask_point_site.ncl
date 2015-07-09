;  $ID: match_viirs_epa_cloudmask_point_site.ncl V01 01/30/2014 11:40 
;   BRUCE EXP$
;
;******************************************************************************
;   PROCEDURE match_viirs_epa_cloudmask_point_site MATCH SELECTED VIIRS AND EPA 
;   DATA WITH CLOUD MASK.
;
;   VARIABLES:
;   ===========================================================================
;   (1 )
;
;   NOTES:
;   ===========================================================================
;   (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/30/2014)
;******************************************************************************

undef("match_viirs_epa_cloudmask_point_site")
procedure match_viirs_epa_cloudmask_point_site \
          (bv2         :float,                         \; INPUT
           sdate       :integer, cdate      :integer,  \; INPUT
           pm          :float,   p_rad      :float,    \; INPUT
           cmask       :float,                         \; INPUT
           cpm         :float,   cp_rad     :float)     ; OUTPUT

begin

   ndim = dimsizes(sdate)
   nrow = ndim(1)

;  DO LOOP TO FILTER CLOUDY DAY
   do i = 0, nrow - 1
      index1 = ind(sdate(0, i) .eq. cdate(0, :) .and. \
                   sdate(1, i) .eq. cdate(1, :) .and. \
                   sdate(2, i) .eq. cdate(2, :) .and. \
                   sdate(3, i) .eq. cdate(3, :))
      if (.not.ismissing(index1)) then
         if (cmask(index1) .eq. 1.0) then
            cpm(:, i)    = pm(:, i)
            cp_rad(:, i) = p_rad(:, i)
         else if (cmask(index1) .lt. 1.0) then
            cpm(:, i)    = bv2
            cp_rad(:, i) = p_rad(:, i)
         end if
         end if
      else
         cpm(:, i)    = bv2
         cp_rad(:, i) = bv2
      end if
   end do


end
