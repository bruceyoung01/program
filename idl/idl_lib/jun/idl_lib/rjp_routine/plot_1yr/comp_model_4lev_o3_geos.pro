; $Id: comp_model_4lev_o3_geos.pro,v 1.2 2003/12/08 19:34:53 bmy Exp $
pro comp_model_4lev_o3_geos,dir, pref,ptop,dlat,dlon,ext,nalt

   Species='O3'
   
   mmonth=['Jan','Feb','Mar','Apr','May','Jun',$
           'Jul','Aug','Sep','Oct','Nov','Dec']

   std_press=[800,500,300,150]

   ; --- read station & indice ---

   max_station=32
   name_sta=''
   num_sta=''
   pref_sta=''

   num_station=strarr(max_station)
   name_station=strarr(max_station)
   pref_station=strarr(max_station)
   lat_station=strarr(max_station)
   lon_station=strarr(max_station)

   ; Now read in information about stations

   ;filest='Sites.O3.prof.trop'  ;for tropical stations
   filest='Sites.O3.prof.all'   ;for all stations

   openr, usta, filest, /get_lun
   for i=0,max_station-1 do begin
      readf,usta, pref_sta,                  $
         name_sta, lat_sta,         $
         lon_sta,num_sta,         $
         format='(2x,a3,9x,a16,1x,f6.2,3x,f6.2,3x,a3)'
      pref_station(i) = pref_sta
      name_station(i) = name_sta
      lat_station(i) = round(lat_sta)
      lon_station(i) = lon_sta
      num_station(i) = num_sta

   endfor


; ---  open files ---

   ncount=0

   ; Name for output file
   fileout = 'All.stations.geos.statistics'+ext

   ; Now write FILEOUT to temp/ directory (bmy, 8/13/03)
   fileout = 'temp/' + fileout

   iunit = 50
   openw,iunit,fileout
   printf, iunit, 'pressure model mean_bias_pr mean_bias mean_bias_std  mean_abs_bias  stat1 stat2 max_agreement min_agreement amplitude  amplitude_sonde'
   
   for k = 1, max_station do begin

      ncount=ncount+1
      kk = k-1 
      ix = k
      file=''

      if lon_station(kk) gt 180 then lon_station(kk)=lon_station(kk)-360

      name_sonde='/users/trop/iam/sondes.for.gmi/sonde'+num_station(kk)
      
