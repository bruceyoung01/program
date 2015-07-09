;  $ID: read_visualized_cloudmask_date_site.ncl V01 01/24/2014 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_visualized_cloudmask_date_site.ncl READS VISUALIZED CLOUD MASK 
;  FILE, INCLUDING DATE, CLOUDMASK IN EACH SITE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/24/2014)
;******************************************************************************

undef("read_visualized_cloudmask_date_site")
procedure read_visualized_cloudmask_date_site \
         (dir      :string,   filename     :string, \; INPUT
          date     :integer,  cmask        :float)   ; OUTPUT

begin

   ndim_date = dimsizes(date)
   ndate     = ndim_date(0)
   ndim_cmask= dimsizes(cmask)
   ncmask    = ndim_cmask(0)
   delimiter = " "

;  READ FILENAME
   all_data = asciiread(dir + filename, -1, "string")
   data     = all_data(0:)
   nrow     = dimsizes(data)

;  DO nrow LOOP TO READ DATA ONE LINE BY ONE LINE
   do i = 0, nrow - 1
      do j = 0, ndate - 1
         jtmp = j
         date(jtmp, i)  = stringtointeger(str_get_field(data(i), jtmp+1, delimiter))
      end do
      do k = 0, ncmask - 1
         ktmp = k
         cmask(ktmp, i) = stringtofloat(str_get_field(data(i), ktmp+7, delimiter))
      end do
   end do

end
