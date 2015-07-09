;@./study_area.pro
;@./load_aqi_color.pro
;@./aqi_color_routine.pro

; read all PM data

  filedir = '/home/npothier/Assistanceship/EPAAIRS/SimplifiedData/'
  filenames = ['Simple_New_RD_501_88502_2008-0.txt', 'Simple_New_RD_501_88502_2007-0.txt', $
  'Simple_New_RD_501_88502_2006-0.txt','Simple_New_RD_501_88502_2005-0.txt','Simple_New_RD_501_88502_2004-0.txt',$
  'Simple_New_RD_501_88502_2003-0.txt','Simple_New_RD_501_88502_2002-0.txt','Simple_New_RD_501_88502_2001-0.txt',$
  'Simple_New_RD_501_88502_2000-0.txt','Simple_New_RD_501_88502_1999-0.txt']

;location=fltarr

for i=0,9 do begin
; read the pm data
  READCOL, filedir+filenames[i], state_id+string(i), county_id+string(i), site_id+string(i), $
           year+string(i), mon+string(i), day+string(i), time+string(i), pm25+string(i), $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1
;endfor


  location=where(state_id+string(i) eq 48 and county_id+string(i) eq 061 and site_id+string(i) eq 0006, COUNT)

   time2=time+string(i)

  hour=time2[location]
  
  ;timepoint0000=where(hour eq 0000)
  
  ;pm0000=pm25[timepoint0000]
  
  ;average0000=mean(pm0000)
 ; print, " the 0000 average= ", pm0000
  
 
   oclock=[0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300]
 ; timepoint=fltarr(24, )
  ;pm=fltarr(24)
  average=fltarr(24)
  
  
  for j=0,23 do begin
  timepoint=where(hour eq oclock[j])
  
  pm=pm25[timepoint]
  
  average[j]=mean(pm)
  print, " the ", j, " average= ", average[j]
  
  endfor
 endfor
  ;;;NO 1999,2000, 2001, 2002,2003, 2004 FOR THAT LOCATION!
  
    
  ;plot every hour on jan 1, 2009 for desired site
  set_plot, 'ps'
  device, filename='10yraveragetotal.ps'

  plot, oclock, average;, TITLE="10-Year Average PM2.5 Data for Each Hour of Each Day for Cameron County" , $
  ;xtitle="Hour", ytitle="PM2.5 10-Year Average"


  device, /close
 
  ;plot every hour on jan 1, 2009 for desired site
  ;;set_plot, 'ps'
  ;;device, filename='cameroncountypm25.ps'

  ;;plot, hour, pm, TITLE="Cameron County PM2.5 Data for July 11, 2009" , $
  ;;xtitle="Hour", ytitle="PM2.5"


 ;; device, /close

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
