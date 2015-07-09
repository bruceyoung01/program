;7/26/00 this script will read the avg2x2.o3 model file & return
;the time series and for the requested grid box.

pro read_EPAtsfile, file, i, j, tsmod, ll, res, ndays

;i = 22
;j = 34
;res = 4
;file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_std_JJA'
;ndays = 92
;tsmod = fltarr(92)
;lon=-75.
;lat=42.

;i = 41
;j = 63
;tsmod = fltarr(91) ;note -- no August 31 here!!  62.77

dummy = '' 
line = ''

case (res) of
   2: nboxes = 288
   4: nboxes = 3312
endcase
;variables for reading in O3 averages -- 288 grid boxes in model domain.
daymean = fltarr(nboxes, ndays)
ibox = intarr(nboxes)
jbox = intarr(nboxes)
latlon = strarr(nboxes)
long = strarr(nboxes)
latd = strarr(nboxes)
ct = 0
;open file containing 2x2.5 O3 averages
open_file, file, inf, /get_lun

;read title
readf, inf, dummy

;read info
while ( not EOF( inf ) ) do begin
   readf, inf,line
 
    ; this will separate into groups of individual entries
    ; that can then be fed into the structure.
    ; RESULT is an array, each value is a separate element
   Result = Strsplit( Line, ' ', /Extract )
   latlon[ct] = result[0]
   cutres =  strsplit (result[0], 'W',  /Extract)
   long[ct] = cutres[0]
   cutres =  strsplit (cutres[1], 'N', /Extract)
   latd[ct] =  cutres[0]
   ibox[ct] = result[1]
   jbox[ct] = result[2]

   for d= 0, n_elements(tsmod)-1 do begin
      daymean[ct, d] = result[d+3]
   endfor
   ct =  ct+1
endwhile

ind = where(i eq ibox and j eq jbox, S)
if (S gt 0) then begin
   tsmod = daymean[ind,*]
   lat =  float(latd[ind])
   lon = float(long[ind])
   ll=latlon[ind]
endif
close,  inf
;help, tsmod
;print, n_elements(tsmod)
;print,  tsmod

end
