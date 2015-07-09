  pro diag_hno3, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_hno3, File=files, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
   MW_N    = 14E-3
;===============================================================================
;  Nitric acid
;===============================================================================
  ;1) Dry deposition information
    Tracers = 7107L

    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'DRYD-FLX', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      If ND eq 0 then begin
         GetModelAndGridInfo, DInfo[0], ModelInfo, GridInfo
         Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
         Area_cm2 = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
         Nday     = 0.
         For N    = 0, N_elements(Dinfo)-1 do $
             Nday = Nday + float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
         Time     = tau2yymmdd(Dinfo.tau0)
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * MW_N ; kg N/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      If ND eq 0 then Results = create_struct(Dinfo[0].tracername, Data) $
      else Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      HNO3DRYDEP = total(Results.HNO3df) * 1.e-9  ; Tg N/yr

    ;3) WET deposition information
    ;           HNO3
    Tracers = 3307L
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [63.E-3]

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      WFAC = Nday*86400.*MW_N/Mw[ND0]

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)

      Data = Data * Wfac / float(N_elements(Dinfo))
      Name = Dinfo[0].tracername+exchar(Diag[ND1],'-','_')
      Results = create_struct(Results, Name, Data)
      Undefine, Data
    End
    End

      HNO3WETDEP = total(Results.HNO3WETDLS_$ + Results.HNO3WETDCV_$) * 1.e-9 ; Tg N/yr

      TOTLOSS = HNO3DRYDEP + HNO3WETDEP

 ; Retrieve air density

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2004, tau0=tau0
        If N_elements(Datainfo) eq 0 then goto, Jump1

        If N eq 0 then AirdInfo = Datainfo else AirDinfo = [AirDinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

Jump1:

      IF N_elements(AirdInfo) eq 0 then begin

         Year      = strtrim(time.year[0],2)
         CASE Gridinfo.IMX of
              72 : DXDY = '4x5'
             144 : DXDY = '2x25'
             Else: return
         End
         file_aird = '/users/ctm/rjp/Asim/data/aird_'+DXDY+'_'+Year+'.bpch'
         file_aird = findfile(file_aird)
      
         If file_aird[0] ne '' then begin
            CTM_Get_Data, AirdInfo, 'BXHGHT-$', File=file_aird[0], tracer=2004, tau0=tau0
         end else begin
            Print, 'No Airdensity data'
            Return
         End

      Endif
         
      AD = FLTARR(Gridinfo.imx,Gridinfo.jmx,Gridinfo.lmx,N_elements(airdinfo))
      For D = 0, N_elements(Airdinfo)-1 do $
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume * 1.D-9 ; mole

    ; Burden information

    Tracers = 7L
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-AVG-$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + (*(Dinfo[D].data) * AD[*,*,*,D]) ; mole
      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      HNO3BURD = total(Results.HNO3[*,*,0:19]) * MW_N * 1.e-9

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Deposition, Tg N     ', TOTLOSS
 print, ' HNO3 Dry deposition :     ', HNO3DRYDEP, HNO3DRYDEP/TOTLOSS*100.
 print, ' HNO3 Wet deposition :     ', HNO3WETDEP, HNO3WETDEP/TOTLOSS*100.
 print, ' '
 print, 'Burden, Tg N               '
 print, ' Nitric Acid             : ', HNO3BURD
 print, ' '
 print, 'Life time, days
 print, ' Nitric Acid             : ', HNO3BURD/(HNO3DRYDEP+HNO3WETDEP)*Nday
 print, ' '
 print, 'Loss frequency, /day       '
 print, ' HNO3 dry deposition :     ', HNO3DRYDEP/HNO3BURD/Nday
 print, ' HNO3 wet scavenging :     ', HNO3WETDEP/HNO3BURD/Nday
 print, '-----------------------------------------------------'

 If Keyword_set(Saveout) then begin

  Openw, Ilun, 'Diag_sulf.txt', /Get

  If N_elements(region) ne 0 then $
 printf, ilun, 'Regional Budget for '+Region
 printf, ilun,'---------------------------------------------------------------'
 printf, ilun,'	  Budget Component	   GEOS-CHEM    for ' + Period
 printf, ilun,'---------------------------------------------------------------'
 printf, ilun,'Total Deposition, Tg N     ', TOTLOSS
 printf, ilun,' Nitrate Dry deposition : ', NITDRYDEP, NITDRYDEP/TOTLOSS*100.
 printf, ilun,' Nitrate Wet deposition : ', NITWETDEP, NITWETDEP/TOTLOSS*100.
 printf, ilun,' '
 printf, ilun,'Burden, Tg N               '
 printf, ilun,' Nitrate                : ', NITBURD
 printf, ilun,' '
 printf, ilun,'Life time, days
 printf, ilun,' Nitrate                : ', NITBURD/(NITDRYDEP+NITWETDEP)*Nday
 printf, ilun,' '
 printf, ilun,'Loss frequency, /day       '
 printf, ilun,' Nitrate dry deposition : ', NITDRYDEP/NITBURD/Nday
 printf, ilun,' Nitrate wet scavenging : ', NITWETDEP/NITBURD/Nday
 printf, ilun,'-----------------------------------------------------'

 free_lun, ilun

 Endif

 Heap_gc
end


