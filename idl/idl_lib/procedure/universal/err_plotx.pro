pro err_plotx, y, xlow, xhigh, width = width, $
    _extra = extra_keywords

; Check arguments
  if(n_params() ne 3) then message, $
    'Usage: err_plot, y, xlow, xhigh'
  if(n_elements(y) eq 0) then $
    message, 'Argument Y is undifined'
  if(n_elements(xlow) eq 0) then $
    message, 'Argument XLOW is undefined'
  if(n_elements(xhigh) eq 0) then $
    message, 'Argument XHIGH is undefined'

; check keywords
  if(n_elements(width) eq 0) then width = 0.02

; plot the error bars
  for index = 0L, n_elements(y) - 1L do begin
; plot vertical bar using data coordinates
   ydata = [y[index], y[index]]
   xdata = [xlow[index], xhigh[index]]
   plots, xdata, ydata, /data, noclip = 0, $
         _extra = extra_keywords

; compute horizontal bar width in normal coordinates
   normalwidth = (!x.window[1] - !x.window[0])*width
  
; plot horizontal bar using normal coordinates
   lower = convert_coord(xlow[index], y[index], $
          /data, /to_normal)
   upper = convert_coord(xhigh[index], y[index], $
          /data, /to_normal)
   ydata = [lower[0] - 0.5*width, lower[0] + 0.5*width]
   xlower = [lower[1], lower[1]]
   xupper = [upper[1], upper[1]]
   plots, xlower, ydata, /normal, noclip = 0, $
         _extra = extra_keywords
   plots, xupper, ydata, /normal, noclip = 0, $
         _extra = extra_keywords

endfor
end  
