;  $ID: match_group_number_site_pickup_cloudmask.ncl V01 02/17/2014 15:09 
;       BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_group_number_site_pickup_cloudmask MATCHES THE DATE FROM 
;  GROUP NUMBER ON EACH SITE AND TOTAL PICKUP AND CLOUD MASK DATE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) isite     (integer): index of the site.                           [---]
;  (2 ) dateind   (integer): date for group number index.                 [---]
;  (3 ) date      (integer): date for site pickup virrs radiance.         [---]
;  (4 ) cdate     (integer): date for cloud mask.                         [---]
;  (5 ) index     (integer): group number index.                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2014)
;  (2 ) MODIFIED FROM match_group_number_site_pickup.ncl BY BRUCE. ADDING 
;       CLOUDMASK FILTER. (02/17/2014)
;******************************************************************************

undef("match_group_number_site_pickup_cloudmask")
procedure match_group_number_site_pickup_cloudmask \
         (isite      :integer,                         \ ;INPUT
          dateind    :integer,     date     :integer,  \ ;INPUT
          cdate      :integer,     cmask    :float,    \ ;INPUT
          index      :integer)                           ;OUTPUT

begin
;  MATCH THE DATE FROM GROUP NUMBER SITE AND PICKUP
   tmpindex1 = ind(date(0, :)  .eq. dateind(0) .and. \
                   date(1, :)  .eq. dateind(1) .and. \
                   date(2, :)  .eq. dateind(2))
   tmpindex2 = ind(cdate(0, :) .eq. dateind(0) .and. \
                   cdate(1, :) .eq. dateind(1) .and. \
                   cdate(2, :) .eq. dateind(2))
   if (.not.all(ismissing(tmpindex2))) then
      if (cmask(tmpindex2(0)) .eq. 1) then
         index = tmpindex1(0)
      end if
   end if
end
