;  $ID: convert_date_order_day_epa.ncl V01 03/11/2013 22:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_date_order_day_epa CONVERT READ DATA ORDER TO DATE (DAY) 
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
undef("convert_date_order_day_epa")
procedure convert_date_order_day_epa \
          (bv2        :float,    site_id       :string,  \; INPUT
           start_year :integer,  start_month   :integer, \; INPUT
           start_day  :integer,  start_hour    :integer, \; INPUT
           nsmp       :integer,  ename         :string,  \; INPUT
           date1      :integer,  data1         :float,   \; INPUT
           data2      :float,    data3         :float)    ; OUTPUT

begin
   print("COVNERTING EPA")
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
    index = ind(ename(:, 0) .eq. site_id .and. \
                date1(:, 0) .eq. year    .and. \
                date1(:, 1) .eq. month   .and. \
                date1(:, 2) .eq. day)
    if (.not.all(ismissing(index)) .and. \
        .not.all(ismissing(data1(index, 0)))) then
     data2(i) = avg(data1(index, 0))
     data3(i) = stddev(data1(index, 0))
    else
     data2(i) = bv2
     data3(i) = bv2
    end if
    delete([/index/])
   end do
end
