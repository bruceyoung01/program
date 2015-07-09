;  $ID: calculate_average_stddev.ncl V01 06/07/2015 15:22 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_average_stddev CALCULATES AVERAGE AND STANDARD DEVIATION
;  FOR ARRAYS WITH VARIOUS DIMENSIONS, SUCH AS 1-D, 2-D, 3-D, 4-D AND SO FORTH.
;  AND SPECIFIY CALCULATING FOR WHICH DIMENSION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data (numeric)      :1-4-D ARRAY                                 [   ]
;  (2 ) dimension (integer) :THE DIMENSION WHICH YOU WANT TO GET AVERAGE [   ]
;  (3 ) total_average (numeric) :THE TOTAL AVERAGE FOR ARRAY             [   ]
;  (4 ) average (numeric)       :AVERAGE OF THE DEMANDED ARRAY           [   ]
;  (5 ) error (numeric)         :STANDARD DEVIATION OF THE DEMANDED ARRAY[   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITEN BY BRUCE. (06/07/2015)

undef("calculate_average_stddev")
procedure calculate_average_stddev \
          (data           :numeric, dimension      :integer,   \;INPUT
           total_average  :numeric, average        :numeric,   \;OUTPUT
           error          :numeric)                             ;OUTPUT

begin
;  GET THE DIMENSION SIZE FOR THE ARRAY
   ndim = dimsizes(data)

;  1-D: CALCULATE total_average, average, AND error
   if (ndim .eq. 1) then
      total_average = avg(data)
      average(0)    = avg(data)
      error(0)      = stddev(data)
   end if

;  2-D: CALCULATE total_average, average, AND error
   if (ndim .eq. 2) then
      if (dimension .eq. 0) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(i, :))
            error(:)      = stddev(data(i, :))
         end do
      else if (dimension .eq. 1) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(:, i))
            error(:)      = stddev(data(:, i))
         end do
      end if
      end if
   end if
;  3-D: CALCULATE total_average, average, AND error
   if (ndim .eq. 3) then
      if (dimension .eq. 0) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(i, :, :))
            error(:)      = stddev(data(i, :, :))
         end do
      else if (dimension .eq. 1) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(:, i, :))
            error(:)      = stddev(data(:, i, :))
         end do
      else if (dimension .eq. 2) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(:, :, i))
            error(:)      = stddev(data(:, :, i))
         end do
      end if
      end if
      end if
   end if
;  4-D: CALCULATE total_average, average, AND error
   if (ndim .eq. 4) then
      if (dimension .eq. 0) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = avg(data(i, :, :, :))
            error(:)      = stddev(data(i, :, :, :))
         end do
      else if (dimension .eq. 1) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = dim_avg_n(data(:, i, :, :))
            error(:)      = stddev(data(:, i, :, :))
         end do
      else if (dimension .eq. 2) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = dim_avg_n(data(:, :, i, :))
            error(:)      = stddev(data(:, :, i, :))
         end do
      else if (dimension .eq. 3) then
         do i = 0, ndim(dimension)-1
            total_average = avg(data)
            average(:)    = dim_avg_n(data(:, :, :, i))
            error(:)      = stddev(data(:, :, :, i))
         end do
      end if
      end if
      end if
      end if

end
