
 function get_fire

  file = '/users/ctm/rjp/Data/MAP/mask/usa_canada_mask.generic.1x1'
;  if n_elements(mask) eq 0 then mask = get_mask(file)

  YEAR  = [2001L,2002L,2003L,2004L]
  CYEAR = strtrim(YEAR,2)

   ; General model and grid information
  MODELINFO = CTM_Type( 'generic', Res=1 )
  GRIDINFO  = CTM_Grid( MODELINFO )
  AREA_M2   = CTM_BOXSIZE( GRIDINFO, /M2)

  Data      = fltarr(360,180,48)

  For N = 0L, N_elements(YEAR)-1L Do begin
    gfed = get_gfed2( CYEAR[N], mask=mask )
    for m = 0, 11 do gfed[*,*,m] = gfed[*,*,m] * AREA_M2 * 1.e-3  ; kg/box
    N1 = N * 12L
    N2 = N1 + 11L
    Data[*,*,N1:N2] = GFED
  End

  OutType = CTM_Type( 'GEOS3_30L', Resolution=2 )
  OutGrid = CTM_Grid( OutType )

  print, total(data)

  Data = CTM_Regridh( Data, GRIDINFO, OutGrid,  $
                      Use_Saved_Weights=Use_Saved_Weights )

  print, total(data)

  str  = create_struct('fire', data, 'modelinfo', outtype)

  return, str
 end

;==============================================================================

 pro find_p_burning, fire, season=season

  COMMON SHARE, mdat, nsk_ibf

  if n_elements(season) eq 0 then season = [1,2,12]

  multipanel, col=2, row=2 
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.10,0.15], $
        xgap=0.02,ygap=0.12,order=0)


  jday = mdat[0].jday
  jmon = jday2month(jday)
  lon  = mdat.lon
  lat  = mdat.lat

  nmon = float(n_elements(season)*4.)

  thresh = 1.E-5

   ; General model and grid information
;  MODELINFO = CTM_Type( 'generic', Res=1 )
  GRIDINFO  = CTM_Grid( fire.MODELINFO )

  p_burn    = fltarr(N_elements(mdat))
  r_biof    = p_burn
  p_divi    = p_burn
  r_divi    = p_burn


  modis     = fire.fire * 1.e-6 ; Gg
  dm        = 0.
  ic        = 0.
  For N = 0, n_elements(jmon)-1L do begin
      p = where( season eq jmon[N] )
      if p[0] ne -1 then begin
          dm = dm + modis[*,*,N]
          ic = ic + 1.
      end
  End            

  print, 'month of data', ic
  dm = dm / ic

  For D = 0, n_elements(mdat)-1L do begin
      CTM_INDEX, fire.MODELINFO, I, J, center=[mdat[D].lat,mdat[D].lon], /non_interactive

      nsk  = mdat[d].knon             ; 48 months
      burn = reform(modis[i-1,j-1,*]) ; 48 month

      For N = 0, n_elements(nsk)-1L do begin

          val       = nsk[N] - nsk_ibf[D]
          if nsk[N] le 0. or val le 0. then goto, skip ; missing data
          p = where( season eq jmon[N] )
          if p[0] eq -1 then goto, skip

          ; if there is any drymass burn > thresh we consider it as prescribed burning
          if burn[N] gt thresh then begin
             p_burn[D] = p_burn[D] + val
             p_divi[d] = p_divi[D] + 1.
          end else begin
             r_biof[D] = r_biof[D] + val
             r_divi[D] = r_divi[D] + 1.
          end

          skip:           
      End
  End

  For D = 0, n_elements(mdat)-1L do begin
      if p_divi[D] ge 1. then p_burn[D] = p_burn[D] / nmon else p_burn[D] = 'NaN'
      if r_divi[D] ge 1. then r_biof[D] = r_biof[D] / nmon else r_biof[D] = 'NaN'
  End

;  For D = 0, n_elements(mdat)-1L do begin
;      if p_divi[D] ge 1. then p_burn[D] = p_burn[D] / p_divi[D] else p_burn[D] = 'NaN'
;      if r_divi[D] ge 1. then r_biof[D] = r_biof[D] / r_divi[D] else r_biof[D] = 'NaN'
;  End

  position = pos[*,0]
  cbar     = 1  &  CBFormat = '(F5.3)'
  mindata  = 0  &  maxdata  = 0.02  &  meanvalue = 1
  mapplot, p_burn, mdat, mindata=mindata, maxdata=maxdata, pos=position,         $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,                    $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, cbar=cbar, $
   meanvalue=meanvalue, title='pres. burn'

  position = pos[*,1]
  cbar     = 1  &  CBFormat = '(F5.3)' & nogylabel=1   &  meanvalue = 1
  mapplot, r_biof, mdat, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, cbar=cbar, $
   meanvalue=meanvalue, title='res. biofuel'

  position = pos[*,2]
  cbar     = 1  &  CBFormat = '(F5.1)'
  mindata  = 0  &  maxdata  = nmon & nogylabel = 0
  mapplot, p_divi, mdat, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, cbar=cbar

  position = pos[*,3]
  cbar     = 1  &  CBFormat = '(F5.1)' & nogylabel = 1
  mapplot, r_divi, mdat, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, cbar=cbar

 end
;==============================================================================

 @define_plot_size

  COMMON SHARE, mdat, nsk_ibf

 if N_elements(imp01) eq 0 then begin

    restore, filename='nsk_ibf.sav'     ; nsk_ibf

;    restore, filename='daily_2001.sav'  ; dat01
;    restore, filename='daily_2002.sav'  ; dat02
;    restore, filename='daily_2003.sav'   
;    restore, filename='daily_2004.sav'

    restore, filename='monthly_2001-2004.sav'  ; mdat
  end

  ; retrieve fire infomation from satellite
  if n_elements(fire) eq 0 then fire = get_fire()

  others = [1,2,3,4,5,9,10,11,12]
  winter = [1,2,12]
  spring = [3,4,5]
  autumn = [9,10,11]

  if !D.name eq 'PS' then $
    open_device, file='nsk_burns.ps', /color, /ps, /landscape

    find_p_burning, fire, season=winter
    xyouts, 0.5, 0.95, 'winter', /normal, color=1, charsize=charsize, charthick=charthick, $
         alignment=0.5
    halt

    find_p_burning, fire, season=spring
    xyouts, 0.5, 0.95, 'spring', /normal, color=1, charsize=charsize, charthick=charthick, $
         alignment=0.5
    halt

    find_p_burning, fire, season=autumn
    xyouts, 0.5, 0.95, 'autumn', /normal, color=1, charsize=charsize, charthick=charthick, $
         alignment=0.5
    halt

    find_p_burning, fire, season=others
    xyouts, 0.5, 0.95, 'non-summer', /normal, color=1, charsize=charsize, charthick=charthick, $
         alignment=0.5

  if !D.name eq 'PS' then close_device


End
