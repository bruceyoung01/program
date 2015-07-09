

 ; based upon VIIRS data file names to find its orbit #
 ; August 1 will be orbit # 0; VIIRS has repeat cycle of 16 days. 
 PRO ORbit, YY, mm, day, orbitnum
    ; given a certain day, we can find the group #
    ; first we compute Julian day, and # of days from Aug1.
     JD = JulDAY (MM, day, YY)
     JD0 = JulDAY (8,   1, 2012)
     orbitnum = (JD-JD0) mod 16
 END 

 
 ; unpack the VIIRS filename into mm, dd, yy, and time.
 ; read all the file names
  PRO  VFileNamedecode, svdnbfnames, YY, Mon, DD, HH, MM, SS, orbitnum
  ;readcol, 'svdnbfiles.txt', svdnbfnames, format='(a)'
  nf = n_elements(svdnbfnames)
  YY = strmid(svdnbfnames, 11, 4)
  Mon = strmid(svdnbfnames, 15, 2)
  DD = strmid(svdnbfnames, 17, 2)

  ; in UTC
  HH = strmid(svdnbfnames, 21, 2)
  MM = strmid(svdnbfnames, 23, 2)
  SS = strmid(svdnbfnames, 25, 3)
  print, YY, MM, DD, HH, MM, SS
  ORbit, long(YY), long(Mon), long(DD), orbitnum
 END

 ; arrange the png file we already generated.
  PRO  PNGNamedecode, svdnbfnames, YY, Mon, DD, HH, MM, SS, orbitnum
  ;readcol, 'svdnbfiles.txt', svdnbfnames, format='(a)'
  nf = n_elements(svdnbfnames)
  YY = strmid(svdnbfnames, 5, 4)
  Mon = strmid(svdnbfnames, 9, 2)
  DD = strmid(svdnbfnames, 11, 2)

  ; in UTC, Ss is seconds * 10.
  HH = strmid(svdnbfnames, 15, 2)
  MM = strmid(svdnbfnames, 17, 2)
  SS = strmid(svdnbfnames, 19, 3)
  print, YY, Mon, DD, HH, MM, SS
  ORbit, long(YY), long(Mon), long(DD), orbitnum
 END

;  readcol, 'svdnbfiles.txt', svdnbfnames, format='(a)'
;  VFileNamedecode, svdnbfnames, YY, Mon, DD, HH, MM, SS, orbitnum

  readcol, 'Atlanta_overpass.txt', pngfilenames, format='(a)'
  PNGNamedecode, pngfilenames, YY, Mon, DD, HH, MM, SS, orbitnum

; change file names
  nf = n_elements(pngfilenames)
  for i = 0, nf-1 do begin
   if orbitnum(i) lt 10 then group = '0'+string(orbitnum(i), format= '(I1)')
   if orbitnum(i) ge 10 then group = string(orbitnum(i), format='(I2)')
    spawn, 'mv ' + pngfilenames(i) + ' G' + group + pngfilenames(i)
  endfor
 
  END
