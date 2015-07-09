;  $ID: convert_date_order_day_liu.ncl V01 03/11/2013 22:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_date_order_day_liu CONVERT READ DATA ORDER TO DATE (DAY) 
;  ORDER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/11/2013)
;******************************************************************************
undef("convert_date_order_day_liu")
procedure convert_date_order_day_liu \
          (bv2        :float,                            \; INPUT
           start_year :integer,  start_month   :integer, \; INPUT
           start_day  :integer,  start_hour    :integer, \; INPUT
           nsmp       :integer,                          \; INPUT
           date1      :integer,  data1         :float,   \; INPUT
           data2      :float,    data3         :float)    ; OUTPUT

begin
   print("COVNERTING LIU")
;  DO TIME LOOP TO PUT DATA INTO DATE ORDER---HOUR
   do i = 0, nsmp-1
    if (i .eq. 0) then
     year   = start_year
     month  = start_month
     day    = start_day
     hour   = start_hour
     julian = greg2jul(year, month, day, hour-1)
    else
     julian = julian + 1
     greg   = jul2greg(julian)
     year   = greg(0)
     month  = greg(1)
     day    = greg(2)
    end if
    index = ind(date1(:, 0) .eq. year    .and. \
                date1(:, 1) .eq. month   .and. \
                date1(:, 2) .eq. day)
    ndim  = dimsizes(data1)
    nitem = ndim(1)
    do j = 0, nitem-1
     if (.not.all(ismissing(index)) .and. \
         .not.all(ismissing(data1(index, j)))) then
      data2(i, j) = avg(data1(index, j))
      data3(i, j) = stddev(data1(index, j))
     else
      data2(i, j) = bv2
      data3(i, j) = bv2
     end if
    end do
    delete([/index/])
   end do
end
