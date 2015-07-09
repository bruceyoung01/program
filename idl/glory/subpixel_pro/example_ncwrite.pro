;======================================================================
; Saved to nc file
;======================================================================
  angle_attr = {units:'degrees'}
  aod_attr   = {units:'none'}
  pm10_attr  = {units:'ug/m^3'}
  glob_attr  = {source:'XXU for GEOS-Chem AOD calculation',version:1}
  ncfile= nc_path + 'ensemble_aod_'+date+'.nc'

  ncfields = 'xmid[]:angle_attr; ' $
           + 'ymid[]:angle_attr; ' $
           + 'gc_aod550[xmid,ymid]:aod_attr; ' $
           + 'gc_dust_aod[xmid,ymid]:aod_attr; ' $
           + 'gc_aod670[xmid,ymid]:aod_attr; ' $
           + 'misr_aod[xmid,ymid]:aod_attr; ' $
           + 'misr_aod_stdv[xmid,ymid]:aod_attr; ' $
           + 'misr_time[xmid,ymid]:aod_attr; ' $
           + 'misr_gc_aod[xmid,ymid]:aod_attr; ' $
           + 'misr_gc_dstod[xmid,ymid]:aod_attr; ' $
           + 'db_aod[xmid,ymid]:aod_attr; ' $
           + 'db_aod_stdv[xmid,ymid]:aod_attr; ' $
           + 'db_time[xmid,ymid]:aod_attr; ' $
           + 'db_gc_aod[xmid,ymid]:aod_attr; ' $
           + 'db_gc_dstod[xmid,ymid]:aod_attr; ' $
           + 'ret_aod[xmid,ymid]:aod_attr; ' $
           + 'gc_pm[xmid,ymid]:pm10_attr; ' $
           + 'epa_pm[xmid,ymid]:pm10_attr; ' $
           + '@ glob_attr'

  ; call routine to write
  @ncdf_quickwrite

