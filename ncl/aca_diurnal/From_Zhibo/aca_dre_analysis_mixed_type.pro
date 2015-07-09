
pro aca_dre_analysis_mixed_type,save_file=save_file,debug=debug
;RESOLVE_ALL
if n_elements(debug) le 0 then debug=0

header  =  'Global_ACA_'
MODIS_cloud_fraction_file = 'MODIS_Total_Cloud_Fraction.nc'

DJF = [0,1,11]
MAM = [2,3,4]
JJA = [5,6,7]
SON = [8,9,10]

ntype = 6


day_or_night = ''
smoke_model =''
dust_model = ''
aot_scaling = ''
aqua_or_terra = ''
save_file = ''
data_dir = ''
figure_dir = ''
cot_cor_flag=''
openr, input_lun,'ACA_DRE_analysis_input.txt' , /get_lun
readf, input_lun, nyears
years  = make_array(nyears)
readf, input_lun, years
readf, input_lun, grid_size_stat
readf, input_lun, day_or_night
readf, input_lun, smoke_model
readf, input_lun, dust_model
readf, input_lun, aot_scaling
readf, input_lun, aqua_or_terra
readf, input_lun, cot_cor_flag
readf, input_lun, data_dir
readf, input_lun, figure_dir
free_lun, input_lun

;-------- MODIS cloud fraction information for deriving cloudy-sky DRE --------;
read_MODIS_cloud_fraction, MODIS_cloud_fraction_file, MODIS_L3_lon, MODIS_L3_lat, $
     aqua_MODIS_total_CF_monthly_2007to2012, terra_MODIS_total_CF_monthly_2007to2012, ocean_mask
;------------------------------------------------------------------------------;

;--- prepare lat&lon grids ---------;
nlat_grid_stat   = fix(180.0/grid_size_stat)
nlon_grid_stat   = fix(360.0/grid_size_stat)
lat_grid_stat = -90.0  + (FindGen(nlat_grid_stat)+0.5) * grid_size_stat
lon_grid_stat = -180.0 + (FindGen(nlon_grid_stat)+0.5) * grid_size_stat
lat_bound_stat = -90.0  + FindGen(nlat_grid_stat+1) * grid_size_stat
lon_bound_stat = -180.0 + FindGen(nlon_grid_stat+1) * grid_size_stat

total_count_total = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears)
cloud_count_total = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears)
ACA_count_total   = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
aca_aod_532       = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
bac_cot_median    = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears) ; below aerosol cloud optical thickness
bac_cot_mean      = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears) ; below aerosol cloud optical thickness

diurnal_aca_dare_toa  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
diurnal_aca_dare_srf  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
diurnal_aca_dare_atm  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)

