;  $ID: read_group_number_site.ncl V01 02/12/2014 11:47 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_group_number_site READS GROUP NUMBER IN EACH SITE.
;
;  VARIABLES:
;  ===========================================================================
;  (1 ) 
;
;  NOTES:
;  ===========================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2014)
;*****************************************************************************

undef("read_group_number_site")
procedure read_group_number_site \
         (dir         :string,        filename     :string,  \;INPUT
          ngsite      :integer)                               ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter   = " "
   all_data    = asciiread(dir + filename, -1, "string")
   data        = all_data(0:)
   nrow        = dimsizes(data)
   nfield      = str_fields_count(all_data(0), delimiter)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrow-1
      do j = 0, nfield - 1
         ngsite(i, j) = stringtoint(str_get_field(data(i), j+1, delimiter))
      end do
   end do
return

end
