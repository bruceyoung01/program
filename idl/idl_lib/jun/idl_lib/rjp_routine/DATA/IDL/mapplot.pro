
  function make_grid_val, data, lon, lat, modelinfo=modelinfo

   ; General model and grid information
  GRIDINFO  = CTM_Grid( MODELINFO )

  Grid_dat  = fltarr(Long(Gridinfo.imx) * Long(Gridinfo.jmx))
  divi      = replicate(0., Long(Gridinfo.imx) * Long(Gridinfo.jmx))

  ID        = mapid(Modelinfo, LON=LON, LAT=LAT)

  For D = 0, n_elements(ID)-1 do begin
      Grid_dat[id[D]] = Grid_dat[id[D]] + data[D]
      divi[id[D]]     = divi[id[D]] + 1.
  End

  divi[where(divi eq 0.)] = 1.
  Grid_dat = Grid_dat * (divi^(-1.))
  
  return, Reform(Grid_dat, Gridinfo.imx, Gridinfo.jmx)

  end

;==============================================================================


 pro mapplot, fld, str, pos=pos, mindata=mindata, maxdata=maxdata, $
     cbformat=cbformat, Unit=Unit, missing=missing, cfac=cfac,     $
     comment=comment, title=title,                                 $
     nogxlabel=nogxlabel, nogylabel=nogylabel, cbar=cbar,          $
     C_Levels=C_Levels,   ndiv=ndiv,                               $
     discrete=discrete, limit=limit, c_shift=c_shift,              $
     commsize=commsize, meanvalue=meanvalue,                       $
     contour=contour, modelinfo=modelinfo
;+
; pro mapplot, fld, str, pos=pos, mindata=mindata, maxdata=maxdata, $
;     cbformat=cbformat, Unit=Unit, missing=missing, cfac=cfac,     $
;     comment=comment, title=title,                                 $
;     nogxlabel=nogxlabel, nogylabel=nogylabel, cbar=cbar,          $
;     C_Levels=C_Levels,   ndiv=ndiv,                               $
;     discrete=discrete, limit=limit, c_shift=c_shift,              $
;     commsize=commsize, meanvalue=meanvalue
;-
  @define_plot_size
  if n_elements(fld) eq 0 then return
  if n_elements(str) eq 0 then return
  if n_elements(pos) eq 0 then pos = [0.1, 0.15, 0.9, 0.95]
  if n_elements(fld) ne n_elements(str) then $
     message, 'dimensions mismatched'
  if n_elements(mindata)  eq 0 then mindata = min(fld)
  if n_elements(maxdata)  eq 0 then maxdata = max(fld)
  if n_elements(cbformat) eq 0 then CBFormat = '(F5.1)'
  if n_elements(Unit)     eq 0 then Unit   = ' '
  if n_elements(missing)  eq 0 then missing = -999.
  if n_elements(cfac)     eq 0 then cfac    = 1.
  if n_elements(comment)  eq 0 then comment = ' '
  if n_elements(limit)    eq 0 then limit = [25., -130., 50., -60.]
  if n_elements(c_shift)  eq 0 then c_shift = 0
  if n_elements(c_levels) ne 0 then ndiv = n_elements(c_levels)
  if n_elements(commentsize) eq 0 then commentsize = charsize
  if n_elements(title)    eq 0 then title   = ' '
  if keyword_set(contour) then $
     if n_elements(modelinfo) eq 0 then modelinfo = CTM_Type( 'GEOS3', Res=2 )

;======================================================================
;  Plotting begins here
;======================================================================


  gxlabel = 1L-keyword_set(nogxlabel)
  gylabel = 1L-keyword_set(nogylabel)

  P    = where(fld eq missing or finite(fld) eq 0, complement=I)
  dat  = FLD[I]
  Lon  = str[I].Lon
  Lat  = str[I].lat

  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom
  if n_elements(ndiv) eq 0 then Ndiv  = 5

  csfac  = 1.2

  ;========================
;  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]


  C_colors = bytscl( dat, Min=Mindata, Max=Maxdata, $
      	         Top = Ncolor) + Bottom

  if keyword_set(discrete) then begin
     if N_elements(C_Levels) eq 0 then $
        C_Levels = Findgen(NDIV)*(maxdata-mindata)/float(Ndiv) + mindata
       CC_COLORS = Fix((INDGEN(NDIV)+0.5) * (NCOLOR)/NDIV + BOTTOM)

       C_COL    = locate(dat, c_levels, cof=cof)
       C_COLORS = Byte(C_COL + FIX(COF))

;  print, c_levels
;  print, '========'
;  print, DAT
;  print, c_colors

;     C_colors = bytscl( DAT, Min=Mindata, Max=Maxdata, Top = NDIV-1L)
     C_COLORS = Fix((C_COLORS+0.5) * (NCOLOR)/(NDIV)+BOTTOM)


;     cc_colors = c_colors[uniq(c_colors, sort(c_colors))]
;     print, cc_colors
;     p = where(c_colors eq 148)
;     check, DAT[p]
  end

 ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0], /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  if (gylabel) then $
  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  if (gxlabel) then $
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, lon, Lat, color=c_colors, psym=8, symsize=symsize*cfac

  if keyword_set(contour) then begin

    grid_val = make_grid_val( dat, lon, lat, modelinfo=modelinfo )
    GRIDINFO = CTM_Grid( MODELINFO )
    nval     = n_elements(c_levels)
    if nval gt 5 then begin
      ip       = indgen(nval/2L)*2L + 1L
      levels   = c_levels(IP)
      labels   = replicate(1., n_elements(levels))
    end else begin
      levels   = c_levels
      labels   = replicate(1., n_elements(levels))
    end

    contour, grid_val, gridinfo.xmid, gridinfo.ymid, /overplot, /follow, $
       color=1, thick=thick, levels=levels, c_colors=1, $
       c_labels= labels, c_charsize=charsize, c_charthick=charthick, $
       c_thick = thick*0.8, /closed
  end

  XYOuts, (pos[0]+pos[2])*0.5, pos[3]+0.01, title, $
    color=1, /normal, $
    charsize=charsize,  charthick=charthick, alignment=0.5
   

  XYOuts, pos[2]-(pos[2]-pos[0])*0.16, pos[1]+(pos[3]-pos[1])*0.20, Comment, $
    color=1, /normal, $
    charsize=commsize,  charthick=charthick, alignment=0.5


  if keyword_set(meanvalue) then begin

    idw = where(lon le -95.)
    ide = where(lon gt -95.) 

    format  = cbformat

    x = pos[0]
    y = pos[3]+0.01
    val = string(mean(dat[idw],/nan),format=format)
    xyouts, x, y, val, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = pos[2]
    y = pos[3]+0.01
    val = string(mean(dat[ide],/nan),format=format)
    xyouts, x, y, val, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  end

  if keyword_set(cbar) then begin
     ; colorbar
     dx = (pos[2,0]-pos[0,0])*0.1
     dy = 0.04
     CBPosition = [pos[0,0]+dx,pos[1,0]-dy*2,pos[2,0]-dx,pos[1,0]-dy]

     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,         $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition,    $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,                $
	         Format=CBFormat, Charsize=csfac,                         $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
               _EXTRA=e
  end

 end
