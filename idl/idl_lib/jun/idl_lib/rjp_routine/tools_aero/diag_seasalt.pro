  pro diag_seasalt, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_sulf, File=file, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = 'SALTSRCE'      ; seasalt
    N_SALA = 40L

    Tracers = Lindgen(2) + 400L + N_SALA
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag, tau0=tau0, tracer=Tracers[ND]
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      Data = region_only(Data, region=region)
      Name = Dinfo[0].tracername+'SRCE'

      If ND eq 0 then  Results = create_struct(Name, Data) $
      else             Results = create_struct(Results, Name, Data)
 
      Undefine, Dinfo
      Undefine, Data
    Endfor

    SALTSRC_A = total(Results.SALASRCE) * 1.e-9
    SALTSRC_C = total(Results.SALCSRCE) * 1.e-9 ; Tg/yr

    ;2) Dry deposition information
    Tracers = Lindgen(2) + 7100L + N_SALA

    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'DRYD-FLX', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      If ND eq 0 then begin
         ; extract Modelinfo and Gridinfo
         GetModelAndGridInfo, DInfo[0], ModelInfo, GridInfo
         ; Grid = CTM_Grid( CTM_type('GEOS3_30L',res=4) )
         Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
         Area_cm2 = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
         Nday     = 0.
         For N    = 0, N_elements(Dinfo)-1 do $
             Nday = Nday + float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
         Time     = tau2yymmdd(Dinfo.tau0)
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * 32D-3 ; kg S/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      SALADRYDEP = total(Results.SALAdf) * 1.e-9  ; Tg S/yr
      SALCDRYDEP = total(Results.SALCdf) * 1.e-9  ; Tg S/yr


    ;3) WET deposition information
    ;           SALA SALC
    Tracers = Lindgen(2) + 200L + N_SALA
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [36., 36.]

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      WFAC = Nday*86400.

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)

      Data = Data * Wfac / float(N_elements(Dinfo))
      Name = Dinfo[0].tracername+exchar(Diag[ND1],'-','_')
      Results = create_struct(Results, Name, Data)
      Undefine, Data
    End
    End

      SALAWETDEP = total(Results.SALAWETDLS_$ + Results.SALAWETDCV_$) * 1.e-9 ; Tg/yr
      SALCWETDEP = total(Results.SALCWETDLS_$ + Results.SALCWETDCV_$) * 1.e-9 ; Tg S/yr


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
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume ; mole

    ; Burden information

    Tracers = Lindgen(2) + N_SALA
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-AVG-$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      unit = Dinfo[0].unit  
      case strmid(unit,0,3) of 
         'ppb' : fac = 1.E-9 
         'ppt' : fac = 1.E-12
         'v/v' : fac = 1.
         else  : fac = 1.
      end

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do $
          Data = Data + (*(Dinfo[D].data) * AD[*,*,*,D] * fac) ; mole
      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      SALABURD = total(Results.SALA[*,*,0:19]) * 36.e-12
      SALCBURD = total(Results.SALC[*,*,0:19]) * 36.e-12

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg S       ', SALTSRC_A + SALTSRC_C
 print, ' Acuumulate SEASALT      : ', SALTSRC_A                        
 print, ' Coarse SEASALT          : ', SALTSRC_C                       
 print, ' '
 print, 'Total Deposition, Tg S     '
 print, ' SALA Dry deposition      : ', SALADRYDEP
 print, ' SALA Wet deposition      : ', SALAWETDEP
 print, ' SALC Dry deposition      : ', SALCDRYDEP
 print, ' SALC Wet deposition      : ', SALCWETDEP
 print, ' '
 print, 'Burden, Tg S               '
 print, ' SALA                    : ', SALABURD
 print, ' SALC                    : ', SALCBURD
 print, ' '
 print, 'Life time, days
 print, ' SALA                    : ', SALABURD/(SALADRYDEP+SALAWETDEP)*Nday
 print, ' SALC                    : ', SALCBURD/(SALCDRYDEP+SALCWETDEP)*Nday
 print, '-----------------------------------------------------'


 Heap_gc
end


