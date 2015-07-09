  File = pickfile()
  Category = 'IJ-AVG-$'  ; Monthly or time averaged field.
  Tracer = 1             ; for NOx or several tracers are possible 
                         ; without tracer option, all avaiable fields are 
                         ; accessed and contained DataInfo structure
  CTM_Get_Data, DataInfo, Category, Filename=File, Tracer=Tracer

  Data = *(DataInfo[0].data) ; Access the data

  End


  
