;  $ID: read_viirs_pickup.ncl V01 01/31/2014 10:07 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_pickup READS SELECTED VIIRS DATA INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/31/2014)
;******************************************************************************

undef("read_viirs_pickup")
procedure read_viirs_pickup \
          (bv2       :float,                           \ ;INPUT
           dir       :string,  filename   :string,     \ ;INPUT
           np        :integer, nl         :integer,    \ ;INPUT
           sitename  :string,                          \ ;OUTPUT
           date      :integer, rad        :float)        ;OUTPUT

begin

;  GET SITE NAME
   sitename    = str_get_cols(filename, -20, -12)
;  READ ALL THE DATA
   delimiter   = " "
   all_data    = asciiread(dir + filename, -1, "string")
   data        = all_data(0:)
   nfield      = str_fields_count(data(0), delimiter)
   nrow        = dimsizes(data)
   npixel      = np*nl
   tmprad      = new((/npixel/), float, bv2)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrow-1
      do j = 0, nfield - 1
         if (j .le. 3) then
            date(j, i)    = stringtoint(str_get_field(data(i), j+1, delimiter))
         end if
         if (j .ge. 10) then
            tmprad(j-10)  = stringtofloat(str_get_field(data(i), j+1, delimiter))
            rad(:, :, i)  = onedtond(tmprad, (/np, nl/))
         end if
      end do
   end do
return
end

