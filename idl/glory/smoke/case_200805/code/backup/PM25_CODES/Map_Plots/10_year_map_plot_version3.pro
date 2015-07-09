  hour=0
  
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
    
   ; nsite=n_elements(site_id2008)
   ; ncounty=n_elements(county_id2008)
   ; nstate=n_elements(state_id2008)
   ; station=fltarr(nstate, ncounty, nsite)
    
 ;   for i=0, nstate-1 do begin
 ;   
 ;   	state1=state_id2008[i]
  ; 	for j=0, ncounty-1 do begin
;	    for k=0, nsite-1 do begin
	;    	location=where(state_id2008[i] and county_id2008[j] and site_id2008[k] and time2008 eq 0)
    ;	    	station[i,j,k]=
   ; timesep=where(time2008 eq 0)
    ;location[i]=

;mmon=


;dday=
ttime=[0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300]
for i=0, 23 do begin
    regcounter=0.
    
    timelocate2008=where(time2008 eq ttime[i], COUNT2008)   
    if (timelocate2008[0] eq -1) then begin
    	pm2008avg=0.
	SSTATE2008 = !values.F_NaN
    	Ccounty2008 = !values.F_NaN
    	SSite2008 = !values.F_NaN
	
    endif else begin
    	PM2008 = PM252008[timelocate2008]
    	SSTATE2008 = state_id2008[timelocate2008]
    	Ccounty2008 = county_id2008[timelocate2008]
    	SSite2008 = site_id2008[timelocate2008]
	ppm2008=pm2008[SSTATE2008]
	;nstations=n_elements(
	;for k=0, COUNT2008-1 do begin
	
	
	
    	pm2008avg=mean(ppm2008)
  
    	regcounter=regcounter+1.
  
    endelse
  
    timelocate2007=where(time2007 eq ttime[i], COUNT2007)
    if (timelocate2007[0] eq -1) then begin
    	pm2007avg=0.
	SSTATE2007 = !values.F_NaN
    	Ccounty2007 = !values.F_NaN
    	SSite2007 = !values.F_NaN
	
    endif else begin
    	PM2007 = PM252007[timelocate2007]
    	SSTATE2007 = state_id2007[timelocate2007]
    	Ccounty2007 = county_id2007[timelocate2007]
    	SSite2007 = site_id2007[timelocate2007]
	ppm2007=pm2007[SSTATE2007]
    	pm2007avg=mean(ppm2007)
  
    	regcounter=regcounter+1
  
    endelse
  
    timelocate2006=where(time2006 eq ttime[i], COUNT2006)
    if (timelocate2006[0] eq -1) then begin
    	pm2006avg=0.
	SSTATE2006 = !values.F_NaN
    	Ccounty2006 = !values.F_NaN
    	SSite2006 = !values.F_NaN
	
    endif else begin
    	PM2006 = PM252006[timelocate2006]
    	SSTATE2006 = state_id2006[timelocate2006]
    	Ccounty2006 = county_id2006[timelocate2006]
    	SSite2006 = site_id2006[timelocate2006]
	ppm2006=pm2006[SSTATE2006]
    	pm2006avg=mean(ppm2006)
  
    	regcounter=regcounter+1
  
    endelse

    timelocate2005=where(time2005 eq ttime[i], COUNT2005)
    if (timelocate2005[0] eq -1) then begin
    	pm2005avg=0.
	SSTATE2005 = !values.F_NaN
    	Ccounty2005 = !values.F_NaN
    	SSite2005 = !values.F_NaN
	
    endif else begin
    	PM2005 = PM252005[timelocate2005]
    	SSTATE2005 = state_id2005[timelocate2005]
    	Ccounty2005 = county_id2005[timelocate2005]
    	SSite2005 = site_id2005[timelocate2005]
	ppm2005=pm2005[SSTATE2005]
    	pm2005avg=mean(ppm2005)
  
    	regcounter=regcounter+1
  
    endelse
     
    timelocate2004=where(time2004 eq ttime[i], COUNT2004)
    if (timelocate2004[0] eq -1) then begin
    	pm2004avg=0.
	SSTATE2004 = !values.F_NaN
    	Ccounty2004 = !values.F_NaN
    	SSite2004 = !values.F_NaN
	
    endif else begin
    	PM2004 = PM252004[timelocate2004]
    	SSTATE2004 = state_id2004[timelocate2004]
    	Ccounty2004 = county_id2004[timelocate2004]
    	SSite2004 = site_id2004[timelocate2004]
	ppm2004=pm2004[SSTATE2004]
    	pm2004avg=mean(ppm2004)
  
    	regcounter=regcounter+1
  
    endelse
       
    timelocate2003=where(time2003 eq ttime[i], COUNT2003)
    if (timelocate2003[0] eq -1) then begin
    	pm2003avg=0.
	SSTATE2003 = !values.F_NaN
    	Ccounty2003 = !values.F_NaN
    	SSite2003 = !values.F_NaN
	
    endif else begin
    	PM2003 = PM252003[timelocate2003]
    	SSTATE2003 = state_id2003[timelocate2003]
    	Ccounty2003 = county_id2003[timelocate2003]
    	SSite2003 = site_id2003[timelocate2003]
	ppm2003=pm2003[SSTATE2003]
    	pm2003avg=mean(ppm2003)
  
    	regcounter=regcounter+1
  
    endelse
        
    timelocate2002=where(time2002 eq ttime[i], COUNT2002)
    if (timelocate2002[0] eq -1) then begin
    	pm2002avg=0.
	SSTATE2002 = !values.F_NaN
    	Ccounty2002 = !values.F_NaN
    	SSite2002 = !values.F_NaN
	
    endif else begin
    	PM2002 = PM252002[timelocate2002]
    	SSTATE2002 = state_id2002[timelocate2002]
    	Ccounty2002 = county_id2002[timelocate2002]
    	SSite2002 = site_id2002[timelocate2002]
	ppm2002=pm2002[SSTATE2002]
    	pm2002avg=mean(ppm2002)
  
    	regcounter=regcounter+1
  
    endelse
       
    timelocate2001=where(time2001 eq ttime[i], COUNT2001)
    if (timelocate2001[0] eq -1) then begin
    	pm2001avg=0.
	SSTATE2001 = !values.F_NaN
    	Ccounty2001 = !values.F_NaN
    	SSite2001 = !values.F_NaN
	
    endif else begin
    	PM2001 = PM252001[timelocate2001]
    	SSTATE2001 = state_id2001[timelocate2001]
    	Ccounty2001 = county_id2001[timelocate2001]
    	SSite2001 = site_id2001[timelocate2001]
	ppm2001=pm2001[SSTATE2001]
    	pm2001avg=mean(ppm2001)
  
    	regcounter=regcounter+1
  
    endelse   
    
    timelocate2000=where(time2000 eq ttime[i], COUNT2000)
    if (timelocate2000[0] eq -1) then begin
    	pm2000avg=0.
	SSTATE2000 = !values.F_NaN
    	Ccounty2000 = !values.F_NaN
    	SSite2000 = !values.F_NaN
	
    endif else begin
    	PM2000 = PM252000[timelocate2000]
    	SSTATE2000 = state_id2000[timelocate2000]
    	Ccounty2000 = county_id2000[timelocate2000]
    	SSite2000 = site_id2000[timelocate2000]
	ppm2000=pm2000[SSTATE2000]
    	pm2000avg=mean(ppm2000)
  
    	regcounter=regcounter+1
  
    endelse   
    
    timelocate1999=where(time1999 eq ttime[i], COUNT1999)
    if (timelocate1999[0] eq -1) then begin
    	pm1999avg=0.
	SSTATE1999 = !values.F_NaN
    	Ccounty1999 = !values.F_NaN
    	SSite1999 = !values.F_NaN
	
    endif else begin
    	PM1999 = PM251999[timelocate1999]
    	SSTATE1999 = state_id1999[timelocate1999]
    	Ccounty1999 = county_id1999[timelocate1999]
    	SSite1999 = site_id1999[timelocate1999]
	ppm1999=pm1999[SSTATE1999]
    	pm1999avg=mean(ppm1999)
  
    	regcounter=regcounter+1
  
    endelse 
    
    totalpm=pm2008avg+pm2007avg+pm2006avg+pm2005avg+pm2004avg+$
    pm2003avg+pm2002avg+pm2001avg+pm2000avg+pm1999avg
  
    hourlyaverage[i]=totalpm/regcounter
    
    
    
    
    
    
    
    
    
    
    LLAT = fltarr(COUNT) - 999
    LLON = fltarr(COUNT) - 999
    ;endelse
    for j=0,COUNT-1 do begin 
	index2008=where(sitestatecode eq SSTATE2008[j] and $
                    sitecountycode eq Ccounty2008[j] and $
                     sitesiteid eq SSite2008[j], CCOUNT2008)
        
        if ccount2008 eq 0 then begin
           print, 'no match found' 
           print,  SSTATE2008[j], Ccounty2008[j], SSite2008[j] 
        endif   
  ;;;different years have different number of stations...how can we match of the lat and long
  ;;;for the purpose of plotting these?
        if (CCOUNT2008 eq 1 ) then begin
        LLAT[j] = sitelat[index[0]]
        LLON[j] = sitelon[index[0]]
        endif
	
	if (LLAT[j] eq -999.0 or LLON[j] eq -999) then begin
	    LLAT[j]=!values.F_NaN
	    LLON[j]=!values.F_NaN
	    PPM[j]=!values.F_NaN
	endif
	
    endfor


endfor









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