nsample_threshold = 0 
for iyear = 0,  nyears -1 do begin
    for imonth=  0, 11 do begin
       for iday = 0, monthdays(years[iyear],imonth+1)-1 do begin
          year_char  = string(years[iyear],  format='(I4.4)')
          month_char = string(imonth+1     , format='(I2.2)')
          day_char   = string(iday+1,        format='(I2.2)')
          aca_file = file_search(data_dir+header+year_char+'-'+month_char+'-'+day_char+'_'+day_or_night+'_COT_'+cot_cor_flag+'.nc',count=nf)
          if debug then print,aca_file[0]
          if nf le 0 then begin
            print,'data missing',year_char+'-'+month_char+'-'+day_char
              continue
          endif else begin
            ;------ read in data in the netcdf files -----------;
            lat_grid_data           = read_ncdf(aca_file,'lat_grids') 
            lon_grid_data           = read_ncdf(aca_file,'lon_grids') 
            sampled_grids_lat_index = read_ncdf(aca_file,'sampled_grids_lat_index')
            sampled_grids_lon_index = read_ncdf(aca_file,'sampled_grids_lon_index')
            caliop_total_count      = read_ncdf(aca_file,'CALIOP_total_count')
            caliop_cloud_count      = read_ncdf(aca_file,'CALIOP_cloud_count')
            caliop_aca_count        = read_ncdf(aca_file,'CALIOP_ACA_count')
             if  strcmp( aqua_or_terra,'aqua',/fold_case) then begin
                  COT_CTP_hist            = read_ncdf(aca_file,'Aqua_cot_ctp_hist')
             endif else $
                  COT_CTP_hist            = read_ncdf(aca_file,'Terra_cot_ctp_hist')
           
            COT_CTP_hist[where(COT_CTP_hist lt 0, /null)] = 0 ; set -9999 value in histogram to 0
            CTP_hist_bnd            = read_ncdf(aca_file,'CTP_boundary')
            COT_hist_bnd            = read_ncdf(aca_file,'COT_boundary')
            aod_532_grids           = read_ncdf(aca_file,'AOT_grids')
            nAOT                    = n_elements(aod_532_grids)
            COT_grids               = (COT_hist_bnd[0:-2] + COT_hist_bnd[1:-1])/2.0
            nCOT                    = n_elements(COT_grids)
            nCTP                    = n_elements(CTP_hist_bnd) - 1
            ACA_lbp_mean            = read_ncdf(aca_file,'CALIOP_ACA_lbp_mean')
            aod_hist                = read_ncdf(aca_file,'CALIOP_ACA_AOT_hist')
            nsamples                = n_elements(sampled_grids_lat_index) & if nsamples lt nsample_threshold then continue 


            if strcmp(AOT_scaling,'scale',/fold_case) then begin
                aod_hist               = read_ncdf(aca_file,'Simple_Scale_ACA_AOT_hist')
                ;---- toa     DARE ------;
                toa_dare_caliop        = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_toa_diurnal')
                toa_dare_OPAC_dust     = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_OPAC_dust_TOA_diurnal')
                toa_dare_OBS_dust      = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_OBS_dust_TOA_diurnal')
                toa_dare_haywood_smoke = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_haywood_smoke_TOA_diurnal')
                ;---- surface DARE ------;
                srf_dare_caliop        = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_srf_diurnal')
                srf_dare_OPAC_dust     = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_OPAC_dust_srf_diurnal')
                srf_dare_OBS_dust      = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_OBS_dust_srf_diurnal')
                srf_dare_haywood_smoke = read_ncdf(aca_file,'dare_aod_sc_cot_'+aqua_or_terra+'_haywood_smoke_srf_diurnal')
            endif else begin
                aod_hist               = read_ncdf(aca_file,'CALIOP_ACA_AOT_hist')
                ;---- toa     DARE ------;
                toa_dare_caliop        = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_toa_diurnal')
                toa_dare_OPAC_dust     = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_OPAC_dust_TOA_diurnal')
                toa_dare_OBS_dust      = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_OBS_dust_TOA_diurnal')
                toa_dare_haywood_smoke = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_haywood_smoke_TOA_diurnal')
                ;---- surface DARE ------;
                srf_dare_caliop        = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_srf_diurnal')
                srf_dare_OPAC_dust     = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_OPAC_dust_srf_diurnal')
                srf_dare_OBS_dust      = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_OBS_dust_srf_diurnal')
                srf_dare_haywood_smoke = read_ncdf(aca_file,'dare_aod_caliop_cot_'+aqua_or_terra+'_haywood_smoke_srf_diurnal') 
            endelse
            ;----------------- convert NaN to 0.0 ---------------------;
            idx = where(~finite(toa_dare_caliop)   ,count)     & if count gt 0 then toa_dare_caliop[idx] = 0.0
            idx = where(~finite(toa_dare_OPAC_dust),count)     & if count gt 0 then toa_dare_OPAC_dust[idx] = 0.0
            idx = where(~finite(toa_dare_OBS_dust) ,count)     & if count gt 0 then toa_dare_OBS_dust[idx] = 0.0
            idx = where(~finite(toa_dare_haywood_smoke),count) & if count gt 0 then toa_dare_haywood_smoke[idx] = 0.0

            idx = where(~finite(srf_dare_caliop)   ,count)     & if count gt 0 then srf_dare_caliop[idx] = 0.0
            idx = where(~finite(srf_dare_OPAC_dust),count)     & if count gt 0 then srf_dare_OPAC_dust[idx] = 0.0
            idx = where(~finite(srf_dare_OBS_dust) ,count)     & if count gt 0 then srf_dare_OBS_dust[idx] = 0.0
            idx = where(~finite(srf_dare_haywood_smoke),count) & if count gt 0 then srf_dare_haywood_smoke[idx] = 0.0

            if strcmp(smoke_model,'haywood', /fold_case) then begin  ; if haywood model not use, then use caliop defult 
                 smoke_toa_dare = toa_dare_haywood_smoke
                 smoke_srf_dare = srf_dare_haywood_smoke
            endif else begin
                 smoke_toa_dare = reform(toa_dare_caliop[5,*])
                 smoke_srf_dare = reform(srf_dare_caliop[5,*])
            endelse

            if  strcmp(dust_model, 'opac',/fold_case) then begin
                 dust_toa_dare  = toa_dare_OPAC_dust
                 dust_srf_dare  = srf_dare_OPAC_dust
            endif else if strcmp(dust_model,'obs',/fold_case) then begin
                 dust_toa_dare  = toa_dare_obs_dust
                 dust_srf_dare  = srf_dare_obs_dust
            endif else begin
                 dust_toa_dare  = reform(toa_dare_caliop[1,*])
                 dust_srf_dare  = reform(srf_dare_caliop[1,*])
            endelse


            if n_elements(aca_aod_532_hist) le 0 then aca_aod_532_hist = lonarr(nAOT,ntype)
            aca_aod_532_hist  += total(aod_hist,3,/nan) 

                     
            ;------- convert data into gridded format ----------;
            for isample = 0,nsamples -1 do begin
                if caliop_total_count[isample] le nsample_threshold then continue ; not used in statistics if # of caliop samples in the grid box smaller than the threshold value
                ;reproject to statistic grid

                data_to_stat_lat_index = value_locate(lat_bound_stat,lat_grid_data[sampled_grids_lat_index[isample]])
                data_to_stat_lon_index = value_locate(lon_bound_stat,lon_grid_data[sampled_grids_lon_index[isample]])
            	total_count_total[data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear]   += caliop_total_count[isample] 
                cloud_count_total[data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear]   += caliop_cloud_count[isample] 
 	        if (debug) then begin 
			print,isample
			print,'lat idx',data_to_stat_lat_index
			print,'lon idx', data_to_stat_lon_index
		endif
                ; derive the above cloud aerosol optical thickness and below aerosol cloud optical thickness
                aca_height_idx = value_locate(ctp_hist_bnd,max(ACA_lbp_mean[*,isample])) ; locate the height of aca bottom in cot_ctp joint histogram
                if (aca_height_idx lt 0) or (total(caliop_aca_count[*,isample]) le 0) then continue
                if max(COT_CTP_hist[*,aca_height_idx:nctp-1,isample]) gt 0 then begin
                   if aca_height_idx lt nCTP-1 then begin
                       cot_hist_tmp = total(COT_CTP_hist[*,aca_height_idx:nctp-1,isample],2)
                   endif else cot_hist_tmp = (COT_CTP_hist[*,aca_height_idx,isample])
                    cot_mean_tmp = total(cot_hist_tmp*cot_grids)/float(total(cot_hist_tmp))
                    bac_cot_mean[data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear] += cot_mean_tmp * total(caliop_aca_count[*,isample])
	            for i=1,nCOT-1 do begin
		    	cot_hist_cum = total(cot_hist_tmp[0:i])
	                if cot_hist_cum/total(cot_hist_tmp) gt 0.5 then begin ; find the median value
			    bac_cot_median[data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear] += COT_grids[i-1] * total(caliop_aca_count[*,isample])
	                    break
			endif
		    endfor
                 endif
            	for itype=0,ntype-1 do begin
                  ACA_count_total[data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += caliop_aca_count[itype,isample]
                  aca_aod_532[    data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += total(reform(aod_hist[*,itype,isample])*aod_532_grids)
                   weighting = caliop_aca_count[itype,isample] 

                   if (itype eq 0) or (itype eq 2) or (itype eq 3) or (itype eq 4)  then begin
                      diurnal_aca_dare_toa [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += toa_dare_caliop[itype,isample] * weighting 
                      diurnal_aca_dare_srf [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += srf_dare_caliop[itype,isample] * weighting 
                   endif
                   if itype eq 1 then begin  ; this type is dust
                      diurnal_aca_dare_toa [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += dust_toa_dare[isample]  * weighting  
                      diurnal_aca_dare_srf [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += dust_srf_dare[isample]  * weighting  
                   endif
                   if itype eq 5 then begin ; this type is smoke 
                      diurnal_aca_dare_toa [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += smoke_toa_dare[isample] * weighting  
                      diurnal_aca_dare_srf [ data_to_stat_lon_index,data_to_stat_lat_index,imonth,iyear,itype] += smoke_srf_dare[isample] * weighting  
                   endif   
 
                endfor ;aerosol type loop
            endfor ; lat-lon sample loop 
          endelse ;check if data are missing
	if (debug) then stop
       endfor; day loop
    endfor;month loop
endfor; year loop

;total_count_total = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears)
;cloud_count_total = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears)
;ACA_count_total   = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
;aca_aod_532       = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)

;diurnal_aca_dare_toa  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
;diurnal_aca_dare_srf  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)
;diurnal_aca_dare_atm  = dblarr(nlon_grid_stat,nlat_grid_stat,12,nyears,ntype)

total_count_DJF = total(total_count_total[*,*,DJF,*],3)
total_count_MAM = total(total_count_total[*,*,MAM,*],3)
total_count_JJA = total(total_count_total[*,*,JJA,*],3)
total_count_SON = total(total_count_total[*,*,SON,*],3)

cloud_count_DJF = total(cloud_count_total[*,*,DJF,*],3)
cloud_count_MAM = total(cloud_count_total[*,*,MAM,*],3)
cloud_count_JJA = total(cloud_count_total[*,*,JJA,*],3)
cloud_count_SON = total(cloud_count_total[*,*,SON,*],3)

ACA_count_annual = total(ACA_count_total[*,*,*,*],3)
ACA_count_DJF = total(ACA_count_total[*,*,DJF,*],3)
ACA_count_MAM = total(ACA_count_total[*,*,MAM,*],3)
ACA_count_JJA = total(ACA_count_total[*,*,JJA,*],3)
ACA_count_SON = total(ACA_count_total[*,*,SON,*],3)

cloud_fraction_annual  = total(cloud_count_total,3)            / total(total_count_total,3)
cloud_fraction_DJF     = total(cloud_count_total[*,*,DJF,*],3) / total(total_count_total[*,*,DJF,*],3)
cloud_fraction_MAM     = total(cloud_count_total[*,*,MAM,*],3) / total(total_count_total[*,*,MAM,*],3)
cloud_fraction_JJA     = total(cloud_count_total[*,*,JJA,*],3) / total(total_count_total[*,*,JJA,*],3)
cloud_fraction_SON     = total(cloud_count_total[*,*,SON,*],3) / total(total_count_total[*,*,SON,*],3)


all_aca_annual_overlap = total(total(ACA_count_total,5),3)               / total(cloud_count_total,3)
all_aca_DJF_overlap =    total(total(ACA_count_total[*,*,DJF,*,*],5),3)  / total(cloud_count_total[*,*,DJF,*],3)
all_aca_MAM_overlap =    total(total(ACA_count_total[*,*,MAM,*,*],5),3)  / total(cloud_count_total[*,*,MAM,*],3)
all_aca_JJA_overlap =    total(total(ACA_count_total[*,*,JJA,*,*],5),3)  / total(cloud_count_total[*,*,JJA,*],3)
all_aca_SON_overlap =    total(total(ACA_count_total[*,*,SON,*,*],5),3)  / total(cloud_count_total[*,*,SON,*],3)

bac_cot_annual         = total(bac_cot_mean,3) / total(total(ACA_count_total,5),3)
bac_cot_DJF            = total(bac_cot_mean[*,*,DJF,*],3) / total(total(ACA_count_total[*,*,DJF,*,*],5),3)
bac_cot_MAM            = total(bac_cot_mean[*,*,MAM,*],3) / total(total(ACA_count_total[*,*,MAM,*,*],5),3)
bac_cot_JJA            = total(bac_cot_mean[*,*,JJA,*],3) / total(total(ACA_count_total[*,*,JJA,*,*],5),3)
bac_cot_SON            = total(bac_cot_mean[*,*,SON,*],3) / total(total(ACA_count_total[*,*,SON,*,*],5),3)
 

all_aca_aod_532_annual = total(total(aca_aod_532,5),3)              /  total(total(ACA_count_total,5),3)
all_aca_aod_532_DJF    = total(total(aca_aod_532[*,*,DJF,*,*],5),3) /  total(total(ACA_count_total[*,*,DJF,*,*],5),3)
all_aca_aod_532_MAM    = total(total(aca_aod_532[*,*,MAM,*,*],5),3) /  total(total(ACA_count_total[*,*,MAM,*,*],5),3)
all_aca_aod_532_JJA    = total(total(aca_aod_532[*,*,JJA,*,*],5),3) /  total(total(ACA_count_total[*,*,JJA,*,*],5),3)
all_aca_aod_532_SON    = total(total(aca_aod_532[*,*,SON,*,*],5),3) /  total(total(ACA_count_total[*,*,SON,*,*],5),3)

aca_dirunal_toa_annual     = total(total(diurnal_aca_dare_toa,5),3)              /  total(total(ACA_count_total,5),3)
aca_dirunal_toa_DJF        = total(total(diurnal_aca_dare_toa[*,*,DJF,*,*],5),3) /  total(total(ACA_count_total[*,*,DJF,*,*],5),3)
aca_dirunal_toa_MAM        = total(total(diurnal_aca_dare_toa[*,*,MAM,*,*],5),3) /  total(total(ACA_count_total[*,*,MAM,*,*],5),3)
aca_dirunal_toa_JJA        = total(total(diurnal_aca_dare_toa[*,*,JJA,*,*],5),3) /  total(total(ACA_count_total[*,*,JJA,*,*],5),3)
aca_dirunal_toa_SON        = total(total(diurnal_aca_dare_toa[*,*,SON,*,*],5),3) /  total(total(ACA_count_total[*,*,SON,*,*],5),3)

aca_dirunal_srf_annual     = total(total(diurnal_aca_dare_srf,5),3)              /  total(total(ACA_count_total,5),3)
aca_dirunal_srf_DJF        = total(total(diurnal_aca_dare_srf[*,*,DJF,*,*],5),3) /  total(total(ACA_count_total[*,*,DJF,*,*],5),3)
aca_dirunal_srf_MAM        = total(total(diurnal_aca_dare_srf[*,*,MAM,*,*],5),3) /  total(total(ACA_count_total[*,*,MAM,*,*],5),3)
aca_dirunal_srf_JJA        = total(total(diurnal_aca_dare_srf[*,*,JJA,*,*],5),3) /  total(total(ACA_count_total[*,*,JJA,*,*],5),3)
aca_dirunal_srf_SON        = total(total(diurnal_aca_dare_srf[*,*,SON,*,*],5),3) /  total(total(ACA_count_total[*,*,SON,*,*],5),3)

aca_dirunal_atm_annual     = aca_dirunal_toa_annual - aca_dirunal_srf_annual
aca_dirunal_atm_DJF     = aca_dirunal_toa_DJF - aca_dirunal_srf_DJF
aca_dirunal_atm_MAM     = aca_dirunal_toa_MAM - aca_dirunal_srf_MAM
aca_dirunal_atm_JJA     = aca_dirunal_toa_JJA - aca_dirunal_srf_JJA
aca_dirunal_atm_SON     = aca_dirunal_toa_SON - aca_dirunal_srf_SON

cloudy_dirunal_toa_annual     = total(total(diurnal_aca_dare_toa,5),3)              /  total(cloud_count_total,3)
cloudy_dirunal_toa_DJF        = total(total(diurnal_aca_dare_toa[*,*,DJF,*,*],5),3) /  total(cloud_count_total[*,*,DJF,*],3)
cloudy_dirunal_toa_MAM        = total(total(diurnal_aca_dare_toa[*,*,MAM,*,*],5),3) /  total(cloud_count_total[*,*,MAM,*],3)
cloudy_dirunal_toa_JJA        = total(total(diurnal_aca_dare_toa[*,*,JJA,*,*],5),3) /  total(cloud_count_total[*,*,JJA,*],3)
cloudy_dirunal_toa_SON        = total(total(diurnal_aca_dare_toa[*,*,SON,*,*],5),3) /  total(cloud_count_total[*,*,SON,*],3)

cloudy_dirunal_srf_annual     = total(total(diurnal_aca_dare_srf,5),3)              /  total(cloud_count_total,3)
cloudy_dirunal_srf_DJF        = total(total(diurnal_aca_dare_srf[*,*,DJF,*,*],5),3) /  total(cloud_count_total[*,*,DJF,*],3)
cloudy_dirunal_srf_MAM        = total(total(diurnal_aca_dare_srf[*,*,MAM,*,*],5),3) /  total(cloud_count_total[*,*,MAM,*],3)
cloudy_dirunal_srf_JJA        = total(total(diurnal_aca_dare_srf[*,*,JJA,*,*],5),3) /  total(cloud_count_total[*,*,JJA,*],3)
cloudy_dirunal_srf_SON        = total(total(diurnal_aca_dare_srf[*,*,SON,*,*],5),3) /  total(cloud_count_total[*,*,SON,*],3)

cloudy_dirunal_atm_annual  = cloudy_dirunal_toa_annual - cloudy_dirunal_srf_annual
cloudy_dirunal_atm_DJF     = cloudy_dirunal_toa_DJF - cloudy_dirunal_srf_DJF
cloudy_dirunal_atm_MAM     = cloudy_dirunal_toa_MAM - cloudy_dirunal_srf_MAM
cloudy_dirunal_atm_JJA     = cloudy_dirunal_toa_JJA - cloudy_dirunal_srf_JJA
cloudy_dirunal_atm_SON     = cloudy_dirunal_toa_SON - cloudy_dirunal_srf_SON

if n_elements(save_file) gt 0 then save, /VARIABLES,/compress, file=save_file


maplatmin = -60.0
maplatmax =  60.0
maplonmin = -180.0
maplonmax =  180.0
lat_range = where(lat_grid_stat ge maplatmin and lat_grid_stat le maplatmax)
lon_range = where(lon_grid_stat ge maplonmin and lon_grid_stat le maplonmax)
nlat_range = n_elements(lat_range)
nlon_range = n_elements(lon_range)

xrange = [maplonmin,maplonmax]
yrange = [maplatmin,maplatmax]

smoke_region_maplatmin = -30.0
smoke_region_maplatmax =  10.0
smoke_region_maplonmin = -20.0
smoke_region_maplonmax =  20.0
smoke_region_lat_range = where(lat_grid_stat ge smoke_region_maplatmin and lat_grid_stat le smoke_region_maplatmax)
smoke_region_lon_range = where(lon_grid_stat ge smoke_region_maplonmin and lon_grid_stat le smoke_region_maplonmax)
smoke_region_xrange= [smoke_region_maplonmin,smoke_region_maplonmax]
smoke_region_yrange= [smoke_region_maplatmin,smoke_region_maplatmax]

dust_region_maplatmin =  10.0
dust_region_maplatmax =  30.0
dust_region_maplonmin = -45.0
dust_region_maplonmax = -10.0
dust_region_lat_range = where(lat_grid_stat ge dust_region_maplatmin and lat_grid_stat le dust_region_maplatmax)
dust_region_lon_range = where(lon_grid_stat ge dust_region_maplonmin and lon_grid_stat le dust_region_maplonmax)
dust_region_xrange= [dust_region_maplonmin,dust_region_maplonmax]
dust_region_yrange= [dust_region_maplatmin,dust_region_maplatmax]
;----------------------------------------------------------------------------------;

set_plot,'ps'
loadct,39,/silent
!p.background= 255
!p.color = 0
!p.font  = 1

;-------------------plot total sampling number ----------------------------------------------------------;

minval = 0.0
maxval = 1000
divisions = 7
plot_data = total(total_count_DJF,3)/float(nyears)
plot_name = figure_dir+'total_count_DJF_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(total_count_MAM,3)/float(nyears)
plot_name = figure_dir+'total_count_MAM_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(total_count_JJA,3)/float(nyears)
plot_name = figure_dir+'total_count_JJA_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(total_count_SON,3)/float(nyears)
plot_name = figure_dir+'total_count_SON_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
minval = 0.0
maxval = 50.0 
divisions = 7

plot_data = total(ACA_count_DJF,3)/float(nyears)
plot_name = figure_dir+'ACA_count_annual_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(ACA_count_DJF,3)/float(nyears)
plot_name = figure_dir+'ACA_count_DJF_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(ACA_count_MAM,3)/float(nyears)
plot_name = figure_dir+'ACA_count_MAM_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(ACA_count_JJA,3)/float(nyears)
plot_name = figure_dir+'ACA_count_JJA_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(ACA_count_SON,3)/float(nyears)
plot_name = figure_dir+'ACA_count_SON_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

;------------------- plot ACA cloud overalpping frequency ----------------------------------------------------------;
minval = 0.0
maxval = 0.8
divisions = 7

plot_data = total(all_aca_annual_overlap,3)/float(nyears)
plot_name = figure_dir+'all_aca_overlaping_freq_annual_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_Region_all_aca_overlaping_freq_annual_'+day_or_night+'.eps'
plot_cf_routine, plot_name, plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                      smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				       minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_DJF_overlap,3)/float(nyears)
plot_name = figure_dir+'all_aca_overlaping_freq_DJF_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_Region_all_aca_overlaping_freq_DJF_'+day_or_night+'.eps'
plot_cf_routine, plot_name, plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
		                      smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				       minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_MAM_overlap,3)/float(nyears)
plot_name = figure_dir+'all_aca_overlaping_freq_MAM_'+day_or_night+'.eps'
plot_cf_routine, plot_name,all_aca_MAM_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_Region_all_aca_overlaping_freq_MAM_'+day_or_night+'.eps'
plot_cf_routine, plot_name, plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
		                      smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				       minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6


plot_data = total(all_aca_JJA_overlap,3)/float(nyears)
plot_name = figure_dir+'all_aca_overlaping_freq_JJA_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_Region_all_aca_overlaping_freq_JJA_'+day_or_night+'.eps'
plot_cf_routine, plot_name, plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
		                      smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				       minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_SON_overlap,3)/float(nyears)
