pro  plot_mxmn,z,x,y,channel=channel,max_value=max_value, $
	       mn_charsize=mn_charsize,mn_color=mn_color, $
	       mn_font=mn_font,mn_format=mn_format,mn_sym=mn_sym, $
	       mn_thick=mn_thick,mn_xalign=mn_xalign,mn_yalign=mn_yalign, $
	       mx_charsize=mx_charsize,mx_color=mx_color,mx_font=mx_font, $
	       mx_format=mx_format,mx_sym=mx_sym,mx_thick=mx_thick, $
	       mx_xalign=mx_xalign,mx_yalign=mx_yalign,noclip=noclip, $
	       nomax=nomax,nomin=nomin,xsearch=xsearch,ysearch=ysearch

;+
; NAME:
;   plot_mxmn
; PURPOSE:
;   To plot max and min values on a contour plot.  This routine should be
;	called immediately after CONTOUR, using the same data array.
; CATEGORY:
;  graphics
; CALLING SEQUENCE:
;  plot_mxmn,z [,x,y]
; INPUTS:
;   z		= 2-d array used for contours.  This should be exactly
;				the same array as in the contour call.
; OPTIONAL INPUTS:
;   x		= A vector or 2-d array specifying the X coordinates.
;			This should be the same array as in the 
;			contour call.
;   y		= A vector or 2-d array specifying the Y coordinates.
;			This should be the same array as in the 
;			contour call.
; KEYWORD INPUTS:
;   channel	= Same as for contour call.
;   max_value	= Same as for contour call.  Basically treats values
;			>= to this as outside edge values.
;   mn_xalign	= Alignment of minimum labels. (Default = 0.5)
;			0.0 = aligns left edge of text to min point.
;			0.5 = aligns center of text to min point.
;			1.0 = aligns right edge of text to min point.
;   mn_yalign	= Alignment of minimum labels. (Default = 0.5)
;			0.0 = aligns bottom edge of text to min point.
;			0.5 = aligns center of text to min point.
;			1.0 = aligns top edge of text to min point.
;   mn_charsize	= The size of the characters in the minimum labels.
;			The labels are scaled at the same size as the 
;			axis labels.  This keyword allows the minimum 
;			label size to specified independently.  
;			(Default = 1.0)
;   mn_color	= The color index used to draw the minimum labels.
;			(Default = !p.color)
;   mn_font	= The font used to draw the minimum labels.
;			(Default = !p.font)
;   mn_format	= (String) The format for writing the minimum labels.  
;			This is similar to the FORMAT keyword in the 
;			STRING and PRINT calls.  Note that beginning
;			and ending spaces will be trimmed.  
;			(Default = '(F10.1)') 
;   mn_sym	= (String) The symbol to place at the minimum spot.
;			(Default = 'L')
;   mn_thick	= (String) The thickness of the characters used in the minimum
;			labels.  (Default = 1.0)
;   mx_xalign	= Alignment of maximum labels. (Default = 0.5)
;			0.0 = aligns left edge of text to max point.
;			0.5 = aligns center of text to max point.
;			1.0 = ligns right edge of text to max point.
;   mx_yalign	= Alignment of maximum labels. (Default = 0.5)
;			0.0 = aligns bottom edge of text to max point.
;			0.5 = aligns center of text to max point.
;			1.0 = ligns top edge of text to max point.
;   mx_charsize	= The size of the characters in the maximum labels.
;			The labels are scaled at the same size as the 
;			axis labels.  This keyword allows the maximum 
;			label size to specified independently.  
;			(Default = 1.0)
;   mx_color	= The color index used to draw the maximum labels.
;			(Default = !p.color)
;   mx_font	= The font used to draw the maximum labels.
;			(Default = !p.font)
;   mx_format	= (String) The format for writing the maximum labels.  
;			This is similar to the FORMAT keyword in the 
;			STRING and PRINT calls.  Note that beginning
;			and ending spaces will be trimmed.  
;			(Default = '(F10.1)') 
;   mx_sym	= (String) The symbol to place at the maximum spot.
;			(Default = 'L')
;   mx_thick	= (String) The thickness of the characters used in the maximum
;			labels.  (Default = 1.0)
;   /noclip	= If this keyword is set, the labels will not be clipped at the
;			window boundary.
;   /nomax	= If this keyword is set, maximum labels will not be
;			plotted.
;   /nomin	= If this keyword is set, minimum labels will not be
;			plotted.
;   xsearch	= Number of points along the x-axis to search for max 
;			and mins.  (Default = NX/12+1)
;   ysearch	= Number of points along the y-axis to search for max 
;			and mins.  (Default = NY/12+1)
;		The search for max and min values involves a box of 
;			2*xsearch+1 by 2*ysearch+1 points.  If the 
;			center of this box is a max or min then a 
;			label will plotted.
; OUTPUTS
;   None.
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;	Data is plotted to output device.
; RESTRICTIONS:
;	Arrays must be the same as in the contour call.
; PROCEDURE:
;	Uses a mask for checking each grid point with the surrounding grid
;		points. Wherever a max or min is found the value is plotted
;		on the output device.
;REVISION HISTORY:
;   Written, Eric Nash, May 1991
;   er nash 910830 streamlined code. Max and min will no longer plot at the
;	           edge of the plotting window.
;   er nash 920630 fixed several bugs for missing data case
;   $Header $
;-

