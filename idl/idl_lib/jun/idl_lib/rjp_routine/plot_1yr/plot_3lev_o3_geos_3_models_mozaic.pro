; $Id: plot_3lev_o3_geos_3_models_mozaic.pro,v 1.1 2005/03/10 15:52:14 bmy Exp $
pro plot_3lev_o3_geos_3_models_mozaic, pref1, ptop1, dlat1, dlon1, nalt1, $
                                       pref2, ptop2, dlat2, dlon2, nalt2, $
                                       pref3, ptop3, dlat3, dlon3, nalt3, $
                                      title, psname, max_station, filest

   ; NOTE: Now uses GET_PRESSURE_GEOS and GET_SPECIES_GEOS, which can
   ;       now read both GEOS-3 and GEOS-4 met fields.  Also updated
   ;       comments and made cosmetic changes. (bmy, 3/7/05)
   ; 
   ; This version is for the 0.5 degree resolution data that comes
   ; with the MOZAIC Data set (iam, bmy, 3/7/05)

   ;======================================================================
   ; Initialization
   ;======================================================================

   !X.OMARGIN=[12,8] 
   !Y.OMARGIN=[10,8]
   !X.MARGIN=[0,0]
   !Y.MARGIN=[0,0]
   !P.CHARTHICK=4.0
   !P.THICK=4.5
   !X.THICK=4.0
   !Y.THICK=4.0

   ; now set up plotting parameters
   nrow=4
   ncol=3
   !P.Multi = [0,nrow,ncol,0,1]

   Species='O3'

   mmonth = strarr(12)
   mmonth=['Jan','Feb','Mar','Apr','May','Jun',$
           'Jul','Aug','Sep','Oct','Nov','Dec']

   std_press=[800,500,300,150]
   
   ; Open plot device
   open_device, olddevice,/ps,/color,filename=psname
   
   pre = '/users/trop/iam/surface.ozone/'

   ;========================================================================
   ; --- read station & indice ---
   ;========================================================================
   name_sta=''
   num_sta=''
   pref_sta=''

   num_station=strarr(max_station)
   name_station=strarr(max_station)
   pref_station=strarr(max_station)
   lat_station=strarr(max_station)
   lon_station=strarr(max_station)
   lat_station_1=strarr(max_station)
   lon_station_1=strarr(max_station)

   ; Open station file
   openr, usta, filest, /get_lun

   ; Read header
   for i=0,max_station-1 do begin
      readf,usta, pref_sta,                  $
         name_sta, lat_sta,         $
         lon_sta,num_sta,         $
         format='(2x,a3,9x,a16,1x,f6.2,3x,f6.2,3x,a3)'
      pref_station(i) = pref_sta
      name_station(i) = name_sta
      lat_station(i) = lat_sta
      lon_station(i) = lon_sta
      lat_station_1(i) = round(lat_sta)
      lon_station_1(i) = round(lon_sta)
      num_station(i) = num_sta
      
   endfor
   
   ;========================================================================
   ; ---  open files ---
   ;========================================================================
   ncount=0

   ; Loop over stationls
   for k = 1, max_station do begin

      ncount=ncount+1
      kk = k-1 
      ix = k
      file=''

      if lon_station_1(kk) gt 180 then lon_station_1(kk)=lon_station_1(kk)-360
      if lon_station(kk) gt 180 then lon_station(kk)=lon_station(kk)-360

      name_sonde='/users/trop/iam/sondes.for.gmi/sonde'+num_station(kk)+'.0.5'

      ;===============================================================
      ; Read O3 from first model
      ;===============================================================
      out=fltarr(12,4)
      
      ; Loop over months
      for i=0,11 do begin

         ; Month name
         mn=strtrim(String(fix(i+1)),2)
         if (strlen(mn) eq 1) then begin
            mn='0'+mn
         endif
         name=pref1+mn+'01.nc'

         if (lon_station(kk) eq 178 and dlon1 eq 5) then lon_station(kk)=-182
         
         ; Get O3
         O3 = Get_Species_Geos( name, Date=Date, $
                                Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

         ; Get pressure
         Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )

         ; Now select proper box
         Indlat = Where( Lat ge lat_station(kk)-dlat1/2 and $
                         Lat le lat_station(kk)+dlat1/2 )
         Indlon = Where( Lon ge lon_station(kk)-dlon1/2 and $
                         Lon le lon_station(kk)+dlon1/2 )
         
         if (lon_station(kk) eq -182) then lon_station(kk)=178
         O3_box = O3[Indlon,Indlat,*]
         Pressure_box = Pressure[Indlon,Indlat,*]
         
         Nalt=nalt1
         Ozone=fltarr(Nalt)
         pres=fltarr(Nalt)
         
         for j=0,Nalt-1 do begin
            Ozone[j]=mean(O3_box[*,*,j])
            Pres[j]=mean( Pressure_box [*,*,j]) 
         endfor
         
         out[i,*]=interpol(Ozone,alog10(Pres),alog10(std_press))
         
      endfor

      ;===================================================================
      ; Read O3 from 3rd model
      ;===================================================================
      out3=fltarr(12,4)

      for i=0,11 do begin

         ; month name
         mn=strtrim(String(fix(i+1)),2)
         if (strlen(mn) eq 1) then begin
            mn='0'+mn
         endif
         name=pref3+mn+'01.nc'

         if (lon_station(kk) eq 178 and dlon3 eq 5) then lon_station(kk)=-182

         ; Get O3
         O3 = Get_Species_Geos( name, Date=Date, $
                          Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

         ; Get pressure 
         Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )

         ; Now select proper box
         Indlat = Where( Lat ge lat_station(kk)-dlat3/2 and $
                         Lat le lat_station(kk)+dlat3/2 )
         Indlon = Where( Lon ge lon_station(kk)-dlon3/2 and $
                         Lon le lon_station(kk)+dlon3/2 )

         if (lon_station(kk) eq -182) then lon_station(kk)=178
         O3_box = O3[Indlon,Indlat,*]
         Pressure_box = Pressure[Indlon,Indlat,*]
         
         Nalt=nalt3 
         Ozone=fltarr(Nalt)
         pres=fltarr(Nalt)
         for j=0,Nalt-1 do begin
            Ozone[j]=mean(O3_box[*,*,j])
            Pres[j]=mean( Pressure_box [*,*,j]) 
         endfor
         
         out3[i,*]=interpol(Ozone,alog10(Pres),alog10(std_press))
         
      endfor

      ;====================================================================
      ; Read O3 from 2nd model
      ;====================================================================
      out2=fltarr(12,4)

      for i=0,11 do begin

         ; Month name
         mn=strtrim(String(fix(i+1)),2)
         if (strlen(mn) eq 1) then begin
            mn='0'+mn
         endif
         name=pref2+mn+'01.nc'

         if (lon_station(kk) eq 178 and dlon2 eq 5) then lon_station(kk)=-182

         ; Get O3
         O3 = Get_Species_Geos( name, Date=Date, $
                                Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )

         ; Get Pressure
         Pressure = Get_Pressure_Geos( Name, PTOP=PTOP2, Lat=Lat, Lon=Lon )

         ; Now select proper box
         Indlat = Where( Lat ge lat_station(kk)-dlat2/2 and $
                         Lat le lat_station(kk)+dlat2/2 )
         Indlon = Where( Lon ge lon_station(kk)-dlon2/2 and $
                         Lon le lon_station(kk)+dlon2/2 )

         if (lon_station(kk) eq -182) then lon_station(kk)=178

         O3_box = O3[Indlon,Indlat,*]
         Pressure_box = Pressure[Indlon,Indlat,*]

         Nalt=nalt2 
         Ozone=fltarr(Nalt)
         pres=fltarr(Nalt)
         for j=0,Nalt-1 do begin
            Ozone[j]=mean(O3_box[*,*,j])
            Pres[j]=mean( Pressure_box [*,*,j]) 
         endfor
         
         out2[i,*]=interpol(Ozone,alog10(Pres),alog10(std_press))

      endfor

      ;=====================================================================
      ;  Now read sonde means and standard deviations
      ;=====================================================================
      read_sondes_4lev_mozaic_0_5,name_sonde, sonde, std_sonde

      ;=====================================================================
      ; First plot panel
      ;=====================================================================
      ltitle=''
      ltitle = strtrim(name_station(kk),2)+$
         ' ('+strtrim(string(fix(lat_station_1(kk))),1)+$
         ' ,'+strtrim(string(fix(lon_station(kk))),1)+' )'

      ; -- plot observed data --
      loval=0 
      highval=150
      if lat_station(kk) ge 51 then begin
         highval=300
      endif

      plot, findgen(12)+1, sonde[*,2], xstyle=1,ystyle=5,$
         title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
         xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
         charsize=1.5,color=1,$
         xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']

      ; Now plot standard deviations
      for w = 0, 11 do begin
         if std_sonde[w,2] gt 0 then begin
            errbar = [sonde[w,2]-std_sonde[w,2],sonde[w,2]+std_sonde[w,2] ]
            oplot,  [w+1,w+1],errbar,$
               linestyle=0,color=1
         endif
      endfor

      ; 1st month
      oplot, findgen(12)+1,out[0:11,2],linestyle=0,color=2
      oplot, findgen(12)+1,out[0:11,2],linestyle=0,psym=-5,$
         symsize=0.6,color=2   

      ; 2nd month
      oplot, findgen(12)+1,out2[0:11,2],linestyle=0,color=3
      oplot, findgen(12)+1,out2[0:11,2],linestyle=0,psym=-5,$
         symsize=0.6,color=3   

      ; 3rd month
      oplot, findgen(12)+1,out3[0:11,2],linestyle=0,color=4
      oplot, findgen(12)+1,out3[0:11,2],linestyle=0,psym=-5,$
         symsize=0.6,color=4   

      ; Now plot standard deviations
      xyouts,1,0.8*highval, '300 hPa', charsize = 1,color=1

      yt1=[' 0 ','50','100','150']
      if lat_station(kk) ge 51 then begin
         yt1=[' 0 ','75','150','225','300']
      endif
      
      ; Plot Axes
      if ncount eq 1 or ncount eq 5 or ncount eq 9 or ncount eq 13 or ncount eq 17 or ncount eq 21 or ncount eq 25 or ncount eq 29 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,highval],$
            ytickv=findgen(5)*highval/3, ytickname=yt1,$
            charsize=1.5,/ystyle,color=1
      endif

      if ncount ne 1 and ncount ne 5 and ncount ne 9 and ncount ne 13 and ncount ne 17 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,highval],$
            ytickv=findgen(5)*highval/3, ytickname=[' ',' ',' ',' ',' '],$
            charsize=1.5,/ystyle,color=1
      endif

      if ncount ne 1 and ncount ne 5 and ncount ne 9 and ncount ne 13 and ncount ne 17 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,150],$
            ytickv=[0,50,100,150], ytickname=[' ',' ',' ',' ',' ',' ',' '],$
            charsize=1.5,/ystyle,color=1
      endif

      axis,13, yaxis=1,yticks=4, yrange=[0,150],$
         ytickv=[0,50,100,150], ytickname=[' ',' ',' ',' ',' ',' ',' '],$
         charsize=1.5,/ystyle,color=1
      
      ;=====================================================================
      ; Second plot panel
      ;=====================================================================
      loval=0 
      highval=100
      
      plot, findgen(12)+1, sonde[*,1], xstyle=1,ystyle=5,$
         linestyle=0,psym=-5,symsize=0.6, $
         xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
         charsize=1.5,color=1,$
         xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']

      ; Now plot standard deviations
      for w = 0, 11 do begin
         if std_sonde[w,1] gt 0 then begin
            errbar = [sonde[w,1]-std_sonde[w,1],sonde[w,1]+std_sonde[w,1] ]
            oplot,  [w+1,w+1],errbar,$
               linestyle=0,color=1
         endif
      endfor
      
      ; 1st month
      oplot, findgen(12)+1,out[0:11,1],linestyle=0,color=2
      oplot, findgen(12)+1,out[0:11,1],linestyle=0,psym=-5,$
         symsize=0.6,color=2   

      ; 2nd month
      oplot, findgen(12)+1,out2[0:11,1],linestyle=0,color=3
      oplot, findgen(12)+1,out2[0:11,1],linestyle=0,psym=-5,$
         symsize=0.6,color=3   

      ; 3rd month
      oplot, findgen(12)+1,out3[0:11,1],linestyle=0,color=4
      oplot, findgen(12)+1,out3[0:11,1],linestyle=0,psym=-5,$
         symsize=0.6,color=4   

      xyouts,1,0.8*highval, '500 hPa', charsize = 1,color=1

      ; Plot axes
      if ncount eq 1 or ncount eq 5 or ncount eq 9 or ncount eq 13 or ncount eq 17 or ncount eq 21 or ncount eq 25 or ncount eq 29 then begin  

         axis, 0, yaxis=0, yticks=4, yrange=[0,100],$
            ytickv=[0,25,50,75,100], ytickname=[' 0','25','50','75','100'],$
            charsize=1.5,/ystyle,color=1
      endif

      if ncount ne 1 and ncount ne 5 and ncount ne 9 and ncount ne 13 and ncount ne 17 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,100],$
            ytickv=[0,25,50,75,100], ytickname=[' ',' ',' ',' ',' '],$
            charsize=1.5,/ystyle,color=1
      endif

      axis,13, yaxis=1,yticks=4, yrange=[0,100],$
         ytickv=[0,25,50,75,100], ytickname=[' ',' ',' ',' ',' '],$
         charsize=1.5,/ystyle,color=1
      
      ;=====================================================================
      ; Third plot panel
      ;=====================================================================   
      loval=0 
      highval=100

      plot, findgen(12)+1, sonde[*,0], xstyle=1,ystyle=5,$
         linestyle=0,psym=-5,symsize=0.6, $
         xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
         charsize=1.5,color=1,$
         xtickname=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' ']

      ; Now plot standard deviations
      for w = 0, 11 do begin
         if std_sonde[w,0] gt 0 then begin
            errbar = [sonde[w,0]-std_sonde[w,0],sonde[w,0]+std_sonde[w,0] ]
            oplot,  [w+1,w+1],errbar,$
               linestyle=0,color=1
         endif
      endfor
      
      ; 1st month
      oplot, findgen(12)+1,out[0:11,0],linestyle=0,color=2
      oplot, findgen(12)+1,out[0:11,0],linestyle=0,psym=-5,$
         symsize=0.6,color=2   

      ; 2nd month
      oplot, findgen(12)+1,out2[0:11,0],linestyle=0,color=3
      oplot, findgen(12)+1,out2[0:11,0],linestyle=0,psym=-5,$
         symsize=0.6,color=3   

      ; 3rd month
      oplot, findgen(12)+1,out3[0:11,0],linestyle=0,color=4
      oplot, findgen(12)+1,out3[0:11,0],linestyle=0,psym=-5,$
         symsize=0.6,color=4   
      
      xyouts,1,0.8*highval, '800 hPa', charsize = 1,color=1

      xyouts, 0.04, 0.5, 'O3 (ppb)', /normal, align=0.5, orientation=90, $
         charsize=1.2,color=1

      ; Plot axes
      if ncount eq 1 or ncount eq 5 or ncount eq 9 or ncount eq 13 or ncount eq 17 or ncount eq 21 or ncount eq 25 or ncount eq 29 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,100],$
            ytickv=[0,25,50,75,100], ytickname=[' 0','25','50','75','100'],$
            charsize=1.5,/ystyle,color=1
      endif

      if ncount ne 1 and ncount ne 5 and ncount ne 9 and ncount ne 13 and ncount ne 17 then begin  
         axis, 0, yaxis=0, yticks=4, yrange=[0,100],$
            ytickv=[0,25,50,75,100], ytickname=[' ',' ',' ',' ',' '],$
            charsize=1.5,/ystyle,color=1
      endif

      axis,13, yaxis=1,yticks=4, yrange=[0,100],$
         ytickv=[0,25,50,75,100], ytickname=[' ',' ',' ',' ',' '],$
         charsize=1.5,/ystyle,color=1
      xyouts, 0.5, 0.96,title, /normal, align=0.5, charsize=1.2,color=1
   endfor

   close_device,/TIMESTAMP
   
   close, /all

end


