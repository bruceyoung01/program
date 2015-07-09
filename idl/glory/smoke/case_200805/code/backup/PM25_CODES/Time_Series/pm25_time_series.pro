;@./study_area.pro
;@./load_aqi_color.pro
;@./aqi_color_routine.pro

; read all PM data

  filedir = '/home/npothier/Assistanceship/EPAAIRS/SimplifiedData/'
  filenames = 'Simple_New_RD_501_88502_2009-0.txt'

; read the pm data
  READCOL, filedir+filenames, state_id, county_id, site_id, $
           year, mon, day, time, pm25, $
           FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1


  nrecord = n_elements(site_id)
  print, "number of sites= ", nrecord
  
  location=where(state_id eq 48 and county_id eq 061 and site_id eq 0006 and mon eq 7 and day eq 3, COUNT)

  hour=time[location[0:23]]
  pm=pm25[location[0:23]]
  
  maximum=max(pm25)
  minimum=min(pm25)
  
  print, "max= ", maximum
  print, "min= ", minimum
    
  ;plot every hour on jan 1, 2009 for desired site
  set_plot, 'ps'
  device, filename='cameroncountypm25.ps'

  plot, hour, pm, TITLE="Cameron County PM2.5 Data for July 11, 2009" , $
  xtitle="Hour", ytitle="PM2.5"
  ;, PSYM= 3

  device, /close

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