; *****Get number of dimensions of data array
  z1=reform(z)
  s=size(z1)

; *****Exit if data array does not have two dimensions
  if  (s(0) ne 2)  then  begin
    message,' Array must have two dimensions',/continue
    return
  endif

; *****Number of dimension in x and y directions
  nx=s(1)
  ny=s(2)

; *****X and Y not specified, set them to [0..nx-1],[0..ny-1]
  if  (n_params() eq 1)  then  begin
    xx=rebin(indgen(nx),nx,ny)
    yy=rebin(indgen(1,ny),nx,ny)

; *****Must specify Y and X
  endif  else  if  (n_params() eq 2)  then  begin
    message,'Must specify 1 or 3 variables in procedure call',/continue
    return

; *****X and Y are both specified
  endif  else  begin
    sx=size(x)
    sy=size(y)

;   *****X and Y must have the same number of dimensions
    if  (sx(0) ne sy(0))  then  begin
      message,'X and Y must have the same number of dimensions',/continue
      return
    endif

;   *****X and Y have 1 dimension
    if  (sx(0) eq 1)  then  begin

;     *****X and Y must have the same number of elements as the corresponding
;     *****dimensions in Z
      if  ((sx(1) ne nx) or (sy(1) ne ny))  then  begin
	message,'The dimensions of X and Y must agree with Z',/continue
	return
      endif
      xx=rebin(x,nx,ny)
      yy=rebin(reform(y,1,ny),nx,ny)

;   *****X and Y have 2 dimensions
    endif  else  begin

;     *****X and Y must be the same size as Z
      if  ((sx(1) ne s(1)) or (sx(2) ne s(2)) or (sy(1) ne s(1)) or $
	  (sy(2) ne s(2)))  then  begin
	message,'X and Y must be the same size as Z',/continue
      endif
      xx=x
      yy=y
    endelse
  endelse

; *****Set default channel
  if  (n_elements(channel) eq 0)  then  channel=!p.channel

; *****Check clipping
  if  (n_elements(noclip) eq 0)  then  noclip=0

; *****Get search box size
  if  keyword_set(xsearch)  then  xs=(xsearch > 1) < (nx/2-1)  $
  else  xs=nx/12+1
  if  keyword_set(ysearch)  then  ys=(ysearch > 1) < (ny/2-1)  $
  else  ys=ny/12+1
  xhi=xs+nx-1
  yhi=ys+ny-1

