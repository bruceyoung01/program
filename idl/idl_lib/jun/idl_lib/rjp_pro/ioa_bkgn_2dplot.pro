
 pro choose, calc=calc, spec=spec, gdat=gdat

  if n_elements(spec) eq 0 then spec = 'SO4'

  case spec of
    'SO4' : begin
            conc = calc.so4_conc*96.
            range=[0.,12.]
            if N_elements(calc.so4_conc_globe) ne 0 then $
               gdat = calc.so4_conc_globe*96.
            end
    'NH4' : begin
            conc = calc.nh4_conc*18.
            range=[0.,5.]
            if N_elements(calc.nh4_conc_globe) ne 0 then $
               gdat = calc.nh4_conc_globe*18.
            end
    'NO3' : begin
            conc = calc.nit_conc*62.
            range=[0.,10.]
            if N_elements(calc.nit_conc_globe) ne 0 then $
               gdat = calc.nit_conc_globe*62.
            end
    'EC'  : begin
            conc = (calc.ecpi_conc+calc.ecpo_conc)*12.
            range= [0.,1.0]
            if N_elements(calc.ecpi_conc_globe) ne 0 then $
               gdat = (calc.ecpi_conc_globe+calc.ecpo_conc_globe)*12.
            end
    'OMC' : begin
            conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 $
                 + (calc.soa1_conc)*150.                   $
                 + (calc.soa2_conc)*160.                   $
                 + (calc.soa3_conc)*220.
            range=[0.,6.]
            if N_elements(calc.ocpi_conc_globe) ne 0 then $
               gdat = (calc.ocpi_conc_globe+calc.ocpo_conc_globe)*12.*1.4 $
                    + (calc.soa1_conc_globe)*150.                   $
                    + (calc.soa2_conc_globe)*160.                   $
                    + (calc.soa3_conc_globe)*220.
            end
    'THNO3': begin
            conc = calc.hno3_conc*63. + calc.nit_conc*62.
            range=[0.,10.]
            Unit = ' [!4l!3g/m!u3!n]'
            if N_elements(calc.nit_conc_globe) ne 0 then $
               gdat = calc.hno3_conc_globe*63. + calc.nit_conc_globe*62.

            end

    'DUST': begin
            conc = (calc.dst1_conc + calc.dst2_conc*0.38)*29.
            range= [0.,5.0]
            Unit = ' [!4l!3g/m!u3!n]'
            if N_elements(calc.dst1_conc_globe) ne 0 then $
               gdat = (calc.dst1_conc_globe + calc.dst1_conc_globe*0.38)*29.

            end
  endcase


 end

;============================================================================

 pro makeplot, spec, nat_calc, bkg_calc, modelinfo, $
     NoGXLabels=NoGXLabels, NoGYLabels=NoGYLabels, unit=unit, margin=margin

 COMMON SHARE, MINDATA, MAXDATA
  @define_plot_size

  choose, calc=nat_calc, spec=spec, gdat=gdat_nat
  choose, calc=bkg_calc, spec=spec, gdat=gdat_bkg  

   grid = ctm_grid(modelinfo)
   time = nat_calc.time
   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   OFFSET = nat_calc.OFFSET

   nat_glb = fltarr(grid.imx, grid.jmx)
   bkg_glb = nat_glb

   DIM = size(gdat_nat)

   X1 = OFFSET[0]
   X2 = X1+DIM[1]-1L
   Y1 = OFFSET[1]
   Y2 = Y1+DIM[2]-1L
   nat_glb[X1:X2,Y1:Y2] = total(gdat_nat,3)/float(Nmon)
   bkg_glb[X1:X2,Y1:Y2] = total(gdat_bkg,3)/float(Nmon)

   print, spec
   check, bkg_glb

  case spec of
    'SO4' : begin
            Name  = 'SO!d4!u2-!n'
            Maxd  = 3.
            annot0 = ['0','0.07','0.13','0.2']
            annot1 = ['0','0.67','1.33','2']
            end
    'NH4' : begin
            Name  = 'NH!d4!u+!n'
            Maxd  = 3.0
            annot0 = ['0','0.03','0.07','0.1']
            annot1 = ['0','0.33','0.67','1']
            end
    'NO3' : begin
            Name  = 'NO!d3!u-!n'
            Maxd  = 3.0
            annot0 = ['0','0.03','0.07','0.1']
            annot1 = ['0','0.33','0.67','1']
            end
    'EC'  : begin
            Name  = 'EC'
            Maxd  = 1.
            end           
    'OMC'  : begin
            Name  = 'OMC'
            Maxd  = 6
            end  
    'DUST': BEGIN
            Name  = 'SOIL DUST'
            Maxd  = 6
            end  
     else : begin
            Print, 'There is no such case'
            stop
            end
  endcase


   Limit   = [ 20., -130., 55., -60.]

   Ndiv = 4
   csfac=charsize
   CBformat = '(F4.2)'
   C_size  = 1.5
   C_thick = 4
   !P.charthick=4
   Log = 1L

   undefine, annot1
   undefine, annot0
  ; Color bar

   C = MYCT_Defaults()
   Bottom  = C.BOTTOM
   NColors = 256L-Bottom
   CBColor = C.BLACK

   multipanel, position=p

   dp = p[2]-p[0]
   CBPosition = [P[0]+0.1*dp,P[1]-0.05,P[2]-0.1*dp,P[1]-0.03]

  ; Model (natural)
   plot_region, nat_glb, /sample, divis=Ndiv, unit=unit, $
     maxdata=Maxdata, mindata=MinData, csfac=csfac, $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.], $
     NoGXLabels=NoGXLabels[0], NoGYLabels=NoGYLabels[0], limit=limit, $
     Log=Log

