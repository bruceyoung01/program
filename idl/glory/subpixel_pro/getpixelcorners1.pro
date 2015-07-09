;+
; NAME:
; getPixelCorners
; 
; PURPOSE:
; This function returns the corner values of the values 
; in an array.
; 
; AUTHOR:
; Luke Ellison
; 
; CREATED:
; March 23, 2010
; 
; SYNTAX:
; array = getPixelCorners(Xdata [, Ydata] [, Zdata] 
;   [, /sidemethod] [, /flatten] [, /condense] [, /edges] 
;   [, /MODIScorrection] [, /excludeMODISoverlap] 
;   [, line=variable] [, sample=variable] 
;   [, index=variable])
; 
; INPUTS:
; Xdata: An array representing the data in the x-axis.
; 
; Ydata: An optional array representing the data in the 
; y-axis that corresponds to the Xdata array.
; 
; Zdata: An optional array representing the data in the 
; z-axis that corresponds to the Xdata array.
; 
; KEYWORDS:
; sidemethod: The default method used to calculate the 
; pixel corners is to average the surrounding four points 
; of each corner.  If sidemethod is set, then the four 
; surrounding pixels of each pixel are used to find the 
; midpoint value between each of these pixels, and those 
; values used to calculate the corners.
; 
; flatten: If set, getPixelCorners will return a semi-
; flattened array where the first dimension represents 
; all of the pixels; whereas the defaultwould be to have 
; the first two dimensions correspond to the dimensions 
; of Xdata.  This keyword is automatically set if 
; excludeMODISoverlap is set.
; 
; condense: If set, and if keywords sidemethods, flatten, 
; MODIScorrection and excludeMODISoverlap are not set, 
; then the corners are returned in a 2-D array with 
; dimensions corresponding to Xdata so that any corner is 
; not reported twice.
; 
; edges: If set, the corners for the outter pixels are 
; approximated and included.  The default is to exclude 
; the outter pixels.
; 
; MODIScorrection: If set, the pixel corners that need to 
; be corrected due to MODIS' overlapping pixels are 
; corrected for using symmetry.
; 
; excludeMODISoverlap: If set, MODIS' overlapping pixels 
; are excluded from the returned array.
; 
; OUTPUTS:
; array: Returns an m x n x 4 x 2 array where m and n are 
; two less than the dimensions of Xdata.  The third 
; dimension represents the corners of each pixel and the 
; last dimension represents a latitude/longitude pair.
; 
; line: Returns the indices of the first dimension of 
; Xdata that are in the returned array.
; 
; sample: Returns the indices of the second dimension of 
; Xdata that are in the returned array.
; 
; index: Returns the indices of Xdata that are in the 
; returned array.
; 
; USER ROUTINES:
; excludeScannerOverlap
; 
; REVISION HISTORY:
; 7 Apr 10 by Luke Ellison: Made index to be flattened 
; always.
; 
; 20 Jul 10 by Luke Ellison: Replaced obsoleted 
; excludeMODISoverlap routine with excludeScannerOverlap.
; 
; 2 Sep 10 by Luke Ellison: Updated arguments to 
; excludeScannerOverlap.
;-

