;program to retrieve area fraction and fire temperature within MODIS fire pixels
;  the sub-pixel-based FRP is also calculated
;
;created by DAVE PETERSON
;date 9-27-2011, modifed from subpixel_no_overlap.pro
;
;
;INPUT FILES
;MODIS level-1B radiance
;MODIS geolocation
;MODIS fire product
;MODIS water vapor
;

;sub-routines called
@read_modis_level1B_routines.pro
;@getPixelCorners1.pro
@closest.pro
@dozier_calculation_fast.pro ;actual sub-pixel retrieval
;getHDFdata 
;getScannerOverlapIndices

;date/time functions
Function fileday, filename
 day = float( strmid(filename, 14, 3) )
 return, day
END

Function fileyear, filename
 year = float( strmid(filename, 10, 4) )
 return, year
END

Function filehour, filename
 hour = float( strmid(filename, 15, 2) )
 return, hour
END

Function filemin, filename
 min = float( strmid(filename, 17, 2) )
 return, min
END

;compute brightness temp function
Function compute_btemp, lmd, data
	     h=6.626068*10^(-34.)
	     k=1.38066*10^(-23.)
	     c=2.997925*10^(8.)
		
		k1=2.*h*c^2.*lmd^(-5.)
        	k2=(h*c)/(k*lmd) 
		k1=k1*10^(-6.)   	
		btemp=k2/alog((k1/data)+1)
return, btemp
END

;compute radiance function
Function compute_radiance, lmd, backt
	     h=6.626068*10^(-34.)
	     k=1.38066*10^(-23.)
	     c=2.997925*10^(8.)
	    		    
		rad=((2*h*c^2.*lmd^(-5.))/(exp((h*c)/(k*lmd*backt))-1))*10^(-6.)	

return, rad		
END

;----------------------------------
;INPUT directories

;level 1B radiance
rad_dir = '/media/disk-1/data/modis/ca/2003mod021km/day/'

;fire product
fire_dir = '/media/disk-1/data/modis/ca/2003mod14/'

;geolocation
geo_dir = '/media/disk-1/data/modis/ca/2003mod03/'

;water vapor
wv_dir='/media/disk-1/data/modis/ca/2003mod05/'

;OUTPUT directory
outdir='/home/bruce/program/idl/subpixel_pro/results/'

;----------------------------------
;READ all data sources, multiple files from multiple directories

;number of files
nf=20 ;this will change

;define filenames
rad_fname = strarr(nf)
fire_fname= strarr(nf)
geo_fname = strarr(nf)
wv_fname  = strarr(nf)

;get filenames
openr,1, rad_dir + 'filenames.txtnn'
readf,1,rad_fname
close,1

openr,1, fire_dir + 'filenames.txtnn'
readf,1, fire_fname
close,1

openr,1, geo_dir + 'filenames.txtnn'
readf,1, geo_fname
close,1

openr,1, wv_dir + 'filenames.txtnn'
readf,1, wv_fname
close,1

;another way to read files
    	;readcol, rad_dir + 'filenames.txt', rad_fname, format = 'A'
    	;nf=n_elements(rad_fname)
		
	;readcol, fire_dir + 'filenames.txt', fire_fname, format = 'A'
	
	;readcol, geo_dir + 'filenames.txt', geo_fname, format = 'A' 
	
	;readcol, wv_dir + 'filenames.txt', wv_fname, format = 'A' 
			
;go through each file	
for ff=0, nf-1 do begin	
               
;get MODIS GEOLOCATION DATA
	
	; read latitude
	SDSname = 'Latitude'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  fLat)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	; read longitude 
	SDSname = 'Longitude'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  fLon)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	;use as viewing zenith vzen
	;read modis03 geolocation data : sensor zenith
	SDSname = 'SensorZenith'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  VZA1)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	;read modis03 geolocation data: sensor azimuth
	SDSname = 'SensorAzimuth'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  VAZM1)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	;use as solar zenith sza
	;read modis03 geolocation data : solar zenith
	SDSname = 'SolarZenith'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  SZA1)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	;read modis03 geolocation data: solar azimuth
	SDSname = 'SolarAzimuth'
	readflag = read_dataset(geo_dir + geo_fname(ff), SDSname,  SAZM1)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	;INPUT GEOMETRIES conversions
	   szat=SZA1*.01
	   ;check for day vs night 	     
	   if mean(szat) gt 90 then begin
	   sza=(SZA1-SZA1)+999.
	   raz=(SAZM1-SAZM1)+0.
	   endif else begin
	   sza=SZA1*.01
	   raz=SAZM1*.01 
	   endelse 
	   vza=VZA1*.01	   	   

