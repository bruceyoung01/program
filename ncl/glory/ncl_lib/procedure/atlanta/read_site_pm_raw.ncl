;  $ID: read_site_pm_raw.ncl V01 02/05/2013 14:32 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_site_pm_raw READS SITES OBERVATION PM FROM LIU.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/05/2012)
;  (2 ) MODIFIED FROM read_site_pm.ncl. (02/05/2012)
;******************************************************************************

undef("read_site_pm_raw")
procedure read_site_pm_raw \
          (dir       :string,  filename   :string,     \ ;INPUT
           bv0       :string,                          \ ;INPUT
           bv1       :integer, bv2        :float,      \ ;INPUT
           start_jd  :integer, end_jd     :integer,    \ ;INPUT
           start_hour:integer, end_hour   :integer,    \ ;INPUT
           date      :integer, pm         :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "	"
   delimiter2  = "/"
   delimiter3  = ":"
   delimiter4  = " "
   data        = readAsciiTable(dir + filename, 1, "string", (/5/))
   dimdata     = dimsizes(data)
   nrows       = dimdata(0)
;  DECLARE TWO TEMPERARY ARRAY
   tmp_date    = new((/nrows, 4/), integer, bv1)
   tmp_pm      = new((/nrows, 3/), float,   bv2)
   tmp_ampm    = new((/nrows, 1/), string,  bv0)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
    tmp1              = str_get_field(data(i, 0), 1, delimiter4)
    tmp_date(i, 0)    = stringtoint(str_get_field(tmp1, 3, delimiter2))
    tmp_date(i, 1)    = stringtoint(str_get_field(tmp1, 1, delimiter2))
    tmp_date(i, 2)    = stringtoint(str_get_field(tmp1, 2, delimiter2))
    tmp2              = str_get_field(data(i, 0), 2, delimiter4)
    tmp_date(i, 3)    = stringtoint(str_get_field(tmp2, 1, delimiter3))
    tmp_ampm(i, 0)    = str_get_field(data(i, 0), 3, delimiter4)
    tmp_pm(i, 0)      = stringtofloat(str_get_field(data(i, 0), 2, delimiter1))
    tmp_pm(i, 1)      = stringtofloat(str_get_field(data(i, 0), 3, delimiter1))
    tmp_pm(i, 2)      = stringtofloat(str_get_field(data(i, 0), 4, delimiter1))
;  COVNERT 12-HOUR TO 24-HOUR
    if (tmp_date(i, 3) .eq. 12) then
     tmp_date(i, 3) = 0
    else if (tmp_ampm(i, 0) .eq. "PM")
     tmp_date(i, 3) = tmp_date(i, 3) + 12
    end if
    end if
   end do

;  REARRANGE THE DATE AND DATA INTO REGULAR DATE ORDER
   icount = 0
   do ijd = start_jd, end_jd
    greg_date = jul2greg(ijd)
    iyear     = greg_date(0)
    imonth    = greg_date(1)
    iday      = greg_date(2)
    do ihour = start_hour, end_hour
     index = ind(tmp_date(:, 0)    .eq. iyear  .and. \
                 tmp_date(:, 1)    .eq. imonth .and. \
                 tmp_date(:, 2)    .eq. iday   .and. \
                 tmp_date(:, 3)    .eq. ihour  .and. \
                 tmp_pm(:, 0) .lt. 50.0)
     if (.not. all(ismissing(index))) then
      date(icount, :)    = (/iyear, imonth, iday, ihour/)
      pm(icount, :)      = dim_avg_n(tmp_pm(index, :), 0)
     else
      date(icount, :)    = (/iyear, imonth, iday, ihour/)
      pm(icount, :)      = bv2
     end if
     delete([/index/])
     icount = icount + 1
    end do
   end do

return
end
