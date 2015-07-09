 pro siteplot, data, lat=lat, lon=lon, mind=mind, maxd=maxd, position=position, $
     colorbar=colorbar, nogylabel=nogylabel, nogxlabel=nogxlabel, $
     unit=unit, format=format, comment=comment

     if n_elements(format) eq 0 then Format = '(I3)'

  @define_plot_size

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 5

; Unit   = '[dv]'
 csfac  = 1.2

 colors = bytscl( data, Min=MinD, Max=MaxD, Top = Ncolor) + Bottom

  ;=========================
  ; Distribution of mean 
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

 
  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=position, /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

 if keyword_set(nogylabel) eq 0L then $
  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

 if keyword_set(nogxlabel) eq 0L then $
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  id = where(lat gt 25.)
  plots, lon[id], Lat[id], color=colors[id], psym=8, symsize=symsize

  if keyword_set(colorbar) then begin
    dx = (position[2]-position[0])*0.2
    CBPosition = [position[0]+dx,position[1]-0.06,position[2]-dx,position[1]-0.03]
    ColorBar, Max=maxD,     Min=minD,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e
  endif


  dy = (position[3]-position[1])*0.2
  xyouts, position[2]-dx*0.5, position[1]+dy*0.5, comment, color=1, $
          charsize=charsize, $
          charthick=charthick, /normal

 
 end

;------------------------------------------------------------------

 function annual_mean, Dinfo=Dinfo, spec=spec, time=time, sot=sot, $
    badsite=badsite

 if n_elements(badsite) eq 0 then badsite = ' '

 case spec of 
   'SO4' : if n_elements(sot) ne 0 then Data = Dinfo.so4[sot] $
           else Data = Dinfo.so4
   'OMC' : if n_elements(sot) ne 0 then Data = Dinfo.omc[sot] $
           else Data = Dinfo.omc
   'NO3' : Data = Dinfo.no3
   'NIT' : if n_elements(sot) ne 0 then Data = Dinfo.nit[sot] $
           else Data = Dinfo.nit
   'EC'  : if n_elements(sot) ne 0 then Data = Dinfo.ec[sot] $
           else Data = Dinfo.ec
   'SOIL' : Data = Dinfo.soil
   'DUST' : if n_elements(sot) ne 0 then Data = Dinfo.DST1[sot] + Dinfo.DST2[sot]*0.38 $
           else Data = Dinfo.DST1 + Dinfo.DST2*0.38
 end
            
 if n_elements(sot) ne 0 then jday = Dinfo[0].jday[sot] $
 else jday = Dinfo[0].jday

 Nsite= n_elements(Dinfo)
 mobs = fltarr(Nsite)
 ID   = ' '

 For D = 0, Nsite - 1L do begin
     p = where(Dinfo[D].siteid eq badsite)
     if p[0] ne -1 then begin
        mobs[D] = -999.
        goto, bad
     end
 For M = 0, N_elements(jday) - 1L do begin

     s = reform(Data[*, D])    ; sample data
     p = where(s gt 0.)        ; remove missing data

     if p[0] eq -1 then begin
        mobs[D] = -999.
        goto, bad
     end

     mobs[D] = mean(s[p]) ; taking mean

     jump:
 end
     ID = [ID, Dinfo[D].siteid]
   bad:
 end

 return, mobs

 end

;-------------------------------------------------------------------
  Pro map2d, Dname, $
                    Modelinfo=Modelinfo, data=data, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec, $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, position=position, margin=margin, $
                    NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels, unit=unit


   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=1)

   grid = ctm_grid(modelinfo)

   Color = [1,1,1]

   @define_plot_size

   fd2d = fltarr(grid.imx,grid.jmx)
   divi = replicate(0.,grid.imx,grid.jmx)

       for N = 0, N_elements(Data)-1 do begin

           X = Data[N]

           CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                      /non_interactive

           If Keyword_set(PositiveD) then begin
              If X gt 0. then begin
                 FD2D[I-1,J-1] = FD2D[I-1,J-1] + X
                 DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
              Endif
           End Else begin
                 FD2D[I-1,J-1] = FD2D[I-1,J-1] + X
                 DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
           End

       endfor

   for J = 0, grid.jmx-1 do begin
   for I = 0, grid.imx-1 do begin
       IF DIVI[I,J] gt 0. then $
          FD2D[I,J] = FD2D[I,J]/float(DIVI[I,J])
   endfor
   endfor
   
   plot_region, fd2d, /sample, /cbar, divis=4, unit=unit, maxdata=maxdata,    $
     mindata=mindata, min_valid=1.e-5, position=[0.,0.,1.,1.], margin=margin, $
     limit=[25.,-130.,50.,-60.], NoGYLabels=NoGYLabels, NoGXLabels=NoGXLabels,$
     csfac=3, cbposition=[0.2,0.1,0.8,0.15]

 End


 ;=========================================================================;
  @define_plot_size

  ospec = 'SO4'
  mspec = 'SO4'
  range = [0., 10.]
  Year   = 2001L
  CYear = Strtrim(Year,2)
  RES    = 1