;get MODIS 1B Data	
    	;only get the channels needed for MODIS fire detection

	; read 1km radiance: 4um channel 23 
	bandname = '23'
	readflag = read_1km_data(rad_dir + rad_fname(ff), bandname,  IR4, /rad)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif

	; read 1km radiance: 3.96um channel 22 
	bandname = '22'
	readflag = read_1km_data(rad_dir + rad_fname(ff), bandname,  IR396, /rad)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif	
	
	; read 1km radiance: 11um channel 31 
	bandname = '31'
	readflag = read_1km_data(rad_dir + rad_fname(ff), bandname,  IR11, /rad)
	if readflag ne 0 then begin
	  print, 'read data wrong'
	  stop
	endif	

;get MODIS fire products
    	firemask=getHDFdata(fire_dir+fire_fname(ff), 'fire mask')
    	rcheck=where(firemask ge 7, count)
	
    ;CHECK FOR CASES WITH NO FIRE PIXELS...no output if there are no fire pixels
    if count gt 0 then begin			  
	FP_line_data = getHDFdata(fire_dir+fire_fname(ff), 'FP_line', /keepopen, id=fileID)
	FP_sample_data = getHDFdata(fileID, 'FP_sample')
	backt4 = getHDFdata(fileID, 'FP_MeanT21')
	backt11 = getHDFdata(fileID, 'FP_MeanT31')
	pixt4=getHDFdata(fileID, 'FP_T21')
	pixt11=getHDFdata(fileID, 'FP_T31')
	plat=getHDFdata(fileID, 'FP_latitude')
	plon=getHDFdata(fileID, 'FP_longitude')
	clouds = getHDFdata(fileID, attr='LandCloudPix')
	frp_raw = getHDFdata(fileID, 'FP_power', /close)
							
;get other info   	
	;dimensions
	result = size(flat)
	np = result(1)
	nl = result(2)
	
	;date/time of the modis scene
	year = string(fileyear(rad_fname(ff)), format = '(I4)')
    	hour = string(filehour(fire_fname(ff)), format = '(I2)')
	min  = string(filemin(fire_fname(ff)), format = '(I2)')
	jday  = string(fileday(rad_fname(ff)), format = '(I3)')	
	;convert Julian Day to get day and month  
	CALDAT, jday, month,day   
	;get total Julian date for output
    	jd=julday(month,day,year,hour,min,0)
	;regular date
	reg_date=string(jd,format='(C(CYI4.4,CMOI2.2,CDI2.2,CHI2.2,CMI2.2))')
		
;get water vapor
	twaterv = getHDFdata(wv_dir+wv_fname(ff), 'Water_Vapor_Infrared', /keepopen, id=fileID)
	wvunits = getHDFdata(fileID, 'Water_Vapor_Infrared',attribute='units')
    	sf = getHDFdata(fileID, 'Water_Vapor_Infrared',attribute='scale_factor')
	aoff = getHDFdata(fileID, 'Water_Vapor_Infrared',attribute='add_offset')
	ln=getHDFdata(fileID, 'Water_Vapor_Infrared',attribute='long_name', /close)	    
	    waterv5=(sf(0)*float(twaterv))+aoff(0)
	    waterv=float(congrid(waterv5,np, nl)) 		

;---------------------------------------------	
;MAJOR CALCULATIONS FOLLOW...

