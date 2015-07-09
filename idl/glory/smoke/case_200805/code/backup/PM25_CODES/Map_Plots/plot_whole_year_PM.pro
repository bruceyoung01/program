;
;  plot (1) whole year PM variation
;       (2) yearly average diurnal variation
;
;  USING variable: all_available_PM(nday,nhour)
;                  yearly_PM[iyear,ihour]
;

   if (yearly_PM[iyear,0] gt 0) then begin

     title01 = '!6Yearly Averge PM!d2.5!n  Year:'+STRING(THIS_YEAR,format='(I4)') + $
               ' Site: '+ STATE_LABL[isite]+'-'+COUNTY_LABL[isite]+'-'+SITE_LABL[isite]

     title02 = '!6Daily Averge PM!d2.5!n  Year:'+STRING(THIS_YEAR,format='(I4)') + $
               ' Site: '+ STATE_LABL[isite]+'-'+COUNTY_LABL[isite]+'-'+SITE_LABL[isite]

    max_y = max(yearly_PM[iyear,*])
    min_y = min(yearly_PM[iyear,*]) 
    range_yearly_PM = max_y - min_y
    max_y = max_y + range_yearly_PM / 2.
    min_y = min_y - range_yearly_PM / 2.

    plot, indgen(nhour), yearly_PM[iyear,*], $
           color=1, xrange = [0,24], yrange=[min_y,max_y], $
           xstyle=1, ystyle=1, $
           xtitle='!6Hour', ytitle='!6Average PM!d2.5!n',$
           title=title01, position = [0.2,0.6,0.8,0.9]

    plot, [10],[10], /nodata,/noerase, color=1, $
          xrange=[-1,nday_THIS_YEAR], yrange=[0,50], $
           xstyle=1, ystyle=1, $
           xtitle='!6Day', ytitle='!6Daily PM!d2.5!n',$
           title = title02, position = [0.2,0.1,0.8,0.4]

    for iiiday = 0, nday_THIS_YEAR-1 do begin

       idx_iiiday = where(all_available_PM(iiiday,*) gt 0, count_iiiday )
       if (count_iiiday eq 24) then begin
         plots, [iiiday,iiiday], [0,mean(all_available_PM[iiiday,idx_iiiday])], color=1
       endif
    
    endfor 

  endif
  
