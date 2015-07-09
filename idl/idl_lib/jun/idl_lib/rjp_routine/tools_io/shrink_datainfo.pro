
 function shrink_datainfo, Datainfo, Lat=Lat, Lon=Lon, Lev=Lev, $
          ThisFileInfo=ThisFileInfo

 if n_elements(Lat)  eq 0 then return, -1 
 if n_elements(Lon)  eq 0 then return, -1 
 if n_elements(Lev)  eq 0 then return, -1 

   GetModelAndGridInfo, DataInfo[0], ModelInfo, GridInfo
   Start = 1L

   For D = 0, N_elements(Datainfo)-1 do begin
    
      ThisDatainfo = Datainfo[D]
      BigData = *( ThisDatainfo.Data )
      BigDim  = Size(BigData)
      ;=====================================================================
      ; Call CTM_EXTRACT to extract a region from the data block
      ; according to the latitude, longitude, level, altitude, and 
      ; pressure ranges that were passed from the calling program.
      ;=====================================================================
      Data = CTM_Extract( BigData, X, Y, Z,                              $
                          ModelInfo=ModelInfo, GridInfo=GridInfo,        $
                          Average=Average,     AltRange=AltRange,        $
                          Index=Index,         Lat=Lat,                  $
                          Lon=Lon,             Lev=Lev,                  $
                          PRange=PRange,       SN=SN,                    $
                          Total=FTotal,        WE=WE,                    $
                          UP=UP,               First=ThisDataInfo.First, $
                          Debug=Debug )

      Undefine, BigData

      If BigDim[0] eq 2 then begin
         Data = Reform(Data[*,*,0])
         DIM  = [Size(Data,/dim),1L]
      end else begin
         DIM   = Size(Data, /dim)
      end

      First = [min(WE), min(SN), min(UP)]+1L

      ; Make a Shrinked DATAINFO structure for each month of OH data
      Success = CTM_Make_DataInfo( Float( Data ),                      $
                                   SDataInfo,                          $
                                   ThisFileInfo,                       $
                                   ModelInfo = ModelInfo,              $
                                   GridInfo  = GridInfo,               $
                                   DiagN     = ThisDatainfo.Category,  $
                                   Tracer    = ThisDatainfo.Tracer,    $
                                   Tau0      = ThisDatainfo.Tau0,      $
                                   Tau1      = ThisDatainfo.Tau1,      $
                                   Unit      = ThisDatainfo.UNIT,      $
                                   Dim       = [ DIM, 0L ],            $       
                                   First     = First,                  $
                                   /No_Global )

      Undefine, Data

      ; Store all data blocks in the NEWDATAINFO array of structures
      if ( Start )                                          $
         then NewDataInfo = [ SDataInfo ]                   $
         else NewDataInfo = [ NewDataInfo, SDataInfo ]

      Start = 0

      Undefine, ThisDataInfo
      Undefine, SDataInfo

   Endfor

   return, NewDataInfo

 End
