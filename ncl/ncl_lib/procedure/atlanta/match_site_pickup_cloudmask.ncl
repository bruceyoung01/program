;  $ID: match_site_pickup_cloudmask.ncl V01 02/17/2014 22:49 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_site_pickup_cloudmask MATCHES THE DATE FROM SELECTED VIIRS 
;  ON EACH SITE AND TOTAL PICKUP AND CLOUD MASK DATE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) isite     (integer): index of the site.                           [---]
;  (2 ) date      (integer): date for site pickup virrs radiance.         [---]
;  (3 ) cdate     (integer): date for cloud mask.                         [---]
;  (4 ) index     (integer): group number index.                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2014)
;  (2 ) MODIFIED FROM match_group_number_site_pickup_cloudmask.ncl BY BRUCE. 
;       ADDING CLOUDMASK FILTER. (02/17/2014)
;******************************************************************************

undef("match_site_pickup_cloudmask")
procedure match_site_pickup_cloudmask \
         (bv1        :integer,                         \ ;INPUT
          isite      :integer,     date     :integer,  \ ;INPUT
          cdate      :integer,     cmask    :float,    \ ;INPUT
          index      :integer)                           ;OUTPUT

begin
;  MATCH THE DATE FROM GROUP NUMBER SITE AND PICKUP
   tmpindex  = ind(cdate(0, :) .eq. date(0) .and. \
                   cdate(1, :) .eq. date(1) .and. \
                   cdate(2, :) .eq. date(2))
   if (.not.all(ismissing(tmpindex))) then
      if (cmask(tmpindex(0)) .eq. 1) then
         index = tmpindex(0)
      else
         index = bv1
      end if
   end if
end
