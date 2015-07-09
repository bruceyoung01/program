; $ID: correlation_nd.ncl V01 05/08/2012 13:43 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION correlation_nd CALCULATES THE CORRELATION BETWEEN TWO N-D ARRARY
;
;  VARIABLES:
;  ============================================================================
;  (1 ) x    (numeric): N-D ARRAY TO BE CALCULATED CORRELATION WITH y   [---]
;  (2 ) y    (numeric): N-D ARRAY TO BE CALCULATED CORRELATION WITH x   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/08/2012)
;  (2 ) x AND y SHOULD HAVE THE SAME MISSING VALUE. (05/08/2012)
;******************************************************************************

undef("correlation_nd")
function correlation_nd(x       :numeric, y       :numeric)    ; INPUT

;  DEFINE LOCAL VARIABLES
   local bv2, cor, xa, xa2, ya, ya2, xya
begin

;  MATCH x AND y WITH NO BAD VALUES
   oned_x = ndtooned(x)
   oned_y = ndtooned(y)
   noned_x= dimsizes(oned_x)
   indexx = ind(ismissing(oned_x))
   if(.not.all(ismissing(indexx)))then
    bv2   = oned_x(indexx(0))
    oned_x(indexx) = bv2
    oned_y(indexx) = bv2
   end if
   indexy = ind(ismissing(oned_y))
   if(.not.all(ismissing(indexy)))then
    bv2   = oned_y(indexy(0))
    oned_x(indexy) = bv2
    oned_y(indexy) = bv2
   end if
   if(all(ismissing(indexx)) .and. \
      all(ismissing(indexx)))then
    bv2 = -9999.
   end if

   xa   = new((/noned_x(0)/), float, bv2)
   ya   = new((/noned_x(0)/), float, bv2)
   xa2  = new((/noned_x(0)/), float, bv2)
   ya2  = new((/noned_x(0)/), float, bv2)
   xya  = new((/noned_x(0)/), float, bv2)
   avgxa= avg(x)
   avgya= avg(y)
   do i = 0, noned_x(0)-1
    xa(i) = oned_x(i) - avgxa
    ya(i) = oned_y(i) - avgya
    xa2(i)= (oned_x(i)-avgxa)^2
    ya2(i)= (oned_y(i)-avgya)^2
    xya(i)= xa(i)*ya(i)
   end do
   if(sum(xa2) .ne. 0.0 .and. \
      sum(ya2) .ne. 0.0)then
    cor = sum(xya)/sqrt(sum(xa2)*sum(ya2))
   else
    cor = bv2
   end if

return(cor)
end
