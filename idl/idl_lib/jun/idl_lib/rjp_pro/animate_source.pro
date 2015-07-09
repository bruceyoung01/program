 function retrieve, file

 Hd   = ' '
 Openr, Il, file, /get

 For D = 1, 7 do Readf, il, Hd

 NCOL = 13L
 Data = Fltarr(NCOL)
 Dat  = -1.

 While (Not eof(IL)) do begin
   Readf, Il, Data
   Dat  = [Dat, Data]
 End

 Dat = Dat[1:*]
 NDD = N_Elements(Dat) / NCOL
 Dat = Reform(Dat, NCOL, NDD)

 Free_lun, IL

 TIM = Reform(Dat[8,*])
 LAT = Reform(Dat[9,*])
 LON = Reform(Dat[10,*])
 ALT = Reform(DAT[12,*])

 Return, {LAT:LAT,LON:LON,ALT:ALT,TIME:TIM}

 End

;=====================================================

 files = collect('./hysplit/*.txt')

 For D = 0, n_elements(files)-1 do begin
   TRA = retrieve( files[D] )
   IF D eq 0 then STR = TRA else STR = [STR, TRA]
 End


  @define_plot_size

;    m_s_dir = '/as2/home/misc/clh/GEOS/rundir_7-02-04_ICARTT/OUT2_full/'

    file  = '/as2/home/misc/stu/INTEX/BIOBURN_daily/' $
          + 'bioburn_peat.dailyICARTT.geos4.2x25.2004' 

    modelinfo = ctm_type('geos4_30l',res=2)
    gridinfo = ctm_grid(ctm_type('geos4_30l',res=2))
    omc      = fltarr(gridinfo.imx, gridinfo.jmx)

    multipanel, row=1, col=1, omargin=[0.1,0.1,0.1,0.1]

;    limit = [24., -150., 68., -62.]
    limit = [35., -160., 70., -95.]

    mindata = 1
    maxdata = 1.E6

    tracer = [33,35,42,43,44]

    ctm_get_data, datainfo, file=file, tracer=135, $
        taurange=[nymd2tau(20040615L),nymd2tau(20040901L)] ; OC
    log=1

    For D = 0, N_elements(DAtainfo)-1 do begin

      conc = *(datainfo[D].data) ; kg/day
     
      date = tau2yymmdd(datainfo[D].tau0)
      yyyy = strtrim(string(date.year,form='(i4)'),2)
      mm   = strtrim(string(date.month,form='(i2)'),2)
      dd   = strtrim(string(date.day,form='(i2)'),2)

      if strlen(mm) eq 1 then mm = '0'+mm
      if strlen(dd) eq 1 then dd = '0'+dd

      title = strtrim(mm+'/'+dd+'/'+yyyy)
      title = 'OC biomass burning source '+title
      plot_region, conc, limit=limit, title=title, /cbar, $
         divis=5, mindata=mindata, maxdata=maxdata,  $
         /sample, min_valid=1, /rjpmap, log=log

;      For N = 0, N_elements(STR)-1 do begin
;
;         LON = STR[N].LON
;         LAT = STR[N].LAT
;         TIME= STR[N].TIME
;         COLOR = N + 1 + 5
;
;         plots, lon[0], lat[0], color=color, psym=4, symsize=symsize*2, thick=dthick
;
;         For M = 1, N_elements(Lon)-1 do begin
;         plots, lon[M], Lat[M], color=color, psym=8, symsize=symsize
;         DDD = TIME[M] mod 12  ; every 6 hr
;         dg  = 0.5
;         dx  = [lon[M]-dg,lon[M]+dg]
;         dy  = [lat[M], lat[M]]
;         IF DDD eq 0 then $
;            plots, dx, dy, color=1, thick=thick
;
;         End
;      End

     C      = Myct_defaults()
     Bottom = C.Bottom
     Ncolor = 255L-Bottom
     Ndiv   = 5
     cbformat='(E7.1)'
     unit='kg/day'
     ; colorbar
;     dx = (pos[2,0]-pos[0,0])*0.1
     dy = 0.04
     CBPosition = [0.2,0.15,0.8,0.19]
     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,      $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	         Format=CBFormat, Charsize=csfac,                      $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
               _EXTRA=e


      filename = 'oc_ems.'+yyyy+mm+dd
      screen2gif, filename

;      ThisFrame = TvRead( FileName=FileName, /BMP )

    halt
 
    Endfor

      ctm_cleanup

 End
