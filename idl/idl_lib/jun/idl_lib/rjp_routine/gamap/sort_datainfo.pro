function Sort_DataInfo, DataInfo

   if ( N_Elements( DataInfo ) eq 0 ) then Message, 'DataInfo not passed!'
   
   ; Error check
   if ( not Chkstru( DataInfo, ['TAU0', 'TRACER'] ) ) $
      then Message, 'Invalid DATAINFO structure!'

   ; Find unique TAU0 values
   Tau0 = DataInfo[*].Tau0
   Tau0 = Tau0[ Uniq( Tau0, Sort( Tau0 ) ) ]

   ; Loop over each TAU0 value
   for N = 0L, N_Elements( Tau0 )-1L do begin

      ; Get the TRACER numbers for each TAU0 value
      IndTau = Where( DataInfo[*].Tau0 eq Tau0[N] )

      ; Sort TRACER numbers
      IndTra = Sort( DataInfo[IndTau].Tracer ) 

      print, '### TAU0[N]       : ', Tau0[N]
      print, '### Tracer        : ', DataInfo[IndTau].Tracer
      print, '### IndTra        : ', IndTra
      print, '### Tracer[IndTra]: ', DataInfo[IndTra].Tracer

      ; Store into an array for return
      if ( N eq 0 )                             $
         then IndReturn = IndTra                $
         else IndReturn = [ IndReturn, IndTra ]

      ; Undefine stuff
      UnDefine, IndTau
      UnDefine, IndTra
      UnDefine, Tracer

   endfor
      
   ; Return to calling program
   return, IndReturn
end
