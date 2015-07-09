; $Id: ctm_examples.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $


pro ctm_examples



    ; Quick an dirty demonstration of new CTM_* routines

    ; mgs, 20 Aug 1998
    ; mgs, 22 Oct 1998: adapted for new use of CTM_GET_DATA
    ;                   some more comments
    ; mgs, 26 Oct 1998: attached a few more comments about extended 
    ;                   use of ctm_get_data at end
    ; mgs, 18 Nov 1998: added call to ctm_make_datainfo

    ; NOTE: Images will not be completely correctly displayed
    ; because in these examples no use is made of 
    ; grid information

    ; Also, the current version of the routines does not
    ; perform any unit conversion !


    ; set color table
    myct,27,sat=0.97,value=1.3,bottom=20

    ; ============================================================ 
    ; Load data from a user selected file and plot surface 
    ; concentrations (LEVEL 1 in DIAG 45) as image map
    ; Requires the "correct" category name for DIAG45 in
    ; diaginfo.dat
    ; ============================================================ 

print
print,'======   EXAMPLE   1   ================'
print,'Display Ox surface data...'
print

    DIAGN  = 45              ; diagnostic number. Could also be
                             ; a name, e.g. 'IJ-AVG-$'

    TRACER = 2               ; Ox

    filename = ''            ; filename must be initialized to 
                             ; force opening of a file when running
                             ; this program repeatedly!
                             ; If filename is UNDEFINED, CTM_GET_DATA
                             ; will use whatever data is available 
                             ; in the global FileInfo and DataInfo 
                             ; structures and only open a file on
                             ; first calling.


    CTM_GET_DATA,DataInfo,diagn,  $
                 file=filename,tracer=tracer,/FIRST
                             ; The user will be asked to select a file
                             ; with PICKFILE. Note that the file will not be
                             ; parsed again, and the data not re-read
                             ; if the same file is selected twice.
                             ;
                             ; /FIRST selects the first time value in
                             ; the file.
                             ;
                             ; DATAINFO will contain all records for OX
                             ; concentrations in that file.

    if (n_elements(DATAINFO) eq 0) then message,'Sorry: No data loaded.'

    print,strcompress(n_elements(DATAINFO)),  $ 
          ' records loaded from file ',filename
                             ; filename contains name of actually selected 
                             ; file

    data = *(DataInfo[0].data)
                             ; Retrieve data from first record 
                             ; (There should only be one anyhow because
                             ; we selected a specific tracer and the first
                             ; time step)
                             ; NOTE: This is a 3D data cube although
                             ; the diagnostic was saved in individual
                             ; levels (at least in ASCII files)

    srfdata = reform(data(*,*,0))    
                             ; extract surface data

    print,'Min and max: ',min(srfdata,max=m),m

    img = bytscl(srfdata,min=0.,max=m,top=!d.n_colors-20)+20
                             ; convert data to color image

    window,0
    tvimage,img,position=p,/keep_aspect
                             ; display data

    map_set,0,0,/noborder,/noerase,pos=p
                             ; prepare map

    map_continents,color=1   ; show continents
    map_grid,color=1         ; and grid lines

    xyouts,0.5,0.95,'Ox surface average (diag 45)',/norm,  $
           color=1,charsize=1.4,align=0.5


    ; ============================================================ 
    ; Now load 3D cube for a different tracer and display 
    ; zonal means  (Again: Grid information is *not* used
    ; in the display.
    ; ============================================================ 


print
print,'======   EXAMPLE   2   ================'
print,'Display zonal means for Ethane ...'
print

    TRACER = 21              ; Ethane

    CTM_GET_DATA,DataInfo,diagn,filename=filename,  $
                 tracer=tracer,/FIRST
                             ; Note that we pass filename as variable
                             ; which now contains a full qualifier.
                             ; Therefore, we won't be asked to pick a 
                             ; file again.
                             ; (If we reset filename to '' or anything
                             ; containing wildchards will we be asked
                             ; to select a file again) 
                             ; NOTE: When calling CTM_EXAMPLES the
                             ; first time, you can omit FILENAME
                             ; completely. It will then use the datainfo
                             ; records that were loaded before.

    if (n_elements(DATAINFO) eq 0) then message,'Sorry: No data loaded.'

    datb = *(DataInfo[0].data)
                             ; Retrieve 3D data from first record 

    zmeans = total(datb(*,*,*),1)/DataInfo[0].dim[0]
                             ; compute zonal means

    print,'Min and max: ',min(zmeans,max=m),m
help,datainfo,datb,zmeans
help,datainfo[0],/stru

    img = bytscl(zmeans,min=0.,max=m,top=!d.n_colors-20)+20

    window,1
    tvimage,img,position=p   ; display image


    xyouts,0.5,0.95,'Zonal means for Ethane',/norm,  $
           color=1,charsize=1.4,align=0.5


    ; ============================================================ 
    ; Now, let's compute the difference in ozone between the last
    ; and first time step of a simulation. NOTE: we will ask the
    ; user to pick a file again, and CTM_GET_DATA will only "see"
    ; the data from the newly selected file.
    ; ============================================================ 

print
print,'======   EXAMPLE   3   ================'
print,'Display Ox difference between 2 time steps ...'
print

    TRACER = 2               ; Ox again

    CTM_GET_DATA,DataInfo,diagn,  $
                 filename='',tracer=tracer, $
                 tau0=tau0
                             ; The (empty) string constant in the 
                             ; filename parameter ensures the
                             ; file selection.
                             ; Since no selection is made for tau
                             ; (tau0 is un-initialized)
                             ; we will return all time steps that were
                             ; recorded in that file

    if (n_elements(DATAINFO) eq 0) then message,'Sorry: No data loaded.'

    mintau = min(DataInfo.tau0,max=maxtau)
    first = where(DataInfo.tau0 eq mintau) 
    last  = where(DataInfo.tau0 eq maxtau) 
                             ; get index to index for first and
                             ; last time step
   
    if (first[0] eq last[0]) then print,'% First and last time step identical!'
 
    data = *(DataInfo[first].data)
    datb = *(DataInfo[last].data)
                             ; Retrieve 3D data

    diff = datb-data
                             ; compute difference. In a more general
                             ; application, we must first test the 
                             ; dimensions and grid compatibility

    slice = reform(diff[*,34,*])
                             ; extract a slice along a northern mid lat.
                             ; (4x5 models)

    mi = min(slice,max=m)
    print,'Min and max: ',mi,m

    absmax = abs(mi) > abs(m) 
                             ; compute scaling factor for image

    img = bytscl(slice,min=-absmax,max=absmax,  $
                 top=!d.n_colors-20)+20

    window,2
    tvimage,img,position=p   ; display image

    xyouts,0.5,0.95,'Ox difference last-first time step - latitudinal cut', $
           /norm,color=1,charsize=1.4,align=0.5



    ; ============================================================ 
    ; add difference as record in datainfo
    ; ============================================================ 

    dummy = ctm_make_datainfo(diff,diagn='Ox difference',tracer=2, $
             tau0=DataInfo[last].tau1,tau1=DataInfo[first].tau0, $
             unit='ppbv')


    ; ============================================================ 
    ; And here is an example for a GISS_II_PRIME file
    ; (including Prashnat's blanks for MATLAB)
    ; Let's display PORL-L=6, but note it's extracted from the
    ; 3D cube!
    ; ============================================================ 

print
print,'======   EXAMPLE   4   ================'
print,'Display Loretta''s production/loss diagnostics ...'
print

    DIAGN  = 'PORL-L=$'      ; Use category name

    TRACER = 2               ; whatever it is

    CTM_GET_DATA,DataInfo,diagn,  $
                 filename='~ppm/terra/Runs/ljmmod/ctm.pch',tracer=tracer
                             ; All tau values will be returned
                             ; Since the file is specified fully,
                             ; there will be no file selection

    if (n_elements(DATAINFO) eq 0) then message,'Sorry: No data loaded.'


    data = *(DataInfo[0].data)
                             ; Retrieve data from first record 
                             ; (see first example)

    levdata = reform(data(*,*,5))    
                             ; extract data for layer 6
                             ; NOTE: IDL always starts with 0 !!

    print,'Min and max: ',min(levdata,max=m),m

    img = bytscl(levdata,min=0.,max=m,top=!d.n_colors-20)+20
                             ; convert data to color image

    window,3
    tvimage,img,position=p,/keep_aspect
                             ; display data

    map_set,0,0,/noborder,/noerase,pos=p

    map_continents,color=1   ; show continents
    map_grid,color=1         ; and grid lines

    xyouts,0.5,0.95,'PORL-L=6 (diag 99, Loretta special)',/norm,  $
           color=1,charsize=1.4,align=0.5




    ; ============================================================ 
    ; Now let us summarize and check what is stored in memory
    ; ============================================================ 


@gamap_cmn.pro                   ; include global common block


    ; File information records
    FileInfo = *pGlobalFileInfo

    for i=0,n_elements(FileInfo)-1 do $
        print,FileInfo[i].ilun,FileInfo[i].filename,  $
              FileInfo[i].modelinfo.name,format='(I5,A45,A20)'

    print

    ; data information records
    DataInfo = *pGlobalDataInfo

    ; extract unique category names
    all_cat = DataInfo.category
    all_cat = all_cat( uniq(all_cat,sort(all_cat)) )
                             ; get a list of all categories

    print,'loaded data by category:'
    print,'  CATEGORY   TRACER     TAU0     TAU1   DIMENSIONS'

    for i=0,n_elements(all_cat)-1 do begin
       all_loaded = ctm_doselect_data(all_cat[i],DataInfo)

       if (all_loaded[0] ge 0) then $
          for j=0,n_elements(all_loaded)-1 do begin
             tmp = DataInfo[all_loaded[j]]
             print,tmp.category,tmp.tracer,tmp.tau0,tmp.tau1,tmp.dim, $
                   format='(A10,3I9,4I5)'
          endfor

    endfor


    return


    ; ================================================================ 
    ; EXTENDED USE OF CTM_GET_DATA
    ; (section added Oct 26, 1998)
    ; ================================================================ 

    ; Read data for tracer N for all diagnostics
    ; (use diagn=0 !)

    ctm_get_data,datainfo,diagn,file=filename,tracer=N  ; [tau0=...]


    ; Read data for SRF-AVRG and HZ$-AVRG in one step
    ; (NOTE that this will result in two datainfo records! The two
    ; diagnostics are not combined unless you rename SRF-AVRG to HZ1-AVRG!)

    ctm_get_data,datainfo,['SRF-AVRG','HZ$-AVRG'],file=filename,tracer=N


    ; Read all data for tracer 2 from 2nd file
    ; (logical units (usually) start with 20. Use help,/files to check!)

    ctm_get_data,datainfo,0,ilun=21,tracer=2


end

    




