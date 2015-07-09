; $ID: ydn2md.ncl V01 05/06/2012 13:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE ydn2md CONVERTS THE DAY NUMBER OF SPECIFIC YEAR INTO MONTH AND DAY
;
;  VARIABLES:
;  ============================================================================
;  (1 ) year    (integer): SPECIFIED YEAR                               [---]
;  (2 ) dn      (integer): DAY NUMBER OF THE SPECIFIED YEAR             [---]
;  (3 ) month   (integer): MONTH IN THE SPECIFIED YEAR                  [---]
;  (4 ) day     (integer): DAY OF THE MONTH IN THE SPECIFIED YEAR       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;******************************************************************************

undef("ydn2md")
procedure ydn2md (year   :integer,  dn    :integer,  \ ; INPUT
                  month  :integer,  day   :integer)    ; OUTPUT

begin
;  GET THE JULIAN DAY OF THE FIRST DAY OF THIS YEAR
   yjul  = greg2jul(year, 1, 1, -1)
;  CONVERT THE DAY NUMBER TO JULIAN DAY
   jul   = yjul + dn -1
;  CONVERT JULIAN DAY TO GREGORIAN DATE
   ymd   = jul2greg(jul)
;  JUDGE THE DIMENSION SIZE OF year
   ndim  = dimsizes(year)
   if(ndim .gt. 1)then
    month = ymd(:, 1)
    day   = ymd(:, 2)
   else
    month = ymd(1)
    day   = ymd(2)
   end if
   
return
end
