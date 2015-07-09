;@./study_area.pro
;@./load_aqi_color.pro
;@./aqi_color_routine.pro

; specify date
  ; yr = 2008
  ; dday = 17
  ; mmon = 7
  ; ttime = 1200


; read all PM data

  filedir = '/home/npothier/Assistanceship/EPAAIRS/SimplifiedData/'
  filename1 = 'Simple_New_RD_501_88502_2008-0.txt'
  filename2='Simple_New_RD_501_88502_2007-0.txt'
  filename3= 'Simple_New_RD_501_88502_2006-0.txt'
  filename4='Simple_New_RD_501_88502_2005-0.txt'
  filename5='Simple_New_RD_501_88502_2004-0.txt'
  filename6='Simple_New_RD_501_88502_2003-0.txt'
  filename7='Simple_New_RD_501_88502_2002-0.txt'
  filename8='Simple_New_RD_501_88502_2001-0.txt'
  filename9='Simple_New_RD_501_88502_2000-0.txt'
  filename10='Simple_New_RD_501_88502_1999-0.txt'
  filename11='Simple_new_site_monitor.txt'
  
  READCOL, filedir+filename1, state_id2008, county_id2008, site_id2008, $
           year2008, mon2008, day2008, time2008, pm252008, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
  
  READCOL, filedir+filename2, state_id2007, county_id2007, site_id2007, $
           year2007, mon2007, day2007, time2007, pm252007, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
  
  READCOL, filedir+filename3, state_id2006, county_id2006, site_id2006, $
           year2006, mon2006, day2006, time2006, pm252006, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
  
  READCOL, filedir+filename4, state_id2005, county_id2005, site_id2005, $
           year2005, mon2005, day2005, time2005, pm252005, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename5, state_id2004, county_id2004, site_id2004, $
           year2004, mon2004, day2004, time2004, pm252004, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename6, state_id2003, county_id2003, site_id2003, $
           year2003, mon2003, day2003, time2003, pm252003, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename7, state_id2002, county_id2002, site_id2002, $
           year2002, mon2002, day2002, time2002, pm252002, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename8, state_id2001, county_id2001, site_id2001, $
           year2001, mon2001, day2001, time2001, pm252001, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename9, state_id2000, county_id2000, site_id2000, $
           year2000, mon2000, day2000, time2000, pm252000, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
	   
  READCOL, filedir+filename10, state_id1999, county_id1999, site_id1999, $
           year1999, mon1999, day1999, time1999, pm251999, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
   
  READCOL, filedir+filename11, class, $
    	    sitestatecode, sitecountycode, sitesiteid, sitelat, sitelon, $
           format = 'A, I, I, I, F,  F',  skipline = 1,/debug
    
  average=fltarr(24)
  totalpm=fltarr(24)
  hourlyaverage=fltarr(24)
  
  
  location1=where(state_id2008 eq 21 and county_id2008 eq 019 and site_id2008 eq 0017, COUNT1)
  location2=where(state_id2007 eq 21 and county_id2007 eq 019 and site_id2007 eq 0017, COUNT2)
  location3=where(state_id2006 eq 21 and county_id2006 eq 019 and site_id2006 eq 0017, COUNT3)
  location4=where(state_id2005 eq 21 and county_id2005 eq 019 and site_id2005 eq 0017, COUNT4)
  location5=where(state_id2004 eq 21 and county_id2004 eq 019 and site_id2004 eq 0017, COUNT5)
  location6=where(state_id2003 eq 21 and county_id2003 eq 019 and site_id2003 eq 0017, COUNT6)
  location7=where(state_id2002 eq 21 and county_id2002 eq 019 and site_id2002 eq 0017, COUNT7)
  location8=where(state_id2001 eq 21 and county_id2001 eq 019 and site_id2001 eq 0017, COUNT8)
  location9=where(state_id2000 eq 21 and county_id2000 eq 019 and site_id2000 eq 0017, COUNT9)
  location10=where(state_id1999 eq 21 and county_id1999 eq 019 and site_id1999 eq 0017, COUNT10) 

