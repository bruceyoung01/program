
pro dist_plot, obs, sim, bkg, nat, asi, chi, pos=pos

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext


  ; Data selecting 

  CASE SPEC OF
   'SO4' : begin
             bkg_fld = bbext_ammso4
             nat_fld = nbext_ammso4
           end
   'NO3' : begin
             bkg_fld = bbext_ammno3
             nat_fld = nbext_ammno3
           end
   'EC'  : begin
             bkg_fld = bbext_ec
             nat_fld = nbext_ec
           end
   'OMC' : begin
             bkg_fld = bbext_omc
             nat_fld = nbext_omc
           end
   'ALL4': begin
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           end
   'ALL' : begin
        ;     bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+0.5+1.8
        ;     nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+0.5+1.8
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+soil_bext+cm_bext
           end
  END

  print, mean(nat_fld, /nan)
  print, mean(nbext_ammso4,/nan)
  print, mean(nbext_ammno3,/nan)
  print, mean(nbext_omc, /nan)
  print, mean(soil_bext, /nan)
  print, mean(cm_bext,/nan)

  ; Convert extinction into visibility
  bkg_fld = 10. * Alog( (bkg_fld + 10.) / 10. )
  nat_fld = 10. * Alog( (nat_fld + 10.) / 10. )

  bkg_stat  = stat( bkg, bkg_fld )
  nat_stat  = stat( nat, nat_fld )

  Min_avg = 1.
  Max_avg = 13.

  Min_std = 1.
  Max_std = 7.


 if n_elements(pos) eq 0 then begin
  ;---------------Plotting----------------------;
 !P.multi=[0,2,2,0,0]

 Pos = cposition(2,2,xoffset=[0.05,0.15],yoffset=[0.1,0.1], $
       xgap=0.02,ygap=0.12,order=0)

 end

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 7
 Format = '(I3)'
 Unit   = '[dv]'
 csfac  = 1.2

 C_bkg_avg = bytscl( bkg_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_nat_avg = bytscl( nat_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_bkg_std = bytscl( bkg_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

 C_nat_std = bytscl( nat_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

  ;=========================
  ; Distribution of mean 
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

 
  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0]

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_avg, psym=8, symsize=symsize

  ;----simulation------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa, $
   /noerase, position=pos[*,1]
  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_avg, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ; colorbar
  dx = pos[2,1]-pos[2,1]*0.8
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.05,pos[2,1]*0.8,pos[1,0]-0.03]
  ColorBar, Max=max_avg,     Min=min_avg,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


  ;==========================
  ; Distribution of std
  ;==========================

  ;------observation----------
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,2], /noerase

  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac , charthick=charthick
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------simulation----------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa,$
    position=pos[*,3], /noerase

  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------colorbar---------------
  dx = pos[2,3]-pos[2,3]*0.8
  CBPosition = [pos[0,2]+dx,pos[1,2]-0.05,pos[2,3]*0.8,pos[1,2]-0.03]
 
  ColorBar, Max=max_std,     Min=min_std,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format, Charsize=csfac,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  x1 = 0.5*(pos[0,0]+pos[2,0])
  x2 = 0.5*(pos[0,1]+pos[2,1])
  y1 = pos[3,0]+0.01

  xyouts, 0.07, 0.95, spec, color=1, charsize=tcharsize, $
   charthick=charthick, /normal, alignment=0.5

  xyouts, x1, y1, 'Background', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y1, 'Natural', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  y2 = pos[3,2]+0.01
  xyouts, x1, y1+0.03, 'MEAN', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y2+0.03, 'STANDARD DEVIATION', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5

  idw = where(bkg_stat.lon le -95.)
  ide = where(bkg_stat.lon gt -95.) 

  ;1)
  x = pos[0,0]
  str = string(mean(bkg_stat.avg[idw]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,0]
  str = string(mean(bkg_stat.avg[ide]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick
 
  ;2)
  x = pos[0,1]
  str = string(mean(nat_stat.avg[idw]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,1]
  str = string(mean(nat_stat.avg[ide]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  ;3)
  x3 = pos[0,2]
  str = string(mean(bkg_stat.std[idw]),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x3 = pos[2,2]
  str = string(mean(bkg_stat.std[ide]),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick


  ;4)
  x4 = pos[0,3]
  str = string(mean(nat_stat.std[idw]),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x4 = pos[2,3]
  str = string(mean(nat_stat.std[ide]),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end

;============================================================================

  @ctl
  SPEC    = 'ALL'
  figfile = 'new_dv_bkgn.ps'

  mapid = indgen(135)

  !P.multi=[0,2,2,0,0]
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.15,0.15], $
        xgap=0.01,ygap=0.15,order=0)
  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape


  @define_plot_size

  erase


;  comment = 'Western site (<95W),!C!C #1, Mean<9, STD<3.5'
;  comment = 'Estern site(>95W), !C!C #2, Mean>18, STD<5'
;  comment = 'Western site (<95W)'
  comment=''

  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,2:3]

  dist_plot, newobs(mapid), newsim(mapid), newbkg1(mapid), newnat1(mapid), newasi(mapid), $
             newchi(mapid), pos=newpos

  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))

  xyouts, 0.66, 0.4, comment, color=1, alignment=0., /normal, $
    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
