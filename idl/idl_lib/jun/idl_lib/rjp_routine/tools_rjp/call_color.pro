
pro call_color, table, reverse=reverse

 if N_elements(table) eq 0 then table = 25L
 if N_elements(reverse) eq 0 then reverse = 0L
         C = MYCT_Defaults( _EXTRA=e )

         MyCT, TABLE,    $
            Bottom=C.BOTTOM, NColors=C.NCOLORS, $
            Range=[0.1,1], Reverse=REVERSE, Sat=1,    $
            Value=C.VALUE, _EXTRA=e

end