plot_name = figure_dir+'all_aca_overlaping_freq_SON_'+day_or_night+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar
plot_name = figure_dir+'Smoke_Region_all_aca_overlaping_freq_SON_'+day_or_night+'.eps'
plot_cf_routine, plot_name, plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
		                      smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				       minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
;-------------------------------------------------------------------------------------------------------------------;

;------------------- plot ACA AOD 532 ----------------------------------------------------------;
minval = 0.0
maxval = 0.8
divisions = 7

plot_data = total(all_aca_aod_532_annual,3)/float(nyears)
plot_name = figure_dir+'all_aca_aod_532_annual_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_region_all_aca_aod_532_annual_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                     smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				     minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
plot_name = figure_dir+'Dust_region_all_aca_aod_532_annual_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                     dust_region_lat_range[0]:dust_region_lat_range[-1]],$
				     minval,maxval, dust_region_xrange,dust_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6


plot_data = total(all_aca_aod_532_DJF,3)/float(nyears)
plot_name = figure_dir+'all_aca_aod_532_DJF_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_region_all_aca_aod_532_DJF_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                     smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				     minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
plot_name = figure_dir+'Dust_region_all_aca_aod_532_DJF_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                     dust_region_lat_range[0]:dust_region_lat_range[-1]],$
				     minval,maxval, dust_region_xrange,dust_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_aod_532_MAM,3)/float(nyears)
plot_name = figure_dir+'all_aca_aod_532_MAM_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,all_aca_MAM_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_region_all_aca_aod_532_MAM_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                     smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				     minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
plot_name = figure_dir+'Dust_region_all_aca_aod_532_MAM_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                     dust_region_lat_range[0]:dust_region_lat_range[-1]],$
				     minval,maxval, dust_region_xrange,dust_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_aod_532_JJA,3)/float(nyears)
plot_name = figure_dir+'all_aca_aod_532_JJA_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_name = figure_dir+'Smoke_region_all_aca_aod_532_JJA_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                     smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				     minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
plot_name = figure_dir+'Dust_region_all_aca_aod_532_JJA_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                     dust_region_lat_range[0]:dust_region_lat_range[-1]],$
				     minval,maxval, dust_region_xrange,dust_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6

plot_data = total(all_aca_aod_532_SON,3)/float(nyears)
plot_name = figure_dir+'all_aca_aod_532_SON_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar
plot_name = figure_dir+'Smoke_region_all_aca_aod_532_SON_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                     smoke_region_lat_range[0]:smoke_region_lat_range[-1]],$
				     minval,maxval, smoke_region_xrange,smoke_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
plot_name = figure_dir+'Dust_region_all_aca_aod_532_SON_'+day_or_night+'_aod_'+AOT_scaling+'.eps'
plot_cf_routine, plot_name,plot_data[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                     dust_region_lat_range[0]:dust_region_lat_range[-1]],$
				     minval,maxval, dust_region_xrange,dust_region_yrange,divisions=divisions,format='(f5.1)',xs=6,ys=6
;-------------------------------------------------------------------------------------------------------------------;
; plot below ACA cloud COT


minval = 0.0
maxval = 20.0
divisions = 10

plot_data = total(bac_cot_annual,3)/float(nyears)
plot_name = figure_dir+'below_aca_cot_'+cot_cor_flag+'_annual.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                         minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_data = total(bac_cot_DJF,3)/float(nyears)
plot_name = figure_dir+'below_aca_cot_'+cot_cor_flag+'_DJF.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
plot_data = total(bac_cot_MAM,3)/float(nyears)
plot_name = figure_dir+'below_aca_cot_'+cot_cor_flag+'_MAM.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_data = total(bac_cot_JJA,3)/float(nyears)
plot_name = figure_dir+'below_aca_cot_'+cot_cor_flag+'_JJA.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_data = total(bac_cot_SON,3)/float(nyears)
plot_name = figure_dir+'below_aca_cot_'+cot_cor_flag+'_SON.eps'
plot_cf_routine, plot_name,plot_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
	                                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

;--------------- plot smoke region ACA annual cycle ------------------------------------------------;


smoke_atype_idx = 5
PD_atype_idx = 4
dust_atype_idx = 1
others_atype_idx = [0,2,3]


;-------------------------------------------------------------------------------------------------------------------;
tmp = total(total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                  smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,others_atype_idx],5),4) / $
      total(cloud_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                              smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*],4)
smoke_region_ACA_overlapping_annual_cycle_others = fltarr(12) 
for i=0,11 do smoke_region_ACA_overlapping_annual_cycle_others[i] = mean(tmp[*,*,i],/nan)
;-------------------------------------------------------------------------------------------------------------------;
tmp = total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                            smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,smoke_atype_idx],4) / $
      total(cloud_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                              smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*],4)
smoke_region_ACA_overlapping_annual_cycle_smoke = fltarr(12)
for i=0,11 do smoke_region_ACA_overlapping_annual_cycle_smoke[i] = mean(tmp[*,*,i],/nan)
;-------------------------------------------------------------------------------------------------------------------;
tmp = total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                            smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,dust_atype_idx],4) / $
      total(cloud_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                              smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*],4)
smoke_region_ACA_overlapping_annual_cycle_dust = fltarr(12)
for i=0,11 do smoke_region_ACA_overlapping_annual_cycle_dust[i] = mean(tmp[*,*,i],/nan)
;-------------------------------------------------------------------------------------------------------------------;
tmp = total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                            smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,PD_atype_idx],4) / $
      total(cloud_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                              smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*],4)
smoke_region_ACA_overlapping_annual_cycle_PD = fltarr(12)
for i=0,11 do smoke_region_ACA_overlapping_annual_cycle_PD[i] =  mean(tmp[*,*,i],/nan)
;-------------------------------------------------------------------------------------------------------------------;
smoke_region_lat_range_MODIS = where(MODIS_L3_lat ge smoke_region_maplatmin and MODIS_L3_lat le smoke_region_maplatmax)
smoke_region_lon_range_MODIS = where(MODIS_L3_lon ge smoke_region_maplonmin and MODIS_L3_lon le smoke_region_maplonmax)

CF_subset = aqua_MODIS_total_CF_monthly_2007to2012[smoke_region_lon_range_MODIS[0]:smoke_region_lon_range_MODIS[-1],$
                                                   smoke_region_lat_range_MODIS[0]:smoke_region_lat_range_MODIS[-1],*,*]
cot_subset = bac_cot_mean[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                          smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*]

aca_count_subset = total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                         smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,*],5)

aca_aod_subset_smoke = aca_aod_532[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                   smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,smoke_atype_idx]

aca_count_subset_smoke = ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                         smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,smoke_atype_idx]

aca_aod_subset_PD    = aca_aod_532[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                   smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,PD_atype_idx]

aca_count_subset_PD = ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                      smoke_region_lat_range[0]:smoke_region_lat_range[-1],*,*,PD_atype_idx]

smoke_region_MODIS_CF_annual_cycle        = fltarr(12)
smoke_region_bac_cot_annual_cycle         = fltarr(12)
smoke_region_aca_smoke_aod_annual_cycle   = fltarr(12)
smoke_region_aca_PD_aod_annual_cycle      = fltarr(12)
smoke_region_aca_SmokePD_aod_annual_cycle = fltarr(12)

for i =0, 11 do begin

   smoke_region_MODIS_CF_annual_cycle[i]        = mean(mean(reform(CF_subset[*,*,i,*]),DIMENSION=3))
   smoke_region_bac_cot_annual_cycle[i]         = mean(total(reform(cot_subset[*,*,i,*]),3)/total(reform(aca_count_subset[*,*,i,*]),3),/nan)
   smoke_region_aca_smoke_aod_annual_cycle[i]   = mean(total(reform(aca_aod_subset_smoke[*,*,i,*]),3)/total(reform(aca_count_subset_smoke[*,*,i,*]),3),/nan)
   smoke_region_aca_PD_aod_annual_cycle[i]      = mean(total(reform(aca_aod_subset_PD[*,*,i,*]),3)/total(reform(aca_count_subset_PD[*,*,i,*]),3),/nan)
   smoke_region_aca_SmokePD_aod_annual_cycle[i] = mean(total(reform(aca_aod_subset_PD[*,*,i,*]+aca_aod_subset_smoke[*,*,i,*]),3)/ $ 
                                                    total(reform(aca_count_subset_PD[*,*,i,*]+aca_count_subset_smoke[*,*,i,*]),3), /nan)
endfor


period = JJA
cot_subset_period = bac_cot_mean[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                     smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*]

aca_count_subset_period = total(ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                         smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,*],5)

aca_aod_subset_smoke_period = aca_aod_532[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                   smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,smoke_atype_idx]

aca_count_subset_smoke_period = ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                         smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,smoke_atype_idx]

aca_aod_subset_PD_period    = aca_aod_532[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                   smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,PD_atype_idx]

aca_count_subset_PD_period = ACA_count_total[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                      smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,PD_atype_idx]

aca_dirunal_toa_subset_smoke_period = diurnal_aca_dare_toa[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                      smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,smoke_atype_idx]

aca_dirunal_toa_subset_PD_period = diurnal_aca_dare_toa[smoke_region_lon_range[0]:smoke_region_lon_range[-1],$
                                      smoke_region_lat_range[0]:smoke_region_lat_range[-1],period,*,PD_atype_idx]

device,file=figure_dir+'Smoke_region_DRE_vs_AOD_COT_period.eps',/color,/inches,/encapsulated,xs=10,ys=5.,$
       set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

loadct,39,/silent,ncolors=254
!p.multi=[0,2,1]
!p.font = 0
cot_max = 10
plot_xdata  = total(aca_aod_subset_smoke_period,3)      /total(aca_count_subset_smoke_period,3)
plot_ydata  = total(aca_dirunal_toa_subset_smoke_period,3)/total(aca_count_subset_smoke_period,3)
plot_zdata  = (total(reform(cot_subset_period[*,*,period,*]),3)/total(reform(aca_count_subset[*,*,period,*]),3))
plot_idx    = where(finite(plot_xdata) and plot_xdata le 1.0 and finite(plot_ydata))
plot_colors = bytscl(plot_zdata,max=cot_max,min=0.0,top=254)
	
plot,[0],[0],/nodata,xrange=[0.0,1],yrange=[-10,40],ystyle=1,xtitle='AOT @ 532nm',ytitle = 'TOA DARE [W/m!u2!n]',pos = [0.1,0.12,0.45,0.9],title='a) Smoke'
plots,plot_xdata[plot_idx],plot_ydata[plot_idx],psym=symcat(9),color=plot_colors[plot_idx],symsize=0.4
xx = findgen(11)/10.0
g1 = where(plot_zdata gt 8 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p1 = ladfit(plot_xdata[g1],plot_ydata[g1])
oplot,xx,p1[0]+p1[1]*xx,line=2,thick=5,color=250

g2 = where(plot_zdata gt 4 and plot_zdata le 8 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p2 = ladfit(plot_xdata[g2],plot_ydata[g2])
oplot,xx,p2[0]+p2[1]*xx,line=2,thick=5,color=150

g3 = where(plot_zdata lt 4 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p3 = ladfit(plot_xdata[g3],plot_ydata[g3])
oplot,xx,p3[0]+p3[1]*xx,line=2,thick=5,color=50

xyouts, 0.05,37,'                     Slope',charsize=0.8,charthick=2.0,color=0
xyouts, 0.05,34,'    COT>8  '+string(p1[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=250
xyouts, 0.05,31,'4<COT<8  '+string(p2[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=150
xyouts, 0.05,28,'    COT<4  '+string(p3[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=50


plot_xdata  = total(aca_aod_subset_PD_period,3)      /total(aca_count_subset_PD_period,3)
plot_ydata  = total(aca_dirunal_toa_subset_PD_period,3)/total(aca_count_subset_PD_period,3)
plot_zdata = (total(reform(cot_subset_period[*,*,period,*]),3)/total(reform(aca_count_subset[*,*,period,*]),3))
plot_idx    = where(finite(plot_xdata) and plot_xdata le 1.0 and finite(plot_ydata))
plot_colors = bytscl(plot_zdata,max=cot_max,min=0.0,top=254)
	
plot,[0],[0],/nodata,xrange=[0.0,1],yrange=[-10,40],ystyle=1,xtitle='AOT @ 532nm',pos = [0.5,0.12,0.85,0.9],title='b) Polluted Dust'
plots,plot_xdata[plot_idx],plot_ydata[plot_idx],psym=symcat(9),color=plot_colors[plot_idx],symsize=0.4

g1 = where(plot_zdata gt 8 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p1 = ladfit(plot_xdata[g1],plot_ydata[g1])
oplot,xx,p1[0]+p1[1]*xx,line=2,thick=5,color=250

g2 = where(plot_zdata gt 4 and plot_zdata le 8 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p2 = ladfit(plot_xdata[g2],plot_ydata[g2])
oplot,xx,p2[0]+p2[1]*xx,line=2,thick=5,color=150

g3 = where(plot_zdata lt 4 and finite(plot_zdata) and finite(plot_xdata) and finite(plot_ydata))
p3 = ladfit(plot_xdata[g3],plot_ydata[g3])
oplot,xx,p3[0]+p3[1]*xx,line=2,thick=5,color=50

xyouts, 0.05,37,'                     Slope',charsize=0.8,charthick=2.0,color=0
xyouts, 0.05,34,'    COT>8  '+string(p1[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=250
xyouts, 0.05,31,'4<COT<8  '+string(p2[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=150
xyouts, 0.05,28,'    COT<4  '+string(p3[1],format='(f5.1)')+'W/m!u2!n/AOT',charsize=0.8,charthick=2.0,color=50

colorbar,range=[0,cot_max],ncolors=253,format='(f5.0)',charsize=0.8,pos=[0.88, 0.12, 0.90, 0.90],title='Median COT',divisions = 5,/vertical,/right

device,/close

!p.multi=0

;---------------------------------------------------------------------------------------------------------;
tmp = total(total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                  dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,*],5),4) / $
      total(cloud_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                  dust_region_lat_range[0]:dust_region_lat_range[-1],*,*],4)
dust_region_ACA_overlapping_annual_cycle = fltarr(12)
for i =0,11 do  dust_region_ACA_overlapping_annual_cycle[i] = mean(tmp[*,*,i],/nan)
;---------------------------------------------------------------------------------------------------------;
tmp  = total(total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                  dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,others_atype_idx],5),4) / $
             total(cloud_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                 dust_region_lat_range[0]:dust_region_lat_range[-1],*,*],4)
dust_region_ACA_overlapping_annual_cycle_others= fltarr(12)
for i=0,11 do  dust_region_ACA_overlapping_annual_cycle_others[i] = mean(tmp[*,*,i],/nan)
;---------------------------------------------------------------------------------------------------------;
tmp  = total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                             dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,smoke_atype_idx],4) / $
      total(cloud_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                             dust_region_lat_range[0]:dust_region_lat_range[-1],*,*],4)
dust_region_ACA_overlapping_annual_cycle_smoke = fltarr(12)
for i =0,11 do  dust_region_ACA_overlapping_annual_cycle_smoke[i] = mean(tmp[*,*,i],/nan)
;---------------------------------------------------------------------------------------------------------;
tmp = total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                           dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,dust_atype_idx],4) / $
      total(cloud_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                           dust_region_lat_range[0]:dust_region_lat_range[-1],*,*],4)
dust_region_ACA_overlapping_annual_cycle_dust =fltarr(12)
for i=0,11 do dust_region_ACA_overlapping_annual_cycle_dust[i] = mean(tmp[*,*,i],/nan)
;---------------------------------------------------------------------------------------------------------;
tmp = total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                            dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,PD_atype_idx],4) / $
      total(cloud_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                           dust_region_lat_range[0]:dust_region_lat_range[-1],*,*],4)
