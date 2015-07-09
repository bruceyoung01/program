;  $ID: convert_date_order_hour_liu.ncl V01 03/11/2013 22:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM convert_date_order_hour_liu CONVERT READ DATA ORDER TO DATE (HOUR) 
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
undef("convert_date_order_hour_liu")
procedure convert_date_order_hour_liu \
          (bv2        :float,                            \; INPUT
           start_year :integer,  start_month   :integer, \; INPUT
           start_day  :integer,  start_hour    :integer, \; INPUT
           nsmp       :integer,  nhour         :integer, \; INPUT
           date1      :integer,  data1         :float,   \; INPUT
           data2      :float)                             ; OUTPUT

begin
   print("CONVERTING LIU")
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
;  JUDGE IF THE HOUR IS FROM 0 TO 23
;  OR FROM 1 TO 24
    index0 = ind(date1(:, 3) .eq. 0)
    if (.not.all(ismissing(index0))) then
     do j = 0, nhour-1
      index = ind(date1(:, 0) .eq. year  .and. \
                  date1(:, 1) .eq. month .and. \
                  date1(:, 2) .eq. day   .and. \
                  date1(:, 3) .eq. j)
      if (.not.all(ismissing(index))) then
       data2(i, j) = data1(index, 0)
      else
       data2(i, j) = bv2
      end if
      delete([/index/])
     end do
    end if
    index1 = ind(date1(:, 3) .eq. 24)
    if (.not.all(ismissing(index1))) then
     do j = 0, nhour-1
      index = ind(date1(:, 0) .eq. year  .and. \
                  date1(:, 1) .eq. month .and. \
                  date1(:, 2) .eq. day   .and. \
                  date1(:, 3) .eq. j+1)
      if (.not.all(ismissing(index))) then
       data2(i, j) = data1(index, 0)
      else
       data2(i, j) = bv2
      end if
      delete([/index/])
     end do
    end if
    delete([/index0, index1/])
   end do
end
