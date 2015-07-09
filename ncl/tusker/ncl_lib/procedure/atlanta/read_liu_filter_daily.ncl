;  ID: read_liu_filter_daily.ncl V01 15:04 04/01/2013 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_liu_filter_daily READS LIU'S FILTER-BASED PM2.5 DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/01/2013)
;******************************************************************************
undef("read_liu_filter_daily")
procedure read_liu_filter_daily \
          (dir       :string,   filename    :string, \ ; INPUT
           date      :integer,  weight      :float,  \ ; OUTPUT
           volume    :float,    pm          :float)    ; OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "-"
   delimiter2  = ":"
   delimiter3  = "	"
   delimiter4  = " "
   all_data    = asciiread(dir + filename, -1, "string")
   all_data    = str_sub_str(all_data, ",,", ",data@_FillValue,")
   header      = all_data(0:1)
   data        = all_data(2:)
   nrow        = dimsizes(data)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrow-1
;  DATE
    tmp_date      = str_get_field(data(i), 2, delimiter3)
    ntmp_date     = strlen(tmp_date)
    if (ntmp_date .gt. 0) then
     date(i, 0)   = stringtoint(str_get_field(tmp_date,   1, delimiter1))
     date(i, 1)   = stringtoint(str_get_field(tmp_date,   2, delimiter1))
     date(i, 2)   = stringtoint(str_get_field(tmp_date,   3, delimiter1))
     tmp_hour     = str_get_field(tmp_date,   2, delimiter4)
     date(i, 3)   = stringtoint(str_get_field(tmp_hour, 1, delimiter2))
    end if
;  37mm FILTER1
    tmp_weight1   = str_get_field(data(i),  5, delimiter3)
    ntmp_weight1  = strlen(tmp_weight1)
    if (.not.all(ismissing(tmp_weight1))) then
     weight(i, 0) = stringtofloat(tmp_weight1)
    end if
    tmp_volume1   = str_get_field(data(i),  6, delimiter3)
    ntmp_volume1  = strlen(tmp_volume1)
    if (tmp_volume1 .gt. 0) then
     volume(i, 0) = stringtofloat(tmp_volume1)
    end if
    tmp_pm1       = str_get_field(data(i),  7, delimiter3)
    ntmp_pm1      = strlen(tmp_pm1)
    if (ntmp_pm1 .gt. 0) then
     pm(i, 0)     = stringtofloat(tmp_pm1)
    end if

;  37mm FILTER2
    tmp_weight2   = str_get_field(data(i),  9, delimiter3)
    ntmp_weight2  = strlen(tmp_weight2)
    if (ntmp_weight2 .gt. 0) then
     weight(i, 1) = stringtofloat(tmp_weight2)
    end if
    tmp_volume2   = str_get_field(data(i),  10, delimiter3)
    ntmp_volume2  = strlen(tmp_volume2)
    if (tmp_volume2 .gt. 0) then
     volume(i, 1) = stringtofloat(tmp_volume2)
    end if
    tmp_pm2       = str_get_field(data(i),  11, delimiter3)
    ntmp_pm2      = strlen(tmp_pm2)
    if (ntmp_pm2 .gt. 0) then
     pm(i, 1)     = stringtofloat(tmp_pm2)
    end if

;  25mm FILTER
    tmp_weight3   = str_get_field(data(i),  13, delimiter3)
    ntmp_weight3  = strlen(tmp_weight3)
    if (tmp_weight3 .gt. 0) then
     weight(i, 2) = stringtofloat(tmp_weight3)
    end if
    tmp_volume3   = str_get_field(data(i),  14, delimiter3)
    ntmp_volume3  = strlen(tmp_volume3)
    if (tmp_volume3 .gt. 0) then
     volume(i, 2) = stringtofloat(tmp_volume3)
    end if
    tmp_pm3       = str_get_field(data(i),  15, delimiter3)
    ntmp_pm3      = strlen(tmp_pm3)
    if (ntmp_pm3 .gt. 0) then
     pm(i, 2)     = stringtofloat(tmp_pm3)
    end if

;  GRIMM
    tmp_pm4       = str_get_field(data(i),  16, delimiter3)
    ntmp_pm4      = strlen(tmp_pm4)
    if (ntmp_pm4 .gt. 0) then
     pm(i, 3)     = stringtofloat(tmp_pm4)
    end if
   end do

return
end
