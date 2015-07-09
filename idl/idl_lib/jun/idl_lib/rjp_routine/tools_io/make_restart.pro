; Program to make a "fake" restart file for 24 full chemistry tracers
pro make_restart

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Get_DataBlock, Nymd2Tau

   ; List of tracers for full chemistry
   Nspec = 2
   TRCOFFSET = 58 ; Hg
   TracerList = IndGen(Nspec) + 1 + TRCOFFSET

   ; Time indices for restart file -- Jan 1, 2001
   ;Tau0 = Nymd2Tau(20010201L)
   ;Tau1 = Nymd2Tau(20010201L)
   Tau0 = Nymd2Tau(19980101L)
   Tau1 = Nymd2Tau(19980101L)

   ; First time flag
   First = 1L

   ; MODELINFO and GRIDINFO structures for 2 x 2.5 GEOS-3 grid
    ModelInfo  = CTM_Type( 'GEOS3_30L', Resolution=4 )
   ;ModelInfo  = CTM_Type( 'GEOS_STRAT', Res=4 )
   GridInfo   = CTM_Grid( ModelInfo )

   ; Define data array
   NewData    = FltArr( GridInfo.IMX, GridInfo.JMX, GridInfo.LMX )

   ; Set data everywhere to 1e-9 v/v (1 ppbv) for the sake of argument;
   ; you can decide how to initialize the data for your own purposes
   NewData[*] = 1e-20

   ; Loop over tracers
   for N = 0L, N_Elements( TracerList ) - 1L do begin

      ; Call CTM_MAKE_DATAINFO to make a DATAINFO structure
      ; for this tracer.  Return this structure in THISDATAINFO
      Success = CTM_Make_DataInfo( Float( NewData ),         $
                                   ThisDataInfo,             $
                                   ModelInfo=ModelInfo,      $
                                   GridInfo=GridInfo,        $
                                   DiagN='IJ-AVG-$',         $
                                   Tracer=TracerList[N],     $
                                   Tau0=Tau0,                $
                                   Tau1=Tau1,                $
                                   Unit='ppbv',               $
                                   Dim=[GridInfo.IMX,        $
                                        GridInfo.JMX,        $ 
                                        GridInfo.LMX, 0],    $
                                   First=[1L, 1L, 1L] )

      ; Stop upon error
      if ( not Success ) then begin
         S = 'Could not make data block for tracer '+String( N )
         Message, S
      endif

      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( First )                                          $             
         then NewDataInfo = [ ThisDataInfo              ]   $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      First = 0L

      ; Undefine THISDATAINFO for safety's sake
      UnDefine, ThisDataInfo

   endfor                       

   ; Write binary punch file for Jan 1, 2001
   ; CTM_WRITEBPCH needs an array of DATAINFO structures 
   CTM_WriteBpch, NewDataInfo, FileName='gctm.trc.19980101'

end