dust_region_ACA_overlapping_annual_cycle_PD = fltarr(12)
for i=0,11 do dust_region_ACA_overlapping_annual_cycle_PD[i] = mean(tmp[*,*,i],/nan)
;---------------------------------------------------------------------------------------------------------;

dust_region_lat_range_MODIS = where(MODIS_L3_lat ge dust_region_maplatmin and MODIS_L3_lat le dust_region_maplatmax)
dust_region_lon_range_MODIS = where(MODIS_L3_lon ge dust_region_maplonmin and MODIS_L3_lon le dust_region_maplonmax)

CF_subset = aqua_MODIS_total_CF_monthly_2007to2012[dust_region_lon_range_MODIS[0]:dust_region_lon_range_MODIS[-1],$
                                                   dust_region_lat_range_MODIS[0]:dust_region_lat_range_MODIS[-1],*,*]
cot_subset = bac_cot_mean[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                     dust_region_lat_range[0]:dust_region_lat_range[-1],*,*]

aca_count_subset           = total(ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                              dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,*],5)

aca_aod_subset_dust   = aca_aod_532[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                        dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,dust_atype_idx]

aca_count_subset_dust     =        ACA_count_total[dust_region_lon_range[0]:dust_region_lon_range[-1],$
                                              dust_region_lat_range[0]:dust_region_lat_range[-1],*,*,dust_atype_idx]
dust_region_MODIS_CF_annual_cycle = fltarr(12)
dust_region_bac_cot_annual_cycle  = fltarr(12)
dust_region_aca_dust_aod_annual_cycle = fltarr(12)

for i=0,11 do begin
	dust_region_MODIS_CF_annual_cycle[i] = mean(mean(reform(CF_subset[*,*,i,*]),DIMENSION=3))
	dust_region_bac_cot_annual_cycle[i]  = mean(total(reform(cot_subset[*,*,i,*]),3)/total(reform(aca_count_subset[*,*,i,*]),3),/nan)
	dust_region_aca_dust_aod_annual_cycle[i]  = mean(total(reform(aca_aod_subset_dust[*,*,i,*]),3)/$
                                                         total(reform(aca_count_subset_dust[*,*,i,*]),3),/nan)
endfor


;---------------------------------------------------------------------------------------------------------------------------;
device,file=figure_dir+'Regional_ACA_overlapping_annual_cycle.eps',/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

loadct,39,/silent
plot,IndGen(12)+1,IndGen(12)+1,/nodata,xrange=[1,12],yrange=[0,0.8],xstyle=1,ystyle=1,xcharsize=1.5,ycharsize=1.5,xthick=2.0,ythick=2.0,$
     xticks = 11,ytitle='Cloud Fraction or Overlapping Frequency',xtitle='Month',ymargin=[5,2],xticklen=0.5,xgridstyle=3

oplot,IndGen(12)+1,smoke_region_MODIS_CF_annual_cycle,psym=-2,line=0,thick=3.0,color=254
oplot,IndGen(12)+1,smoke_region_ACA_overlapping_annual_cycle_others + $
                   smoke_region_ACA_overlapping_annual_cycle_smoke +  $
                   smoke_region_ACA_overlapping_annual_cycle_dust  +  $
                   smoke_region_ACA_overlapping_annual_cycle_PD,psym=-2,line=2,thick=3.0,color=254


oplot,IndGen(12)+1,dust_region_MODIS_CF_annual_cycle,psym=-2,line=0,thick=3.0,color=50
oplot,IndGen(12)+1,dust_region_ACA_overlapping_annual_cycle_others + $
                   dust_region_ACA_overlapping_annual_cycle_smoke +  $
                   dust_region_ACA_overlapping_annual_cycle_dust  +  $
                   dust_region_ACA_overlapping_annual_cycle_PD,psym=-2,line=2,thick=3.0,color=50
legend,['Smoke Region CF','Dust Region CF'],textcolor = [254,50],charsize=1.2,charthick=2.0,linestyle=0,psym=-2,color=[254,50],thick=3.0,box=1,pos=[1.1,0.79];,/clear
legend,['Smoke Region OF','Dust Region OF'],textcolor = [254,50],charsize=1.2,charthick=2.0,linestyle=2,psym=-2,color=[254,50],thick=3.0,box=1,pos=[1.2,0.28];,/clear


device,/close



device,file=figure_dir+'Smoke_region_overlapping_Atype_annual_cycle.eps',/color,/inches,/encapsulated,xs=6,ys=6*3./4.,$
       set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

d1 = smoke_region_ACA_overlapping_annual_cycle_smoke
d2 = smoke_region_ACA_overlapping_annual_cycle_PD
d3 = smoke_region_ACA_overlapping_annual_cycle_dust
d4 = smoke_region_ACA_overlapping_annual_cycle_others
bar_plot,d1+d2+d3+d4, colors=make_array(12,/integer,value=0), xtitle = 'Month', ytitle='Overlapping Frequency',barnames=['1','2','3','4','5','6','7','8','9','10','11','12' ]
bar_plot,d1+d2+d3,    colors=make_array(12,/integer,value=50), /overplot
bar_plot,d1+d2,       colors=make_array(12,/integer,value=200), /overplot
bar_plot,d1,          colors=make_array(12,/integer,value=254), /overplot

legend,['Smoke','Polluted Dust','Dust','Others'],textcolors=[254,200,50,0],charsize=1.2,pos=[0.8,0.22]


device,/close

;----------------------------------------------------------------------------------------------------------------------------;
device,file=figure_dir+'Dust_region_overlapping_Atype_annual_cycle.eps',/color,/inches,/encapsulated,xs=6,ys=6*3./4.,$
       set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

d1 = dust_region_ACA_overlapping_annual_cycle_smoke
d2 = dust_region_ACA_overlapping_annual_cycle_PD
d3 = dust_region_ACA_overlapping_annual_cycle_dust
d4 = dust_region_ACA_overlapping_annual_cycle_others
bar_plot,d1+d2+d3+d4, colors=make_array(12,/integer,value=0), xtitle = 'Month', ytitle='Overlapping Frequency',barnames=['1','2','3','4','5','6','7','8','9','10','11','12' ]
bar_plot,d1+d2+d3,    colors=make_array(12,/integer,value=50), /overplot
bar_plot,d1+d2,       colors=make_array(12,/integer,value=200), /overplot
bar_plot,d1,          colors=make_array(12,/integer,value=254), /overplot

legend,['Smoke','Polluted Dust','Dust','Others'],textcolors=[254,200,50,0],charsize=1.2,pos=[0.8,0.29]


device,/close

;----------------------------------------------------------------------------------------------------------------------------;


device,file=figure_dir+'Dust_Regional_aca_aot_'+AOT_scaling+'_and_bac_cot_'+day_or_night+'_annual_cycle.eps',/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       set_font='Times',/tt_font,font_size=16,bits_per_pixel=8
loadct,39,/silent
plot,IndGen(12)+1,IndGen(12)+1,/nodata,xrange=[1,12],yrange=[0.01,10],/ylog,xstyle=1,ystyle=8,xcharsize=1.5,ycharsize=1.5,xthick=2.0,ythick=2.0,$
     xticks = 11,ytitle='Below-Aerosol COT',xtitle='Month',ymargin=[5,2],xmargin=[9,8],xticklen=0.5,xgridstyle=3

oplot,IndGen(12)+1,dust_region_bac_cot_annual_cycle,  psym=-2,line=0,thick=3.0,color=0 ;52
oplot,IndGen(12)+1,smoke_region_bac_cot_annual_cycle, psym=-2,line=1,thick=3.0,color=0 ;254
legend,['NTA','SEA'],textcolor = [0,0],charsize=1.2,charthick=3.0,linestyle=[0,1],psym=-2,color=[0,0],thick=3.0,box=1,pos=[8.1,2.0];,/clear

;axis,yaxis=1,yrange=[0.05,1],ystyle=1,/ylog,charsize=1.5,ythick=2.0,ytitle='Above-Cloud AOT 532 nm',/save
oplot,IndGen(12)+1,dust_region_aca_dust_aod_annual_cycle,    psym=-1,line=0,thick=3.0,color=0
oplot,IndGen(12)+1,smoke_region_aca_smoke_aod_annual_cycle,  psym=-4,line=1,thick=3.0,color=254
oplot,IndGen(12)+1,smoke_region_aca_PD_aod_annual_cycle,     psym=-5,line=1,thick=3.0,color=254
oplot,IndGen(12)+1,smoke_region_aca_SmokePD_aod_annual_cycle,psym=-6,line=1,thick=3.0,color=254

legend,['COT','Dust AOT'],textcolor = [0,52],charsize=1.2,charthick=2.0,linestyle=0,psym=-2,color=[254,50],thick=3.0,box=1,pos=[1.1,9.8];,/clear

device,/close

;axis,yaxis=1,yrange=[0.05,1],ystyle=1,/ylog,charsize=1.5,ythick=2.0,ytitle='Above-Cloud AOT 532 nm',/save
;oplot,IndGen(12)+1,smoke_region_aca_smoke_aod_annual_cycle,  psym=-2,line=1,thick=3.0,color=254
;oplot,IndGen(12)+1,smoke_region_aca_PD_aod_annual_cycle,     psym=-2,line=2,thick=3.0,color=254
;oplot,IndGen(12)+1,smoke_region_aca_SmokePD_aod_annual_cycle,psym=-2,line=3,thick=3.0,color=254
;oplot,IndGen(12)+1,dust_region_aca_dust_aod_annual_cycle,    psym=-2,line=4,thick=3.0,color=52
;oplot,IndGen(12)+1,smoke_region_bac_cot_annual_cycle,psym=-2,line=0,thick=3.0,color=0 ;254

;legend,['Smoke Region Smoke AOT','Smoke Region PD AOT','Dust Region Dust AOT'],textcolor = [254,254,50],$
;        charsize=1.2,charthick=2.0,linestyle=[1,2,4],psym=-2,color=[254,254,52],thick=3.0,box=1,pos=[1.1,0.7];,/clear


;-------------------------------------------------------------------------------------------------------------------;

;================================= Plot annual mean and seasonal cloudy-sky toa srf, & atm DARE ========================================;

ocean_mask_grid = congrid(ocean_mask,360.0/grid_size_stat,180.0/grid_size_stat)

;-------------------------------------------------------------------------------------------------------------------;
minval = -3.0 & maxval =  3.0 &  divisions = 6
plot_name = figure_dir+'cloudy_sky_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(cloudy_dirunal_toa_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

minval = -6.0 & maxval =  0.0 &  divisions = 6
plot_name = figure_dir+'cloudy_sky_srf_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(cloudy_dirunal_srf_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