;for m=0, n_elements
   
  if (location1[0] eq -1) then begin 
    hour2008= -1.      
  endif else begin
    hour2008=time2008[location1]   
  endelse
  
  if (location2[0] eq -1) then begin 
   hour2007= -1.    
  endif else begin
   hour2007=time2007[location2]
  endelse
   
  if (location3[0] eq -1) then begin 
   hour2006= -1.    
  endif else begin
   hour2006=time2006[location3]
  endelse 
   
  if (location4[0] eq -1) then begin 
   hour2005= -1. 
  endif else begin
   hour2005=time2005[location4]
  endelse 
  
  if (location5[0] eq -1) then begin 
    hour2004= -1.   
  endif else begin
   hour2004=time2004[location5]
  endelse 
   
  if (location6[0] eq -1) then begin
    hour2003= -1.    
  endif else begin
   hour2003=time2003[location6] 
  endelse 
  
  if (location7[0] eq -1) then begin 
    hour2002= -1.   
  endif else begin
   hour2002=time2002[location7]
  endelse
   
  if (location8[0] eq -1) then begin 
    hour2001= -1.    
  endif else begin
   hour2001=time2001[location8]
  endelse 
    
  if (location9[0] eq -1) then begin 
   hour2000= -1.   
  endif else begin
   hour2000=time2000[location9]
  endelse  
   
  if (location10[0] eq -1) then begin 
    hour1999= -1.
  endif else begin
   hour1999=time1999[location10]
   
   
   

   
   
   
   
   
   
   
   
   
   
   
   
   
   
  LLAT = fltarr(COUNT) - 999
  LLON = fltarr(COUNT) - 999 
  
  oclock=[0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300]
  



filelength=n_elements(state_id2008)-1

for i=0, filelength do begin 
	index2008=where(sitestatecode eq state_id2008[i] and $
                    sitecountycode eq county_id2008[i] and $
                     sitesiteid eq site_id2008[i], CCOUNT2008)
       
        if ccount2008 eq 0 then begin
           print, 'no match found' 
           print,  state_id2008[i], county_id2008[i], site_id2008[i]   
        endif   
  
        if (CCOUNT2008 eq 1 ) then begin
        LLAT[i] = sitelat[index[0]]
        LLON[i] = sitelon[index[0]]
        endif
	
	if (LLAT[i] eq -999.0 or LLON[i] eq -999) then begin
	    LLAT[i]=!values.F_NaN
	    LLON[i]=!values.F_NaN
	    hourlyaverage[i]=!values.F_NaN
	endif    
	
	hour2008=time2008[index2008]
	
	index2007=where(sitestatecode eq state_id2007[i] and $
                    sitecountycode eq county_id2007[i] and $
                     sitesiteid eq site_id2007[i], CCOUNT2007)
       
        if ccount2007 eq 0 then begin
           print, 'no match found' 
           print,  state_id2007[i], county_id2007[i], site_id2007[i]   
        endif   
  
        if (CCOUNT2007 eq 1 ) then begin
        LLAT[i] = sitelat[index[0]]
        LLON[i] = sitelon[index[0]]
        endif
	
	if (LLAT[i] eq -999.0 or LLON[i] eq -999) then begin
	    LLAT[i]=!values.F_NaN
	    LLON[i]=!values.F_NaN
	    hourlyaverage[i]=!values.F_NaN
	endif    
	
	hour2008=time2008[index2008]
	
    for j=0,23 do begin  
    	count=0.  

    	timepoint2008=where(hour2008 eq oclock[j], count2008)

    	if (timepoint2008[0] eq -1) then begin
 
     	    pm2008avg=0.
    
    	endif else begin
  
    	    pm2008=pm252008[timepoint2008]
  
    	    pm2008avg=mean(pm2008)
  
    	    count=count+1.
    
    	endelse
  
    	    timepoint2007=where(hour2007 eq oclock[j], count2007)
  
    	if (timepoint2007[0] eq -1) then begin
 
    	    pm2007avg=0.
    
    	endif else begin
  
    	    pm2007=pm252007[timepoint2007]
  
    	    pm2007avg=mean(pm2007)
  
    	    count=count+1.
  
    	endelse
  
    	    timepoint2006=where(hour2006 eq oclock[j], count2006)
  
    	if (timepoint2006[0] eq -1) then begin
 
    	    pm2006avg=0.
    
   	endif else begin
  
    	    pm2006=pm252006[timepoint2006]
  
    	    pm2006avg=mean(pm2006)
  
    	    count=count+1.
  
    	endelse
    
    	    timepoint2005=where(hour2005 eq oclock[j], count2005)
  
    	if (timepoint2005[0] eq -1) then begin
 
    	 pm2005avg=0.
    
    	endif else begin
  
    	    pm2005=pm252005[timepoint2005]
  
    	    pm2005avg=mean(pm2005)
  
    	    count=count+1.
  
    	endelse
  
    	    timepoint2004=where(hour2004 eq oclock[j], count2004)
  
    	if (timepoint2004[0] eq -1) then begin
 
    	    pm2004avg=0.
    
    	endif else begin
  
    	    pm2004=pm252004[timepoint2004]
  
    	    pm2004avg=mean(pm2004)
  
    	    count=count+1.
  
    	endelse

    	    timepoint2003=where(hour2003 eq oclock[j], count2003)
  
    	if (timepoint2003[0] eq -1) then begin
 
    	    pm2003avg=0.
    
    	endif else begin
  
    	    pm2003=pm252003[timepoint2003]
  
    	    pm2003avg=mean(pm2003)
  
    	    count=count+1.
  
    	endelse

    	    timepoint2002=where(hour2002 eq oclock[j], count2002)
  
    	if (timepoint2002[0] eq -1) then begin
 
    	    	pm2002avg=0.
    
    	endif else begin
  
    	    pm2002=pm252002[timepoint2002]
  
    	    pm2002avg=mean(pm2002)
  
    	    count=count+1.
  
    	endelse
	    
    	    timepoint2001=where(hour2001 eq oclock[j], count2001)
  
    	if (timepoint2001[0] eq -1) then begin
 
    	    	pm2001avg=0.
    
    	endif else begin
  
    	    pm2001=pm252001[timepoint2001]
  
    	    pm2001avg=mean(pm2001)
  
    	    count=count+1.
  
    	endelse

    	    timepoint2000=where(hour2000 eq oclock[j], count2000)
  
    	if (timepoint2000[0] eq -1) then begin
 
    	    pm2000avg=0.
    
    	endif else begin
  
    	    pm2000=pm252000[timepoint2000]
  
    	    pm2000avg=mean(pm2000)
  
    	    count=count+1.
  
    	endelse

    	    timepoint1999=where(hour1999 eq oclock[j], count1999)
  
    	if (timepoint1999[0] eq -1) then begin
 
    	    pm1999avg=0.
    
    	endif else begin
  
    	    pm1999=pm251999[timepoint1999]
  
    	    pm1999avg=mean(pm1999)
  
    	    count=count+1.
  
    	endelse

    	    totalpm=pm2008avg+pm2007avg+pm2006avg+pm2005avg+pm2004avg+$
    	    pm2003avg+pm2002avg+pm2001avg+pm2000avg+pm1999avg
  
    	    hourlyaverage[j]=totalpm/count
    	
    endfor
