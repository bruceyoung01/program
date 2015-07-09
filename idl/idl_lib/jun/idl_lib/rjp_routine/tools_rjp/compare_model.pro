 pro compare_model, file1, file2, DIAG=DIAG, tracers=tracers, LEV=LEV
;
 if n_elements(file1) eq 0 then FILE1=PICKFILE()
 if n_elements(file2) eq 0 then FILE2=PICKFILE()
 
 if n_elements(DIAG) eq 0 then DIAG = 'IJ-24H-$'
 IF N_ELEMENTS(LEV)  EQ 0 THEN LEV  = 0L

   ; retrive data
   ctm_get_data, d1info, DIAG, tracer=tracers, file=file1
   ctm_get_data, d2info, DIAG, tracer=tracers, file=file2

   GETMODELANDGRIDINFO, D1INFO[0], MODEL1, GRID1
   GETMODELANDGRIDINFO, D2INFO[0], MODEL2, GRID2

   Dat1 = fltarr(GRID1.IMX, GRID1.JMX, GRID1.LMX)
   Dat2 = fltarr(GRID2.IMX, GRID2.JMX, GRID2.LMX)

  if (!D.NAME eq 'PS') then $
    Open_device, file='diff.ps', /PS, /portrait, /color

   multipanel, row=3, col=1, omargin=[0.1,0.,0.1,0.]

   For D = 0, N_elements(D1INFO)-1 do begin

       CATEGORY = D1INFO[D].CATEGORY
       TRACER   = D1INFO[D].TRACER
       TAU0     = D1INFO[D].TAU0
       TNAME    = D1INFO[D].TRACERNAME
       DATE     = TAU2YYMMDD(TAU0, /NFORMAT)
       TITLE    = TNAME+' :: '+STRTRIM(DATE[0],2)
       F1       = D1INFO[D].FIRST - 1L
       D1       = D1INFO[D].DIM - 1L
       F2       = F1 + D1[0:2]
      
       DAT1[F1[0]:F2[0], F1[1]:F2[1], F1[2]:F2[2] ] = *(d1info[D].data)

       IP = WHERE(D2INFO.CATEGORY EQ CATEGORY AND $
                  D2INFO.TRACER   EQ TRACER   AND $
                  D2INFO.TAU0     EQ TAU0)

       IF IP[0] EQ -1 THEN BEGIN
          PRINT, 'NO MATHING FOUND FOR ', CATEGORY, TRACER, TAU0
          RETURN
       ENDIF

       ; DATA FROM SECOND FILE
       F1       = D2INFO[D].FIRST - 1L
       D1       = D2INFO[D].DIM - 1L
       F2       = F1 + D1[0:2]

       DAT2[F1[0]:F2[0], F1[1]:F2[1], F1[2]:F2[2] ] = *(d2info[IP[0]].data)

       diff = dat1 - dat2

       plot_region, dat1[*,*,lev], /conti, /cbar, divis=5, /sample, $
            title=TITLE+'!C!C'+file1
       plot_region, dat2[*,*,lev], /conti, /cbar, divis=5, /sample, $
            title=TITLE+'!C!C'+file2
       plot_region, diff[*,*,lev], /conti, /cbar, divis=5, /sample, $
            title='DIFFERENCE'

   halt

   end

  if (!D.NAME eq 'PS') then Close_device

 End
