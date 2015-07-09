;******************************************************************************
;  $ID: viirs_true_color_image.pro V01 20:28 03/17/2014 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_true_color_image READS VIIRS' RADIANCE IN GREEN, BLUE AND RED 
;  BANDS TO PLOT TRUE COLOR IMAGE.
;
;  VARIABLES:
;  ============================================================================
;  (1) 
;
;  NOTES:
;  ============================================================================
;  (1) ORIGINALLY WRITTEN BY BRUCE. (03/17/2014)
;******************************************************************************

;  LOAD LIBRARIES AND FUNCTIONS
@/Users/bruce/Documents/A/program/idl/idl_lib/procedure/universal/truecolor_img.pro


 fpath     = '/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/' 
 flist_geo = 'GMTCO.list'
 flist_m03 = 'SVM03.list'
 flist_m04 = 'SVM04.list'
 flist_m05 = 'SVM05.list'

 ; read the list
 readcol, fpath + flist_geo, fname_geo, format='A'
 readcol, fpath + flist_m03, fname_m03, format='A'
 readcol, fpath + flist_m04, fname_m04, format='A'
 readcol, fpath + flist_m05, fname_m05, format='A'

 dateb    = 20140312L 
 nday     = 1
 plot_day = 1

 ; set region of our interests
 region   = [32, -86.5, 35.5, -82.5]
 winx     = 400
 winy     = 350

 ; define day loop
 for i = plot_day-1, plot_day-1 do begin
    
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
 
      ; granule loop
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

        ; index to remove missing values [optional!!!]
        positive_nl = lonarr(nl)+1

        for inl = 0, nl-1 do begin
          nl_min = min( r01[*,inl] )
          if nl_min lt 0 then positive_nl[inl] = 0
        endfor

        index_nl = where( positive_nl eq 1, count_nl)
                
        r03 = reform( r03[*,index_nl] )
        r02 = reform( r02[*,index_nl] )
        r01 = reform( r01[*,index_nl] )
        lat = reform( lat[*,index_nl] )
        lon = reform( lon[*,index_nl] )

        ; update the dimension indexing
        nls = nle
        nle = nls + count_nl

        ; save the read variables to the global variable
        red [*,nls:nle-1] = r03[*,0:count_nl-1]
        grn [*,nls:nle-1] = r02[*,0:count_nl-1]
        blu [*,nls:nle-1] = r01[*,0:count_nl-1]
        flat[*,nls:nle-1] = lat[*,0:count_nl-1]
        flon[*,nls:nle-1] = lon[*,0:count_nl-1]
     
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
 
      ; enhance image
      red = hist_equal(bytscl(red))
      grn = hist_equal(bytscl(grn))
      blu = hist_equal(bytscl(blu))

      ; find the central pixel at Atlanta
      dis = abs(flon + 84.40)+abs(flat-33.75)
      atlanta_index = where( dis eq min(dis) )
      atlanta_indices = array_indices(dis, atlanta_index[0] )
      atlanta_i = atlanta_indices[0]
      atlanta_j = atlanta_indices[1]    

      ; select the 200x200 pixles 
      l_i = max( [atlanta_i - 100, 0    ] )
      r_i = min( [atlanta_i +  99, np-1 ] )
      d_j = max( [atlanta_j - 100, 0    ] )
      u_j = min( [atlanta_j +  99, nle-1] )

      red  = reform( red[l_i:r_i,d_j:u_j] )
      grn  = reform( grn[l_i:r_i,d_j:u_j] )
      blu  = reform( blu[l_i:r_i,d_j:u_j] )
      flat = reform( flat[l_i:r_i,d_j:u_j] )
      flon = reform( flon[l_i:r_i,d_j:u_j] ) 
 
      print, ' - data manipulation complete!'

      img_dir  = './images/'
      img_file = strmid(fname_geo[file_index],11,8)

      set_plot, 'X'
      window, 1, xsize=200, ysize=200
      tv, [[[red]], [[grn]], [[blu]]], true=3
      image = tvrd(true=3, order=1)

       ; write to tiff
       write_jpeg,  img_dir+'non-proj-'+ img_file + '.jpg', image, $
               quality = 300, true = 3, order=1


      truecolor_img, red=red, green=grn, blue=blu, $
               flat = flat, flon= flon, mag = 2, $
               londel=0.5, latdel=0.5, $
               region=region, winx=winx, winy=winy, $
               outputname = img_dir+img_file

   endif


 endfor

 ; End of program
 end

