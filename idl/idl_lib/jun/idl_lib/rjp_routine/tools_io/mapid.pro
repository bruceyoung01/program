 function mapid, Modelinfo, LON=LON, LAT=LAT

;+
; Function IDL mapid returns model grid location as a vector 
; for specific longitude and latitude
;-
   if N_elements(Modelinfo) eq 0 then return, -1
   if N_elements(LON) eq 0 then return, -1
   if N_elements(LAT) eq 0 then return, -1

   GridInfo = CTM_GRID( ModelInfo )

   XID = ROUND( (LON + 180.) / Gridinfo.DI )
   YID = ROUND( (LAT + 90. ) / Gridinfo.DJ )

   ID = XID + YID * GridInfo.IMX

   Return, ID
 end
  
