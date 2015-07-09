;  $ID: convert_1d_to_2d.ncl V01 04/23/2013 23:10 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_1d_to_2d CONVERTS 1-D ARRAY TO 2-D ARRAY SIMPLY FOR EACH 
;  LAYER AND COLUMN.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2013)
;******************************************************************************

undef("convert_1d_to_2d")
procedure convert_1d_to_2d \
          (inth      :integer,     in       :integer, \; INPUT
           height    :float,                          \; INPUT
           latlon    :float,       hgt      :float)    ; OUTPUT

begin
;  DO LOOP TO ASSIGN VALUE
   do ih = 0, inth-1
    do jh = 0, in-2
     latlon(ih, jh) = jh
     hgt(ih, jh)    = height(ih)
    end do
   end do

return
end
