; $Id: plot_surface_o3_geos_3_models.pro,v 1.3 2005/03/10 15:52:15 bmy Exp $
pro plot_surface_o3_geos_3_models, pref1, ptop1, dlat1, dlon1, $
                                   pref2, ptop2, dlat2, dlon2, $
                                   pref3, ptop3, dlat3, dlon3, title, psname

   ; For a given set of stations compares O3 surface data from cmdl (black
   ; solid line) with surface data from 3 models plotted with linestyles 1 
   ; to 3 and colors red, green and blue correspondently
   ;
   ; NOTE: Now uses GET_PRESSURE_GEOS andGET_SPECIES_GEOS which can read
   ;       both GEOS-3 and GEOS-4 met fields.  Also updated comments
   ;       and made cosmetic changes. (bmy, 3/8/05)

   ;=======================================================================
   ; Initialization
   ;=======================================================================

   !X.OMARGIN=[8,6] 
   !Y.OMARGIN=[6,6]
   !X.THICK=4
   !Y.THICK=4
   !P.CHARTHICK=2.5
   !P.THICK=2.5

   Species='O3'

   ;input data about stations
   filest=''
   filest='/users/trop/iam/netCDF/Sites.ground.'+Species+'.remote.1' 

   ; Open file with stations
   openr, usta, filest, /get_lun
   iname_sta=''
   ititle_sta=''
   ipref_sta=''

   mmonth = strarr(12)
   mmonth=['Jan','Feb','Mar','Apr','May','Jun',$
           'Jul','Aug','Sep','Oct','Nov','Dec']

   ; Open PS device
   open_device, olddevice,/ps,/color,filename=psname ;color plot
   
   ; Specify directory with surface data 
   pre = '/users/trop/iam/surface.ozone/'

   ;====================================================================
   ; --- read station & indice ---
   ;====================================================================

   ; Set max_sta parameter
   max_sta=19                   ;real

   ; Read in information about stations to be plotted - 
   ; 3-letter name(capital), station name, latitude and longitude

   name_sta = strarr(max_sta)
   lon_sta      = fltarr(max_sta)
   lat_sta      = fltarr(max_sta)
   lon_sta_1      = fltarr(max_sta)
   lat_sta_1      = fltarr(max_sta)
   title_sta = strarr(max_sta)
   pref_sta = strarr(max_sta)

   for i=0,max_sta-1 do begin
      readf,usta, iname_sta,ititle_sta,  ilat, ilon, ipref_sta, $
         format='(2x,a3,7x,a12,5x,f6.2,3x,f6.2,4x,a3)'
      name_sta(i) = iname_sta
      lon_sta_1(i)      = round(ilon)
      lat_sta_1(i)      = round(ilat)
      lon_sta(i)      = ilon
      lat_sta(i)      = ilat
      title_sta(i) = ititle_sta
      pref_sta[i] = ipref_sta
   endfor

   nrow=4
   ncol=4
   !P.Multi = [0,nrow,ncol,1,0]
   
   ;==================================================================== 
   ; ---  open files ---
   ;====================================================================
   ncount=0

   ; --- loop for stations ---
   for k = 1, max_sta do begin

      ncount=ncount+1
    kk = k-1 
    ix = k
    file=''

    file=pre+'surf'+pref_sta(kk)+'.dat'

    ilun = k+50
    openr,ilun,file

    maxd = 12
    o3mean   = fltarr(maxd)
    o3mon = fltarr(maxd)

    ; Loop over months
    for i=0,11 do begin
       readf,ilun,                                             $
          io3mon,io3mean
       o3mon(i)    = io3mon
       o3mean(i)   = io3mean
    endfor
    close, ilun

    ; Put longitude in (-180,180) range
    if lon_sta_1(kk) gt 180 then lon_sta_1(kk)=lon_sta_1(kk)-360
    if lon_sta(kk) gt 180 then lon_sta(kk)=lon_sta(kk)-360

    ; Create station title
    ltitle=''
    ltitle = strtrim(title_sta(kk),2)+$
       ' ('+strtrim(string(fix(lat_sta_1(kk))),1)+$
       ' ,'+strtrim(string(fix(lon_sta_1(kk))),1)+' )'
    
    ;======================================================================
    ; Read data from first model 
    ;======================================================================
    out=fltarr(12)

    for i=0,11 do begin
       
       ; Month name
       mn=strtrim(String(fix(i+1)),2)
       if (strlen(mn) eq 1) then begin
          mn='0'+mn
       endif
       name=pref1+mn+'01.nc'

       ; Get O3
       O3 = Get_Species_Geos( name, Date=Date, $
                              Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

       ; Get pressure
       Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )

       ; Now select proper box
       Indlat = Where( Lat ge lat_sta(kk)-dlat1/2.0 and $
                       Lat le lat_sta(kk)+dlat1/2.0 )
       Indlon = Where( Lon ge lon_sta(kk)-dlon1/2.0 and $
                       Lon le lon_sta(kk)+dlon1/2.0 )

       O3_box = O3[Indlon,Indlat,0]
       out[i]=mean(O3_box)

       if (name_sta(kk) eq 'NWR') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif
       
       if (name_sta(kk) eq 'IZO') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(800.))
       endif

       if (name_sta(kk) eq 'MLO') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif

       if (name_sta(kk) eq 'SPO') then begin
          ;out[i]=interpol(O3[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'LEF') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'UUM') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'UTA') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'CUI') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'WLG') then begin
          out[i]=interpol(O3[Indlon,Indlat,0:18],$
                          -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(600.))
       endif

    endfor

    ;======================================================================
    ; Read data from 2nd model 
    ;======================================================================
    out2=fltarr(12)

    ; Loop over months
    for i=0,11 do begin

       ; Month name
       mn=strtrim(String(fix(i+1)),2)
       if (strlen(mn) eq 1) then begin
          mn='0'+mn
       endif
       name=pref2+mn+'01.nc'
       
       ; Get O3
       O3 = Get_Species_Geos( name, Date=Date, $
                              Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

       ; Get pressure
       Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )
       
       ; Now select proper box
       Indlat = Where( Lat ge lat_sta(kk)-dlat2/2.0 and $
                       Lat le lat_sta(kk)+dlat2/2.0 )
       Indlon = Where( Lon ge lon_sta(kk)-dlon2/2.0 and $
                       Lon le lon_sta(kk)+dlon2/2.0 )

       O3_box = O3[Indlon,Indlat,0]

       out2[i]=mean(O3_box)

       if (name_sta(kk) eq 'NWR') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif
       
       if (name_sta(kk) eq 'IZO') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(800.))
       endif

       if (name_sta(kk) eq 'MLO') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif

       if (name_sta(kk) eq 'SPO') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'LEF') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'UUM') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'UTA') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'CUI') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'WLG') then begin
          out2[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(600.))
       endif
       
    endfor

    ;======================================================================
    ; Read data from 3rd model 
    ;======================================================================
    out3=fltarr(12)

    for i=0,11 do begin

       ; Month name
       mn=strtrim(String(fix(i+1)),2)
       if (strlen(mn) eq 1) then begin
          mn='0'+mn
       endif
       name=pref3+mn+'01.nc'

       ; O3
       O3 = Get_Species_Geos( name, Date=Date, $
                              Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

       ; Pressure
       Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )

   ; Prior to 9/23/03:
       Indlat = Where( Lat ge lat_sta(kk)-dlat3/2.0 and $
                       Lat le lat_sta(kk)+dlat3/2.0 )
       Indlon = Where( Lon ge lon_sta(kk)-dlon3/2.0 and $
                       Lon le lon_sta(kk)+dlon3/2.0 )

       O3_box = O3[Indlon,Indlat,0]
       out3[i]=mean(O3_box)

       if (name_sta(kk) eq 'NWR') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif

       if (name_sta(kk) eq 'IZO') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(800.))
       endif

       if (name_sta(kk) eq 'MLO') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
       endif

       if (name_sta(kk) eq 'SPO') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'LEF') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'UUM') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif
       
       if (name_sta(kk) eq 'UTA') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif

       if (name_sta(kk) eq 'CUI') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
       endif
       
       if (name_sta(kk) eq 'WLG') then begin
          out3[i]=interpol(O3[Indlon,Indlat,0:18],$
                           -alog10(Pressure[Indlon,Indlat,0:18]),-alog10(600.))
       endif
       
    endfor

    ;======================================================================
    ; Plot the data
    ;======================================================================

    ; Define the range for y axis
    loval=0 
    highval=60

    if  max([o3mean,out]) gt 60 then begin highval=80
    endif

    ; -- plot observed data --
    plot, findgen(12)+1, o3mean, xstyle=1,ystyle=1,$
       title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
       xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
       charsize=1.5, xmargin=[3,2], ymargin=[3,1],color=1,$
         xtickname=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' ']
    
    ; 1st model
    oplot, findgen(12)+1,out,linestyle=1,color=2
    oplot, findgen(12)+1,out,linestyle=1,psym=2,symsize=0.3,color=2   

    ; 2nd model
    oplot, findgen(12)+1,out2,linestyle=2,color=3
    oplot, findgen(12)+1,out2,linestyle=2,psym=2,symsize=0.3,color=3   

    ; 3rd model
    oplot, findgen(12)+1,out3,linestyle=3,color=4
    oplot, findgen(12)+1,out3,linestyle=3,psym=2,symsize=0.3,color=4   
    
    xyouts, 0.04, 0.5, 'O3 (ppb)', /normal, align=0.5, orientation=90, $
       charsize=1.2,color=1
    xyouts, 0.5, 0.96,title, /normal, align=0.5, charsize=1.2,color=1
 endfor

 ; Cleanup & quit
 close_device, /TIMESTAMP
 
 close, /all

end


