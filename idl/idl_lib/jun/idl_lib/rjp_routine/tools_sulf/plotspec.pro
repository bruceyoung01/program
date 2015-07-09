 function readdata, spec=spec, category=category

  if n_elements(spec) eq 0 then spec = 'SO2'
  if n_elements(category) eq 0 then category = 'IJ-AVG-$'
  
  spawn, 'ls ctm.bpch_*',filenames
  index = 0
  ntime = n_elements(filenames) 
  
  for nf = 0, ntime-1 do begin
    ctm_get_data,datainfo,file=filenames[nf]
   
    for i = 0, n_elements(datainfo.category)-1 do begin
  
     if ( category eq datainfo[i].category and  $
          spec eq datainfo[i].tracername) then begin   
          if index eq 0 then begin
	       dim = size(*datainfo[i].data)
	       case dim(0) of 
	        1 : data_data = fltarr(dim(1),ntime)
		  2 : data_data = fltarr(dim(1),dim(2),ntime)
              3 : data_data = fltarr(dim(1),dim(2),dim(3),ntime)
	       endcase
	    endif
	  
	    fac = 1.
	    ; Convert to sec to month
	    if (datainfo[i].unit eq 'kgS/s') then fac = 365.25/12.*86400. 
	    if (datainfo[i].unit eq 'ppbv') then fac = 1.e3
	  
	       case dim(0) of 
	        1 : data_data(*,index) = *datainfo[i].data * fac
              2 : data_data(*,*,index) = *datainfo[i].data * fac
              3 : data_data(*,*,*,index) = *datainfo[i].data * fac
	       endcase     
	    index = index + 1
     endif
   
    endfor
    
  endfor
  
  return, data_data
          
  end
  
 pro plotspec,emis=emis,spec=spec
  
  if (!D.name eq 'PS') then begin
    Open_Device, OLD_DEVICE, PS=1, /Portrait, /Color, Bits=8, $
      FileName='temp.ps', _EXTRA=e
  endif
  
  multipanel, rows=3,cols=1
  
  if Keyword_set(emis) then begin
    
  DMSEMIS = readdata(spec='DMS',category='DMS-BIOG')
  fd2d  = total(dmsemis,3)
  title = 'DMS, Total = '+strtrim(total(fd2d(*,*))*1.e-9,1)+' Tg S/yr'
  tvmap, fd2d*1.e-6,/sample,/conti,/cbar,divis=7,title=title,cbunit='Kton S/yr'
  
  SO2EMIS_AN = readdata(spec='SO2',category='SO2-AN-$')
  fd2d = total(total(so2emis_an,4),3)
  title = 'SO2 (Fuel), Total = '+ strtrim(total(fd2d(*,*))*1.e-9,1)+ $
  ' Tg S/yr'
  tvmap, fd2d*1.e-9,/sample,/conti,/cbar,divis=7,title=title,cbunit='Tg S/yr'
  
  SO2EMIS_BB = readdata(spec='SO2',category='SO2-BIOB')
  fd2d = total(so2emis_bb,3)
  title = 'SO2 (BB), Total = '+strtrim(total(fd2d(*,*))*1.e-9,1)+' Tg S/y
  tvmap, fd2d*1.e-6,/sample,/conti,/cbar,divis=7,title=title,cbunit='Kton S/yr'
  
  endif
  
  if Keyword_set(spec) then begin
  
  SO2 = readdata(spec='SO2',category='IJ-AVG-$')
  
  fd2d = (SO2(*,*,0,5)+SO2(*,*,0,6)+SO2(*,*,0,7))/3.
  title = 'SO!D2!N (JJA)'
  tvmap, fd2d,/sample,/conti,/cbar,divis=7,title=title,cbunit='pptv'
  
  SO4 = readdata(spec='SO4',category='IJ-AVG-$')
  fd2d = (SO4(*,*,0,5)+SO4(*,*,0,6)+SO4(*,*,0,7))/3.
  title = 'Sulfate (JJA)'
  tvmap, fd2d,/sample,/conti,/cbar,divis=7,title=title,cbunit='pptv'
    
  DMS = readdata(spec='DMS',category='IJ-AVG-$')
  fd2d = (DMS(*,*,0,5)+DMS(*,*,0,6)+DMS(*,*,0,7))/3.
  title = 'DMS (JJA)'
  tvmap, fd2d,/sample,/conti,/cbar,divis=7,title=title,cbunit='pptv'  
  end
  
  ;   jja = (data_data(*,*,*,5)+data_data(*,*,*,6)+data_data(*,*,*,7))/3.
  ;   tvmap, jja(*,*,0),/sample,/conti,/cbar,divis=7
  
  if (!D.name eq 'PS') then begin
   Close_Device, _EXTRA=e
   set_plot,'X'
  endif
     
  end
