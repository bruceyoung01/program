;+
; NAME:
; excludeScannerOverlap
; 
; PURPOSE:
; This function returns the pixels from a scanner data 
; array that do not overlap each other.
; 
; AUTHOR:
; Luke Ellison
; 
; CREATED:
; March 23, 2010
; 
; SYNTAX:
; array = excludeScannerOverlap(data | {, line=variable, 
;   sample=variable}, indices=variable | 
;   {[, percentOverlap=variable] {, height=variable, 
;   nadirPixelWidth=variable, numScanPixels=variable, 
;   scanWidth=variable} | , /MODIS [, /shift]} 
;   [, /inverse] [, /retboolean | , /retdata] 
;   [, /overwrite] [, count=variable])
; 
; INPUTS:
; data: An optional 2D input array that can be used in 
; lieu of line and sample inputs where the first 
; dimension is taken as line and the second as sample.
; 
; line: The along-track indices.  If not specified, line 
; is derived from data.
; 
; sample: The along-scan indices.  If not specifed, 
; sample is derived from data.
; 
; indices: A scanWidth x 2 array of sample indices 
; defining the limits of the range of non-overlapping 
; pixels.
; 
; percentOverlap: The percentage of overlap needed in 
; order to tag a pixel as overlapping.  The default is 
; 50.
; 
; height: The satellite's altitude.
; 
; nadirPixelWidth: The width of a pixel at nadir.
; 
; numScanPixels: The number of pixels along scan.
; 
; scanWidth: The width of a scan in pixels (along track).
; 
; MODIS: Set this keyword to use MODIS values for 
; height, nadirPixelWidth, numScanPixels and scanWidth.
; 
; shift: Perform a shifting of the results so that the 
; outter edges of the scan have the most overlap.
; 
; KEYWORDS:
; inverse: If set, inverts the output so that output 
; array and count correspond to overlapping-pixels.
; 
; retboolean: If set, output array returns a binary 
; array with 1's indicating non-overlapping pixels.  
; This keyword has precedence over keyword retdata.
; 
; retdata: If set, output array returns the data input 
; array of only the non-overlapping pixels.
; 
; overwrite: If set, overlapping pixels are excluded 
; from inputs data, line and sample.
; 
; OUTPUTS:
; array: Returns an array of indices corresponding to 
; inputs data/line/sample of non-overlapping pixels
; 
; count: Returns the number of non-excluded pixels.
; 
; USER ROUTINES:
; getScannerOverlapIndices
; 
; REVISION HISTORY:
; 7 Apr 10 by Luke Ellison: Added percentOverlap 
; keyword and the use of getScannerOverlapIndices.
; 
; 19 Jul 10 by Luke Ellison: Added output nvalid.
; 
; 20 Jul 10 by Luke Ellison: Fixed error in calculating 
; include and broadened the scope of the routine for 
; any scanner.
; 
; 2 Sep 10 by Luke Ellison: Added input indices, deleted 
; keyword index, renamed keyword binary as retboolean, 
; added keywords inverse and retdata, added functionality 
; to keyword overwrite, and renamed output nvalid as count.
;-

function excludeScannerOverlap, data, line=line, sample=sample, $
  indices=indices, percentOverlap=percentOverlap, height=height, $
  nadirPixelWidth=nadirPixelWidth, numScanPixels=numScanPixels, $
  scanWidth=scanWidth, MODIS=MODIS, shift=shift, inverse=inverse, $
  retboolean=retboolean, retdata=retdata, overwrite=overwrite, count=count
	on_error, 2
	Dsize = size(data, /dim)
	if (keyword_set(sample) and not (size(line, /type) eq 0)) then $
	  L = reform(line) $
	else $
	  L = indgen(Dsize[0]) # replicate(1, Dsize[1])
	if (keyword_set(sample) and not (size(sample, /type) eq 0)) then $
	  S = reform(sample) $
	else $
	  S = indgen(Dsize[1]) ## replicate(1, Dsize[0])
	if not keyword_set(percentOverlap) then $
	  percentOverlap = 50
	
	;Exclude overlapping pixels (defined as when a percentage of a 
	;  pixel's area is within the area of a preceeding scan)
	if not keyword_set(indices) then $
	  indices = getScannerOverlapIndices(percentOverlap, height=height, $
	    nadirPixelWidth=nadirPixelWidth, numScanPixels=numScanPixels, $
	    scanWidth=scanWidth, MODIS=MODIS, shift=shift)
	ntrack = (size(indices, /dim))[0]
	modline = L mod ntrack
	include = bytarr(size(S, /dim))
	for itrack=0*ntrack, ntrack-1 do $
	  include = include or ((modline eq itrack) and $
	    (indices[itrack,0] > S < indices[itrack,1] eq S))
	include = include or (L lt (ntrack-keyword_set(shift)))
	
	;Invert values
	if keyword_set(inverse) then $
	  include = ~include
	
	;Get indices of non-overlapping samples
	winclude = where(include, count)
	
	;Overwrite input data
	if (keyword_set(overwrite) and (count gt 0)) then begin
		if keyword_set(data) then $
		  data = data[winclude]
		line = L[winclude]
		sample = S[winclude]
	endif
	
	;Return
	if keyword_set(retboolean) then $
	  return, include $
	else $
	  if ((count gt 0) and keyword_set(data) and keyword_set(retdata)) then $
	    if keyword_set(overwrite) then $
	      return, data $
	    else $
	      return, data[winclude] $
	  else $
	    return, winclude
end