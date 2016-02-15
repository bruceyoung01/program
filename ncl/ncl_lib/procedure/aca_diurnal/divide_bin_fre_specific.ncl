;  $ID: divide_bin_fre_specific.ncl V01 02/14/2016 11:46 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROCEDURE divide_bin_fre_specific.ncl DIVIDES DATA INTO SPECIFIC BINS AND 
;  CALCULATES THE FREQUENCY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) xdata      (N-D)   :xdata                                         [   ]
;  (2 ) ydata      (N-D)   :ydata                                         [   ]
;  (3 ) xdata_bin  (1-D)   :xdata BIN                                     [   ]
;  (4 ) ydata_bin  (1-D)   :ydata BIN                                     [   ]
;  (5 ) data_fre   (1-D)   :xdata FREQUENCY                               [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHFIENG YANG. (02/14/2016)
;******************************************************************************
;
undef ("divide_bin_fre_specific")
procedure divide_bin_fre_specific \
          (xdata      :float,    ydata      :float,   \;INPUT
           xdata_bin  :float,    ydata_bin  :float,   \;INPUT
           data_fre   :float)                          ;OUTPUT

begin

;  CALCULATE THE HOW MANY BINS FOR xdata_bin AND ydata_bin
   npts_x     = dimsizes(xdata_bin)
   npts_y     = dimsizes(ydata_bin)

;  CONVERT BOTH xdata AND ydata INTO 1-D
   xdata_oned = ndtooned(xdata)
   ydata_oned = ndtooned(ydata)

;  DO xbin LOOP TO DIVIDE Y DATA INTO BINS
   do inpts_x = 0, npts_x - 2
      do inpts_y = 0, npts_y - 2
         index = ind(xdata_oned .ge. xdata_bin(inpts_x)   .and. \
                     xdata_oned .lt. xdata_bin(inpts_x+1) .and. \
                     ydata_oned .ge. ydata_bin(inpts_y)   .and. \
                     ydata_oned .lt. ydata_bin(inpts_y+1))
         if (.not.all(ismissing(index))) then
            if (.not.all(ismissing(ydata_oned(index)))) then
               data_fre(inpts_y, inpts_x) = dimsizes(index)
            end if
         end if
         delete([/index/])
      end do
   end do

;  CALCULATE THE FREQUENCY FOR DATA IN EACH BIN
   if (.not.all(ismissing(data_fre)) .and. \
      sum(data_fre) .gt. 0.0) then
      data_fre = data_fre/sum(data_fre)
   else
      print("All data are missing. Bad Luck!!!")
   end if
return










end
