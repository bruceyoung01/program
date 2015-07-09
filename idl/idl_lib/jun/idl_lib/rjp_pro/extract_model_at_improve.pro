  Years    = Lindgen(6) + 1997L
;  Obs      = improve_datainfo( year=1997L )
;  ID       = where(obs.lon lt -100.)
;  sitename = obs.siteid[ID]

  For II = 0, N_elements(Years)-1L do begin

  Year     = Years[II]
 ;=========================================================================;

  RES      = 4
  YYMM     = Year*100L + Lindgen(12) + 1L
  MTYPE    = 'GEOS4_30L'
  CATEGORY = 'IJ-AVG-$'
 ;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  CYear = Strtrim(Year,2)

;  SITENAME = ['GLAC','LAVO','ROMO','YELL']

  Obs    = improve_datainfo( year=Year )
; seasonal emission
  filter = '~dvs/testrun/runs/run.v7-04-01_AER/'
  fname  = '/ctm.bpch.seasonal.'

;  Westerling et al
;  filter = '~dvs/testrun/runs/run.v7-04-01_WEST/'
;  fname  = '/ctm.bpch.westerling.'

  FILE   = filter + fname + Cyear

  READ_MODEL_at_site,     $
     FILE,                $
     CATEGORY,            $
     TRACER=TRACER,       $
     YYMM=YYMM,           $               
     MODELINFO=MODELINFO, $
     CALC=CALC,           $
     OBS=OBS,             $
     FIXZ=FIXZ,           $
     LEV=LEV

    For d = 0, n_elements(obs.siteid)-1 do begin
       SITE  = obs.siteid[d]
       mfile = 'MODEL_at_'+SITE+'_'+DXDY+'.txt'
       path = findfile(mfile, count=count)
       if count eq 0L then openw, il, mfile, /get else goto, jump

       printf, il, 11, format='(I2)'
       printf, il, 9, format='(I2)'
       printf, il, strtrim(obs.siteid[d],2), format='(A5)'
       printf, il, obs.lon[d],    format='(F8.3)'
       printf, il, obs.lat[d],    format='(F8.3)'
       printf, il, obs.elev[d],   format='(F8.3)'
       printf, il, 'YYMM',        format='(A4)'
       printf, il, 'BC_obs ',     format='(A6)'
       printf, il, 'OC_obs',      format='(A6)'
       printf, il, 'BC_sim ',     format='(A6)'
       printf, il, 'OC_sim',      format='(A6)'
       free_lun, il
       jump:
    Endfor

     TIME    = calc.time
     CFAC    = calc.AD * 1.E-3   ; ppbv to ug/m3
     EC_CONC = (calc.BCPI_CONC + calc.BCPO_CONC)*CFAC*12.
     OC_CONC = (calc.OCPI_CONC + calc.OCPO_CONC)*CFAC*12.

  For D = 0, N_elements(calc.siteid)-1L do begin
     SITE  = calc.siteid[D]
     mfile = 'MODEL_at_'+SITE+'_'+DXDY+'.txt'
     path  = findfile(mfile, count=count)
     if count eq 1L then openu, il, mfile, /get, /append else stop

     BCo   = Reform(Obs.EC[D,*])
     OCo   = Reform(Obs.OC[D,*])
     BCm   = Reform(EC_CONC[D,*])
     OCm   = Reform(OC_CONC[D,*])

     For N = 0L, N_elements(TIME)-1L do $
         printf, iL, TIME[N], BCo[N], OCo[N], BCm[N], OCm[N], $
                 format='(I6,4f9.3)'

     free_lun, il

  End


 End
  
 END
