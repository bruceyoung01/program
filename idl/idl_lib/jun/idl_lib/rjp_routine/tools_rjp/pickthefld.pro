
function pickthefld, filename, category=category, tracername=tracername

 if n_elements(filename) eq 0 then filename = pickfile()

    ctm_get_data,datainfo,file=filename
  
   if n_elements(category) eq 0 then begin
      print, datainfo.category
	return, 0
   endif
   
   if n_elements(tracername) eq 0 then begin
      print, datainfo.tracername
	return, 0
   endif
  
  index = 0
  
  for i = 0, n_elements(datainfo.category)-1 do begin
  
    if ( category eq datainfo[i].category and $
         tracername eq datainfo[i].tracername ) then begin
	   
	   if index eq 0 then begin
	      dim = size(*datainfo[i].data)
	   	case dim(0) of 
	        1 : data_data = fltarr(dim(1))
		  2 : data_data = fltarr(dim(1),dim(2))
		  3 : data_data = fltarr(dim(1),dim(2),dim(3))
	       endcase
	   endif
	   
	   case dim(0) of 
	     1 : data_data = data_data + *datainfo[i].data
	     2 : data_data = data_data + *datainfo[i].data
	     3 : data_data = data_data + *datainfo[i].data
	   endcase
	   
	   index = index + 1
	   
    endif
    
  endfor
  
  return, data_data
  
  end
	   
