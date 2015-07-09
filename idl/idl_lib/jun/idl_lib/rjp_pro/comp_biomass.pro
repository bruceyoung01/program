 pro get_dat, clim, b2001

 file = '/data/ctm/GEOS_1x1_NA/biomass_200110/bioburn.seasonal.geos.1x1'
 ctm_get_data, datainfo, file=file, tracer=33

 clim = 0.
 for d = 0, n_elements(datainfo)-1 do $
   clim = clim + *(datainfo[D].data)


 file = '/data/ctm/GEOS_1x1_NA/biomass_200110/bioburn.interannual.geos.1x1.2001'
 ctm_get_data, datainfo, file=file, tracer=33

 b2001 = 0.
 for d = 0, n_elements(datainfo)-1 do $
   b2001 = b2001 + *(datainfo[D].data)

 end


 if n_elements(clim) eq 0 then begin
    get_dat, clim, b2001
    us_clim = region_only(clim, region='UScont')
    us_2001 = region_only(b2001,region='UScont')
 end

  if (!D.name eq 'PS') then $
   Open_device, file='biomass_comp.ps', /land, /ps, /color

  Gridinfo = ctm_grid(ctm_type('GEOS3', res=1))
  A_cm2    = CTM_BoxSize( GridInfo, /GEOS, /cm2 )

  multipanel, row=1, col=2, omargin=[0.1,0.1,0.1,0.1]
  margin = [0.05,0.,0.,0.]

  maxdata=30.
  mindata=0.
  plot_region, us_clim*1000., /sample, maxdata=maxdata, mindata=mindata, $
   margin=margin, title='Climatology (35 Tg DM)'
  plot_region, us_2001*1000., /sample, maxdata=maxdata, mindata=mindata, $
   /nogylabel, margin=margin, title='2001 (72 Tg DM)'
;  plot_region, us_2001-us_clim, /sample, divis=4, /cbar

  CBPosition = [0.25,0.13,0.75,0.17]
  C      = Myct_defaults()
  Ncolor = 255L-Bottom
  Format = '(I3)'
  Unit   = 'g DM m!u-2!nyr!u-1!n'
  Ndiv   = 4
  ColorBar, Max=maxdata,      Min=0.,         NColors=Ncolor,     $
     	      Bottom=C.Bottom,  Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,        Divisions=Ndiv, Log=Log,             $
	      Format=Format,    Charsize=charsize,       $
     	      Charthick=charthick, _EXTRA=e

  print, total(us_clim*a_cm2)*1.e-12, total(us_2001*a_cm2)*1.e-12

  if (!D.name eq 'PS') then close_device
 End