function getPixelCorners1, Xdata, Ydata, Zdata, sidemethod=sidemethod, $
  flatten=flatten, condense=condense, edges=edges, $
  MODIScorrection=MODIScorrection, $
  excludeMODISoverlap=excludeMODISoverlap, line=line, sample=sample, $
  index=index
	on_error, 2
	X = reform(Xdata)
	if keyword_set(Ydata) then begin
		Y = reform(Ydata)
		if keyword_set(Zdata) then begin
			Z = reform(Zdata)
			ndims = 3
		endif else $
		  ndims = 2
	endif else $
	  ndims = 1
	
	;get dimensions of arrays
	Xsize = size(X, /dim)
	
	;extend data if edges is specified
	if keyword_set(edges) then begin
		X = [2*X[0,*]-X[1,*], X, 2*X[Xsize[0]-1,*]-X[Xsize[0]-2,*]]
		X = [[2*X[*,0]-X[*,1]], [X], [2*X[*,Xsize[1]-1]-X[*,Xsize[1]-2]]]
		if (ndims ge 2) then begin
			Y = [2*Y[0,*]-Y[1,*], Y, 2*Y[Xsize[0]-1,*]-Y[Xsize[0]-2,*]]
			Y = [[2*Y[*,0]-Y[*,1]], [Y], $
			  [2*Y[*,Xsize[1]-1]-Y[*,Xsize[1]-2]]]
			if (ndims ge 3) then begin
				Z = [2*Z[0,*]-Z[1,*], Z, $
				  2*Z[Xsize[0]-1,*]-Z[Xsize[0]-2,*]]
				Z = [[2*Z[*,0]-Z[*,1]], [Z], $
				  [2*Z[*,Xsize[1]-1]-Z[*,Xsize[1]-2]]]
			endif
		endif
		Xsize = size(X, /dim)
	endif
	
	line = indgen(Xsize[0]-2) + (~ keyword_set(edges))
	if keyword_set(sidemethod) then begin
		;calculate coordinates of sides of pixels
		Xmid = X[1:Xsize[0]-2,1:Xsize[1]-2]
		Xpl = (Xmid + X[2:Xsize[0]-1, 1:Xsize[1]-2])/2
		Xnl = (Xmid + X[0:Xsize[0]-3, 1:Xsize[1]-2])/2
		Xps = (Xmid + X[1:Xsize[0]-2, 2:Xsize[1]-1])/2
		Xns = (Xmid + X[1:Xsize[0]-2, 0:Xsize[1]-3])/2
		if (ndims ge 2) then begin
			Ymid = Y[1:Xsize[0]-2,1:Xsize[1]-2]
			Ypl = (Ymid + Y[2:Xsize[0]-1, 1:Xsize[1]-2])/2
			Ynl = (Ymid + Y[0:Xsize[0]-3, 1:Xsize[1]-2])/2
			Yps = (Ymid + Y[1:Xsize[0]-2, 2:Xsize[1]-1])/2
			Yns = (Ymid + Y[1:Xsize[0]-2, 0:Xsize[1]-3])/2
			if (ndims ge 3) then begin
				Zmid = Z[1:Xsize[0]-2,1:Xsize[1]-2]
				Zpl = (Zmid + Z[2:Xsize[0]-1, 1:Xsize[1]-2])/2
				Znl = (Zmid + Z[0:Xsize[0]-3, 1:Xsize[1]-2])/2
				Zps = (Zmid + Z[1:Xsize[0]-2, 2:Xsize[1]-1])/2
				Zns = (Zmid + Z[1:Xsize[0]-2, 0:Xsize[1]-3])/2
			endif
		endif
		
		;calculate coordinates of corners of pixels
		corners = fltarr(Xsize[0]-2, Xsize[1]-2, 4, ndims)
		corners[*,*,0,0] = Xnl + (Xns-Xmid)
		corners[*,*,1,0] = Xnl + (Xps-Xmid)
		corners[*,*,2,0] = Xpl + (Xps-Xmid)
		corners[*,*,3,0] = Xpl + (Xns-Xmid)
		if (ndims ge 2) then begin
			corners[*,*,0,1] = Ynl + (Yns-Ymid)
			corners[*,*,1,1] = Ynl + (Yps-Ymid)
			corners[*,*,2,1] = Ypl + (Yps-Ymid)
			corners[*,*,3,1] = Ypl + (Yns-Ymid)
			if (ndims ge 3) then begin
				corners[*,*,0,2] = Znl + (Zns-Zmid)
				corners[*,*,1,2] = Znl + (Zps-Zmid)
				corners[*,*,2,2] = Zpl + (Zps-Zmid)
				corners[*,*,3,2] = Zpl + (Zns-Zmid)
			endif
		endif
		
		;if MODIScorrection if specified, recalculate location of 
		;corners at the edges of each scan (scans are 10 pixels wide)
		if keyword_set(MODIScorrection) then begin
			order = where(((line mod 10) eq 0) and (line ne max(line)))
			corners[order,*,0,0] = 2*Xns[order,*]-corners[order+1,*,0,0]
			corners[order,*,1,0] = 2*Xps[order,*]-corners[order+1,*,1,0]
			if (ndims ge 2) then begin
				corners[order,*,0,1] = 2*Yns[order,*]- $
				  corners[order+1,*,0,1]
				corners[order,*,1,1] = 2*Yps[order,*]- $
				  corners[order+1,*,1,1]
				if (ndims ge 3) then begin
					corners[order,*,0,2] = 2*Zns[order,*]- $
					  corners[order+1,*,0,2]
					corners[order,*,1,2] = 2*Zps[order,*]- $
					  corners[order+1,*,1,2]
				endif
			endif
			order = where(((line mod 10) eq 9) and (line ne min(line)))
			corners[order,*,2,0] = 2*Xps[order,*]-corners[order-1,*,2,0]
			corners[order,*,3,0] = 2*Xns[order,*]-corners[order-1,*,3,0]
			if (ndims ge 2) then begin
				corners[order,*,2,1] = 2*Yps[order,*]- $
				  corners[order-1,*,2,1]
				corners[order,*,3,1] = 2*Yns[order,*]- $
				  corners[order-1,*,3,1]
				if (ndims ge 3) then begin
					corners[order,*,2,2] = 2*Zps[order,*]- $
					  corners[order-1,*,2,2]
					corners[order,*,3,2] = 2*Zns[order,*]- $
					  corners[order-1,*,3,2]
				endif
			endif
		endif
		
		;flatten array if specified
		if (keyword_set(flatten) or $
		  keyword_set(excludeMODISoverlap)) then begin
			Csize = size(corners, /dim)
			temp = corners
			corners = fltarr(product(Csize[0:1]), Csize[2], Csize[3])
			corners[*,*,*] = temp
		endif
	endif else begin
		;calculate corner directly from mean of four surrounding pixels
		corners = fltarr(Xsize[0]-1, Xsize[1]-1, ndims)
		corners[*,*,0] = (X[0:Xsize[0]-2, 0:Xsize[1]-2] + $
		  X[0:Xsize[0]-2, 1:Xsize[1]-1] + $
		  X[1:Xsize[0]-1, 1:Xsize[1]-1] + $
		  X[1:Xsize[0]-1, 0:Xsize[1]-2])/4.
		if (ndims ge 2) then begin
			corners[*,*,1] = (Y[0:Xsize[0]-2, 0:Xsize[1]-2] + $
			  Y[0:Xsize[0]-2, 1:Xsize[1]-1] + $
			  Y[1:Xsize[0]-1, 1:Xsize[1]-1] + $
			  Y[1:Xsize[0]-1, 0:Xsize[1]-2])/4.
			if (ndims ge 3) then $
			  corners[*,*,2] = (Z[0:Xsize[0]-2, 0:Xsize[1]-2] + $
			    Z[0:Xsize[0]-2, 1:Xsize[1]-1] + $
			    Z[1:Xsize[0]-1, 1:Xsize[1]-1] + $
			    Z[1:Xsize[0]-1, 0:Xsize[1]-2])/4.
		endif
		
		;alter array if condense is not specified
		if (keyword_set(flatten) or not keyword_set(condense) or $
		  keyword_set(MODIScorrection) or $
		  keyword_set(excludeMODISoverlap)) then begin
			Csize = size(corners, /dim)
			temp = corners
			corners = fltarr(Csize[0]-1, Csize[1]-1, 4, Csize[2])
			corners[*,*,0,*] = temp[0:Csize[0]-2, 0:Csize[1]-2, *]
			corners[*,*,1,*] = temp[0:Csize[0]-2, 1:Csize[1]-1, *]
			corners[*,*,2,*] = temp[1:Csize[0]-1, 1:Csize[1]-1, *]
			corners[*,*,3,*] = temp[1:Csize[0]-1, 0:Csize[1]-2, *]
		
			;if MODIScorrection if specified, recalculate location of 
			;corners at the edges of each scan (scans are 10 pixels wide)
			if keyword_set(MODIScorrection) then begin
				Xmid = X[1:Xsize[0]-2,1:Xsize[1]-2]
				Xps = (Xmid + X[1:Xsize[0]-2, 2:Xsize[1]-1])/2
				Xns = (Xmid + X[1:Xsize[0]-2, 0:Xsize[1]-3])/2
				if (ndims ge 2) then begin
					Ymid = Y[1:Xsize[0]-2,1:Xsize[1]-2]
					Yps = (Ymid + Y[1:Xsize[0]-2, 2:Xsize[1]-1])/2
					Yns = (Ymid + Y[1:Xsize[0]-2, 0:Xsize[1]-3])/2
					if (ndims ge 3) then begin
						Zmid = Z[1:Xsize[0]-2,1:Xsize[1]-2]
						Zps = (Zmid + Z[1:Xsize[0]-2, 2:Xsize[1]-1])/2
						Zns = (Zmid + Z[1:Xsize[0]-2, 0:Xsize[1]-3])/2
					endif
				endif
				order = where(((line mod 10) eq 0) and $
				  (line ne max(line)))
				corners[order,*,0,0] = 2*Xns[order,*]- $
				  corners[order+1,*,0,0]
				corners[order,*,1,0] = 2*Xps[order,*]- $
				  corners[order+1,*,1,0]
				if (ndims ge 2) then begin
					corners[order,*,0,1] = 2*Yns[order,*]- $
					  corners[order+1,*,0,1]
					corners[order,*,1,1] = 2*Yps[order,*]- $
					  corners[order+1,*,1,1]
					if (ndims ge 3) then begin
						corners[order,*,0,2] = 2*Zns[order,*]- $
						  corners[order+1,*,0,2]
						corners[order,*,1,2] = 2*Zps[order,*]- $
						  corners[order+1,*,1,2]
					endif
				endif
				order = where(((line mod 10) eq 9) and $
				  (line ne min(line)))
				corners[order,*,2,0] = 2*Xps[order,*]- $
				  corners[order-1,*,2,0]
				corners[order,*,3,0] = 2*Xns[order,*]- $
				  corners[order-1,*,3,0]
				if (ndims ge 2) then begin
					corners[order,*,2,1] = 2*Yps[order,*]- $
					  corners[order-1,*,2,1]
					corners[order,*,3,1] = 2*Yns[order,*]- $
					  corners[order-1,*,3,1]
					if (ndims ge 3) then begin
						corners[order,*,2,2] = 2*Zps[order,*]- $
						  corners[order-1,*,2,2]
						corners[order,*,3,2] = 2*Zns[order,*]- $
						  corners[order-1,*,3,2]
					endif
				endif
			endif
			
			;flatten array if specified
			if (keyword_set(flatten) or $
			  keyword_set(excludeMODISoverlap)) then begin
				Csize = size(corners, /dim)
				temp = corners
				corners = fltarr(product(Csize[0:1]), Csize[2], Csize[3])
				corners[*,*,*] = temp
			endif
		endif
	endelse
	
	;build line, sample and index arrays
	line = (indgen(Xsize[0]-2)+(~ keyword_set(edges))) # $
	  replicate(1, Xsize[1]-2)
	sample = (indgen(Xsize[1]-2)+(~ keyword_set(edges))) ## $
	  replicate(1, Xsize[0]-2)
	index = make_array(Xsize-2*keyword_set(edges), /index)
	if not keyword_set(edges) then $
	  index = index[1:Xsize[0]-2, 1:Xsize[1]-2]
	index = reform(index, n_elements(index))
	
	;exclude overlapping MODIS pixels if specified
	if keyword_set(excludeMODISoverlap) then begin
		order = excludeScannerOverlap(line=line, sample=sample, /MODIS, $
		  /shift, /overwrite)
		corners = corners[order,*,*]
		index = index[order]
	endif
	
	;return
	return, reform(corners)
end
