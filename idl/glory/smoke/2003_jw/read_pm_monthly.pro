pro read_pm_monthly, datadir, filelist, monchar, datatype, $
                     np, pmlat, pmlon, pmdata, pmns, pmstachar


nouse = ' '
stationidchar = ' '
epaid = 0L
maxnl = 90
maxsta = 500
oneline = fltarr(np)
onemonth = fltarr(np, maxnl)
tmplat = fltarr(maxsta)
tmplon = fltarr(maxsta)
tmpname = strarr(maxsta)
totalmonth = fltarr(maxsta, maxnl*24.)+999 

; read the data station by station
       openr, 1, filelist
       readf, 1, nouse
       
       ns = 0               ; station index
     
       while (not eof(1) ) do begin
          readf, 1, stationidchar
	  stationidchar = strcompress(stationidchar, /remove_all)
	  
       	  tnl = 0
	  
	  for k = 0, n_elements(monchar) -1 do begin 
	  
            onemonth = fltarr(np, maxnl)+99  
	    mnl = 0
	
           ; get the filename corresponding to id and month
             stationfile = datadir + monchar(k) + '_'+stationidchar + '.dat.asc'
           
           ; read data (US and TX dataformat is slightly different)
           ; print, 'open file ', stationfile
            
	     print, ' sta file = ', stationfile 
	     
	     openr, 2, stationfile
             if ( strmid(datatype, 0, 2) eq 'TX') then begin
             readf, 2, nouse
             readf, 2, stateid, countyid, stanum, camsid, lat, lon, height, regionbox
             readf, 2, nouse
             readf, 2, nouse
             endif else begin
               readf, 2, nouse
               readf, 2, epaid, lon, lat
               readf, 2, nouse
             endelse

             ; read one month
              while  not eof(2) do begin
                readf, 2, oneline
                onemonth(0:np-1, mnl) = oneline(0:np-1)
	        mnl = mnl+1
              endwhile
	     
	     ; merge one month into total month
	      if mnl gt 32 then mnl = 31
	     
	      for i = 0, mnl-1 do begin
	        nl = onemonth(0,i)-1+tnl
		totalmonth( ns, nl*24L:(nl+1)*24L-1 ) = onemonth(1:24, i)
              endfor
	     close,2
	     
	     tnl = tnl + mnl
	     print, 'nl = ', nl, ' mnl=', mnl
	    
	    ; after one month per station is over. 
	 endfor    
	 
	 ; after all motn for save stations is over
           tmplat(ns) = lat
	   tmplon(ns) = lon
	   tmpname(ns) = stationidchar
	   ns = ns + 1
      endwhile
      close,1
      
      
      pmlat = tmplat(0:ns-2) 
      pmlon = tmplon(0:ns-2)
      pmstachar = tmpname(0:ns-2)
      pmdata = totalmonth(0:ns-2, 0:tnl*24-1)
      pmns = ns-2
      
      
      

END 
