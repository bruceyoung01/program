;
  @./routines/truecolor_img.pro
  @./routines/threeband_ps.pro
  @./routines/color_imagemap.pro


 fpath     = '../data/' 
 flist_geo = '../data/GMTCO.list'
 flist_m03 = '../data/SVM03.list'
 flist_m04 = '../data/SVM04.list'
 flist_m05 = '../data/SVM05.list'

 ; read the list
 readcol, flist_geo, fname_geo, format='A'
 readcol, flist_m03, fname_m03, format='A'
 readcol, flist_m04, fname_m04, format='A'
 readcol, flist_m05, fname_m05, format='A'

 dateb = 20120401L 
 nday  = 29
 plot_day = 8

 ; set region of our interests
 ;region = [33, -85.5, 34.5, -83.5]
 region = [30, -89.5, 37, -79.5]
 ;region = [32, -87.5, 35.5, -81.5] 
 winx = 800
 winy = 600


 for i = plot_day-1, plot_day-1 do begin ; nday-1 do begin
    
   ; determine file for the day
   this_date = dateb + i
   index = where( strmid(fname_geo,11,8) eq strtrim( this_date, 2 ), count)
   print, ' - date:', this_date
   print, ' - file count:',   count

   ;================================
   ; now for day
   ;================================
   nls = 0 
   nle = 0 

   if count ge 1 then begin
 
      for j = 0, count-1 do begin

        file_index = index[j]
        print, ' - time for this granule: ', strmid(fname_geo[file_index],21,6)
 
        ; read radiance and geolocation
        get_h5_dataset, r01, file=fpath+fname_m03[file_index], name='Radiance'
        get_h5_dataset, r02, file=fpath+fname_m04[file_index], name='Radiance'
        get_h5_dataset, r03, file=fpath+fname_m05[file_index], name='Radiance'
        get_h5_dataset, lat, file=fpath+fname_geo[file_index], name='Latitude'
        get_h5_dataset, lon, file=fpath+fname_geo[file_index], name='Longitude' 

        ; size of the variables
        rsize = size(r01, /dimension)
        np    = rsize[0]
        nl    = rsize[1]

        ; define array
        if j eq 0 then begin
          red  = fltarr( np, nl*count )
          grn  = fltarr( np, nl*count )
          blu  = fltarr( np, nl*count )
          flat = fltarr( np, nl*count )
          flon = fltarr( np, nl*count )
        endif

        ; update the dimension indexing
        nls = nle
        nle = nls + nl

        ; save the read variables to the global variable
        red [*,nls:nle-1] = r03[*,0:nl-1]
        grn [*,nls:nle-1] = r02[*,0:nl-1]
        blu [*,nls:nle-1] = r01[*,0:nl-1]
        flat[*,nls:nle-1] = lat[*,0:nl-1]
        flon[*,nls:nle-1] = lon[*,0:nl-1]
     
        print, ' - read file:', j+1, '  of', count

      endfor

      ; screen print
      print, ' - reading complete!'

      ;manupilate data and enhance the image 
      red  = reform( red [*,0:nle-1] )
      grn  = reform( grn [*,0:nle-1] )
      blu  = reform( blu [*,0:nle-1] )
      flat = reform( flat[*,0:nle-1] )
      flon = reform( flon[*,0:nle-1] )
 
      ;dis = abs(flon + 84.40)+abs(flat-33.75)
      ;atlanta_index = where( dis eq min(dis) )
      ;atlanta_indices = array_indices(dis, atlanta_index[0] )
      ;atlanta_i = atlanta_indices[0]
      ;atlanta_j = atlanta_indices[1]    

      ;l_i = max( [atlanta_i - 400, 0    ] )
      ;r_i = min( [atlanta_i + 400, np-1 ] )
      ;d_j = max( [atlanta_j - 300, 0    ] )
      ;u_j = min( [atlanta_j + 300, nle-1] )

      ;red = reform( red[l_i:r_i,d_j:u_j] )
      ;grn = reform( grn[l_i:r_i,d_j:u_j] )
      ;blu = reform( blu[l_i:r_i,d_j:u_j] )
      ;flat = reform( flat[l_i:r_i,d_j:u_j] )
      ;flon = reform( flon[l_i:r_i,d_j:u_j] ) 

      index_img = where( red ge 0. and flat ge -90. and flon ge -180.)
      red = red[index_img]
      grn = grn[index_img]
      blu = blu[index_img]
      flon = flon[index_img]
      flat = flat[index_img]

      red = hist_equal(bytscl(red))
      grn = hist_equal(bytscl(grn))
      blu = hist_equal(bytscl(blu))

      print, ' - data manipulation complete!'

      img_dir  = './images/'
      img_file = strmid(fname_geo[file_index],11,8)

      truecolor_img, red=red, green=grn, blue=blu, $
               flat = flat, flon= flon, mag = 1, $
               region=region, winx=winx, winy=winy, $
               outputname = img_dir+img_file

      overlay, red, grn, blu, lat=flat, lon=flon, $
             region_limit=region, mag=1, $
             position=[0.1,0.1,0.9,0.9], $
             OutPutName=img_dir+img_file+'.ps'

   endif


 endfor

 ; End of program
 end

