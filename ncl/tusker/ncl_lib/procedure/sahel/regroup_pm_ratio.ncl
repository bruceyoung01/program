;  $ID: regroup_pm_ratio.ncl V01 04/04/2013 11:53 BRUCE EXP$
;
;******************************************************************************
;  PRCEDURE regroup_pm_ratio COMBINES PM MASS CONCENTRATION AND THE RATIO OF 
;  SMOKE/(DUST+SMOKE) TO ONE VARIABLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/04/2013)
;******************************************************************************
undef("regroup_pm_ratio")
procedure regroup_pm_ratio \
          (minv      :float,  maxv     :float, \; INPUT
           interval  :float,  maxpm    :float, \; INPUT
           nfactor   :integer,                 \; INPUT
           pm        :float,  ratio    :float, \; INPUT
           data      :float)                    ; OUTPUT

begin
;  GET INFO FOR LATER USE
   ndim      = dimsizes(pm)
   oned_pm   = ndtooned(pm)
   oned_ratio= ndtooned(ratio)
   iminv     = floattoint(minv*nfactor)
   imaxv     = floattoint(maxv*nfactor)
   iinterval = floattoint(interval*nfactor)
   ratio_bin = ispan(iminv, imaxv, iinterval)/int2flt(nfactor)
   nbin      = dimsizes(ratio_bin)
;  DO # OF RATIO BIN LOOP TO REASIGN THE VALUE OF RATIO
   do i = 0, nbin-1
    if (i .lt. nbin-1) then
     index1 = ind(oned_ratio .ge. ratio_bin(i) .and. \
                  oned_ratio .lt. ratio_bin(i+1))
     if (.not.all(ismissing(index1))) then
      index2 = ind_resolve(index1, (/ndim/))
      ratio(index2(:, 0), index2(:, 1)) = ratio_bin(i)
      delete([/index2/])
     end if
     delete([/index1/])
    end if
    if (i .eq. nbin) then
     index1 = ind(oned_ratio .ge. ratio_bin(i))
     if (.not.all(ismissing(index1))) then
      index2 = ind_resolve(index1, (/ndim/))
      ratio(index2(:, 0), index2(:, 1)) = ratio_bin(i)
      delete([/index2/])
     end if
     delete([/index1/])
    end if
   end do

   data = pm + maxpm*(ratio*(nbin-1))


return
end
