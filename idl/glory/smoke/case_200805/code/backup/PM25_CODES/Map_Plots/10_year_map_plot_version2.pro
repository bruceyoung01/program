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
    timelocate=where(time eq ttime[i], COUNT)
    PPM = PM25[timelocate]
    SSTATE = state_id[timelocate]
    Ccounty = county_id[timelocate]
    SSite = site_id[timelocate]
    LLAT = fltarr(COUNT) - 999
    LLON = fltarr(COUNT) - 999
    ;endelse
    for j=0,COUNT-1 do begin 
	index=where(sitestatecode eq SSTATE[j] and $
                    sitecountycode eq Ccounty[j] and $
                     sitesiteid eq SSite[j], CCOUNT)
        
        if ccount eq 0 then begin
           print, 'no match found' 
           print,  SSTATE[j], Ccounty[j], SSite[j] 
        endif   
  
        if (CCOUNT eq 1 ) then begin
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
