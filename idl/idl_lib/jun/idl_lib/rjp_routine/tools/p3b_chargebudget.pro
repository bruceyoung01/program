; $Id: p3b_chargebudget.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $


pro p3b_chargebudget,data,vardesc,  $
       lonrange=lonrange,latrange=latrange,altrange=altrange, $
       o3range=o3range,  $
       sortlon=sortlon,sortlat=sortlat,sortalt=sortalt, $
       sortrh=sortrh,sortc2h2=sortc2h2



    if (n_elements(lonrange) ne 2) then lonrange = [-180.,360.]
    if (n_elements(latrange) ne 2) then latrange = [-90.,90.]
    if (n_elements(altrange) ne 2) then altrange = [0.,80.]
    if (n_elements(o3range) ne 2) then o3range = [0.,10000.]

    ; assume merged aerosol files exist in ~/tmp/aero_d$$.bdt
    ; (if not use gte_mergeaero attached below)

    path = '~/tmp/'

    ; read first flight
    fname = path + 'aero_p' + string(4,format='(i2.2)') + '.bdt'
    gte_readbin,fname,data,vardesc,filedesc

    ; read all others and merge them
    !QUIET = 1
    for i=5,21 do begin
        fname = path + 'aero_p' + string(i,format='(i2.2)') + '.bdt'
        gte_readbin,fname,tmpdata,tmpdesc,/NO_PICKFILE

        if (n_elements(tmpdata) lt 2) then goto,nextone

        ; We *know* that variables are identical ! Let's just check
        ; the number of variables for safety
        if (n_elements(vardesc) ne n_elements(tmpdesc)) then begin
            message,'FLIGHT '+strtrim(i,2)+  $
                    ': Number of variables does not agree!'  
        endif

        ; Add observations to data
        data = [ data, tmpdata ]
nextone:
    endfor
    !QUIET = 0


    ; Extract lon, lat, and alt variables and select data range
    selind = make_selection(vardesc.name,['LON','LAT','ALTP'],/REQUIRED)
    lon = data[*,selind[0]]
    lat = data[*,selind[1]]
    alt = data[*,selind[2]]
