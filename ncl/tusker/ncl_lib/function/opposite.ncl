;******************************************************************************
; ID: opposite.ncl V01 01/24/2012 11:13 BRUCE EXP$
;
; FUNCTION opposite IS USED TO GET THE OPPOSITE VALUE FOR THE GIVEN VALUE.
; FOR INSTANCE, -3 AND 3.
;
; VARIABLES:
; =============================================================================
; (1 ) x    (numeric) : THE NUMBER WHICH IS USED TO GET OPPSITE NUMBER [---]
; (2 ) y    (numeric) : THE OPPOSITE NUMBER                            [---]
;
; NOTES:
; =============================================================================
; (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/24/2012)
;******************************************************************************

undef("opposite")
function opposite(x   :numeric, \ ; INPUT
                  y   :numeric)   ; OUTPUT

begin
  
  if (typeof(x) .eq. "integer") then
   y = 0 - x
  end if
  if (typeof(x) .eq. "float" .or. typeof(x) .eq. "double") then
   y = 0.0 - x
  end if
return(y)
end