minval = 0.0 & maxval =  6.0 &  divisions = 6
plot_name = figure_dir+'cloudy_sky_atm_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(cloudy_dirunal_atm_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'


global_toa_dre = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                 total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE:',global_toa_dre 


;-------------------------------------------------------------------------------------------------------------------;

toa_minval = -5.0  &  toa_maxval =  5.0 &  toa_divisions = 10 
srf_minval = -10.0 &  srf_maxval =  0.0 &  srf_divisions = 10 
atm_minval =  0.0  &  atm_maxval = 10.0 &  atm_divisions = 10 


for iseason =0,3 do begin
for j =0,1 do begin
case iseason of 
    0: begin
      if j eq 0 then begin
        toa_data = cloudy_dirunal_toa_DJF
        srf_data = cloudy_dirunal_srf_DJF
        atm_data = cloudy_dirunal_atm_DJF
        header = 'cloudy_sky'
      endif else begin
        toa_data = aca_dirunal_toa_DJF
        srf_data = aca_dirunal_srf_DJF
        atm_data = aca_dirunal_atm_DJF
        header = 'aca'
      endelse	
      season_name = 'DJF'
      end
    1: begin
       if j eq 0 then begin
        toa_data = cloudy_dirunal_toa_MAM
        srf_data = cloudy_dirunal_srf_MAM
        atm_data = cloudy_dirunal_atm_MAM
        header = 'cloudy_sky'
      endif else begin
        toa_data = aca_dirunal_toa_MAM
        srf_data = aca_dirunal_srf_MAM
        atm_data = aca_dirunal_atm_MAM
        header = 'aca'
      endelse
      season_name = 'MAM'
      end
    2: begin
       if j eq 0 then begin
        toa_data = cloudy_dirunal_toa_JJA
        srf_data = cloudy_dirunal_srf_JJA
        atm_data = cloudy_dirunal_atm_JJA
        header = 'cloudy_sky'
      endif else begin
        toa_data = aca_dirunal_toa_JJA
        srf_data = aca_dirunal_srf_JJA
        atm_data = aca_dirunal_atm_JJA
        header = 'aca'
      endelse
      season_name = 'JJA'
      end
    3: begin
      if j eq 0 then begin
        toa_data = cloudy_dirunal_toa_SON
        srf_data = cloudy_dirunal_srf_SON
        atm_data = cloudy_dirunal_atm_SON
        header = 'cloudy_sky'
      endif else begin
        toa_data = aca_dirunal_toa_SON
        srf_data = aca_dirunal_srf_SON
        atm_data = aca_dirunal_atm_SON
        header = 'aca'
      endelse
      season_name = 'SON'
      end
