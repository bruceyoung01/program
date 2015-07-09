
  function readts24h_tag, filename  = filename,  $
                          taurange  = taurange,  $
                          Tracer    = Tracer,  $
                          unit      = unit,  $
                          Pfilename = Pfilename


;  DIR   = '/scratch/rjp/run_carb_2x2_1998_tag/out_std/'
;  FILEname = DIR+'ts24h.bpch_9801-9803'
;  Pfilename = DIR+'ctm.bpch_9801-9803'
;  Tracer = Indgen(9)+91
;  Tbeg= 19980101L
;  Tend= 19980401L
;  Taurange = [nymd2tau(Tbeg,0L),nymd2tau(Tend,0L)]


   If N_elements(Unit) eq 0 then Unit = 'ug/m3'
   If N_elements(Pfilename) eq 0 then Pfilename = Filename

   Case Unit of 
      'pptv' : begin
               fac = 1.e12
               AD  = 1.
               end
      'ug/m3': begin
               fac = 12.e06/6.022e23
               end
       else  : begin
               print, 'No this case', Unit
               end
   Endcase


   ; Retrive Air density information from the standard GEOS-CHEM output
   IF Unit eq 'ug/m3' then begin

     CTM_Get_Data, PDataInfo, 'BXHGHT-$', Filename=PFilename, Tracer=2004, $
     Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
     _EXTRA=e 
  
     ThisDataInfo = PDataInfo[0]
     BigData = *( ThisDataInfo.Data )
     f_ind = where(Use_FileInfo.ilun eq ThisDataInfo.ilun)
     ThisFileInfo = Use_FileInfo[f_ind[0]]
     ModelInfo = ThisFileInfo.ModelInfo
     GridInfo = CTM_Grid( ModelInfo, PSURF=PSurf )

     AAAA = CTM_Extract( BigData, XMid, YMid, ZMid,                     $
                         ModelInfo=ModelInfo, GridInfo=GridInfo,        $
                         First=ThisDataInfo.First )
   Endif

;  Retrieve pressure 

     CTM_Get_Data, PresInfo, 'PS-PTOP', Filename=PFilename, Tracer=1, $
     Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
     _EXTRA=e 


; This routine is intended to read OC/BC tagged run results
    
   CTM_Get_Data, DataInfo, 'IJ-AVG-$', Filename=Filename, Taurange=taurange, $
   Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
   _EXTRA=e

     ThisDataInfo = DataInfo[0]
     BigData = *( ThisDataInfo.Data )
     f_ind = where(Use_FileInfo.ilun eq ThisDataInfo.ilun)
     ThisFileInfo = Use_FileInfo[f_ind[0]]
     ModelInfo = ThisFileInfo.ModelInfo
     GridInfo = CTM_Grid( ModelInfo, PSURF=PSurf )

     AAAA = CTM_Extract( BigData, XXMid, YYMid, ZZMid,                  $
                         ModelInfo=ModelInfo, GridInfo=GridInfo,        $
                         First=ThisDataInfo.First )

; Synchronize the grid between Airden and Concentration
; Extract the location
      ix = 0
      iy = 0
      iz = 0
     For ij = 0, N_elements(XXMid)-1 do begin
         D  = where(XXMid[ij] eq Xmid)
         If D[0] ne -1 then ix = [ix,D[0]]
     Endfor
     For ij = 0, N_elements(YYMid)-1 do begin
         D  = where(YYMid[ij] eq Ymid)
         if D[0] ne -1 then iy = [iy,D[0]]
     Endfor
     For ij = 0, N_elements(ZZMid)-1 do begin
         D  = where(ZZMid[ij] eq Zmid)
         if D[0] ne -1 then iz = [iz,D[0]]
     Endfor
      ix = ix[1:*]
      iy = iy[1:*]
      iz = iz[1:*]
      nx = N_elements(ix)
      ny = N_elements(iy)
      nz = N_elements(iz)

      If total(XXMid-Xmid[ix]) ne 0. then stop
      If total(YYMid-Ymid[iy]) ne 0. then stop
      If total(ZZMid-Zmid[iz]) ne 0. then stop
    
     PYYMM = fltarr(N_elements(PDataInfo))
     AD    = fltarr(nx,ny,nz,N_elements(PDataInfo))
     PRES  = fltarr(nx,ny,N_elements(Presinfo))

     If N_elements(PDataInfo) ne N_elements(Presinfo) then stop

     For nc = 0, N_elements(PDataInfo)-1 do begin
         A      = tau2yymmdd(PDataInfo[nc].Tau0,/Nformat)
         PYYMM[nc] = A[0]/100L
         AIRDEN = *(PDataInfo[nc].Data)
         AD[*,*,*,nc] = AIRDEN(ix[0]:max(ix),iy[0]:max(iy),iz[0]:max(iz))
         PS_PTOP      = *(Presinfo[nc].Data)
         Pres[*,*,nc] = PS_PTOP(ix[0]:max(ix),iy[0]:max(iy))
     Endfor

     time = where(datainfo.tracer eq Tracer[0])
     Ntim = N_elements(time)
     time = tau2yymmdd(Datainfo[time].Tau0,/Nformat)
     time = time[0:Ntim-1]
     YYMM = time/100L

     CONC = Fltarr(nx,ny,nz,N_elements(Tracer),Ntim)

     For nc = 0, N_elements(Tracer)-1 do begin
         D  = where(Datainfo.Tracer eq Tracer[nc])
         If Ntim ne N_elements(D) then stop

         For nd = 0, N_elements(D)-1 do begin
             N = where(YYMM[nd] eq PYYMM)
             Data = *( DataInfo[D[nd]].data )
             Conc[*,*,*,nc,nd] = Data(*,*,*) * AD[*,*,*,N] * Fac  ; ug/m3 or pptv
             Undefine, data
         Endfor
     Endfor

     Undefine, DataInfo
     Undefine, PDataInfo
     ctm_cleanup, /data_only

;   EC = Reform( Conc[*,0]+Conc[*,1]+conc[*,5]+conc[*,6] )
;   OC = Reform( Conc[*,2]+conc[*,3]+conc[*,4]+conc[*,7]+conc[*,8] )

  Data = {time:time, tracer:tracer, conc:conc, Pres:pres, $
          xmid:xxmid, ymid:yymid, zmid:zzmid}

  Undefine, conc
  return, Data

End


