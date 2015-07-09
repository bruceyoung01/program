function retriev, file=file

   ctm_get_data, dinfo, file=file, tracer=33  ; g/cm2

   OC_EF = 0.7*9.7E-3 ; g/g drymass burned

   MODELINFO = CTM_Type( 'GEOS3', Res=1 )
   GRIDINFO  = CTM_Grid( MODELINFO )
   AREA_CM2  = CTM_BOXSIZE( GRIDINFO, /CM2)

   FIRST = dinfo[0].first
   DIM   = dinfo[0].dim
  
   x1 = first[0]-1L
   x2 = x1 + dim[0]-1L
   y1 = first[1]-1L
   y2 = y1 + dim[1]-1L

    t = fltarr(360,181)

   For D = 0, N_elements(dinfo)-1 do begin
     t[x1:x2,y1:y2] = t[x1:x2,y1:y2] + *(dinfo[D].data)
   Endfor

   t = t * area_cm2

   xmid = gridinfo.xmid[x1:x2]
   ymid = gridinfo.ymid[y1:y2]

   ems = region_only(t, region='USCONT')
   print, total(ems)*1.e-12

   return, ems*oc_ef
End


 if n_elements(clim) eq 0 then begin
   file = '/data/ctm/GEOS_1x1_NA/biomass_200110/bioburn.seasonal.geos.1x1'
   clim = retriev( file=file )
 
   file = '/data/ctm/GEOS_1x1_NA/biomass_200110/bioburn.interannual.geos.1x1.2001'
   yr01 = retriev( file=file )
 end

   print, total(clim)*1.e-12, total(yr01)*1.e-12

   multipanel, row=2, col=1
   plot_region, clim
   plot_region, yr01

 end