; *****Set default for missing data regions
  zmax=max(z1,min=zmin)
  zmax=zmax+.1*abs(zmax)+1
  zmin=zmin-.1*abs(zmin)-1
  nxt=nx+2*xs
  nyt=ny+2*ys
  ny1=ny+ys
  zz=make_array(nxt,nyt)
  zz(xs,ys)=z1
  zz(0,ys)=rebin(z1(0,*),xs,ny)
  zz(nx+xs,ys)=rebin(z1(nx-1,*),xs,ny)
  zz(0,0)=rebin(zz(*,ys),nxt,ys)
  zz(0,ny1)=rebin(zz(*,ny1-1),nxt,ys)
  if  (n_elements(max_value) eq 0)  then  miss=-1 $
  else  miss=where(zz ge max_value)

; *****Write out max
  if  (keyword_set(nomax) eq 0)  then  begin

;   *****List of current maxima through each iteration
    list=lindgen(nxt*nyt)

;   *****Create a search array containing the data with edges expanded to
;   *****	include the search rectangle. All edge or missing values
;   *****	wil be filled with the data minimum
    if  (miss(0) gt -1) then  zz(miss)=zmax
    l=0l

;   *****Search in the x direction only
    for  ix=1,xs  do  if  (l(0) gt -1)  then  begin

;     *****Shift to the left and right by increments
      t1=shift(zz,ix,0)
      t2=shift(zz,-ix,0)

;     *****Check previously defined maxima to see if they are still maxima
      t=zz(list)
      l=where((t gt t1(list)) and (t gt t2(list)))

;     *****Update list to the still surviving maxima
      list=list(l > 0)
    endif

;   *****If there are still maxima, search in the y direction only
    if  (l(0) gt -1)  then  begin
      for  iy=1,ys  do  if  (l(0) gt -1)  then  begin

;	*****Shift up and down by increments
	t1=shift(zz,0,iy)
	t2=shift(zz,0,-iy)

;	*****Check previously defined maxima to see if they are still maxima
	t=zz(list)
	l=where((t gt t1(list)) and (t gt t2(list)))

;	*****Update list to the still surviving maxima
	list=list(l > 0)
      endif

;     *****If there are still maxima, search in offset directions directions
      if  (l(0) gt -1)  then  begin
	for  iy=1,ys  do  for  ix=1,xs  do  if  (l(0) gt -1)  then  begin

;	  *****Shift in four offset directions
	  t1=shift(zz,ix,iy)
	  t2=shift(zz,ix,-iy)
	  t3=shift(zz,-ix,iy)
	  t4=shift(zz,-ix,-iy)

;	  *****Check previously defined maxima to see if they are still maxima
	  t=zz(list)
	  l=where((t gt t1(list)) and (t gt t2(list)) and (t gt t3(list)) and $
		 (t gt t4(list)))

;	  *****Update list to the still surviving maxima
	  list=list(l > 0)
	endif
      endif
    endif

;   *****Plot maximum
    if  (l(0) ne -1)  then  begin
      l=where(zz(list) ne zmax)
      if  (l(0) ne -1)  then  begin
      list=list(l)

;     *****Set defaults of keywords
      if  (n_elements(mx_sym) eq 0)  then  sym='H'  else  sym=strtrim(mx_sym,2)
      if  (n_elements(mx_format) eq 0)  then  mx_format='(f10.1)'
      if  (n_elements(mx_xalign) eq 0)  then  mx_xalign=.5
      if  (n_elements(mx_yalign) eq 0)  then  yf=!d.y_ch_size/3. $
      else  yf=(mx_yalign*!d.y_ch_size)/1.5
      if  (n_elements(mx_charsize) eq 0)  then  mx_charsize=1.
      if  (n_elements(mx_thick) eq 0)  then  mx_thick=1.
      if  (n_elements(mx_color) eq 0)  then  mx_color=!p.color
      if  (n_elements(mx_font) eq 0)  then  mx_font=!p.font

;     *****Value to plot at max point
      s=sym+'!C'+strtrim(string(zz(list),format=mx_format),2)

;     *****Convert the x and y coordinates from data to device space
      list=(list mod nxt)-xs+(list/nxt-ys)*nx
      out=convert_coord(xx(list),yy(list),/data,/to_device)
      out(1,*)=out(1,*)-yf

