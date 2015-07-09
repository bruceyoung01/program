; $ID: running_average.ncl V01 05/10/2012 09:31 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE running_average AVERAGES THE DATA ITERATIVELY. FOR INSTANCE,
;  AVG(1)   = AVG(1, 2)
;  AVG(2)   = AVG(2, 3)
;  AVG(3)   = AVG(3, 4)
;  ................
;  AVG(N-1) = AVG(N-1, N)
;  AVG(N)   = AVG(N)
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data1  (numeric): INPUT DATA BEFORE CALCULATING RUNNING AVERAGE [---]
;  (2 ) data2  (numeric): OUTPUT DATA AFTER CALCULATING RUNNING AVERAGE [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/10/2012)
;******************************************************************************

undef("running_average")
procedure running_average (data1     :numeric, \ ; INPUT
                           data2     :numeric)   ; OUTPUT


begin

;  GET THE DIMENSION SIZE OF data1
   ndim1      = dimsizes(data1)
   nndim1     = dimsizes(ndim1)
;  GET MISSING VALUE
   oned_data1 = ndtooned(data1)
   index1     = ind(ismissing(oned_data1))
   if(.not.all(ismissing(index1)))then
    bv        = oned_data1(index1(0))
   end if

;  JUDGE THE DIMENSION SIZE OF data1
   if(nndim1 .eq. 1)then
    do i = 0, ndim1(0)-2
     if(.not.all(ismissing(data1(i:i+1))))then
      data2(i) = avg(data1(i:i+1))
     else
      data2(i) = bv
     end if
    end do
    data2(ndim1(0)-1) = data1(ndim1(0)-1)
   else if(nndim1 .eq. 2)then
    oned_data1 = ndtooned(data1)
    ndimoned1  = dimsizes(oned_data1)
    do i = 0, ndimoned1(0)-2
     if(.not.all(ismissing(oned_data1(i:i+1))))then
      oned_data1(i) = avg(oned_data1(i:i+1))
     else
      oned_data1(i) = bv
     end if
    end do
    data2 = onedtond(oned_data1, (/ndim1(0), ndim1(1)/))
   else if(nndim1 .eq. 3)then
    oned_data1 = ndtooned(data1)
    ndimoned1  = dimsizes(oned_data1)
    do i = 0, ndimoned1(0)-2
     if(.not.all(ismissing(oned_data1(i:i+1))))then
      oned_data1(i) = avg(oned_data1(i:i+1))
     else
      oned_data1(i) = bv
     end if
    end do
    data2 = onedtond(oned_data1, (/ndim1(0), ndim1(1), ndim1(2)/))
   else if(nndim1 .eq. 4)then
    oned_data1 = ndtooned(data1)
    ndimoned1  = dimsizes(oned_data1)
    do i = 0, ndimoned1(0)-2
     if(.not.all(ismissing(oned_data1(i:i+1))))then
      oned_data1(i) = avg(oned_data1(i:i+1))
     else
      oned_data1(i) = bv
     end if
    end do
    data2 = onedtond(oned_data1, (/ndim1(0), ndim1(1), ndim1(2), ndim1(3)/))
   end if
   end if
   end if
   end if

return
end
