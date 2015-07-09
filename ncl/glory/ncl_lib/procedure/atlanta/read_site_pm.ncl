;  $ID: read_site_pm.ncl V01 11/08/2012 08:32 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_site_pm READS SITES OBERVATION PM FROM LIU.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/08/2012)
;******************************************************************************

undef("read_site_pm")
procedure read_site_pm \
          (dir       :string,  filename   :string,     \ ;INPUT
           bv1       :integer, bv2        :float,      \ ;INPUT
           start_jd  :integer, end_jd     :integer,    \ ;INPUT
           start_hour:integer, end_hour   :integer,    \ ;INPUT
           site_name :string,                          \ ;OUTPUT
           date      :integer, aod_ang    :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "	"
   delimiter2  = "/"
   delimiter3  = " "
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   data        = all_data(1:)
   nrows       = dimsizes(data)
   nfields     = str_fields_count(header, delimiter1)
;  DECLARE TWO TEMPERARY ARRAY
   tmp_date    = new((/nrows, 4/), integer, bv1)
   tmp_aod_ang = new((/nrows, 3/), float,   bv2)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
    site_name         = str_get_field(data(i), 1, delimiter1)
    tmp1              = str_get_field(data(i), 2, delimiter1)
    tmp_date(i, 0)    = stringtoint(str_get_field(tmp1, 3, delimiter2))
    tmp_date(i, 1)    = stringtoint(str_get_field(tmp1, 1, delimiter2))
    tmp_date(i, 2)    = stringtoint(str_get_field(tmp1, 2, delimiter2))
    tmp2              = str_get_field(tmp1, 2, delimiter3)
    tmp_date(i, 3)    = stringtoint(str_get_cols(tmp2, 0, 1))
    tmp_aod_ang(i, 0) = stringtofloat(str_get_field(data(i), 3, delimiter1))
    tmp_aod_ang(i, 1) = stringtofloat(str_get_field(data(i), 4, delimiter1))
    tmp_aod_ang(i, 2) = stringtofloat(str_get_field(data(i), 5, delimiter1))
   end do

;  REARRANGE THE DATE AND DATA INTO REGULAR DATE ORDER
   icount = 0
   do ijd = start_jd, end_jd
    greg_date = jul2greg(ijd)
    iyear     = greg_date(0)-2000
    imonth    = greg_date(1)
    iday      = greg_date(2)
    do ihour = start_hour, end_hour
     index = ind(tmp_date(:, 0)    .eq. iyear  .and. \
                 tmp_date(:, 1)    .eq. imonth .and. \
                 tmp_date(:, 2)    .eq. iday   .and. \
                 tmp_date(:, 3)    .eq. ihour  .and. \
                 tmp_aod_ang(:, 0) .lt. 50.0)
     if (.not. all(ismissing(index))) then
      date(icount, :)    = tmp_date(index(0), :)
      aod_ang(icount, :) = dim_avg_n(tmp_aod_ang(index, :), 0)
     else
      date(icount, :)    = (/iyear+2000, imonth, iday, ihour/)
      aod_ang(icount, :) = bv2
     end if
     delete([/index/])
     icount = icount + 1
    end do
   end do

return
end
