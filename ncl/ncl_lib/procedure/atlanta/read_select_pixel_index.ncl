;  $ID: read_select_pixel_index.ncl V01 02/11/2014 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_select_pixel_index READS SELECTED PIXEL INDEX FILE GENERATED 
;  FROM IDL.
;
;  VARIABLES:
;  ===========================================================================
;  (1 ) 
;
;  NOTES:
;  ===========================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/11/2014)
;*****************************************************************************

undef("read_select_pixel_index")
procedure read_select_pixel_index \
         (dir         :string,        filename     :string,  \;INPUT
          date        :integer,       index        :integer)  ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter   = " "
   all_data    = asciiread(dir + filename, -1, "string")
   data        = all_data(0:)
   nrow        = dimsizes(data)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrow-1
      date(0, i) = stringtoint(str_get_field(data(i), 1, delimiter))
      date(1, i) = stringtoint(str_get_field(data(i), 2, delimiter))
      date(2, i) = stringtoint(str_get_field(data(i), 3, delimiter))
      tmp        = stringtoint(str_get_field(data(i), 4, delimiter))
      if (tmp .ge. 0) then
         index(i)= tmp
      end if
   end do
return

end