;GET pixel corners and correct for MODIS's overlap issues
    ;Much of the following is based off Luke Ellison's work at GSFC
    percentOverlap=50 ;using 50% overlap in this case
    	;get indices of the pixels that do not overlap based on (percentoverlap)			    
	indices = getScannerOverlapIndices(percentOverlap, /MODIS , /shift)
	
	dsize = size(flat, /dim)
	nx=dsize(0)
	ny=dsize(1)
	scanw=10
	nscan=ny/scanw
	nooverlap=intarr(nx, ny)
	
	;select the pixels that DO NOT overlap (=999 in new array)
	start=0
	for ns=0, nscan-1 do begin	
	for nl=0, scanw-1 do begin	
	    x0=indices(nl,0)
	    x1=indices(nl,1)	
	    nooverlap(x0:x1,start+nl)=999
	endfor
	start=start+10
	endfor
   	
	;get ALL MODIS pixel corners	
        modis_corners1 = getPixelCorners1(flon, flat,/modiscorrection,/edges,/flatten)
        index1=where(nooverlap eq 999)
       
        ;get MODIS pixel corners that DO NOT overlap
	modis_corners=modis_corners1(index1,*,*)
	
	;constrain data based on overlap		    
	nflat=flat(index1)
	nflon=flon(index1)
	nfiremask=firemask(index1)
	nsza=sza(index1)
	nraz=raz(index1)
	nvza=vza(index1)
	nir396=ir396(index1)		    
	nir11=ir11(index1)
	nwaterv=waterv(index1)		    			    
			    					    
       ;get number of MODIS fire pixels in region of interest (constrain data)
       result1=where(nfiremask ge 7,count)
       
       	print, 'fire product file: ',fire_fname(ff)
       	    
    	    ;Now ONLY fire pixels...
	    nfp=n_elements(result1)
	    print, 'number of fire pixels: ',nfp
	    fflat=nflat(result1)
	    fflon=nflon(result1)  	 
	    fsza=nsza(result1)
	    fraz=nraz(result1)
	    fvza=nvza(result1)
	    fmsk=nfiremask(result1)
	    fwaterv=nwaterv(result1)

    ;Prepare: loop for each MODIS fire pixel	
    ;------------------------------------------    
    ;we need only the MODIS fire pixel corners
	modis_fire_corners=fltarr(nfp,4,2)
	modis_fire_area=fltarr(nfp)
	xdist=fltarr(nfp)	
	ydist=fltarr(nfp)

	;define final arrays for fire temp and area fraction
	final_area_fract=fltarr(nfp)
	final_tfire=fltarr(nfp)

	;other new variables in output
	modis_backt4=fltarr(nfp)
	modis_backt11=fltarr(nfp)
	modis_pixt4=fltarr(nfp)
	modis_pixt11=fltarr(nfp)
	modis_frp=fltarr(nfp)
	true_frp=fltarr(nfp)	
	rad4b=fltarr(nfp)
	rad11b=fltarr(nfp)
	rad4pix=fltarr(nfp)
	rad11pix=fltarr(nfp)	
					    
    ;START pixel loop
    	time1 = systime()		 
	for i=0,nfp-1 do begin
	    modis_fire_corners(i,*,*)=modis_corners(result1(i),*,*)

;Integration get MODIS fire pixel area for comparison
	    ;----------------------------------------
		    ;x dimension
		    xpts=fltarr(4)
		    xpts(0:1)=modis_fire_corners(i,1,*)
		    xpts(2:3)=modis_fire_corners(i,2,*)
		    xdist(i)=MAP_2POINTS(xpts(0), xpts(1), xpts(2), xpts(3), /METERS)

		    ;y dimension
		    ypts=fltarr(4)
		    ypts(0:1)=modis_fire_corners(i,2,*)
		    ypts(2:3)=modis_fire_corners(i,3,*)
		    ydist(i)=MAP_2POINTS(ypts(0), ypts(1), ypts(2), ypts(3), /METERS)

		     modis_fire_area(i)=xdist(i)*ydist(i)		   
	   		        		    		    	    			    	    
		;--------------------------------------------	 
;MODIS BACK T  ;get background radiance from fire product background temp
		;need the closest 1b lat/lon to the fire product lat/lon			    		    
		fbt=closest(fflat(i),plat,value=val)

		modis_backt4(i)=backt4(fbt)
		modis_backt11(i)=backt11(fbt)

		modis_pixt4(i)=pixt4(fbt)
    	    	modis_pixt11(i)=pixt11(fbt)

    	    	modis_frp(i)=frp_raw(fbt)

		;convert background temps to radiances
		;Planck handout eqn
		lmd396=3.96*10^(-6.)
		rad4b(i)=compute_radiance(lmd396,modis_backt4(i))
		rad4pix(i) =compute_radiance(lmd396,modis_pixt4(i))

		lmd11=11*10^(-6.)
		rad11b(i)=compute_radiance(lmd11,modis_backt11(i))	
		rad11pix(i) =compute_radiance(lmd11,modis_pixt11(i))		
		
