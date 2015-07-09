
; function quantile,
;   find out the 
;
; Author , Rokjin J. Park

 function quantile, data, p, MinD=MinD, MaxD=MaxD, draw=draw, NBins=NBins, $
     verbose=verbose

 if n_elements(data) eq 0 then return, -1
 if n_elements(p)    eq 0 then p = 0.25  ; 25%
 if n_elements(MinD) eq 0 then MinD = Min(Data)
 if n_elements(MaxD) eq 0 then MaxD = Max(Data)
 if n_elements(Nbins) eq 0 then  NBins    = Float(N_elements(Data)) / 10.

 Binsize  = ( MaxD - MinD ) / NBINS

 Table  = Histogram( data, Binsize=Binsize, Min=MinD, Max=MaxD )
 Value  = Binsize*Findgen(N_elements(Table)) + MinD
 Result = Table/Total(Table)  ; normalization
 Pdf    = Total(Result,/cumul) ; cumulative PDF

 If Keyword_set(Draw) then begin
   @define_plot_size
   !P.multi=[0,1,2,0,0]

   Pos = cposition(1,2,xoffset=[0.1,0.1],yoffset=[0.05,0.1], $
           xgap=0.1,ygap=0.15,order=0)

   Plot, Value, Result*100., color=1, YTitle = 'Pdf (%)', charsize=charsize, $
      charthick=charthick, position=pos[*,0]

   Plot, Value, Pdf*100., color=1, YTitle = 'Cummu. Pdf (%)', charsize=charsize, $
     charthick=charthick, position=pos[*,1]

 Endif

 I = p
 For D = 0, N_elements(p)-1 do begin
     I[D] = Max(Where(Pdf le p[D]))
     If I[D] eq -1 then begin
       print, 'No matching found'
       print, 'Choose mininum value instead'
       I[D] = 0L
     end
 End

 if Keyword_set(verbose) then begin

 print, '============================='
 print, 'Number of data         ',  N_elements(Data)
 print, 'Number of bins         ',  N_elements(Table)
 print, 'Sample mininum value of ', Min(Data)
 print, 'Sample maximum value of ', Max(Data)
 print, 'Sample mean             ', Mean(Data)
 print, 'Sample median           ', Median(Data)
 print, 'Sample stdev            ', stdev(Data)
 print, p, 'Quntile of sample', Value[I]
 print, '============================='

 end

 return, {mean:mean(Data), median:median(data), std:stdev(data), $
          result:result*100., p:Value[I]}

 end
