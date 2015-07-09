 Pro scatter_month, Dname, $
                    Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec, $
                    bdlon=bdlon, color=color, $
                    Subgridoff=subgridoff


   If N_elements(Bdlon) eq 0 then bdLon  = [-180., 180.]
   If N_elements(Color) eq 0 then Color  = [1,4]

; Monthly mean scatter plots
   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   If Nmon gt 6 then $
      Nrow = 3L      $
   else Nrow = 2L

   Ncol = CEIL(float(Nmon)/Nrow)

   multipanel, row=Nrow, col=Ncol

   Month_str = ['Jan','Feb','Mar','Apr','May','Jun',$
                'Jul','Aug','Sep','Oct','Nov','Dec']

   sz = {sym:1.0,lthick:2}
   If (!D.name eq 'PS') then sz = {sym:0.8,lthick:4.}
   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A), /FILL
  
   FOR IM = 0, NMON-1 DO BEGIN
       iobs = Mon[IM]-1L
        XAX = 0.
        YAX = 0.    
     for D = 0, N_elements(bdLon)-2 do begin
        POT = where(lon ge bdLon[D] and lon lt bdLon[D+1])
        XDA = REFORM(DATA(IOBS,POT))  ; Observation
        YDA = REFORM(CONC(IM,POT))       ; Calculation

        ; Sort out missing data
        XX = 0.
        YY = 0.
        For np = 0, N_elements(XDA)-1 do begin
           if (XDA[np] gt 0.) then begin
               XX = [XX, XDA[np]]
               YY = [YY, YDA[np]]
           endif
        endfor
        XDA = XX[1:*]
        YDA = YY[1:*]

      If D eq 0 then $
       plot, XDA, YDA, $
       color=color[D], psym=8, $
       xrange=range, yrange=range,  $
       xtitle='Observation [!4l!3g/m!u3!n]',       $
       ytitle='Calculation [!4l!3g/m!u3!n]',       $
       title=Month_str(IOBS)+' mean '+SPEC, $
       symsize=sz.sym $
      ELSE $
       oplot, XDA, YDA, $
       color=color[D], psym=8, symsize=sz.sym
       IF IM EQ 0 THEN CHECK, LON[POT]

       XAX = [XAX, XDA]
       YAX = [YAX, YDA]

     endfor

       oplot, [0,range[1]], [0,range[1]], color=1
       oplot, [0,range[1]], [0,range[1]*0.5], color=1, line=1
       oplot, [0,range[1]*0.5], [0,range[1]], color=1, line=1

       Y = YAX[1:*]
       X = XAX[1:*]

       rma   = lsqfitgm(X, Y)
       slope = rma[0]
       const = rma[1]
       R2    = rma[2]^2
 
       R2 = strmid(strtrim(R2,2),0,4)
       al = strmid(strtrim(slope,2),0,4)
       ab = strmid(strtrim(const,2),0,4)

       charsize = 0.8

       wid = range[1]-range[0]
       Xyouts, wid*0.5, range[1]-wid*0.85, 'R!u2!n = '+R2, color=1, alignment=0.,$
        charthick=charthick,charsize=charsize
       Xyouts, wid*0.5, range[1]-wid*0.95, 'y = '+al+'x+'+ab, color=1, alignment=0.,$
       charthick=charthick,charsize=charsize

       XXX = Findgen(101)*range(1)/100.
       oplot, XXX, const+slope*XXX, color=1, line=0, thick=sz.lthick

   endfor


 End