endfor    	










    
 
 
    SET_PLOT, 'PS' 
   DEVICE, file = 'us_map_dailyhourly_avg.ps', xsize = 6, ysize =4,$
              /inches, /color, BITS=8
   ;WINDOW, 1, xsize = 600, ysize =400
   loadct, 34, ncolors=80, bottom=20
  
    map_range = [25,-130,50,-70]

   MAP_SET, /CONTINENT, MLINETHICK = 1, LIMIT = map_range, $
            title = '!6PM!d2.5!n Map for July 17, 2008 at 1200', $
            color = 1, /usa, /horizon, position = [0.1,0.2,0.9,0.9]



    FOR i = 0, COUNT2008 -1 DO BEGIN

    ; color index for the scatter is a function of PM values
    color_index     = ROUND( PPM[i] * (80./50.)+20. )
   ; bar_labelv      = fltarr(7)
    bar_labelv      = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0]
    
    
    
    ;PPMlabel	    =ROUND(50./80.)-20.)

    print, 'color_indx:', color_index, '  PM:', PPM[i]

    	    oplot, [LLON[i]], [LLAT[i]], color = color_index,psym = sym(1), symsize=0.5;, $
    
    ENDFOR

;  plot the color bar
   COLORBAR, NCOLORS=80, BOTTOM=20, DIVISIONS=5, TICKNAMES=[bar_labelv],$
   POSITION=[0.1, 0.1, 0.9, 0.15]


   DEVICE, /close

  END

;04 for Arizona
;019 for Pima County
;011 for first Pima site

;21 for Kentucky
;019 for Boyd County
;0017 for boyd site

;36 for New York
;119 for Westchester County
;2004 for

;48 for Texas
;061 for Cameron County
;0006 for
