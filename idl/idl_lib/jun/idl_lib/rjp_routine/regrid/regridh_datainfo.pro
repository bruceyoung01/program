
pro regridh_datainfo, InFileName=InFileName,     OutFileName=OutFileName,     $
                  OutModelName=OutModelName, OutResolution=OutResolution,     $
                  PER_UNIT_AREA=PER_UNIT_AREA

   First = 1

   Ctm_get_data, datainfo, file=infilename
   GETMODELANDGRIDINFO, DATAINFO[0], InType, InGrid

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   ; If OUTMODELNAME is not passed, then use the same value as for INTYPE
   if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

   OutType = CTM_Type( OutModelName, Resolution=outresolution )
   OutGrid = CTM_Grid( OutType )

   For D = 0, N_elements(datainfo)-1 do begin

      Indata  = *(Datainfo[D].data)

      If D eq 0 then Use_Saved_Weights = 0L else Use_Saved_Weights = 1L
      OutData = CTM_Regridh( InData, InGrid, OutGrid, $
                          Use_Saved_Weights=Use_Saved_Weights, /VERBOSE, $
                          PER_UNIT_AREA=PER_UNIT_AREA )

      DIM = Size(OutData, /dim)

      ; Make a DATAINFO structure for each month of OH data
      Success = CTM_Make_DataInfo( Float( OutData ),                  $
                                   ThisDataInfo,                      $
                                   ThisFileInfo,                      $
                                   ModelInfo = OutType,               $
                                   GridInfo  = OutGrid,               $
                                   DiagN     = Datainfo[D].CATEGORY,  $
                                   Tracer    = DATAINFO[D].Tracer,    $
                                   Tau0      = Datainfo[D].Tau0,      $
                                   Tau1      = Datainfo[D].Tau1,      $
                                   Unit      = Datainfo[D].unit,      $
                                   Dim       = [ OutGrid.IMX,         $
                                                 OutGrid.JMX,         $
                                                 datainfo[D].dim[2], 0L ],        $
                                   First     =  [1L,1L,1L],     $
                                   /No_Global )

      ; Store all data blocks in the NEWDATAINFO array of structures
      if ( First )                                             $
         then NewDataInfo = [ ThisDataInfo ]                   $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      First = 0

   End

   CTM_WRITEBPCH, NewDATAinfo, ThisFileInfo, filename=outfilename

 End
