 function histo, data, p, MinD=MinD, MaxD=MaxD, NBins=NBins, $
    draw=draw, Xlog=Xlog, pos=pos, Oplot=Oplot, $
    color=color, line=line, Xtitle=Xtitle, Title=Title, yrange=yrange, $
    cumulative=cumulative, xrange=xrange, xticks=xticks, verbose=verbose

 if n_elements(data) eq 0 then return, -1
 if n_elements(p)    eq 0 then p = 0.20  ; 20%
 if n_elements(MinD) eq 0 then MinD = Min(Data)
 if n_elements(MaxD) eq 0 then MaxD = Max(Data)
 if n_elements(NBins) eq 0 then $
    NBins    = Float(N_elements(Data)) / 10.

 @define_plot_size

 Binsize  = ( MaxD - MinD ) / NBINS

 Q = [1,2.5,16,50,84,97.5,99]*0.01

 Table  = Histogram( data, Binsize=Binsize, Min=MinD, Max=MaxD, /NAN )
 Value  = Binsize*Findgen(N_elements(Table)) + MinD
 Result = Table/Total(Table)  ; normalization
 Pdf    = Total(Result,/cumul) ; cumulative PDF
 sot    = where(pdf gt 0.0 and pdf lt 0.99)

 if Keyword_set(cumulative) then begin
    if n_elements(yrange) eq 0 then yrange = [MinD, MaxD]

;    V = Pdf
;    For D = 0, N_elements(V)-1 do V[D] = -gauss_cvf(Pdf[D])

    if keyword_set(Oplot) then $
       OPlot, Pdf[sot]*100., Value[sot], color=color, line=line, Thick=Thick, psym=8 $
    Else $
       Plot, Pdf[sot]*100., Value[sot], color=color, line=line, $
         Thick=Thick, XTitle = 'Cumulative Pdf (%)', $
         charsize=tcharsize, charthick=charthick, position=pos, $
         Xlog=Xlog, Ytitle=Xtitle, Title=Title, psym=8, xrange=xrange, $
         xstyle=2, xticks=xticks, symsize=symsize, yrange=yrange, ystyle=1, $
         xcharsize=charsize, ycharsize=charsize

 end else begin

    ; Standard frequency plot
    if N_elements(yrange) eq 0 then yrange = [Min(Result), Max(Result)]*100.

    if keyword_set(Oplot) then $
       OPlot, Value, Result*100., color=color, line=line, Thick=Thick $
    Else $
       Plot, Value, Result*100., color=color, line=line, $
         Thick=Thick, YTitle = 'Pdf (%)', $
         charsize=charsize, charthick=charthick, position=pos, $
         Xlog=Xlog, Xtitle=Xtitle, Title=Title, yrange=yrange, ystyle=1, $
         xrange=xrange, xstyle=1, xcharsize=charsize, ycharsize=charsize
 end

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
