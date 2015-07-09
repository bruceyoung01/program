; $ID: plot_error_bar.ncl V01 02/21/2012 15:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_error_bar PLOTS ERROR BAR ON THE GIVEN PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                  [---]
;  (2 ) plot   (graphic): PLOT TO ADD ERROR BAR ON                      [---]
;  (3 ) ecolor (string) : COLOR OF ERROR BAR                            [---]
;  (4 ) data   (float)  : AVERAGE DATA                                  [---]
;  (5 ) datastd(float)  : STANDARD DEVIATION OF DATA                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/21/2012)
;******************************************************************************

undef("plot_error_bar")
procedure plot_error_bar(wks      :graphic, plot    :graphic, \ ; INPUT
                         ecolor   :string,                    \ ; INPUT
                         data     :float,   datastd :float)     ; INPUT

begin

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                  = True
   eres@gsLineColor      = ecolor
   eres@gsLineThicknessF = 2.0

   dim  = dimsizes(data)
   ndim = dim(0)
   do j = 0, ndim-1
     k = j + 1
     if(.not.ismissing(data(j)) .and. \
        .not.ismissing(datastd(j))) then
      gsn_polyline(wks, plot, (/k, k/), \
                              (/data(j)-datastd(j),\
                                data(j)/), eres)
      gsn_polyline(wks, plot, (/k-0.2, k+0.2/), \
                              (/data(j)-datastd(j),\
                                data(j)-datastd(j)/), eres)
      gsn_polyline(wks, plot, (/k, k/), \
                              (/data(j),   \
                                data(j)+datastd(j)/), eres)
      gsn_polyline(wks, plot, (/k-0.2, k+0.2/), \
                              (/data(j)+datastd(j),\
                                data(j)+datastd(j)/), eres)
     end if
    end do
return
end
