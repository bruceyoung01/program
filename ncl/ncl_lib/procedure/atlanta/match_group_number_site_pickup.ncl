;  $ID: match_group_number_site_pickup.ncl V01 02/12/2014 12:12 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_group_number_site_pickup MATCHES THE DATE FROM GROUP NUMBER 
;  ON EACH SITE AND TOTAL PICKUP.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dateind   (integer): date for group number index.                 [---]
;  (2 ) date      (integer): date for site pickup virrs radiance.         [---]
;  (3 ) index     (integer): group number index.                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2014)
;******************************************************************************

undef("match_group_number_site_pickup")
procedure match_group_number_site_pickup \
         (dateind    :integer,     date     :integer,  \ ;INPUT
          index      :integer)                           ;OUTPUT

begin
;  MATCH THE DATE FROM GROUP NUMBER SITE AND PICKUP
   tmpindex = ind(date(0, :) .eq. dateind(0) .and. \
                  date(1, :) .eq. dateind(1) .and. \
                  date(2, :) .eq. dateind(2))
   index    = tmpindex(0)
end
