  pro write_bpch, data, filename=filename, ngas=ngas, unit=unit, $
      category=category, tau0=tau0, tau1=tau1, append=append

;+	
; pro write_bpch, data, filename=filename, ngas=ngas, unit=unit, $
;     category=category, tau0=tau0, tau1=tau1, append=append
;	
; ngas = tracer number
; unit
; tau0
; tau1
;  If N_elements(filename) eq 0 then filename='out.bpch'
;  If N_elements(ngas    ) eq 0 then Return
;  If N_elements(unit    ) eq 0 then unit = 'unitless'
;  If N_elements(category) eq 0 then category = 'IJ-AVG-$'
;  If N_elements(tau0    ) eq 0 then Return
;  If N_elements(tau1    ) eq 0 then Return
;-
  
  If N_elements(filename) eq 0 then filename='out.bpch'
  If N_elements(ngas    ) eq 0 then Return
  If N_elements(unit    ) eq 0 then unit = 'unitless'
  If N_elements(category) eq 0 then category = 'IJ-AVG-$'
  If N_elements(tau0    ) eq 0 then Return
  If N_elements(tau1    ) eq 0 then Return
  
  Dim      = size(data, /dim)
  Category = strupcase(category)
 
  Case 1 of
    N_elements(Dim) lt 2 : begin
    		print, N_elements(Dim), 'Inproper dimension of data'
		return
		end
    N_elements(Dim) eq 2 : begin
            iipar = dim[0]
		jjpar = dim[1]
		llpar = 1L
		end
    N_elements(Dim) eq 3 : begin
            iipar = dim[0]
		jjpar = dim[1]
		llpar = dim[2]
		end
    N_elements(Dim) gt 3 : begin
     		print, N_elements(Dim), 'Inproper dimension of data'
		return
		end
  End
  
  Case jjpar of 
   46   : resol = 4
   91   : resol = 2
   181  : resol = 1
   180  : resol = 1
   else : return
  end
  
  Time = tau2yymmdd(tau0)
  Year = Time.year[0]
    
  Case 1 of
   ( Year le 1995 and Year ge 1985 ) : model = 'GEOS1'
   ( Year gt 1995 and Year le 1997 ) : model = 'GEOSS'
   ( Year ge 1998                  ) : begin
             If   llpar eq 30 then model = 'GEOS3_30L' $
		 else model = 'GEOS3'
		                           end
   else : return
  end
  if jjpar eq 180 then model = 'generic'
  

     modelinfo = ctm_type(model, res=resol) 
 
     open_file,filename,olun,/WRITE,title='Save as binary punch file',  $
     /F77_UNFORMATTED,SWAP_ENDIAN=little_endian(), append=append

     if ( not( Keyword_set( Append ) ) ) then begin
       fti = Str2Byte('CTM bin 02',40)
       toptitle = Str2Byte('CTM output saved by GAMAP '+StrDate(),80)
	 
       writeu,olun,fti
       writeu,olun,toptitle
     endif
	 
         mname       = Str2Byte(modelinfo.name,20)
         mres        = float(modelinfo.resolution)
         mhalfpolar  = long(modelinfo.halfpolar)
         mcenter180  = long(modelinfo.center180)
	          
;         datainfo = CREATE3DHSTRU()
         ngas  = ngas
         gunit = unit
	   
	   category = Str2Byte( category, 40 )
	   Tracer = long( ngas ) mod 100L
	   unit = Str2Byte(gunit,40)
	   tau1 = tau1
	   tau0 = tau0
	   reserved = bytarr(40)
	   dimensions =  long( [iipar,jjpar,llpar] ) 
	   first = long( [1,1,1] ) 
	   dim = [ dimensions, first ]
	   skip = 4L *  ( dim[0] * dim[1] * dim[2]  ) + 8L
	   
     writeu,olun,mname,mres,mhalfpolar,mcenter180
     writeu,olun,category,tracer,unit,tau0,tau1,reserved,dim,skip
   
     writeu, olun, float(data)
     close,  olun
     free_lun,olun
     
  End
