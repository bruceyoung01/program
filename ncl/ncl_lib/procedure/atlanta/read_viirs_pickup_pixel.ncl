;  $ID: read_viirs_pickup_pixel.ncl V01 02/10/2014 10:13 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_pickup READS SELECTED VIIRS DATA INFO, WITH 
;  THE SAME PIXEL POSITION AS IN THE VIIRS OBSERVATIONS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/10/2014)
;******************************************************************************

undef("read_viirs_pickup_pixel")
procedure read_viirs_pickup_pixel \
          (bv2       :float,   isite      :integer,    \ ;INPUT
           dir       :string,  filename   :string,     \ ;INPUT
           np        :integer, nl         :integer,    \ ;INPUT
           sitename  :string,                          \ ;OUTPUT
           date      :integer, rad        :float)        ;OUTPUT

begin

;  GET SITE NAME
;  sitename    = str_get_cols(filename, -20, -12)
   sitename    = str_get_cols(filename, -30, -22)
;  READ ALL THE DATA
   delimiter   = " "
   all_data    = asciiread(dir + filename, -1, "string")
   data        = all_data(0:)
   nfield      = str_fields_count(data(0), delimiter)
   nrow        = dimsizes(data)
   npixel      = np*nl
   tmprad      = new((/npixel/), float, bv2)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrow - 1
      do j = 0, nfield - 1
         if (j .le. 3) then
            date(j, i)    = stringtoint(str_get_field(data(i), j+1, delimiter))
         end if
         if (j .ge. 10) then
            tmprad(j-10)  = stringtofloat(str_get_field(data(i), j+1, delimiter))
            if (isite .eq. 0) then
               rad(2, 0:3, i) = tmprad(0:3)
               rad(1, 1:3, i) = tmprad(4:6)
               rad(0, 1:3, i) = tmprad(7:9)
            else if (isite .eq. 1) then
               rad(2, 0:2, i) = tmprad(0:2)
               rad(1, 0:2, i) = tmprad(3:5)
               rad(0, 0:2, i) = tmprad(6:8)
            else if (isite .eq. 2) then
               rad(1, 0:2, i) = tmprad(0:2)
               rad(0, 0:3, i) = tmprad(3:6)
            else if (isite .eq. 3) then
               rad(1, 1:2, i) = tmprad(1:0)
               rad(1, 0,   i) = tmprad(4)
               rad(0, 1:2, i) = tmprad(3:2)
            else if (isite .eq. 4) then
               rad(:, 0, i) = tmprad(4:0)
               rad(:, 1, i) = tmprad(9:5)
               rad(:, 2, i) = tmprad(14:10)
            else if (isite .eq. 5) then
               rad(:, 0, i) = tmprad(4:0)
               rad(:, 1, i) = tmprad(9:5)
               rad(:, 2, i) = tmprad(14:10)
               rad(:, 3, i) = tmprad(19:15)
               rad(:, 4, i) = tmprad(24:20)
            end if
            end if
            end if
            end if
            end if
            end if
         end if
      end do
   end do
return
end

