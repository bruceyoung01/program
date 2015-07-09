; this code is to read Lincoln's precipitation
; and analyze the Gamma distribution

; input ifle
  inf = 'Precipitation_all_Aug.txt'

; read inf
  readcol, inf, yr, precip, format='(i4, f)', skipline=1


; start to plot histogram
  ps_color, filename = 'precip_analysis.ps'

; find right bin size
; range = [0., 1.0]
; aa= quantile(0.25, precip, range=range) 
  result = sort(precip)
  n = n_elements(precip)
  q25 = precip(result( (n-1)*0.25 + 1))
  q75 = precip(result( (n-1)*0.75 + 1))
  iqr =  q75 - q25

;compute bin size
  c = 2.0 
  h = c * iqr / n ^(1./3) 
  histoplot, precip, binsize=h, position = [0.1, 0.4, 0.9, 0.8],$
             xtitle = 'Precipitation in Lincoln in August (mm)', $
            yrange=[0.0, 40], ystyle=1


; do a fitting
  xmean = mean(precip)
  n = n_elements(precip)
  d = alog(xmean) - 1./n * total(alog(precip))
  alpha = (1 + sqrt(1+4*D/3.) ) / (4*D) 
  bbet = xmean / alpha
  
  x = findgen(301)/300. * fix(max(precip)+1)
  fx = (x/bbet) ^(alpha-1) * exp (-1.* x / bbet) / ( bbet * gamma(alpha))
  oplot, x, fx*n, color=5

; estimate Rain condition in Aug 2011
  x0 = precip(0)
  print, 'probability in Aug. 2011: ', (x0/bbet) ^(alpha-1) * exp (-1.* x0 / bbet) / ( bbet * gamma(alpha)) 


  device, /close
  end
 

  
