;  $ID: calculate_viirs_select_pixel_index_fre.ncl V01 02/11/2014 08:03 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_viirs_select_pixel_index_fre CALCULATES SELECTED VIIRS
;  PIXEL INDEX FREQUENCY.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/11/2014)
;******************************************************************************

undef("calculate_viirs_select_pixel_index_fre")
procedure calculate_viirs_select_pixel_index_fre \
         (np       :integer,     nl       :integer,     \; INPUT
          rad      :float,       index    :integer,     \; INPUT
          countind :integer,     fre      :float)        ; OUTPUT

begin
; CALCULATE TOTAL INDEX #
  countind = num(.not.ismissing(index))
  nindex   = int2flt(countind)
; print("nindex = " + nindex)

; DO np, nl LOOP TO MATCH THE INDEX OF SELECTED PIXEL(1-D) AND PLOTTED PIXEL
; (2-D)
  icount = 0
  do i = 0, np - 1
     do j = 0, nl - 1
;       print("i = " + i + " j = " + j)
;       print(rad(i, j, :))
        if (.not.all(ismissing(rad(np-1-i, j, :)))) then
;          print("icount = " + icount)
;          print("num = " + num(index .eq. icount))
           if (nindex .gt. 0) then
              fre(np-1-i, j) = num(index .eq. icount)/nindex
;             print("fre = " + fre(np-1-i, j))
           end if
;          print("fre = " + fre(np-1-i, j))
           icount = icount + 1
        end if
     end do
  end do
; print("total = " + sum(fre))
end