endcase
;---- TOA ---;
print, ' plotting TOA',header
plot_name = figure_dir+header+'_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_'+season_name+'.eps'
plot_data = total(toa_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, toa_minval,toa_maxval, xrange,yrange,divisions=toa_divisions,format='(f5.1)'

;---- srf ---;
print, ' plotting srf',header
plot_name = figure_dir+header+'_srf_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_'+season_name+'.eps'
plot_data = total(srf_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, srf_minval,srf_maxval, xrange,yrange,divisions=srf_divisions,format='(f5.1)'

;---- atm ---;
print, ' plotting atm',header
plot_name = figure_dir+header+'_atm_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_'+season_name+'.eps'
plot_data = total(atm_data[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
forcing_plot_global, plot_name,plot_data, atm_minval,atm_maxval, xrange,yrange,divisions=atm_divisions,format='(f5.1)'

endfor
endfor
;-------------------------------------------------------------------------------------------------------------------;

;-------------------------------------------------------------------------------------------------------------------;

;================================= Plot annual mean and seasonal cloudy-sky toa DARE ========================================;

;===================Plot annual mean and seasonal toa DARE averaged only over ACA pixels =====================================;

minval = -20.0
maxval =  20.0
divisions = 8
ocean_mask_grid = congrid(ocean_mask,360.0/grid_size_stat,180.0/grid_size_stat)

;-------------------------------------------------------------------------------------------------------------------;
plot_name = figure_dir+'aca_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(aca_dirunal_toa_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears

global_toa_dre = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                 total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE:',global_toa_dre 
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;-------------------------------------------------------------------------------------------------------------------;
minval = -15.0
maxval =  15.0
divisions = 6 
plot_name = figure_dir+'aca_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_DJF.eps'
plot_data = total(aca_dirunal_toa_DJF[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
global_toa_dre_DJF = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                     total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE DJF:',global_toa_dre_DJF
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;-------------------------------------------------------------------------------------------------------------------;
plot_name = figure_dir+'aca_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_MAM.eps'
plot_data = total(aca_dirunal_toa_MAM[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
global_toa_dre_MAM = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                     total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE MAM:',global_toa_dre_MAM
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;-------------------------------------------------------------------------------------------------------------------;
plot_name = figure_dir+'aca_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_JJA.eps'
plot_data = total(aca_dirunal_toa_JJA[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
global_toa_dre_JJA = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                     total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE JJA:',global_toa_dre_JJA
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;-------------------------------------------------------------------------------------------------------------------;
plot_name = figure_dir+'aca_toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_SON.eps'
plot_data = total(aca_dirunal_toa_SON[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
global_toa_dre_SON = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                     total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE DJF:',global_toa_dre_DJF
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;-------------------------------------------------------------------------------------------------------------------;

;================================= Plot annual mean and seasonal cloudy-sky toa DARE ========================================;


plot_name = figure_dir+'cloudy_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(cloudy_dare_dirunal_toa_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
;global_cldy_toa_dre = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$


plot_name = figure_dir+'cloudy_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(cloudy_dare_dirunal_toa_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears
global_cldy_toa_dre = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                      total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global cldy TOA DRE:',global_cldy_toa_dre 
forcing_plot_global, plot_name,plot_Data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

minval = -10.0
maxval =  10.0
divisions = 5

plot_name = figure_dir+'toa_dare_efficiency_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_data = total(all_aca_dirunal_toa_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/ $
            total(all_aca_aod_532_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)

global_toa_dre_eff = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                 total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global TOA DRE_eff:',global_toa_dre_eff
forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'



minval = -6.0
maxval =  0.0
divisions = 6
plot_name = figure_dir+'srf_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_COT_'+cot_cor_flag+'_annual.eps'
plot_Data = total(all_aca_dirunal_srf_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],*],3,/nan)/nyears

global_srf_dre = total(plot_Data*ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])/$
                 total(ocean_mask_grid[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]])
print,'global srf DRE:',global_srf_dre 

forcing_plot_global, plot_name,plot_Data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'


minval = 0.0
maxval = 1.0
divisions = 5
plot_name = figure_dir+'cloud_fraction_annual.eps'
plot_cf_routine, plot_name,cloud_fraction_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

;---------------------------------------------------------------------------------------------------------;

smoke_region_maplatmin = -30.0
smoke_region_maplatmax =  10.0
smoke_region_maplonmin = -20.0
smoke_region_maplonmax =  20.0
smoke_region_lat_range = where(lat_grid_stat ge smoke_region_maplatmin and lat_grid_stat le smoke_region_maplatmax)
smoke_region_lon_range = where(lon_grid_stat ge smoke_region_maplonmin and lon_grid_stat le smoke_region_maplonmax)
nlat_range = n_elements(lat_range)
nlon_range = n_elements(lon_range)

xrange = [smoke_region_maplonmin,smoke_region_maplonmax]
yrange = [smoke_region_maplatmin,smoke_region_maplatmax]
minval = -3.0
maxval =  3.0
divisions = 6

om = ocean_mask_grid[smoke_region_lon_range[0]:smoke_region_lon_range[-1],smoke_region_lat_Range[0]:smoke_region_lat_range[-1]]
for iyear = 0 ,nyears-1 do begin
  plot_name = figure_dir+'toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_smoke_model_'+smoke_model+'_dust_model_'+dust_model+'_smoke_region_annual_yr'+string(iyear+1,format='(I1)')+'.eps'
  plot_data = all_aca_dirunal_toa_annual[smoke_region_lon_range[0]:smoke_region_lon_range[-1],smoke_region_lat_Range[0]:smoke_region_lat_range[-1],iyear]

  global_toa_dre = total(plot_Data*om)/ total(om)
  print,'year',iyear,'global TOA DRE:',global_toa_dre
  forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor 
;---------------------------------------------------------------------------------------------------------;
dust_region_maplatmin =  10.0
dust_region_maplatmax =  30.0
dust_region_maplonmin = -45.0
dust_region_maplonmax = -10.0
dust_region_lat_range = where(lat_grid_stat ge dust_region_maplatmin and lat_grid_stat le dust_region_maplatmax)
dust_region_lon_range = where(lon_grid_stat ge dust_region_maplonmin and lon_grid_stat le dust_region_maplonmax)
nlat_range = n_elements(lat_range)
nlon_range = n_elements(lon_range)

xrange = [dust_region_maplonmin,dust_region_maplonmax]
yrange = [dust_region_maplatmin,dust_region_maplatmax]
minval = -3.0
maxval =  3.0
divisions = 6

om = ocean_mask_grid[dust_region_lon_range[0]:dust_region_lon_range[-1],dust_region_lat_Range[0]:dust_region_lat_range[-1]]
for iyear = 0 ,nyears-1 do begin
  plot_name = figure_dir+'toa_dare_aot_'+aot_scaling+'_cot_'+aqua_or_terra+'_'+day_or_night+$
                        '_dust_model_'+dust_model+'_dust_model_'+dust_model+'_annual_dust_region_yr'+string(iyear+1,format='(I1)')+'.eps'
  plot_data = all_aca_dirunal_toa_annual[dust_region_lon_range[0]:dust_region_lon_range[-1],dust_region_lat_Range[0]:dust_region_lat_range[-1],iyear]

  global_toa_dre = total(plot_Data*om)/ total(om)
  print,'year',iyear,'global TOA DRE:',global_toa_dre
  forcing_plot_global, plot_name,plot_data, minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor


;----------------------------------------------------------------------------------;

stop
;-----------------------------------------------------------------------------------;
minval = 0.0
maxval = 0.6
divisions = 4
for ii=0,5 do begin
plot_name = figure_dir+'aca_overlaping_freq_annual_type'+string(ii,format='(I1)')+'.eps'
plot_cf_routine, plot_name,aca_annual_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

endfor

for ii=0,5 do begin
plot_name = figure_dir+'aca_overlaping_freq_DJF_type'+string(ii,format='(I1)')+'.eps'
plot_cf_routine, plot_name,aca_DJF_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

plot_name = figure_dir+'aca_overlaping_freq_MAM_type'+string(ii,format='(I1)')+'.eps'
plot_cf_routine, plot_name,aca_MAM_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

plot_name = figure_dir+'aca_overlaping_freq_JJA_type'+string(ii,format='(I1)')+'.eps'
plot_cf_routine, plot_name,aca_JJA_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

plot_name = figure_dir+'aca_overlaping_freq_SON_type'+string(ii,format='(I1)')+'.eps'
plot_cf_routine, plot_name,aca_SON_overlap[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar
endfor


;-----------------------------------------------------------------------------------;
minval = 0.0
maxval = 1.0
divisions = 4
plot_name = figure_dir+'all_aca_aod_532_mean_annual.eps'

plot_cf_routine, plot_name,all_aca_aod_532_mean_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                 minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar
for ii =0,5 do begin

	plot_name = figure_dir+'aca_aod_532_mean_annual_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_annual[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

	plot_name = figure_dir+'aca_aod_532_mean_DJF_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_DJF[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

	plot_name = figure_dir+'aca_aod_532_mean_MAM_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_MAM[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

	plot_name = figure_dir+'aca_aod_532_mean_JJA_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_JJA[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

	plot_name = figure_dir+'aca_aod_532_mean_SON_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_SON[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

        plot_name = figure_dir+'aca_aod_532_mean_annual_sc_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_annual_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

        plot_name = figure_dir+'aca_aod_532_mean_DJF_sc_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_DJF_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

        plot_name = figure_dir+'aca_aod_532_mean_MAM_sc_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_MAM_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

        plot_name = figure_dir+'aca_aod_532_mean_JJA_sc_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_JJA_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar

        plot_name = figure_dir+'aca_aod_532_mean_SON_sc_type'+string(ii,format='(I1)')+'.eps'
        plot_cf_routine, plot_name,aca_aod_532_mean_SON_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                         minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)',/plot_colorbar
endfor


minval = -3.0
maxval =  3.0
divisions = 6 
plot_name = figure_dir+'diurnal_aca_dare_toa_annual_mean_alltyp_aqua.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_alltype[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_annual_mean_alltyp_terra.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_alltype[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_annual_mean_alltyp_aqua_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_alltype_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_annual_mean_alltyp_terra_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_alltype_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'


plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_OPAC_dust.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_OPAC_dust[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_OPAC_dust.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_OPAC_dust[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_OPAC_dust_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_OPAC_dust_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_OPAC_dust_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_OPAC_dust_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_OBS_dust.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_OBS_dust[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_OBS_dust.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_OBS_dust[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_OBS_dust_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_OBS_dust_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_OBS_dust_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_OBS_dust_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'


plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_Haywood_smoke.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_Haywood_smoke[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_Haywood_smoke.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_Haywood_smoke[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_aqua_caliop_Haywood_smoke_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_caliop_Haywood_smoke_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_aca_dare_toa_mean_annual_terra_caliop_Haywood_smoke_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_caliop_Haywood_smoke_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir + 'diurnal_aca_dare_toa_mean_annual_aqua_OBS_Haywood.eps'
          forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_OBS_Haywood[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir + 'diurnal_aca_dare_toa_mean_annual_terra_OBS_Haywood.eps'
          forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_OBS_Haywood[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir + 'diurnal_aca_dare_toa_mean_annual_aqua_OBS_Haywood_sc.eps'
          forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_aqua_OBS_Haywood_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir + 'diurnal_aca_dare_toa_mean_annual_terra_OBS_Haywood_sc.eps'
          forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_annual_terra_OBS_Haywood_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'




for ii=0,5 do begin
        plot_name = figure_dir+'diurnal_aca_dare_toa_DJF_mean_type'+string(ii,format='(I1)')+'_aqua.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_DJF_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_MAM_mean_type'+string(ii,format='(I1)')+'_aqua.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_MAM_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_JJA_mean_type'+string(ii,format='(I1)')+'_aqua.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_JJA_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_SON_mean_type'+string(ii,format='(I1)')+'_aqua.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_SON_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor


for ii=0,5 do begin
        plot_name = figure_dir+'diurnal_aca_dare_toa_DJF_mean_type'+string(ii,format='(I1)')+'_aqua_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_DJF_aqua_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_MAM_mean_type'+string(ii,format='(I1)')+'_aqua_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_MAM_aqua_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_JJA_mean_type'+string(ii,format='(I1)')+'_aqua_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_JJA_aqua_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_SON_mean_type'+string(ii,format='(I1)')+'_aqua_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_SON_aqua_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor


minval = -3.0
maxval =  3.0
divisions =6  

for ii=0,5 do begin
        plot_name = figure_dir+'diurnal_aca_dare_toa_DJF_mean_type'+string(ii,format='(I1)')+'_terra.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_DJF_terra[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_MAM_mean_type'+string(ii,format='(I1)')+'_terra.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_MAM_terra[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_JJA_mean_type'+string(ii,format='(I1)')+'_terra.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_JJA_terra[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_SON_mean_type'+string(ii,format='(I1)')+'_terra.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_SON_terra[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor


for ii=0,5 do begin
        plot_name = figure_dir+'diurnal_aca_dare_toa_DJF_mean_type'+string(ii,format='(I1)')+'_terra_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_DJF_terra_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_MAM_mean_type'+string(ii,format='(I1)')+'_terra_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_MAM_terra_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_JJA_mean_type'+string(ii,format='(I1)')+'_terra_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_JJA_terra_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

        plot_name = figure_dir+'diurnal_aca_dare_toa_SON_mean_type'+string(ii,format='(I1)')+'_terra_sc.eps'
        forcing_plot_global, plot_name,diurnal_aca_dare_toa_mean_SON_terra_sc[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1],ii],$
                          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
endfor

plot_name = figure_dir+'diurnal_OPAC_dust_dare_toa_mean_annual_terra.eps'
forcing_plot_global, plot_name,diurnal_OPAC_dust_dare_toa_mean_annual_terra[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_OPAC_dust_dare_toa_mean_annual_aqua.eps'
forcing_plot_global, plot_name,diurnal_OPAC_dust_dare_toa_mean_annual_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_OBS_dust_dare_toa_mean_annual_aqua.eps'
forcing_plot_global, plot_name,diurnal_OBS_dust_dare_toa_mean_annual_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'

plot_name = figure_dir+'diurnal_OBS_dust_dare_toa_mean_annual_aqua.eps'
forcing_plot_global, plot_name,diurnal_OBS_dust_dare_toa_mean_annual_aqua[lon_range[0]:lon_range[-1],lat_Range[0]:lat_range[-1]],$
          minval,maxval, xrange,yrange,divisions=divisions,format='(f5.1)'
;stop
device,/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       file=figure_dir+'Smoke_and_PD_AOD_CALIOP_vs_Hu_vs_SC.eps',set_font='Times',/tt_font,font_size=16,bits_per_pixel=8
loadct,39,/silent

plot, aod_532_grid,float(aca_aod_532_hist_calipso[*,-1])/float(max(aca_aod_532_hist_calipso[*,-1])),psym=10,color=0,thick=5.0,xthick=5.0,ythick=5.0,line=0,$
      xtitle='AOT 532nm', ytitle = 'Relative frequency',xrange=[0.01,10],xstyle=1,/xlog

oplot, aod_532_grid,float(aca_aod_532_hist_hu[*,-1])/float(max(aca_aod_532_hist_hu[*,-1])),psym=10,color=50,thick=5.0,line=0
oplot, aod_532_grid,float(aca_aod_532_hist_sc[*,-1])/float(max(aca_aod_532_hist_sc[*,-1])),psym=10,color=254,thick=5.0,line=0

oplot, aod_532_grid,float(aca_aod_532_hist_calipso[*,-2])/float(max(aca_aod_532_hist_calipso[*,-2])),psym=10,color=0,thick=5.0,line=1
oplot, aod_532_grid,float(aca_aod_532_hist_hu[*,-2])/float(max(aca_aod_532_hist_hu[*,-2])),psym=10,color=50,thick=5.0,line=1
oplot, aod_532_grid,float(aca_aod_532_hist_sc[*,-2])/float(max(aca_aod_532_hist_sc[*,-2])),psym=10,color=254,thick=5.0,line=1

legend,['CALIOP operitional Alay','Hu Method S=19 [sr]','Simple Scaling'],line=0,color=[0,50,254],thick=5.0,textcolor=[0,50,254],pos=[0.6,0.8]

device,/close  


stop
end

pro read_MODIS_cloud_fraction, MODIS_cloud_fraction_file, MODIS_L3_lon, MODIS_L3_lat, $
                               aqua_MODIS_total_CF_monthly_2007to2012, terra_MODIS_total_CF_monthly_2007to2012, ocean_mask
                               ;terra_MODIS_total_CF_monthly_mean, terra_MODIS_total_CF_annual_mean ,$
                               ;terra_MODIS_total_CF_DJF_mean,terra_MODIS_total_CF_MAM_mean,terra_MODIS_total_CF_JJA_mean,terra_MODIS_total_CF_SON_mean,$ 
                               ;aqua_MODIS_total_CF_monthly_2007to2012, aqua_MODIS_total_CF_monthly_mean, aqua_MODIS_total_CF_annual_mean,$
                               ;aqua_MODIS_total_CF_DJF_mean,aqua_MODIS_total_CF_MAM_mean,aqua_MODIS_total_CF_JJA_mean,aqua_MODIS_total_CF_SON_mean,$

MODIS_cloud_fraction_file               = 'MODIS_Total_Cloud_Fraction.nc'
MODIS_L3_lat                            = read_ncdf(MODIS_cloud_fraction_file,'MODIS_L3_lat_grids')
MODIS_L3_lon                            = read_ncdf(MODIS_cloud_fraction_file,'MODIS_L3_lon_grids')

terra_MODIS_total_CF_monthly_2007to2012 = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_monthly_2007to2012')
terra_MODIS_total_CF_monthly_mean       = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_monthly_mean')
terra_MODIS_total_CF_annual_mean        = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_annual_mean')
terra_MODIS_total_CF_DJF_mean           = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_DJF_mean')
terra_MODIS_total_CF_MAM_mean           = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_MAM_mean')
terra_MODIS_total_CF_JJA_mean           = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_JJA_mean')
terra_MODIS_total_CF_SON_mean           = read_ncdf(MODIS_cloud_fraction_file,'terra_MODIS_total_CF_SON_mean')

aqua_MODIS_total_CF_monthly_2007to2012  = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_monthly_2007to2012')
aqua_MODIS_total_CF_monthly_mean        = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_monthly_mean')
aqua_MODIS_total_CF_annual_mean         = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_annual_mean')
aqua_MODIS_total_CF_DJF_mean            = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_DJF_mean')
aqua_MODIS_total_CF_MAM_mean            = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_MAM_mean')
aqua_MODIS_total_CF_JJA_mean            = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_JJA_mean')
aqua_MODIS_total_CF_SON_mean            = read_ncdf(MODIS_cloud_fraction_file,'aqua_MODIS_total_CF_SON_mean')
ocean_mask                              = read_ncdf(MODIS_cloud_fraction_file,'ocean_mask')

return
end


pro colorscale_calipso, LUTR, LUTG, LUTB,whitebackground = whitebackground

;*************************************************************************
; Name: colorscale_phase
;
; Purpose:
;   This routine sets up the colorscale to be used for byte scaling the data
;    and defines the colors to be used for black (255) and white (254).  The
;    data will be scaled, in some form, between 0 and 253, based upon the
;    min and max specified.
;   This color scheme provides two distinct scales.
;
; Inputs:
;  Environmental:
;   None.
;
;  Passed:
;   None.
;
; Outputs:
;  LUTR, LUTG, LUTB:    These are the color assignments form Red, Green, and Blue.
;
; Required Programs:
;  None.
;
; Modification history:
;  11/08/2001
;    Initial Release.
;
; Credits:
;  Written by Eric G. Moody.
;  eric.moody@gsfc.nasa.gov
;  Code 913 NASA/GSFC
;  Greenbelt, MD 20771
;
; License:
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software and to alter
; it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;*************************************************************************



;We will use linear fits to scale the colors,
; so, the basic equation is y = A + Bx
; with boundary conditions as:
;  y1 = A + B x1
;  y2 = A + B x2
;where B = (y2-y1)/(x2-x1)
; and  A = y1 - x1 B


;Create the arrays for the color scale:
LUTR=BYTARR(256)
LUTG=BYTARR(256)
LUTB=BYTARR(256)


;;;;;;;;;;;;;;;;;;
; RED
;;;;;;;;;;;;;;;;;;


;Ice will range between 0 and 126, the 
; colors will range between purple,blue,green
;First start with a light purple and fade to a
; dark purple.  Red will go from 185 to 100
; over 42 levels.
y1 = 185.
x1 = 0.
y2 = 100.
x2 = 42.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTR(INDEX) = A + B * float(INDEX)
end

;Next Fade the Red to zero, to create a deep blue,
;  and then go to pure blue (blue=255):
y1 = 100.
x1 = 42.
y2 = 0.
x2 = 84.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTR(INDEX) = A + B * float(INDEX)
end

;The final part of the ice range is green, so
; red = 0
LUTR(85:126)=0


;The Water will go yellow to pink to red, by first
; having r&g=255 and b=0, then bring blue up to 180,
; then bring g down to 0, creating pink, then bring
; b down to 0 to create red, then bring r down to
; 130 to create a dark red.
;Red will be 255 until the last bit, where we bring
; it down to create a dark red.
LUTR(127:230) = 255

y1 = 255.
x1 = 231.
y2 = 130.
x2 = 253.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
   LUTR(INDEX) = A + B * float(INDEX)
end


;;;;;;;;;;;;;;;;;;
; GREEN
;;;;;;;;;;;;;;;;;;
;For the ice scale, there isn't any green
; Until the last part, which goes from
;  a green of 150 to 255 over the last 3rd.
; The start of the color bar:
LUTG(0:84)=0

;Scale the green from 150 to 255:
y1 = 0.
x1 = 45.
y2 = 255.
x2 = 126.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTG(INDEX) = A + B * float(INDEX)
end


;For the water scale, green will be 255, until
; we create the pink, in the second third:
LUTG(127:169)=255

;Now Bring G down to 230 over 6 spots, to create very
; light orange:
y1 = 255.
x1 = 170.
y2 = 230.
x2 = 175.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTG(INDEX) = A + B * float(INDEX)
end

;Now bring G down to 133 over 176-211
y1 = 230.
x1 = 176.
y2 = 133.
x2 = 211.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTG(INDEX) = A + B * float(INDEX)
end

;Lastly bring G down to 0 from 212-230:
y1 = 133.
x1 = 212.
y2 = 0.
x2 = 230.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTG(INDEX) = A + B * float(INDEX)
end

;Green is 0 for the last stretch:
LUTG(231:253) = 0


;;;;;;;;;;;;;;;;;;
; BLUE
;;;;;;;;;;;;;;;;;;
;For the ice scale, the blue starts at 185 and drops
; to 145 over the first third, to create a deep purple,
; then moves up to 255 over the next third, and then
; fades to 0 for the last third to get green:
; Go from 185 to 145 for purple:
y1 = 185.
x1 = 0.
y2 = 145.
x2 = 42.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTB(INDEX) = A + B * float(INDEX)
end

;Then go up to all blue:
y1 = 145.
x1 = 42.
y2 = 255.
x2 = 84.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTB(INDEX) = A + B * float(INDEX)
end

;Then drop to zero:
y1 = 255.
x1 = 84.
y2 = 0.
x2 = 126.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTB(INDEX) = A + B * float(INDEX)
end


;For water, bring blue up to 180 over the first
; third to create light yellows, then keep at 180 over the next 6, to
; create the light orange, then drop to 0 from 176-211 to create the
; oranges, then end at 0 for the rest of the scale.
;Create the light yellows:
y1 = 0.
x1 = 127.
y2 = 180.
x2 = 169.
;x2 = 155.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTB(INDEX) = A + B * float(INDEX)
end

;Keep blue at 180 over the next 6:
LUTB(170:175) = 180

;Drop blue down to 0 over 176-211 to create oranges:
y1 = 180.
x1 = 176.
y2 = 0.
x2 = 211.
B  = (y2-y1) / (x2-x1)
A  = y1 - x1 * B
FOR INDEX = fix(x1), fix(x2) do begin
  LUTB(INDEX) = A + B * float(INDEX)
end

;Keep it at zero for the rest:
LUTB(211:253)=0

if keyword_set(whitebackground) then begin
   LUTR(0)=255
   LUTG(0)=255
   LUTB(0)=255
   LUTR(1)=200
   LUTG(1)=200
   LUTB(1)=200
   LUTR(255)  =0
   LUTG(255)  =0
   LUTB(255)  =0
endif else begin
   LUTR(0)=0
   LUTG(0)=0
   LUTB(0)=0
;   LUTR(252) = 50
;   LUTG(252) = 50
;   LUTB(252) = 50      ; dark gray
   LUTR(252) = 0
   LUTG(252) = 0
   LUTB(252) = 255	; blue
   LUTR(253) = 255
   LUTG(253) = 0
   LUTB(253) = 0       ; bright red
   LUTR(254) = 200
   LUTG(254) = 200
   LUTB(254) = 200     ; light gray
   LUTR(255) = 255
   LUTG(255) = 255
   LUTB(255) = 255     ; white
endelse

tvlct,LUTR,LUTG,LUTB


end

ME:
;   COLORBAR
;
; PURPOSE:
;       The purpose of this routine is to add a color bar to the current
;       graphics window.
;
; CATEGORY:
;       Graphics, Widgets.
;
; CALLING SEQUENCE:
;       COLORBAR
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;
;       BOTTOM:   The lowest color index of the colors to be loaded in
;                 the bar.
;
;       CHARSIZE: The character size of the color bar annotations. Default is 1.0.
;
;       COLOR:    The color index of the bar outline and characters. Default
;                 is !P.Color..
;
;       DIVISIONS: The number of divisions to divide the bar into. There will
;                 be (divisions + 1) annotations. The default is 6.
;
;       FONT:     Sets the font of the annotation. Hershey: -1, Hardware:0, True-Type: 1.
;
;       FORMAT:   The format of the bar annotations. Default is '(I5)'.
;
;      LOG_SCALE: Whether to plot as a linear or log scale. log/linear, 1/0.
;
;       MAXRANGE: The maximum data value for the bar annotation. Default is
;                 NCOLORS.
;
;       MINRANGE: The minimum data value for the bar annotation. Default is 0.
;
;       MINOR:    The number of minor tick divisions. Default is 2.
;
;       NCOLORS:  This is the number of colors in the color bar.
;
;       POSITION: A four-element array of normalized coordinates in the same
;                 form as the POSITION keyword on a plot. Default is
;                 [0.88, 0.15, 0.95, 0.95] for a vertical bar and
;                 [0.15, 0.88, 0.95, 0.95] for a horizontal bar.
;;
;       RANGE:    A two-element vector of the form [min, max]. Provides an
;                 alternative way of setting the MINRANGE and MAXRANGE keywords.
;
;       RIGHT:    This puts the labels on the right-hand side of a vertical
;                 color bar. It applies only to vertical color bars.
;
;       TITLE:    This is title for the color bar. The default is to have
;                 no title.
;
;       TOP:      This puts the labels on top of the bar rather than under it.
;                 The keyword only applies if a horizontal color bar is rendered.
;
;       VERTICAL: Setting this keyword give a vertical color bar. The default
;                 is a horizontal color bar.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       Color bar is drawn in the current graphics window.
;
; RESTRICTIONS:
;       The number of colors available on the display device (not the
;       PostScript device) is used unless the NCOLORS keyword is used.
;
; EXAMPLE:
;       To display a horizontal color bar above a contour plot, type:
;
;       LOADCT, 5, NCOLORS=100
;       CONTOUR, DIST(31,41), POSITION=[0.15, 0.15, 0.95, 0.75], $
;          C_COLORS=INDGEN(25)*4, NLEVELS=25
;       COLORBAR, NCOLORS=100, POSITION=[0.15, 0.85, 0.95, 0.90]
;
; MODIFICATION HISTORY:
;       Written by: David Fanning, 10 JUNE 96.
;       10/27/96: Added the ability to send output to PostScript. DWF
;       11/4/96: Substantially rewritten to go to screen or PostScript
;           file without having to know much about the PostScript device
;           or even what the current graphics device is. DWF
;       1/27/97: Added the RIGHT and TOP keywords. Also modified the
;            way the TITLE keyword works. DWF
;       7/15/97: Fixed a problem some machines have with plots that have
;            no valid data range in them. DWF
;       12/5/98: Fixed a problem in how the colorbar image is created that
;            seemed to tickle a bug in some versions of IDL. DWF.
;       1/12/99: Fixed a problem caused by RSI fixing a bug in IDL 5.2. Sigh... DWF.
;       3/30/99: Modified a few of the defaults. DWF.
;       3/30/99: Used NORMAL rather than DEVICE coords for positioning bar. DWF.
;       3/30/99: Added the RANGE keyword. DWF.
;       3/30/99: Added FONT keyword. DWF
;       5/6/99: Many modifications to defaults. DWF.
;       5/6/99: Removed PSCOLOR keyword. DWF.
;       5/6/99: Improved error handling on position coordinates. DWF.
;       5/6/99. Added MINOR keyword. DWF.
;       5/6/99: Set Device, Decomposed=0 if necessary. DWF.
;       2/9/99: Fixed a problem caused by setting BOTTOM keyword, but not NCOLORS. DWF.
;       8/17/99. Fixed a problem with ambiguous MIN and MINOR keywords. DWF
;       8/25/99. I think I *finally* got the BOTTOM/NCOLORS thing sorted out. :-( DWF.
;       10/10/99. Modified the program so that current plot and map coordinates are
;            saved and restored after the colorbar is drawn. DWF.
;    11/08/2001 Eric G Moody - Added Log Scale option.
;  eric.moody@gsfc.nasa.gov
;  Climate and Radiation Branch
;  NASA Goddard Space Flight Center
;  Greenbelt, Maryland, U.S.A.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


PRO COLORBAR_log_tau138, BOTTOM=bottom, CHARSIZE=charsize, COLOR=color, DIVISIONS=divisions, $
   FORMAT=format, POSITION=position, MAXRANGE=maxrange, MINRANGE=minrange, NCOLORS=ncolors, $
   TITLE=title, VERTICAL=vertical, TOP=top, RIGHT=right, MINOR=minor, $
   RANGE=range, FONT=font, TICKLEN=ticklen, _EXTRA=extra, LOG_SCALE=log_scale

   ; Return to main level on error.
On_Error,1

   ; Save the current plot state.

bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

   ; Is the PostScript device selected?

postScriptDevice = (!D.NAME EQ 'PS' OR !D.NAME EQ 'PRINTER')

   ; Which release of IDL is this?

thisRelease = Float(!Version.Release)

    ; Check and define keywords.

IF N_ELEMENTS(ncolors) EQ 0 THEN BEGIN

   ; Most display devices to not use the 256 colors available to
   ; the PostScript device. This presents a problem when writing
   ; general-purpose programs that can be output to the display or
   ; to the PostScript device. This problem is especially bothersome
   ; if you don't specify the number of colors you are using in the
   ; program. One way to work around this problem is to make the
   ; default number of colors the same for the display device and for
   ; the PostScript device. Then, the colors you see in PostScript are
   ; identical to the colors you see on your display. Here is one way to
   ; do it.

   IF postScriptDevice THEN BEGIN
      oldDevice = !D.NAME

         ; What kind of computer are we using? SET_PLOT to appropriate
         ; display device.

      thisOS = !VERSION.OS_FAMILY
      thisOS = STRMID(thisOS, 0, 3)
      thisOS = STRUPCASE(thisOS)
      CASE thisOS of
         'MAC': SET_PLOT, thisOS
         'WIN': SET_PLOT, thisOS
         ELSE: SET_PLOT, 'X'
      ENDCASE

         ; Here is how many colors we should use.

      ncolors = !D.TABLE_SIZE
      SET_PLOT, oldDevice
    ENDIF ELSE ncolors = !D.TABLE_SIZE
ENDIF
IF N_ELEMENTS(bottom) EQ 0 THEN bottom = 0B
IF N_ELEMENTS(charsize) EQ 0 THEN charsize = 1.0
IF N_ELEMENTS(format) EQ 0 THEN format = '(I5)'
IF N_ELEMENTS(color) EQ 0 THEN color = !P.Color
IF N_ELEMENTS(minrange) EQ 0 THEN minrange = 0
IF N_ELEMENTS(maxrange) EQ 0 THEN maxrange = ncolors
IF N_ELEMENTS(ticklen) EQ 0 THEN ticklen = 0.2
IF N_ELEMENTS(minor) EQ 0 THEN minor = 2
IF N_ELEMENTS(range) NE 0 THEN BEGIN
   minrange = range[0]
   maxrange = range[1]
ENDIF
IF N_ELEMENTS(divisions) EQ 0 THEN divisions = 6
IF N_ELEMENTS(font) EQ 0 THEN font = -1
IF N_ELEMENTS(title) EQ 0 THEN title = ''

IF KEYWORD_SET(vertical) THEN BEGIN
   bar = REPLICATE(1B,20) # BINDGEN(ncolors)
   IF N_ELEMENTS(position) EQ 0 THEN BEGIN
      position = [0.88, 0.1, 0.95, 0.9]
   ENDIF ELSE BEGIN
      IF position[2]-position[0] GT position[3]-position[1] THEN BEGIN
         position = [position[1], position[0], position[3], position[2]]
      ENDIF
      IF position[0] GE position[2] THEN Message, "Position coordinates can't be reconciled."
      IF position[1] GE position[3] THEN Message, "Position coordinates can't be reconciled."
   ENDELSE
ENDIF ELSE BEGIN
   bar = BINDGEN(ncolors) # REPLICATE(1B, 20)
   IF N_ELEMENTS(position) EQ 0 THEN BEGIN
      position = [0.1, 0.88, 0.9, 0.95]
   ENDIF ELSE BEGIN
      IF position[3]-position[1] GT position[2]-position[0] THEN BEGIN
         position = [position[1], position[0], position[3], position[2]]
      ENDIF
      IF position[0] GE position[2] THEN Message, "Position coordinates can't be reconciled."
      IF position[1] GE position[3] THEN Message, "Position coordinates can't be reconciled."
   ENDELSE
ENDELSE

   ; Scale the color bar.

 bar = BYTSCL(bar, TOP=(ncolors-1 < (255-bottom))) + bottom
   ; Get starting locations in NORMAL coordinates.

xstart = position(0)
ystart = position(1)

   ; Get the size of the bar in NORMAL coordinates.

xsize = (position(2) - position(0))
ysize = (position(3) - position(1))

   ; Display the color bar in the window. Sizing is
   ; different for PostScript and regular display.

IF postScriptDevice THEN BEGIN

   TV, bar, xstart, ystart, XSIZE=xsize, YSIZE=ysize, /Normal

ENDIF ELSE BEGIN

   bar = CONGRID(bar, CEIL(xsize*!D.X_VSize), CEIL(ysize*!D.Y_VSize), /INTERP)

        ; Decomposed color off if device supports it.

   CASE  StrUpCase(!D.NAME) OF
        'X': BEGIN
            IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
            Device, Decomposed=0
            ENDCASE
        'WIN': BEGIN
            IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
            Device, Decomposed=0
            ENDCASE
        'MAC': BEGIN
            IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
            Device, Decomposed=0
            ENDCASE
        ELSE:
   ENDCASE

   TV, bar, xstart, ystart, /Normal

ENDELSE

   ; Annotate the color bar.

IF KEYWORD_SET(vertical) THEN BEGIN

   IF KEYWORD_SET(right) THEN BEGIN
      IF keyword_set(log_scale) THEN BEGIN
;         print,'...log sclae'
         PLOT, [minrange,maxrange],[minrange,maxrange], /NODATA, /NOERASE,/YLOG, $
               position = position, CHARSIZE=charsize, FONT=font, COLOR=color, $
               XTICKS = 1, XSTYLE = 1, XTHICK = 3.0, XTICKFORMAT='(A1)',$
               YSTYLE = 1, YTHICK = 3.0, YTICKFORMAT='(A1)',YRANGE=[minrange,maxrange]

         AXIS, YAXIS=1, YRANGE=[minrange, maxrange], YTICKFORMAT=format, $
               YTICKLEN=ticklen, YSTYLE=1, YTHICK = 3.0, COLOR=color, CHARSIZE=charsize, $
               FONT=font, YTITLE=title, /YLOG

         ;If the upper limit is not 1,10,100, or 1000, then
         ; put the limit on the top of the plot:
         if ((maxrange ne 1.   ) and $
             (maxrange ne 10.  ) and $
             (maxrange ne 100. ) and $
             (maxrange ne 1000.)     $
                                     ) then begin
             st1 = STRCOMPRESS(string(maxrange,format='(F6.2)'),/REMOVE_ALL)
;             st2 = '>'+st1
             st2 = st1
             xyouts, position[0]+0.18,position[3]-0.01,st2,/NORMAL,charsize = charsize, charthick = 4
         endif

         ;If the lower limit is not 1,10,100, or 1000, then
         ; put the limit on the bottom of the plot:
         if ((minrange ne 1.   ) and $
             (minrange ne 10.  ) and $
             (minrange ne 100. ) and $
             (minrange ne 1000.)     $
                                     ) then begin
             st1 = STRCOMPRESS(string(minrange,format='(I6)'),/REMOVE_ALL)
;             st2 = '<'+st1
             st2 = st1
             xyouts, position[0]+0.18,position[1],st2,/NORMAL,charsize = charsize, charthick = 4
         endif

      ENDIF ELSE BEGIN

         PLOT, [minrange,maxrange], [minrange,maxrange], /NODATA, XTICKS=1, $
            YTICKS=divisions, XSTYLE=1, YSTYLE=9, $
            POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
            YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', $;YTICKLEN=ticklen , $
            YRANGE=[minrange, maxrange], FONT=font, _EXTRA=extra, YMINOR=minor

         AXIS, YAXIS=1, YRANGE=[minrange, maxrange], YTICKFORMAT=format, YTICKS=divisions, $
            YTICKLEN=ticklen, YSTYLE=1, COLOR=color, CHARSIZE=charsize, $
            FONT=font, YTITLE=title, _EXTRA=extra, YMINOR=minor

      ENDELSE

   ENDIF ELSE BEGIN

      PLOT, [minrange,maxrange], [minrange,maxrange], /NODATA, XTICKS=1, $
         YTICKS=divisions, XSTYLE=1, YSTYLE=9, YMINOR=minor, $
         POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
         YTICKFORMAT=format, XTICKFORMAT='(A1)', YTICKLEN=ticklen , $
         YRANGE=[minrange, maxrange], FONT=font, YTITLE=title, _EXTRA=extra

      AXIS, YAXIS=1, YRANGE=[minrange, maxrange], YTICKFORMAT='(A1)', YTICKS=divisions, $
         YTICKLEN=ticklen, YSTYLE=1, COLOR=color, CHARSIZE=charsize, $
         FONT=font, _EXTRA=extra, YMINOR=minor

   ENDELSE

ENDIF ELSE BEGIN

   IF KEYWORD_SET(top) THEN BEGIN

      PLOT, [minrange,maxrange], [minrange,maxrange], /NODATA, XTICKS=divisions, $
         YTICKS=1, XSTYLE=9, YSTYLE=1, $
         POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
         YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', XTICKLEN=ticklen, $
         XRANGE=[minrange, maxrange], FONT=font, _EXTRA=extra, XMINOR=minor

      AXIS, XTICKS=divisions, XSTYLE=1, COLOR=color, CHARSIZE=charsize, $
         XTICKFORMAT=format, XTICKLEN=ticklen, XRANGE=[minrange, maxrange], XAXIS=1, $
         FONT=font, XTITLE=title, _EXTRA=extra, XCHARSIZE=charsize, XMINOR=minor

   ENDIF ELSE BEGIN
   
      IF keyword_set(log_scale) THEN BEGIN
;         print,'...log scale'
         PLOT, [minrange,maxrange],[minrange,maxrange], /NODATA, /NOERASE,/XLOG, $
               position = position, CHARSIZE=charsize, COLOR=color, $
               TITLE=title, YTICKS = 1, XSTYLE = 1, YTHICK = 3.0, YTICKFORMAT='(A1)',$
               YSTYLE = 1, XTHICK = 3.0, XTICKFORMAT='(A1)',XRANGE=[minrange,maxrange]
         
         AXIS, XAXIS=0, XRANGE=[minrange, maxrange], XTICKFORMAT=format, XTICKS=divisions, $
            XTICKLEN=ticklen, XSTYLE=1, COLOR=color, CHARSIZE=1.5, $
            _EXTRA=extra, XMINOR=minor, /XLOG
       
       ENDIF ELSE BEGIN

         PLOT, [minrange,maxrange], [minrange,maxrange], /NODATA, $
               YTICKS=1, XSTYLE=1, YSTYLE=1, TITLE=title, $
               POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
               YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', $
               XTHICK=3.0,YTHICK=3.0,$
               XRANGE=[minrange, maxrange], XMinor=minor, _EXTRA=extra
       
         AXIS, XAXIS=0, XRANGE=[minrange, maxrange], XTICKFORMAT=format, XTICKS=divisions, $
            XTICKLEN=ticklen, XSTYLE=1, COLOR=color, CHARSIZE=1.5, $
            _EXTRA=extra, XMINOR=minor
       
       ENDELSE

    ENDELSE

ENDELSE

   ; Restore Decomposed state if necessary.

CASE StrUpCase(!D.NAME) OF
   'X': BEGIN
      IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
      ENDCASE
   'WIN': BEGIN
      IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
      ENDCASE
   'MAC': BEGIN
      IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
      ENDCASE
   ELSE:
ENDCASE

   ; Restore the previous plot and map system variables.

!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map

END

pro rf_statistics_plottv_global_freq,$
        plot_name,plot_arr,minval,maxval,xrange,yrange,$
	title,xtitle,ytitle,divisions,format,minor,tickname=tickname,$
	diff_plot=diff_plot,forcing_plot=forcing_plot,log_scale=log_scale

!p.font=1
set_plot,'ps'
device,/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       file=plot_name,set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

;loadct,39,/silent
colorscale_calipso,redindex,greenindex,blueindex,whitebackground=whitebackground
	
plot,[0.0,0.0],[0.0,0.0],position=[0.12,0.514,0.88,0.97],$
	xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,$
	xtitle=xtitle,ytitle=ytitle,$
	xthick=5.0,ythick=5.0,charsize=1.5;charthick=4.0
	
;tv,plot_arr,xrange(0),yrange(0),xsize=xrange(1)-xrange(0),$
;	ysize=yrange(1)-yrange(0),/data

map_set,/cylindrical,position=[0.12,0.514,0.88,0.97],$
	limit=[yrange(0),xrange(0),yrange(1),xrange(1)],$
	/noerase,/noborder

map_grid,glinestyle=1,glinethick=1.0,latdel=30,londel=30,color=0
map_continents,/hires,/continents,/countries,mlinethick=5.0,color=0,FILL_CONTINENTS=1
	
single_colorbar =  [0.2,0.28,0.8,0.30]
colorbar_log_tau138, divisions = divisions, $
		    maxrange = maxval, $
                    minrange = minval, $
                    title = title,    $
                    format = format,  $
                    font = 1,           $
                    charsize = 1.5,     $
	            color = cgCOLOR('black'),	$
		    ticklen = -0.5,	$
		    tickname = tickname,$
		    minor = minor,	$
                    position = single_colorbar, $
                    ncolors = 253 , bottom = 1B , $
                    /horizontal,/right

device,/close

end

pro plot_cf_routine,plot_name,data,minval,maxval,xrange,yrange,$
   plot_colorbar=plot_colorbar,divisions=divisions,format=format,xs=xs,ys=ys

if n_elements(divisions) lt 0 then divisions=10
if n_elements(format) lt 0 then format='(f5.2)'


s = size(data)
plot_arr = make_array(s[1],s[2],/BYTE,value=255)
w0 = where(finite(data))
plot_arr[w0] = bytscl(data[w0],min=minval,max=maxval,top=254)
w0 = where(data gt maxval,count)
if count gt 0 then plot_arr[w0] = 255
w0 = where(data lt minval or ~finite(data),count)
if count gt 0 then plot_arr[w0] = 0

set_plot,'ps'
!p.font = 1
loadct,39,/silent

if n_elements(xs) le 0 then xs = 8.5
if n_elements(ys) le 0 then xs = 8.5 * 0.75

device,/color,/inches,/encapsulated,xs=xs,ys=ys,$
       file=plot_name,set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

plot,[0.0,0.0],[0.0,0.0],position=[0.12,0.514,0.88,0.97],$
        xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,$
        xtitle=xtitle,ytitle=ytitle,$
        xthick=5.0,ythick=5.0,charsize=1.3,xticks=4,yticks=4;charthick=4.0

tv,plot_arr,xrange[0],yrange[0],xsize=xrange[1]-xrange[0],$
        ysize=yrange[1]-yrange[0],/data

map_set,/cylindrical,position=[0.12,0.514,0.88,0.97],$
        limit=[yrange[0],xrange[0],yrange[1],xrange[1]],$
        /noerase,/noborder

map_grid,glinestyle=1,glinethick=1.0,latdel=15,londel=15,color=0
loadct,0,/silent
map_continents,/hires,/continents,/countries,mlinethick=5.0,color=150,FILL_CONTINENTS=1
loadct,39,/silent

device,/close


if keyword_set(plot_colorbar) then begin
    device,/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       file=plot_name+'_colorbar.eps',set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

    colorbar,/vertical,range=[minval,maxval],ncolors=255,DIVISIONS=divisons,charsize=1.2,format=format,position=[0.91, 0.05, 0.95, 0.95],/right
    device,/close
endif
end

pro forcing_plot_global,plot_name,data,minval,maxval,xrange,yrange,$
	title=title,xtitle=xtitle,ytitle=ytitle,divisions=divisions,$
        format=format,minor=minor,tickname=tickname,$
	diff_plot=diff_plot,forcing_plot=forcing_plot,log_scale=log_scale
;----------------- first set up colors ---------------;
       amin = abs(minval-0.0)
        amax = abs(maxval-0.0)
        if amax ge amin then begin
                ncolors_max = 126
                ncolors_min = fix(126 * (amin/amax))
                top_color = 253
                bottom_color = 126 - ncolors_min
        endif else begin
                ncolors_min = 126
                ncolors_max = 126 * (amax/amin)
                top_color = 127 + ncolors_max
                bottom_color = 0
        endelse

        r = bytarr(256)
        g = bytarr(256)
        b = bytarr(256)

        loadct,1
        tvlct,r1,g1,b1,/get
        r_temp = congrid(r1(126:255),(256/2)-1)
        g_temp = congrid(g1(126:255),(256/2)-1)
        b_temp = congrid(b1(126:255),(256/2)-1)
        r(0:126) = r_temp
        g(0:126) = g_temp
        b(0:126) = b_temp

        loadct,3
        tvlct,r1,g1,b1,/get
        r_temp = congrid(r1(126:255),(256/2)-1)
        g_temp = congrid(g1(126:255),(256/2)-1)
        b_temp = congrid(b1(126:255),(256/2)-1)
        r(127:253) = reverse(r_temp)
        g(127:253) = reverse(g_temp)
        b(127:253) = reverse(b_temp)

        r(254) = 150    ; light gray
        g(254) = 150
        b(254) = 150

        r(255) = 0      ; black
        g(255) = 0
        b(255) = 0

        r(0:253) = congrid(r(bottom_color:top_color),254)
        g(0:253) = congrid(g(bottom_color:top_color),254)
        b(0:253) = congrid(b(bottom_color:top_color),254)

        tvlct,r,g,b

idxx = where(~finite(data),count)
plot_data = data
if count gt 0 then plot_data[idxx] = 0.0

s = size(plot_data)
plot_arr = make_array(s[1],s[2],/BYTE,value=254)
w0 = where(finite(plot_data))
plot_arr[w0] = bytscl(plot_data[w0],min=minval,max=maxval,top=253)
w0 = where(plot_data gt maxval,count)
if count gt 0 then plot_arr[w0] = 253
w0 = where(plot_data lt minval ,count)
if count gt 0 then plot_arr[w0] = 0


!p.font=1
set_plot,'ps'
device,/color,/inches,/encapsulated,xs=8.5,ys=8.5*3./4.,$
       file=plot_name,set_font='Times',/tt_font,font_size=16,bits_per_pixel=8

;colorscale_calipso,redindex,greenindex,blueindex,whitebackground=whitebackground
	
plot,[0.0,0.0],[0.0,0.0],position=[0.12,0.514,0.88,0.97],$
	xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,$
	xtitle=xtitle,ytitle=ytitle,$
	xthick=5.0,ythick=5.0,charsize=1.5,xticks=4,yticks=4,color=255
	
tv,plot_arr,xrange(0),yrange(0),xsize=xrange(1)-xrange(0),$
	ysize=yrange(1)-yrange(0),/data

map_set,/cylindrical,position=[0.12,0.514,0.88,0.97],$
	limit=[yrange(0),xrange(0),yrange(1),xrange(1)],$
	/noerase,/noborder

map_grid,glinestyle=1,glinethick=1.0,latdel=15,londel=15,color=255
map_continents,/hires,/continents,/countries,mlinethick=5.0,color=255,FILL_CONTINENTS=1
	
single_colorbar =  [0.2,0.38,0.8,0.40]
colorbar_log_tau138, divisions = divisions, $
		    maxrange = maxval, $
                    minrange = minval, $
                    title = title,    $
                    format = format,  $
                    font = 1,           $
                    charsize = 1.5,     $
	            color = cgCOLOR('black'),	$
		    ticklen = -0.5,	$
		    tickname = tickname,$
		    minor = minor,	$
                    position = single_colorbar, $
                    ncolors = 253 , bottom = 1B , $
                    /horizontal,/right

device,/close

end