;  ColorBar, Max=Maxdata,   Min=MinData, NColors=NColors,       $
;            Bottom=Bottom, Color=CBColor, Position=CBPosition, $
;            Unit=Unit,      Divisions=NDiv, Log=Log,           $
;            Format=CBFormat,  Charsize=charsize,               $
;            C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
;            annotation=annot0

   xyouts, 0.5*(p[0]+p[2]), p[3]+0.02, Name, alignment=0.5, color=1, $
     charsize=charSize, charthick=charthick, /normal


   multipanel, position=p
   ; Model (background)
   plot_region, bkg_glb, /sample, divis=Ndiv, unit=unit, $
     maxdata=maxdATA, mindata=MinData, csfac=csfac, $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.], $
     NoGXLabels=NoGXLabels[1], NoGYLabels=NoGYLabels[1], limit=limit, $
     Log=Log


  dp = p[2]-p[0]
  CBPosition = [P[0]+0.1*dp,P[1]-0.05,P[2]-0.1*dp,P[1]-0.03]

;  ColorBar, Max=maxd,      Min=MinData, NColors=NColors,     $
;            Bottom=Bottom, Color=CBColor, Position=CBPosition, $
;            Unit=Unit,      Divisions=NDiv, Log=Log,             $
;            Format=CBFormat,  Charsize=charsize,       $
;            C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
;            annotation=annot1

 End

 COMMON SHARE, MINDATA, MAXDATA
 ;=========================================================================;
  @define_plot_size

  Tracer = [26,27,29,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

  Year   = 2001L
  RES    = 1
  TYPE   = 'D' ; 'A', 'S', 'T'
  YYMM   = Year*100L + Lindgen(12)+1L
  MTYPE  = 'GEOS3_30L'
  CATEGORY = 'IJ-24H-$'
 ;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  CYear = Strtrim(Year,2)

; Observations are in ug/m3
  If N_elements(IMPROVE_Obs) eq 0 then $
     improve_Obs  = improve_datainfo(year=Year)

  If N_elements(Castnet_Obs) eq 0 then $
     Castnet_Obs  = castnet_datainfo(year=Year)

  If N_elements(nat_calc) eq 0 then begin

     ; Calculation output is in umoles/m3

     file_calc = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/NATURAL_2001_01-12.1x1.bpch'

     read_model, file_calc,   CATEGORY,  Tracer=Tracer,  $
                 YYMM = YYMM, Modelinfo=Modelinfo,       $
                 calc= nat_calc,    obs = castnet_obs,   $
                 /all

     file_calc = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/NOUSNEW_2001_01-12.1x1.bpch'

     read_model, file_calc,   CATEGORY,  Tracer=Tracer,  $
                 YYMM = YYMM, Modelinfo=Modelinfo,       $
                 calc= bkg_calc,    obs = castnet_obs,   $
                 /all

  endif

  if (!D.Name eq 'PS') then $
      Open_device, file='fig07_ioa_bkgn_2dplot.ps', /ps, /color, /landscape

   MinData = 1.E-2
   MaxDATA = 5.

   omargin = [0.05,0.25,0.17,0.2]
   Margin  = [0.01,0.01,0.01,0.01]
  !p.multi[4] = 1  ; column major
   multipanel, row=2, col=3, omargin=omargin, Margin=margin

  ; only for this plot
  tvlct, r, g, b, /get

  rjp_ctable, r_t, g_t, b_t
  tvlct, r_t, g_t, b_t


  makeplot, 'SO4', nat_calc, bkg_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[0,0], margin=margin
  makeplot, 'NO3', nat_calc, bkg_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[1,1], margin=margin
  makeplot, 'NH4', nat_calc, bkg_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[1,1], unit='!C[!4l!3g m!u-3!n]', margin=margin

;;;;;;;;;;;;;;;;;;;;;
; labelling 
;;;;;;;;;;;;;;;;;;;

   Xloc = 0.832
   YLOC = [0.65, 0.38]
   TAG  = ['NATURAL','BACKGROUND']

   FOR D = 0, N_elements(YLOC)-1 DO $
     xyouts, Xloc, YLOC[D], TAG[D], color=1, /normal, $
     charsize=CharSize, charthick=Charthick



   C = MYCT_Defaults()
   Bottom  = C.BOTTOM
   NColors = 256L-Bottom
   CBColor = C.BLACK

   Ndiv = 6
   csfac=charsize
   CBformat = '(F4.2)'
   C_size  = 1.5
   C_thick = 4
   !P.charthick=4
   Log = 1L
   CBPosition = [0.2, 0.18, 0.7, 0.21]
   unit='!C[!4l!3g m!u-3!n]'

  ColorBar, Max=maxdATA,      Min=MinData, NColors=NColors,     $
            Bottom=Bottom, Color=CBColor, Position=CBPosition, $
            Unit=Unit,        Divisions=NDiv, Log=Log,             $
            Format=CBFormat,  Charsize=charsize,       $
            C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

  tvlct, r, g, b

  if (!D.NAME eq 'PS') then Close_device
 End