;     *****Loop over all max values found
      for i=0,n_elements(list)-1  do  $
        xyouts,out(0,i),out(1,i),s(i),a=mx_xalign,chars=mx_charsize, $
          chart=mx_thick,color=mx_color,fo=mx_font,chan=channel,/dev, $
          noclip=noclip
    endif
  endif
  endif

; *****Write out min
  if  (keyword_set(nomin) eq 0)  then  begin

;   *****List of current minima through each iteration
    list=lindgen(nxt*nyt)

;   *****Create a search array containing the data with edges expanded to
;   *****	include the search rectangle. All edge or missing values
;   *****	wil be filled with the data maximum
    if  (miss(0) gt -1)  then  zz(miss)=zmin
    l=0l

;   *****Search in the x direction only
    for  ix=1,xs  do  if  (l(0) gt -1)  then  begin

;     *****Shift to the left and right by increments
      t1=shift(zz,ix,0)
      t2=shift(zz,-ix,0)

;     *****Check previously defined minima to see if they are still minima
      t=zz(list)
      l=where((t lt t1(list)) and (t lt t2(list)))

;     *****Update list to the still surviving minima
      list=list(l > 0)
    endif

;   *****If there are still minima, search in the y direction only
    if  (l(0) gt -1)  then  begin
      for  iy=1,ys  do  if  (l(0) gt -1)  then  begin

;	*****Shift up and down by increments
	t1=shift(zz,0,iy)
	t2=shift(zz,0,-iy)

;	*****Check previously defined minima to see if they are still minima
	t=zz(list)
	l=where((t lt t1(list)) and (t lt t2(list)))

;	*****Update list to the still surviving minima
	list=list(l > 0)
      endif

;     *****If there are still minima, search in offset directions directions
      if  (l(0) gt -1)  then  begin
	for  iy=1,ys  do  for  ix=1,xs  do  if  (l(0) gt -1)  then  begin

;	  *****Shift in four offset directions
	  t1=shift(zz,ix,iy)
	  t2=shift(zz,ix,-iy)
	  t3=shift(zz,-ix,iy)
	  t4=shift(zz,-ix,-iy)

;	  *****Check previously defined minima to see if they are still minima
	  t=zz(list)
	  l=where((t lt t1(list)) and (t lt t2(list)) and (t lt t3(list)) and $
		 (t lt t4(list)))

;	  *****Update list to the still surviving minima
	  list=list(l > 0)
	endif
      endif
    endif

;   *****Plot minimum
    if  (l(0) ne -1)  then  begin
      l=where(zz(list) ne zmin)
      if  (l(0) ne -1)  then  begin
      list=list(l)

;     *****Set defaults of keywords
      if  (n_elements(mn_sym) eq 0)  then  sym='L'  else  sym=strtrim(mn_sym,2)
      if  (n_elements(mn_format) eq 0)  then  mn_format='(f10.1)'
      if  (n_elements(mn_xalign) eq 0)  then  mn_xalign=.5
      if  (n_elements(mn_yalign) eq 0)  then  yf=!d.y_ch_size/3. $
      else  yf=(mn_yalign*!d.y_ch_size)/1.5
      if  (n_elements(mn_charsize) eq 0)  then  mn_charsize=1.
      if  (n_elements(mn_thick) eq 0)  then  mn_thick=1.
      if  (n_elements(mn_color) eq 0)  then  mn_color=!p.color
      if  (n_elements(mn_font) eq 0)  then  mn_font=!p.font

;     *****Value to plot at min point
      s=sym+'!C'+strtrim(string(zz(list),format=mn_format),2)

;     *****Convert the x and y coordinates from data to device space
      list=(list mod nxt)-xs+(list/nxt-ys)*nx
      out=convert_coord(xx(list),yy(list),/data,/to_device)
      out(1,*)=out(1,*)-yf

;     *****Loop over all min values found
      for i=0,n_elements(list)-1  do  $
        xyouts,out(0,i),out(1,i),s(i),a=mn_xalign,chars=mn_charsize, $
        chart=mn_thick,color=mn_color,fo=mn_font,chan=channel,/dev, $
        noclip=noclip
    endif
  endif
  endif

; *****That's all folks
  return
END