;DOZIER		;actual Dozier step
    	    	;------------------------------------------------
		;these calculations are performed in a separate routine
		; ERRORS have been noticed with the 11 um MODIS fire product data
		;   e.g. 11b > 11 mean
		if rad4b(i)gt rad4pix(i) then begin 
		   ;print, 'MODIS FIRE PRODUCT ERROR 4um'
			final_area_fract(i)=-99999
			final_tfire(i)=-99999			
		endif else if rad11b(i)gt rad11pix(i) then begin
		   ;print, 'MODIS FIRE PRODUCT ERROR 11um'	
			final_area_fract(i)=-99999
			final_tfire(i)=-99999				
		endif else begin
		;print, fsza(i), fvza(i), fraz(i)			   	
		 dozier=dozier_calculation_fast(fsza(i), fvza(i), fraz(i), rad4pix(i),$
		                                  rad11pix(i), rad4b(i),rad11b(i))
						  
			;get final area and temp data per fire pixel
			final_area_fract(i)=dozier(0)
			final_tfire(i)=dozier(1)
					
;sub-pixel FRP		;True FRP calculation based on the sigmaT^4 relationship
			;we are using per fire calculation...kaufman (1998) fig. 7 used per pixel
			;validation analysis method
			sigma=5.67*10^(-8.)
			fire_area=(modis_fire_area(i)*final_area_fract(i))
			;frp in units of W
			frp_valid=sigma*(final_tfire(i)^(4.)-modis_backt4(i)^(4.))*fire_area
			;convert to MW
			true_frp(i)=frp_valid/1000000.			
			    ;print,[ modis_frp(i), true_frp(i)]					
		endelse							
			;print, 'MODIS Pfract = ',final_area_fract(i), ' Sub-pix FRP = ',true_frp(i)   			
    	endfor;for fire pixels
	time2 = systime()
    	print, 'start time ', time1 , ' end time ', time2
	print, ' ' 
	print, ' ' 
    				
		;get real area in m2 for plots
		rarea_modis= modis_fire_area*final_area_fract	
		
		;calculate FRP flux
	    	frp_flux=(true_frp*1000000)/(rarea_modis)		
HELP, nx, ny, jd, reg_date, nfp, fflat, fflon, modis_fire_corners, modis_fire_area, $
      final_area_fract, rarea_modis, final_tfire, true_frp, modis_frp,      $
      frp_flux, modis_backt4, modis_backt11, modis_pixt4, modis_pixt11,     $
      fvza, fsza, fraz, fmsk, firemask, flat, flon, fwaterv
;------------------------------------------------------------------------------
;SAVE THE OUTPUT AS IDL STRUCTURE
;Now create a structure to hold the full output
    	    spdata=create_struct('jd',jd, $; julian date
				'date',reg_date, $; regular date 
                                'nfp',nfp, $; number of fire pixels				
                                'flat',fflat, $ ;lat
                                'flon',fflon, $; lon
				'fire_corners',modis_fire_corners, $;corners of the fire pixels (lat/lon)    
                                'pix_area',modis_fire_area, $;area of the fire pixel (m2)
                                'fire_afrac',final_area_fract, $; area fraction
                                'fire_area',rarea_modis, $; true fire area (m2) 
                                'fire_temp',final_tfire, $; fire temperature (K)
                                'frp_fire',true_frp, $; sub-pixel FRP (MW)
                                'frp_modis',modis_frp, $; modis FRP (MW)
                                'frp_flux',frp_flux, $; sub-pixel FRP/fire area (Wm-2)
                                'tb4',modis_backt4, $; 4um background temp (K)
                                'tb11', modis_backt11, $,; 11um background temp (K)
				'pixt4',modis_pixt4, $; 4um pixel temp (K)
                                'pixt11', modis_pixt11, $,; 11um pixel temp (K)
				'vza', fvza, $, ;viewing zenith angle
				'sza', fsza, $, ;solar zenith angle
				'raz', fraz, $, ;relative azimuth angle
				'confidence', fmsk, $, ;fire mask confidence
				'totalmsk', firemask, $, ;np/nl total fire mask of the scene
				'tlat',flat,$, ;lats for the entire scene
				'tlon',flon,$, ;lons for the entire scene
                                'waterv',fwaterv); MODIS total precipitable water vapor (cm)
;OUTPUT
;save structure as an idl.dat file	
outfile=string(outdir,reg_date,format='(a,"/subpixel_",a,".idldat")')
save,spdata, filename=outfile

endif else begin
print, 'NO FIRE PIXELS!!!'
endelse
endfor; for files
end
