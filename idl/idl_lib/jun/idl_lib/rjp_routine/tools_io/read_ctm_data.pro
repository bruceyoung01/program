;----------------------------------------------------------------------------

pro read_ctm_data, file=file, spec=spec, category=category,  $
    weight=weight, tracer=tracer, $
    AvgDAta=Avgdata, Xmid=Xmid, Ymid=Ymid, Zmid=Zmid
                   

; file   : filename in string
; spec   : species name in string
; category 
; weight : Weighting Used for time averaging

   if n_elements(file) eq 0 then return
   if n_elements(category) eq 0 then category = 'IJ-AVG-$'
   if n_elements(weight) eq 0 then weight=1.
   if n_elements(tracer) eq 0 then return

   CTM_Get_Data, DataInfo, category, Filename=File, Tracer=tracer

   ; Loop over all elements of DATAINFO
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Extract data from the Dth element of DATAINFO
      Data = *( DataInfo[D].Data )
      
      ; Keep a sum of all data blocks in SUMDATA
      if ( D eq 0L )                $
         then SumData = Data / float(weight)       $
         else SumData = SumData + ( Data / float(weight) )

      ; Undefine DATA array to save memory
      UnDefine, Data
      
   endfor

   print, N_elements(datainfo)

   ; Compute average of the data
   AvgData = SumData

   ; Undefine SUMDATA to save memory
   UnDefine, SumData
   
   ; Get the MODELINFO and GRIDINFO structures for the first data 
   ; block (assuming they are all from the same model...)
   ; We need this to define the lats & lons for TVMAP
   GetInfo, DataInfo[0], ModelInfo, GridInfo

   ; Resize AVGDATA so that it does not include the poles
;   AvgData = AvgData[ *, 1:GridInfo.JMX-2, * ]

   ; LON and LAT index arrays (don't include halfpolar boxes)
   Xmid = GridInfo.XMid
   YMid = GridInfo.YMid
   Zmid = Gridinfo.Pmid

   return
end

