pro err_ploty, x, ylow, yhigh, width = width, $
    _extra = extra_keywords

; Check arguments
  if(n_params() ne 3) then message, $
    'Usage: err_plot, x, ylow, yhigh'
  if(n_elements(x) eq 0) then $
    message, 'Argument X is undifined'
  if(n_elements(ylow) eq 0) then $
    message, 'Argument YLOW is undefined'
  if(n_elements(yhigh) eq 0) then $
    message, 'Argument YHIGH is undefined'

; check keywords
  if(n_elements(width) eq 0) then width = 0.02

; plot the error bars
  for index = 0L, n_elements(x) - 1L do begin
; plot vertical bar using data coordinates
   xdata = [x[index], x[index]]
   ydata = [ylow[index], yhigh[index]]
   plots, xdata, ydata, /data, noclip = 0, $
         _extra = extra_keywords

; compute horizontal bar width in normal coordinates
   normalwidth = (!x.window[1] - !x.window[0])*width
  
; plot horizontal bar using normal coordinates
   lower = convert_coord(x[index], ylow[index], $
          /data, /to_normal)
   upper = convert_coord(x[index], yhigh[index], $
          /data, /to_normal)
   xdata = [lower[0] - 0.5*width, lower[0] + 0.5*width]
   ylower = [lower[1], lower[1]]
   yupper = [upper[1], upper[1]]
   plots, xdata, ylower, /normal, noclip = 0, $
         _extra = extra_keywords
   plots, xdata, yupper, /normal, noclip = 0, $
         _extra = extra_keywords

endfor
end  
