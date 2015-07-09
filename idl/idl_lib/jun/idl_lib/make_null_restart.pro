pro make_null_restart

; make a restart file

   NTRACER   = 54L
   TRCOFFSET = 0L
   outfile = 'restart.geos5.2006020100'
   Tau0=nymd2tau(20060201L,0L)
   Tau1=nymd2tau(20060201L,0L)

   First = 1

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   ; 4 for 4X5
   OutType = CTM_Type( 'GEOS5_47L', Resolution=2 )
   OutGrid = CTM_Grid( OutType )

   Tracers = Lindgen( NTRACER ) + TRCOFFSET + 1L

   FOR D = 0, N_ELEMENTS(Tracers)-1 DO BEGIN

       Outdata  = replicate(1.0e-20,OutGrid.IMX,OutGrid.JMX,47)
       DIM      = SIZE(Outdata)
       Print, D
;       Check, Outdata


      ; Make a DATAINFO structure for each month of OH data
      Success = CTM_Make_DataInfo( Float( OutData ),                  $
                                   ThisDataInfo,                      $
                                   ThisFileInfo,                      $
                                   ModelInfo = OutType,               $
                                   GridInfo  = OutGrid,               $
                                   DiagN     = 'IJ-AVG-$',  $
                                   Tracer    = Tracers[D],            $
                                   Tau0      = Tau0,      $
                                   Tau1      = Tau1,      $
                                   Unit      =  'v/v',      $
                                   Dim       = [ OutGrid.IMX,         $
                                                 OutGrid.JMX,         $
                                                 Dim[3], 0L ],        $
                                   First     =  [1L,1L,1L],     $
                                   /No_Global )

      ; Store all data blocks in the NEWDATAINFO array of structures
      if ( First )                                             $
         then NewDataInfo = [ ThisDataInfo ]                   $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      First = 0

   Endfor

   CTM_WRITEBPCH, NewDATAinfo, ThisFileInfo, filename=outfile

 End







