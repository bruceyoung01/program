;  $ID: divide_bin_fre.ncl V01 07/15/2015 16:12 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE divide_bin_fre.ncl DIVIDES VARIABLES INTO BINS AND PLOTS THE 
;  FREQUENCY WITH 2-D COLOR BAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/15/2015)
;******************************************************************************
undef("divide_bin_fre")
procedure divide_bin_fre \
          (xmin       :numeric,  xmax       :numeric, \;INPUT
           ymin       :numeric,  ymax       :numeric, \;INPUT
           npts       :integer,                       \;INPUT
           xdata      :float,    ydata      :float,   \;INPUT
           xdata_bin  :float,    xdata_fre  :float,   \;OUTPUT
           ydata_bin  :float,    ydata_std  :float)    ;OUTPUT

begin
;  BUILD BIN BOUNDRY FOR BOTH xdata AND ydata
   xbin = fspan(xmin, xmax, npts)
   ybin = fspan(ymin, ymax, npts)

;  CONVERT BOTH xdata AND ydata INTO 1-D
   xdata_oned = ndtooned(xdata)
   ydata_oned = ndtooned(ydata)

;  DO xbin LOOP TO DIVIDE Y DATA INTO BINS
   do inpts = 0, npts-2
      xindex = ind(xdata_oned .ge. xbin(inpts) .and. \
                   xdata_oned .lt. xbin(inpts+1))
      if (.not.all(ismissing(xindex))) then
         if (.not.all(ismissing(ydata_oned(xindex)))) then
            xdata_fre(inpts) = dimsizes(xindex)
            ydata_bin(inpts) = avg(ydata_oned(xindex))
            ydata_std(inpts) = stddev(ydata_oned(xindex))
         end if
      end if
      delete([/xindex/])
   end do

;  CALCULATE THE FREQUENCY FOR XDATA IN EACH BIN
   xdata_fre = xdata_fre/sum(xdata_fre)
   xdata_bin = xbin
return
end
