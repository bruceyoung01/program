;
; Purpose of this program is to use HDF to read MOD06 product
;



PRO read_modis06_cldopt, filedir, filename, cldopt, cldreff, cldwtph,$
                         cldphase, cldfrac, cldpress, cldtemp, cldsza, $
			 flat, flon, np,  nl 

; check if this file is a valid HDF file
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
   print, 'Open HDF file : ' + filename
endelse


; the SDS var name we're interested in
SDsvar = strarr(10)
sdsvar = ['Cloud_Optical_Thickness', 'Effective_Particle_Radius', $
          'Water_Path', 'Cloud_Phase_Infrared', 'Cloud_Fraction', $
	  'Cloud_Top_Pressure',  'Cloud_Top_Temperature', $ 
	  'Solar_Zenith', 'Latitude', 'Longitude'] 

slope =    [0.01, 0.01, 0.01, 1, 0.01, 0.1,      0.01,  0.01,  1, 1]
intercpt = [   0,    0,    0, 0,    0,   0,  -15000.0,  0.00,  0, 0]

; get hdf file id
FileID = Hdf_sd_start(filedir + filename, /read)
for  i = 0, n_elements(SDSvar)-1 do begin
  thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
  thisSDS = hdf_sd_select(FileID, thisSDSinx)
   hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                 Ndims = nd, hdf_type = SdsType
;   print, 'SDAname ', thisSDSname, ' SDS Dims', nd,  $
;          ' SdsType = ',  strtrim(SdsType,2)

     ; dimension information
      for kk = 0, nd-1 do begin
        DimID =   hdf_sd_dimgetid( thisSDS, kk)
        hdf_sd_dimget, DimID, Count = DimSize, Name = DimName
;        print, 'Dim  ', strtrim(kk,2), $
;           ' Size = ', strtrim(DimSize,2), $
;           ' Name  = ', strtrim(DimName)

        if ( i eq 0 ) then begin 
        if ( kk eq 0) then np =  DimSize    ; dimension size
        if ( kk eq 1) then nl  = DimSize
	endif
      endfor

      ; end of entering SDS
       hdf_sd_endaccess, thisSDS

      ; get data
       hdf_sd_getdata, thisSDS, Data
       if ( i eq 0 ) then  cldopt  = slope(i)* (data - intercpt(i)) 
       if ( i eq 1 ) then  cldreff = slope(i)* (data - intercpt(i)) 
       if ( i eq 2 ) then  cldwtph = slope(i)* (data - intercpt(i)) 
       if ( i eq 3 ) then  cldphase = slope(i)* (data - intercpt(i)) 
       if ( i eq 4 ) then  cldfrac = slope(i)* (data - intercpt(i)) 
       if ( i eq 5 ) then  cldpress = slope(i)* (data - intercpt(i)) 
       if ( i eq 6 ) then  cldtemp = slope(i)* (data - intercpt(i) )
       if ( i eq 7 ) then  cldsza = slope(i)* (data - intercpt(i) )
       if ( i eq 8 ) then  flat = slope(i)* (data - intercpt(i)) 
       if ( i eq 9 ) then  flon = slope(i)* (data - intercpt(i) )
   endfor

  ; end the access to sd
   hdf_sd_end, FileID
   print, 'np = ', np,  'nl = ', nl
END

  