;   o3  = data[*,selind[3]]

    ind = where(lon ge lonrange[0] AND lon le lonrange[1] AND $
                lat ge latrange[0] AND lat le latrange[1] AND $
                alt ge altrange[0] AND alt le altrange[1] )
    if (ind[0] lt 0) then begin
       message,'No data in selected region!',/CONT
       return
    endif
                

    data = data[ind,*]
    lon = lon[ind]
    lat = lat[ind]
    alt = alt[ind]

    rh = data[*,where(vardesc.name eq 'RHI')]
    c2h2 = data[*,where(vardesc.name eq 'Ethyne')]
    flight = data[*,where(vardesc.name eq 'FLIGHT')]


    ; Select aerosol species
    species = [ 'SO4', 'HNO3 vapor', 'Total NO3', 'Na', 'NH4' ]

    charges = [ -2.,  0., -1., +1., +1. ]


    selind = make_selection(vardesc.name,species)
    test = where(selind lt 0)
    if (test[0] ge 0) then begin
       print,species[test]
       stop
    endif

    ; Compute statistics (valid N) first
    ntotal = n_elements(data[*,0])
    tsel = selind



    ; Compute charge balance and add to data set
    ; Minimum: assume LLOD = 0 or MISS = 0
    ; Maximum: assume LLOD = LLOD
    ; negative charges
    minneg = 0.*data[*,0]
    maxneg = 0.*data[*,0]
    for i=0,2 do begin
       spec1 = data[*,selind[i]]
       spec2 = spec1
       test = where(spec1 le vardesc[i].llodcode)
       if (test[0] ge 0) then begin
           spec1[test] = 0.
       endif
       test = where(abs(spec2-vardesc[i].llodcode) lt 1.0E-3)
       if (test[0] ge 0) then begin
           spec2[test] = data[test,selind[i]+1]  ; LOD stored in next column
       endif
       minneg = minneg + abs(charges[i])*spec1
       maxneg = maxneg + abs(charges[i])*spec2
    endfor

    ; positive charges
    minpos = 0.*data[*,0]
    maxpos = 0.*data[*,0]
    for i=3,4 do begin
       spec1 = data[*,selind[i]]
       spec2 = spec1
       test = where(spec1 le vardesc[i].llodcode)
       if (test[0] ge 0) then begin
           spec1[test] = 0.
       endif
       test = where(abs(spec2-vardesc[i].llodcode) lt 1.0E-3)
       if (test[0] ge 0) then begin
           spec2[test] = data[test,selind[i]+1]  ; LOD storeed in next column
       endif
       minpos = minpos + charges[i]*spec1
       maxpos = maxpos + charges[i]*spec2
    endfor


    ; add to data
    tmpdesc = gte_vardesc()
    tmpdesc.name = 'minNEG'
    gte_insertvar,data,vardesc,minneg,tmpdesc
    tmpdesc.name = 'maxNEG'
    gte_insertvar,data,vardesc,maxneg,tmpdesc
    tmpdesc.name = 'minPOS'
    gte_insertvar,data,vardesc,minpos,tmpdesc
    tmpdesc.name = 'maxPOS'
    gte_insertvar,data,vardesc,maxpos,tmpdesc


    ; Save complete aerosol data
    gte_writebin,'~/tmp/aerosol_p3b.bdt',data,vardesc, $
          experiment_name='PEM-Tropics',  $
          revision_date=strdate(/SHORT)


    ; Sort data for output
    sortind = lindgen(ntotal)   ; default: do not sort data
    if (keyword_set(SORTLON)) then sortind = sort(lon)
    if (keyword_set(SORTLAT)) then sortind = sort(lat)
    if (keyword_set(SORTALT)) then sortind = sort(alt)
    if (keyword_set(SORTC2H2)) then sortind = sort(c2h2)
    if (keyword_set(SORTRH)) then sortind = sort(rh)

    data = data[sortind,*]


    ; Print all samples
    selection = [ 'FLIGHT', 'LON', 'LAT', 'ALTP', $
               'RHW', 'RHI', 'Ethyne', 'CH3I', species, $
               'minNEG', 'maxNEG', 'minPOS', 'maxPOS' ]

    title = [ 'FLIGHT', 'LON', 'LAT', 'ALTP', $
               'RHW', 'RHI', 'C2H2', 'CH3I',  $
               species,  $
               'minNEG', 'maxNEG', 'minPOS', 'maxPOS' ]

    selind = make_selection(vardesc.name,selection)

    ; Get maxima for each column
    maxval = fltarr(n_elements(selection))
    for i=0,n_elements(selection)-1 do $
       maxval[i] = max(data[*,selind[i]])

    open_file,'~/tmp/*result',olun,width=300,/WRITE
    if (olun le 0) then return

    printf,olun,'AEROSOL COMPOSITION DATA   PEM-TROPICS A'
    printf,olun,lonrange,latrange,altrange, $
      format='("LONRANGE:",2f10.2,"  LATRANGE:",2f10.2,"  ALTRANGE:",2f10.2)'
    printf,olun

    printf,olun,'I',title,format='(A4," :",A,A6,2A8,18A7)'
    for i=0,ntotal-1 do begin
        ress = string(i+1,data[i,selind[0:3]],format='(I4," :",I4,3F8.2)' )
        for j=4,16 do begin
            if (maxval[j] lt 10.) then format='(f7.2)' else format='(f7.1)'
            tmps = string(data[i,selind[j]],format=format)
            if (data[i,selind[j]] lt -1.00E30) then tmps = '    ---'
            if (data[i,selind[j]] eq -8.88E30) then tmps = '    ...'
            ress = ress + tmps
        endfor
        printf,olun,ress
    endfor

    printf,olun

    printf,olun,'TOTAL = ',strtrim(ntotal,2)
    printf,olun
    printf,olun,'    NAME                     N_MISS    N_LLOD'
    for i=0,n_elements(species)-1 do begin
        spec = data[*,tsel[i]]
        test = where(abs(spec-vardesc[i].miss) lt 1.0E-3,nmiss)
        test = where(abs(spec-vardesc[i].llodcode) lt 1.0E-3,nllod)
        printf,olun,species[i],nmiss,nllod,format='(A,T25,2I10)'
    endfor

    free_lun,olun
 
    return
end





