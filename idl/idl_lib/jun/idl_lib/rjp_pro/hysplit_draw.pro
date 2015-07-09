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

;=============================================================

 pro grim, lat=lat, lon=lon, TIME=TIME, color=color

  if n_elements(pos) eq 0 then pos = [0.1, 0.15, 0.9, 0.95]
  if n_elements(comment) eq 0 then comment = ' '
  if n_elements(color) eq 0 then color=1

  @define_plot_size

 ;---- observation----
  limit = [40., -130., 60., -95.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0], /noerase
  map_continents, /countries, /continent, color=1

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  gylabel=1
  gxlabel=1

  if (gylabel) then $
  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  if (gxlabel) then $
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  plots, lon[0], lat[0], color=color, psym=4, symsize=symsize*2, thick=dthick

  For D = 1, N_elements(Lon)-1 do begin
    plots, lon[D], Lat[D], color=color, psym=8, symsize=symsize
    DDD = TIME[D] mod 12  ; every 6 hr
    dg  = 0.5
    dx  = [lon[d]-dg,lon[d]+dg]
    dy  = [lat[d], lat[d]]
    IF DDD eq 0 then $
       plots, dx, dy, color=1, thick=thick
    
  End

  XYOuts, pos[2]-(pos[2]-pos[0])*0.05, pos[1]+(pos[3]-pos[1])*0.1, Comment, $
    color=1, /normal, $
    charsize=charsize,  charthick=charthick, alignment=1.



 end

;=============================================================


  if !D.name eq 'PS' then $
    open_device, file='trajectory.ps', /color, /ps, /landscape

 files = collect('./hysplit/*.txt')
 erase

 For D = 0, n_elements(files)-1 do begin
   TRA = retrieve( files[D] )
   LAT = TRA.LAT
   LON = TRA.LON
   TIME= TRA.TIME
   grim, lat=lat, lon=lon, TIME=TIME, color=D+1
 End

  if !D.name eq 'PS' then close_device

 End
