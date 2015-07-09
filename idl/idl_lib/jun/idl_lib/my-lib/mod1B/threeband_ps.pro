;
; Purpose: three band overlay with color quan and save it
;          into a postscript file
; Input:
;    ch1, ch2, and ch3: 3 channels
;         lat and lon : latitude and longitude
;             mag:      magnitude to zoom in 
;           position :  position to plot
; Output:
;           outputname: outputname
;         region_limit: limit of the region  
;   

pro overlay, ch1, ch2, ch3, lat= lat, lon = lon, $
             OutPutName = OutPutName, $
             region_limit = region_limit, $
             mag = mag, $
             position = position

    np = n_elements(ch1(*,0))
    nl = n_elements(ch2(0,*))
    
    if (not keyword_set(region_limit)) then begin
       region_limit = [min(lat)-2, min(lon)-2, max(lat+2), max(lon+2)]
    endif

    if (not keyword_set(OutPutName) then begin
      print, 'No output file name is specified'
      print, 'File will be saved as overlay.ps'
      OutPutName = 'overlay.ps' 
    endif

    if (not keyword_set(mag)) then begin
      mag = 1
    endif

    if (not keyword_set(position)) then begin
     position=[0.05, 0.31, 0.95, 0.87]
    endif
  
  ; scale each channel from 0 ~ 255
    ch1  = congrid(ch1, np*mag, nl*mag)
    ch2  = congrid(ch2, np*mag, nl*mag)
    ch3  = congrid(ch3, np*mag, nl*mag)

  ; set output device : ps file
    set_plot, 'ps'
    device, filename = OutPutName, xoffset=0.5, yoffset=0.5, $
          xsize=7, ysize=10, /color, /inches, bits =8

  ; create color tables and color indices
        result = color_quan(ch1, ch2, ch3, r, g, b, colors=256)
        tvlct, r, g, b
        lat =  congrid(lat, np*mag, nl*mag, /interp)
        lon =  congrid(lon, np*mag, nl*mag, /interp)

     map_set, /continent,$
     charsize=1, mlinethick = 4, $
     position=position, $
     limit = region_limit,/usa, color=255,con_color=255

     color_imagemap, result, lat, lon, /current, missing = 0

     map_set,  /continent,$
     charsize=1, mlinethick = 4, $
     position=position, $
     limit = region_limit,/noerase, /usa,color=255,con_color=255
  ; close device
        device, /close
    end

