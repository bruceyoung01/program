
  filename = '/scratch/rjp/run_4.18_4x5_rjp/ctm.bpch_err'
  ctm_get_data,datainfo,file=filename
  
  category = 'SO2-AC-$'
  tracer   = 'SO2' 
  ntime    = 12
  
  index = 0
  for i = 0, n_elements(datainfo.category)-1 do begin
  
   if ( category eq datainfo[i].category ) then begin   
        if index eq 0 then begin
	     dim = size(*datainfo[i].data)
	     case dim(0) of 
	      1 : data_data = fltarr(dim(1),ntime)
		2 : data_data = fltarr(dim(1),dim(2),ntime)
		3 : data_data = fltarr(dim(1),dim(2),dim(3),ntime)
	     endcase
	  endif
	  
	  fac = 1.
	  if (datainfo[i].unit eq 'kg/s') then fac = 365.25/12.*86400. ; Convert to sec to month
	     case dim(0) of 
	      1 : data_data(*,index) = *datainfo[i].data * fac
		2 : data_data(*,*,index) = *datainfo[i].data * fac
		3 : data_data(*,*,*,index) = *datainfo[i].data * fac
	     endcase     
	  index = index + 1
   endif
   
  endfor
        
  end
   
   
