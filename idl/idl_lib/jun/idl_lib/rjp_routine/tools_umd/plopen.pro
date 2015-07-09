pro  plopen,type,fn=fn,color=color,portrait=portrait,landscape=landscape

;+
; NAME:
;   plopen
; PURPOSE:
;   Opens a tek, postscript, or encapsulated postscript file for graphics 
;   output.
; CATEGORY:
;   plotting
; CALLING SEQUENCE:
;   plopen
;   plopen,type
; INPUTS:
;   type  = (String) File type. Must be : 'TEK', 'PS', 'EPS', or 'CPS'. 
;             Defaults to 'PS'.
; KEYWORDS:
;   (input)
;   fn        = (String) File name.  Will be appended with '.tek', ',ps', 
;                 '.eps','.cps'
;   color     = (Integer) Color number to use. See the xlct routine for this 
;                 value.
;   portrait  = (Any) Set this to do portrait orientation
;   landscape = (Any) Set this to do landscape orientation (default).
; OUTPUTS
; COMMON BLOCKS: (PLOPCL)
;   old_device = Device type to reset to when calling PLCLOSE.
; SIDE EFFECTS:
;   Opens a file named fn.tek, fn.ps, fn.eps, or fn.cps.
; RESTRICTIONS:
;   Will generate only tek, postscript, encapsulated postscript files, or
;   color postscript files.
; PROCEDURE:
;   Saves old device and opens output file.
; MODIFICATION HISTORY:
;   nash  added portrait capability
;    $Header$
;-

  common  plopcl,old_device

; *****set default for TYPE and FN
  if  (n_elements(type) eq 0)  then  type = 'PS'
  if  (n_elements(fn) eq 0)  then  fn = 'idl'
  port = ((not keyword_set(landscape)) and (keyword_set(portrait)))
  if  (port)  then  begin
    xsize = 7
    xoffset = .75
    ysize = 9.5
    yoffset = .75
  endif
;    device,/portrait,xsize=7,xoffset=.75,ysize=9.5,yoffset=1.5,/inches

; *****save old device so that it can be restored in PLCLOSE
  old_device = !d.name 

; *****set plot to device type wanted
  case  strupcase(type)  of
    'CPS' : begin
              set_plot,'PS'
              device,file=fn+'.cps',/color,encap=0,/land
              if  (port)  then  device,/inch,/port, $
                xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset
              if  (n_elements(color) ne 0)  then  loadct,color
            end
    'EPS' : begin
              set_plot,'PS'
              device,file=fn+'.eps',/encap,/land
              if  (port)  then  device,/inch,/port, $
                xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset
            end
    'PS'  : begin
              set_plot,'PS'
              device,file=fn+'.ps',encap=0,color=0,/land
              if  (port)  then  device,/inch,/port, $
                xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset
            end
    'TEK' : begin
              set_plot,'TEK'
              device,/tek4100,file=fn+'.tek',/tty
            end
    else  : begin
              message,/cont,'Type must be TEK, PS, EPS, or CPS - Respecify'
              return
            end
  endcase
  return
end