; badsite = ['BRIG1','AGTI1','PORE1']
; badsite = 'DEVA1'
  Comment = '1x1 Nested NA run for 2001'
 ;=========================================================================;

 if n_elements(obs) eq 0 then begin
    obs    = get_improve_dayly()
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    nat    = get_model_day_improve(res=111)
    asi    = get_model_day_improve(res=1111)
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    newnat = syncro( nat, obs )
    newasi = syncro( asi, obs )
    newobs = group( obs , ID=ID )
 endif

  CASE RES of
  11 : DXDY = '1x1'
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

 MTYPE  = 'GEOS3_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)
 Lon  = obs.lon
 Lat  = obs.lat
 site = obs.siteid

;   omargin = [ 0.05, 0.05, 0.04, 0.05 ]
;   Margin  = [ 0.01, 0.1,  0.01, 0.08 ]
;   RMargin = [ 0.01, 0.05, 0.01, 0.01 ]
;
;   multipanel, row=2, col=2, omargin=omargin

 !P.multi=[0,2,2,0,0]

 Pos = cposition(2,2,xoffset=[0.05,0.05],yoffset=[0.05,0.1], $
       xgap=0.02,ygap=0.1,order=0)


 if (!D.NAME eq 'PS') then $
    Open_device, file='sulfate_conc.ps', /PS, /landscape, /color

 sot  = Long(obs[0].jday)-1L

 if n_elements(data) eq 0 then begin
   data = annual_mean(Dinfo=obs, spec=ospec, time=time, badsite=badsite)
   conc = annual_mean(Dinfo=sim, spec=mspec, badsite=badsite)
   sen1 = annual_mean(Dinfo=nat, spec=mspec, badsite=badsite)
   sen2 = annual_mean(Dinfo=asi, spec=mspec, badsite=badsite)
   sen3 = annual_mean(Dinfo=bkg, spec=mspec, badsite=badsite)
 end

  bdlon = -95.
  bdlat = 35.

  idnw = where(obs.lon le bdlon and obs.lat gt bdlat)
  idne = where(obs.lon gt bdlon and obs.lat gt bdlat)
  idsw = where(obs.lon le bdlon and obs.lat le bdlat)
  idse = where(obs.lon gt bdlon and obs.lat le bdlat)

; conc = month_mean(Dinfo=sim, spec=spec, sot=sot, time=mon)
; ratio= ratio(data, conc)

      Unit = ' [!4l!3g/m!u3!n]'

      maxdata=6.
      mindata=0.

      erase
      siteplot, data, lat=lat, lon=lon, mind=mindata, maxd=maxdata, $
         position=pos[*,0], /colorbar, unit=unit, comm='(a)'
      siteplot, conc, lat=lat, lon=lon, mind=mindata, maxd=maxdata, $
         position=pos[*,1], /colorbar, /nogylabel, unit=unit, comm='(b)'

      ; on 1x1 model grid 
;      map2d,    Modelinfo=Modelinfo, data=data, range=range, $
;                lat=lat, lon=lon, spec=spec, $
;                min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
;                /positived, margin=margin, unit=Unit
;
;      map2d,    Modelinfo=Modelinfo, data=conc, range=range, $
;                lat=lat, lon=lon, spec=spec, $
;                min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
;                /positived, margin=margin, /NoGYLabels, unit=Unit

      maxdata=0.2
      mindata=0.

      asia = sen2-sen1
      siteplot, asia, lat=lat, lon=lon, mind=mindata, maxd=maxdata, $
         position=pos[*,2], /colorbar, unit=unit, format='(F4.2)', comm='(c)'


;      map2d,    Modelinfo=Modelinfo, data=asia, range=range, $
;                lat=lat, lon=lon, spec=spec, $
;                min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
;                /positived, margin=margin, unit=Unit

      maxdata=40.
      mindata=0.
      ratio = asia/conc*100.

      siteplot, ratio, lat=lat, lon=lon, mind=mindata, maxd=maxdata, $
         position=pos[*,3], /colorbar, /nogylabel, unit='[%]', comm='(d)'

;      map2d,    Modelinfo=Modelinfo, data=ratio, range=range, $
;                lat=lat, lon=lon, spec=spec, $
;                min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
;                /positived, margin=margin, /NoGYLabels, unit='[%]'


;  xyouts, 0.95, 0.98, Comment, /normal, color=1, charsize=charsize, $
;          charthick=charthick, alignment=1.

  if (!D.NAME eq 'PS') then Close_device

end