pro p3b_mergeaero,flight


    if (n_elements(flight) eq 0) then flight = 11

    path = '/data/pem-t/p3b/binary/'
    outpath = '~/tmp/'

    ; read aerosol data
    aname = path + 'hunitp' + string(flight,format='(i2.2)') + '.bdt'
    gte_readbin,aname,adata,adesc,afiledesc


    ; read project data and compute relative humidity
    poname = path + 'po_01p' + string(flight,format='(i2.2)') + '.bdt'
    gte_readbin,poname,pdata,pdesc

 ;  message,'Calculating relative humidity ...',/INFO,/NONAME
 ;  gte_calcrh,pdata,pdesc


    ; link temperature, pressure, and relative humidity with aerosol
    ; data
    selind = make_selection(pdesc.name, $
                 ['TSDEGC', 'PSMB', 'RHW', 'RHI' ],/REQUIRED)
    if (selind[0] lt 0) then begin
       message,'Could not find temperature, pressure, or rel. humidity!', $
           /CONT
       stop   ; return
    endif
    ; rename temperature (because it's no longer degC)
    pdesc[selind[0]].name = 'TS'
    ; add time variables
    selind = [ 0 , 1, 2, 3, selind ]

    message,'Merging data ...',/INFO,/NONAME
    gte_link,adata,adesc,pdata[*,selind],pdesc[selind]

    message,'Reading NMHC data ...',/INFO,/NONAME


    ; read hydrocarbons
    hname = path + 'ucgc_p' + string(flight,format='(i2.2)') + '.bdt'
    gte_readbin,hname,hdata,hdesc

    ; create dummy if file not found
    species = ['Ethyne', 'CH3I' ]
    if (n_elements(hdata) lt 2) then begin
        dummy = fltarr(n_elements(adata[*,0])) -9.99E30
        dummydesc = gte_vardesc()
        for i=0,n_elements(species)-1 do begin
            dummydesc.name = species[i]
            gte_insertvar,adata,adesc,dummy,dummydesc
        endfor
        goto,add_flight
    endif


    ; link acetylene and methyl iodide with aerosol
    selind = make_selection(hdesc.name, species,/REQUIRED )
    if (selind[0] lt 0) then begin
       message,'Could not find acetylene or methyl iodide!', $
           /CONT
       stop   ; return
    endif
    ; add time variables
    selind = [ 0 , 1, 2, 3, selind ]

    gte_link,adata,adesc,hdata[*,selind],hdesc[selind]

add_flight:
    ; add FLIGHT variable
    vardesc = gte_vardesc()
    vardesc.name = 'FLIGHT'
    fdata = 0.*adata[*,0] + afiledesc.experiment_number
   
    gte_insertvar,adata,adesc,fdata,vardesc,4 
 
    ; write combined file to tmp directory
    tmpname = outpath + 'aero_p' + string(flight,format='(i2.2)') + '.bdt'
    gte_writebin,tmpname,adata,adesc,  $
          experiment_name=afiledesc.experiment_name,  $
          experiment_date=afiledesc.experiment_date,  $
          experiment_number=afiledesc.experiment_number,  $
          revision_date=afiledesc.revision_date

    return
end




pro p3b_mergeaero2,flight


    if (n_elements(flight) eq 0) then flight = 11

    path0 = '~/tmp/'
    path = '/data/pem-t/p3b/binary/'
    outpath = '~/tmp/'

    ; read aerosol composition data
    aname = path0 + 'aero_p' + string(flight,format='(i2.2)') + '.bdt'
    gte_readbin,aname,adata,adesc,afiledesc

    ; check if CNC data already contained
;   species = ['Ultra-Fine Aerosol', $
;                 'Fine-Aerosol (unheated)', $
;                 'Fine-Aerosol (heated 250 C)', $
;                 'Ratio HEATED to UNHEATED Fine-Aerosol' ]

    ; check if Talbot's acids are already in data
;   species = ['HNO3', $
;                 'HCOOH', $
;                 'CH3COOH' ]

    ; check if Blake's NMHC are already in data
;   species = [ 'Ethyne', 'CH3I' ]

    ; check if Bandy's SO2 is already in data
    species = [ 'SO2' ]

    selind = make_selection(adesc.name,species,/REQUIRED,/QUIET)
    if (selind[0] ge 0) then begin
       message,'New variables already in data set.',/INFO
;      return
; overwrite
  gte_delvar,adata,adesc,selind
    endif


    ; read Anderson's CNCs
;   poname = path + 'abcncp' + string(flight,format='(i2.2)') + '.bdt'
;   gte_readbin,poname,pdata,pdesc

    ; read Talbot's acids
;   poname = path + 'nhatgp' + string(flight,format='(i2.2)') + '.bdt'
;   gte_readbin,poname,pdata,pdesc

    ; read Blake's NMHC
;   poname = path + 'ucgc_p' + string(flight,format='(i2.2)') + '.bdt'
;   gte_readbin,poname,pdata,pdesc

    ; read Bandy's SO2
    poname = path + 'dusu1p' + string(flight,format='(i2.2)') + '.bdt'
    gte_readbin,poname,pdata,pdesc

    ; create dummy if file not found
    if (n_elements(pdata) lt 2) then begin
        dummy = fltarr(n_elements(adata[*,0])) -9.99E30
        dummydesc = gte_vardesc()
        for i=0,n_elements(species)-1 do begin
            dummydesc.name = species[i]
            gte_insertvar,adata,adesc,dummy,dummydesc
        endfor
        goto,write_it
    endif


    ; link with aerosol composition data
if (flight eq 3) then print,pdesc.name

    selind = make_selection(pdesc.name,species,/REQUIRED)
    if (selind[0] lt 0) then begin
       message,'Could not find variable!', $
           /CONT
       stop   ; return
    endif
    ; add time variables
    selind = [ 0 , 1, 2, 3, selind ]

    message,'Merging data ...',/INFO,/NONAME
    gte_link,adata,adesc,pdata[*,selind],pdesc[selind]

write_it: 
    ; write combined file to tmp directory - overwrite old files
    tmpname = outpath + 'aero_p' + string(flight,format='(i2.2)') + '.bdt'
    gte_writebin,tmpname,adata,adesc,  $
          experiment_name=afiledesc.experiment_name,  $
          experiment_date=afiledesc.experiment_date,  $
          experiment_number=afiledesc.experiment_number,  $
          revision_date=afiledesc.revision_date


    return
end

