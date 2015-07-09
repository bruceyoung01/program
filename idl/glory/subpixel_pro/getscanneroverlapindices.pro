;+
; NAME:
; getScannerOverlapIndices
; 
; PURPOSE:
; This function returns ranges of scan indices that do 
; not overlap any pixels from the previous scan, assuming 
; perfectly flat terrain.
; 
; AUTHOR:
; Luke Ellison
; 
; CREATED:
; April 7, 2010
; 
; SYNTAX:
; array = getScannerOverlapIndices([percentOverlap] 
;   {, height=variable, nadirPixelWidth=variable, 
;   numScanPixels=variable, scanWidth=variable} | 
;   , /MODIS [, /shift])
; 
; INPUTS:
; percentOverlap: The percentage of overlap needed in 
; order to exclude a pixel.  The default is 50.
; 
; height: The satellite's altitude.
; 
; nadirPixelWidth: The width of a pixel at nadir.
; 
; numScanPixels: The number of pixels along scan.
; 
; scanWidth: The width of a scan in pixels (along track).
; 
; MODIS: Set this keyword to use MODIS values for height, 
; nadirPixelWidth, numScanPixels and scanWidth.
; 
; KEYWORDS:
; shift: Perform a shifting of the results so that the 
; outter edges of the scan have the most overlap.
; 
; OUTPUTS:
; array: A scanWidth x 2 array of along-scan indices 
; defining the limits of the range of non-overlapping 
; pixels.
; 
; USER ROUTINES:
; None.
; 
; REVISION HISTORY:
; 5 May 10 by Luke Ellison: Fixed error when 0 entered 
; for percentOverlap.
;-

function getScannerOverlapIndices, percentOverlap, height=height, $
  nadirPixelWidth=nadirPixelWidth, numScanPixels=numScanPixels, $
  scanWidth=scanWidth, MODIS=MODIS, shift=shift
	on_error, 2
	if (size(percentOverlap, /type) eq 0) then $
	  percentOverlap = 50
	
	;Inputs
	case (1) of
		keyword_set(MODIS): begin
			h = 705.
			p = 1.
			N = 1354
			ntrack = 10
		end
		else: begin
			h = float(height)
			p = float(nadirPixelWidth)
			N = numScanPixels
			ntrack = scanWidth
		end
	endcase
	
	;Variables
	Re = 6371.
	r = Re + h
	s = p/h
	
	;Build MODIS track and scan
	track = findgen(ntrack) # replicate(1,N)
	scan = findgen(N) ## replicate(1,ntrack)
	
	;Build pixel widths
	theta = s*(scan+(1-N)/2.)
	Dt = r*s*(cos(theta)-sqrt((Re/r)^2-(sin(theta))^2))
	
	;Get overlapping pixels
	overlap = ((ntrack*floor(track/ntrack)+ntrack/2.)*p + $
	  ((track mod ntrack)-ntrack/2.)*Dt) lt $
	  ((ntrack*floor(track/ntrack)-ntrack/2.)*p + $
	  (ntrack/2.-percentOverlap/100.)*Dt)
	
	;Get indices
	indices = intarr(ntrack, 2)
	for i=0, ntrack-1 do begin
		order = where(~ overlap[i,*])
		indices[i,*] = ((order ne [-1]) ? [min(order), max(order)] : $
		  [-1,-1])
	endfor	;i
	
	;Shift results
	if (keyword_set(shift) and (ntrack ge 3)) then $
	  indices[*,*] = indices[([0,indgen(ntrack-2)+2,1]),*]
	
	;Return
	return, indices
end