; Read data from geos model

      out=fltarr(12,4)

      for i=0,11 do begin
         mn=strtrim(String(fix(i+1)),2)
         if (strlen(mn) eq 1) then begin
            
            mn='0'+mn
         endif
         name=dir+pref+mn+'01.nc'

         if lon_station(kk) eq 178 then lon_station(kk)=-182

   ;=================================================================
   ; Read 3-D Ox
   ; return LAT & lon from the file
   ;=================================================================
         O3 = Get_Species_Geos( name, Date=Date, $
                                Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
         Pressure = Get_Pressure_Geos( Name, PTOP=PTOP, Lat=Lat, Lon=Lon )

;   Now select proper box

         Indlat = Where( Lat ge lat_station(kk)-dlat/2 and $
                         Lat le lat_station(kk)+dlat/2 )
         Indlon = Where( Lon ge lon_station(kk)-dlon/2 and $
                         Lon le lon_station(kk)+dlon/2 )

         O3_box = O3[Indlon,Indlat,*]
         Pressure_box = Pressure[Indlon,Indlat,*]

         Ozone=fltarr(Nalt)
         pres=fltarr(Nalt)
         for j=0,Nalt-1 do begin
            Ozone[j]=mean(O3_box[*,*,j])
            Pres[j]=mean( Pressure_box [*,*,j]) 
         endfor
         
         out[i,*]=interpol(Ozone,alog10(Pres),alog10(std_press))
         
      endfor

      ; Now read sonde means and standard deviations
      read_sondes_4lev,name_sonde, sonde, std_sonde
      
      openw,iunit,fileout,/append

      ; Do pressure loop (4 pressure levels) for dao model 
      for j=0,3 do begin
   
         ; Now calculate mean bias for geos model

         bias_geos=out[*,j]-sonde[*,j]
         bias_geos_pr=(out[*,j]-sonde[*,j])/sonde[*,j]*100
         mean_bias_geos_pr=mean(bias_geos_pr)
         
         std_bias_geos=stddev(bias_geos)/sqrt(12)
         mean_bias_geos=mean(bias_geos)
         abs_mean_bias_geos=mean(abs(bias_geos))
         
; Now calculate how close the model is to data stddev
         l1=0.0
         l2=0.0
         for i=0,11 do begin
            
            if (abs(sonde[i,j]-out[i,j]) gt std_sonde[i,j] and $
                abs(sonde[i,j]-out[i,j]) lt 2*std_sonde[i,j]) then $
               l1=l1+0.25    
            if (abs(sonde[i,j]-out[i,j]) le std_sonde[i,j]) then l1=l1+1    	
            
            if (abs((sonde[i,j]-out[i,j])/sonde[i,j]*100) gt 20 and $
                abs((sonde[i,j]-out[i,j])/sonde[i,j]*100) le 40) then $
               l2=l2+0.25 

            if (abs((sonde[i,j]-out[i,j])/sonde[i,j]*100) gt 10 and $
                abs((sonde[i,j]-out[i,j])/sonde[i,j]*100) le 20) then $
               l2=l2+0.5 

            if (abs((sonde[i,j]-out[i,j])/sonde[i,j]*100) le 10) then l2=l2+1 

         endfor

         l1=l1/12.0
         l2=l2/12.0

         ; Calculate maximum and minimum for the model and data, 
         ; measure how far apart they are, also amplitude (max-min)

         max_geos=max(out[*,j])
         min_geos=min(out[*,j])
         max_sonde=max(sonde[*,j])
         min_sonde=min(sonde[*,j])
         
         amp_geos=max_geos-min_geos
         amp_sonde=max_sonde-min_sonde
         
         ; Find months for minimum and maximum for both model and data

         for i=0,11 do begin
            if (sonde[i,j] eq max_sonde) then m1_sonde=i+1
            if (sonde[i,j] eq min_sonde) then m2_sonde=i+1
            if (out[i,j] eq max_geos) then m1_geos=i+1
            if (out[i,j] eq min_geos) then m2_geos=i+1
         endfor

         l3=0
         l4=0
         
         if (abs(m1_sonde-m1_geos) eq 0 or abs(m1_sonde-m1_geos) eq 1 $
             or abs(m1_sonde-m1_geos) eq 11) then l3=l3+1

         if (abs(m1_sonde-m1_geos) eq 2 or abs(m1_sonde-m1_geos) eq 10) $
            then l3=l3+0.5

         if (abs(m2_sonde-m2_geos) eq 0 or abs(m2_sonde-m2_geos) eq 1 or $
             abs(m2_sonde-m2_geos) eq 11) then l4=l4+1

         if (abs(m2_sonde-m2_geos) eq 2 or abs(m2_sonde-m2_geos) eq 10) $
            then l4=l4+0.5

         if (j eq 3) then pres=150
         if (j eq 2) then pres=300
         if (j eq 1) then pres=500
         if (j eq 0) then pres=800


         printf, iunit, name_station(kk),num_station(kk), pres, $
            'geos',mean_bias_geos_pr,mean_bias_geos,std_bias_geos,$
            abs_mean_bias_geos,l1,l2,l3,l4,amp_geos,amp_sonde,$
            format='(a16,1x,i3,2x,i3,2x,a6,2x,f6.2,2x,f7.2,2x,f6.2,2x,f6.2,2x,f6.4,2x,f6.4,2x,f3.1,2x,f3.1,2x,f6.2,2x,f7.2)'
         
      endfor

   endfor

close, /all

end


