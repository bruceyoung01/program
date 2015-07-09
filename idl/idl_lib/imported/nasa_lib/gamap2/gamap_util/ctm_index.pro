; $Id: ctm_index.pro,v 1.1.1.1 2007/07/17 20:41:27 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_INDEX
;
; PURPOSE:
;        Return index of CTM grid boxes for given coordinates
;        (or vice versa) and allow user to interactively select
;        a grid box
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Models & Grids
;
; CALLING SEQUENCE:
;        CTM_INDEX, <minfo | ginfo > [,i,j] [,keywords]
;
; INPUTS:
;        MINFO --> Model type strucure as returned by CTM_TYPE.PRO
;     or GINFO --> Model grid structure as returned by CTM_GRID.PRO
;            If neither is given, the user will be prompted for a model 
;            type and the grid will be computed.
;
;        I, J --> index pair for which lon, lat coordinates shall
;            be found if keyword /GET_COORDINATES is set. Also used 
;            to return index values for given lon, lat pairs (this is 
;            the default operation).  NOTE: I and J will be in "FORTRAN"  
;            notation (e.g. the starting from 1 and not zero). To index
;            IDL arrays, be sure to use I-1 and J-1. 
;
; KEYWORD PARAMETERS:
;        CENTER --> a two element vector with (LAT, LON) coordinates
;            for which the gridbox index shall be returned. Also used
;            to return center coordinates for a given index pair if
;            keyword /GET_COORDINATES is set.
;
;        EDGE --> a four element vector in the MAP_SET LIMIT format
;            (LAT0, LON0, LAT1, LON1). If keyword GET_COORDINATES is
;            not set and no CENTER coordinates are given, I and J will 
;            return two element vectors with I(0) corresponding to LON0 
;            and I(1) corresponding to LON1 etc. In this case, it may
;            be useful to retrieve WE_INDEX and SN_INDEX for indexing
;            of CTM data arrays (note that these indices follow the IDL
;            convention, i.e. starting from 0. To convert them into "true"
;            CTM indices, add 1).
;            If CENTER coordinates are provided or /GET_COORDINATES is set 
;            then EDGE returns the grid box edges for the given or calculated 
;            index pair.
;
;        WE_INDEX --> integer array for indexing of CTM data arrays. This
;            keyword is only used when EDGE is a valid 4 element vector,
;            keyword GET_COORDINATES is not set and no coordinates are 
;            passed in the CENTER keyword. This array is always arranged
;            in west-east order (e.g. for EDGE=[0.,175.,0.,-175.] it will
;            return [70, 71, 0] (GEOS1 grid)). 
;
;        SN_INDEX --> like WE_INDEX but for latitude indexing. Note that
;            latitude values in EDGE must be arranged in ascending order.
;
;        /GET_COORDINATES --> return coordinates to given index rather
;            than an index pair for given coordinates
;        
;        /NON_INTERACTIVE --> default action is interactive box picking per
;            mouse (only need to supply MINFO in this case, but index and
;            coordinates of last click will be returned in I, J, CENTER
;            and EDGES repectively). Set this keyword if you want to convert
;            values to and fro without drawing a map etc.
;
;        XSIZE, YSIZE --> window size (default 900x600)
;
;        MAPCENTER --> center coordinates for map projection [p0lat, polon ]
;
;        COUNTRIES -> draw country boundaries
;
;        _EXTRA --> keywords are passed to MAP_SET 
;            (e.g. LIMIT=[lat0,lon0,lat1,lon1])
;            Careful if you display data!
;
;        WINDOW -> window number to plot into. Normally a new window
;            is opened with the /free option. Use a specific window number
;            to overlay the map onto existing data plotted with tvimage
;             (see example).
;
;        DATA -> a data array with dimensions matching your model grid
;            (no error checking on this!) If DATA contains data, the value
;            at the selected grid box, and a statistic for neighbouring 
;            grid boxes will be displayed together with the corrdinates.
;
; OUTPUTS:
;        Index of grid box in I, J, coordinates in named variables supplied
;        with CENTER and EDGE keywords
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        needs CTM_TYPE for input of MINFO parameter and 
;        CTM_DEFINE_GRID 
;
; NOTES:
;        This routine makes substantial use of recursive calls. Be careful
;        when changing.
;
; EXAMPLES:
;        (1)
;        CTM_INDEX, CTM_TYPE('GEOS1')
;
;             ; Display world map and have fun. 
;
;        (2)
;        CTM_INDEX, CTM_TYPE( 'GEOS1',RESOLUTION=2 ), $
;            I, J, LIMIT=[ 0.,-180., 90., -30. ]
;
;             ; Display map of North America and select grid 
;             ; boxes for GEOS 2x2.5 grid.
;             ; Indices of last point are returned in I and J.
;
;        (3)
;        CTM_INDEX, CTM_TYPE('GISS_II_PRIME'),$
;             I, J, CENTER=[ 42., -72.], /NON_INTERACTIVE
;        print,I,J
;
;             ; returns grid box index for Harvard Forest in 
;             ; GISS CTM II' (21,33) without displaying a map
;
;        (4)
;        CTM_INDEX, CTM_TYPE('GISS_II'), $
;             I, J, EDGE=[-25.,170.,0.,-100.], $
;             WE_INDEX=WE, SN_INDEX=SN, /NON_INTERACTIVE
;
;             ; returns [ 69, 70, 71, 0, 1, ... , 15 ] in WE and 
;             ; [ 15, 16, ..., 21 ] in SN. I is [ 70, 16 ], and J 
;             ; is [ 16, 22 ]. Note that I, J refer to CTM (= FORTRAN)
;             ;  indices, whereas WS and SN are IDL array indices.
;        
;        (5) 
;        IM    = BYTSCL( DATA,MAX=MAX(DATA))
;        MINFO = CTM_TYPE( 'GENERIC', RES=[360./XDIM,180./YDIM] )
;        GINFO = CTM_GRID(MINFO)
;        TVIMAGE, IM, POSITION=P, /KEEP_ASPECT
;        CTM_INDEX, GINFO, I, J, WINDOW=0, DATA=DATA
;
;             ; Overlay interactive map onto data displayed with 
;             ; TVIMAGE.  You should create a generic MODELINFO 
;             ; structure in this case.  NOTE: replace xdim, ydim 
;             ; with the dimensions of your data array!
;             ; This example also demonstrates the use of ginfo vs. minfo.
;
; MODIFICATION HISTORY:
;        mgs, 04 May 1998: VERSION 1.00
;        mgs, 07 May 1998: - added MAPCENTER and _EXTRA keywords, 
;                            fixed bug with lon index
;                          - actually substantially rewritten
;        mgs, 08 May 1998: VERSION 1.10
;                          - CENTER and EDGE keywords now MAP_SET compatible
;                          - added WE_INDEX and SN_INDEX keywords
;                          - improved documentation
;                          - bug fix for display of polar grid boxes
;        mgs, 09 Jun 1998: - added COUNTRIES keyword
;        mgs, 15 Jun 1998: - bug fix for WE
;        mgs, 07 Oct 1998: - added interactive selection of model
;        mgs, 22 Feb 1999: - added DATA, SHELLS and WINDOW keywords
;        mgs, 23 Feb 1999: - can now use either minfo or ginfo as parameter
;        bmy, 24 Jan 2001: GAMAP VERSION 1.47
;                          - commented out annoying & useless warning msg
;                          - updated comments
;        bmy, 12 Mar 2003: GAMAP VERSION 2.02
;                          - updated comments
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - now pass DEFAULTMODEL from @GAMAP_CMN
;                            common block to SELECT_MODEL
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_index."
;-----------------------------------------------------------------------


pro ctm_index,info,i,j,center=center,   $
         edge=edge,we_index=we_index,sn_index=sn_index, $
         get_coordinates=get_coordinates,  $
         non_interactive=non_interactive, $
         xsize=xsize,ysize=ysize,mapcenter=mapc, $
         countries=countries,_extra=e,  $
         window=window_nr,data=data,shells=shells
 
 
FORWARD_FUNCTION ctm_grid,chkstru,select_model

@gamap_cmn

     ; check if either model or grid info is passed
     if (n_elements(info) eq 0) then $
        info = select_model(default=defaultModel)

     ; test validity of info structure and make sure we have a
     ; grid info
     if (chkstru(info,['xmid','ymid','xedge','yedge'])) then begin
        ginfo = info    ; grid information passed directly
     endif else if (chkstru(info,['name','center180'])) then begin
        minfo = info    ; model information passed 
        ginfo = ctm_grid(minfo,/NO_VERTICAL)
     endif else begin
        message,'Must provide minfo or ginfo type structure!',/Continue
        return
     end
 

     ; extract xedges
     xedge = ginfo.xedge

 
     ; ==================================================================  
     ; if data is passed, get dimensions
     ; ==================================================================  

     dxdim = -1L
     dydim = -1L
     if (n_elements(data) gt 0) then begin
        dim = size(data,/dimensions)
        if (n_elements(dim) eq 2) then begin
           dxdim = dim[0]
           dydim = dim[1]
           noerase = 1      ; do not erase previous plot
        endif 
     endif

     ; set window to current window if valid data passed
     if (dxdim gt 0 AND dydim gt 0 AND n_elements(window_nr) eq 0) then begin
        window_nr = !d.window
        if (window_nr lt 0) then window_nr = 0
     endif

     ; number of neighbouring grid boxes on each side for data statistics
     if (n_elements(shells) eq 0) then shells = 2


     ; ==================================================================  
     ; if non_interactive mode is set, do calculation and
     ; return values, but be quiet
     ; ==================================================================  
 
     if (keyword_set(non_interactive)) then begin
        ; ---------------------------------------------------------------
        ; get coordinates for index
        ; ---------------------------------------------------------------
        if (keyword_set(get_coordinates)) then begin
            if (n_elements(i) eq 0 OR n_elements(j) eq 0) then begin 
                print,'CTM_INDEX: ** Need to supply I and J index !'
                return
            endif
            ; make sure I and J are valid
            i = ( (i > 1) < ginfo.imx )
            j = ( (j > 1) < ginfo.jmx )
            ; convert to IDL convention
            pi = i-1
            pj = j-1
            ; return coordinates from gridinfo structure
            center = [ ginfo.ymid(pj), ginfo.xmid(pi) ]
            edge = [ ginfo.yedge(pj), xedge(pi), $
                     ginfo.yedge(pj+1), xedge(pi+1) ]

; print,'#GET COOR:',center

        endif else begin  
        ; ---------------------------------------------------------------
        ; get box index from LON, LAT coordinates
        ; ---------------------------------------------------------------

            ; check if valid coordinates are given
            if (n_elements(CENTER) lt 2 AND  $
                n_elements(EDGE) lt 4) then begin
                  print,'CTM_INDEX: ** Must provide CENTER or '+ $
                        'EDGE coordinates!'
                  return
            endif

            ; -----------------------------------------------------------
            ; CENTER coordinates were provided:
            ;   get CTM indices for I, J, and return "true" coordinates
            ;   in CENTER and EDGE
            ; -----------------------------------------------------------
            if (n_elements(CENTER) ge 2) then begin
               ind = where(ginfo.yedge le center[0])
               j = ((ind(n_elements(ind)-1)) > 0) < ginfo.jmx
               ind = where(xedge le center[1])
               i = ((ind(n_elements(ind)-1)) > 0) < ginfo.imx 

               ; get "true" CTM index values
               i = i + 1
               if (i gt ginfo.imx) then i = 1  ; for center180 grids
               j = j + 1

; print,'#CENTER:',center
               ; get "true" coordinates via recursive call to ctm_index
               ctm_index,ginfo,i,j,/get_coordinates,CENTER=center,  $
                    EDGE=edge,/non_interactive
; print,'#CENTER2:',center
            endif else begin
            ; -----------------------------------------------------------
            ; EDGE coordinates were provided:
            ;   get CTM indices for first and second pair of coordinates
            ;   construct array index arrays WE_INDEX and SN_INDEX
            ; -----------------------------------------------------------
               I = intarr(2)
               J = intarr(2)
               CTR = EDGE[0:1]
               ctm_index,ginfo,newi,newj,CENTER=ctr,/non_interactive
               I[0] = newi
               J[0] = newj

               CTR = EDGE[2:3]
               ; adjust coordinates 
               if (EDGE[2]-EDGE[0] gt 1.0e-4) then CTR[0] = CTR[0]-1.0e-4
               if (EDGE[3]-EDGE[1] gt 1.0e-4) then CTR[1] = CTR[1]-1.0e-4

               ctm_index,ginfo,newi,newj,CENTER=ctr,/non_interactive
               I[1] = newi
               J[1] = newj
             
               ; normally creating the index array is straight forward ...
               SN_INDEX = indgen(J[1]-J[0]+1) + J[0] - 1
; print,'##i0,i1 (ctm_index):',I[0],I[1]
               if (I[0] LE I[1]) then $
                  WE_INDEX = indgen(I[1]-I[0]+1) + I[0] - 1
               ; ... but we have to take care of the Pacific ;-) ...
          ;    if (EDGE(1) GT EDGE(3)) then $
               if (I[0] GT I[1]) then $
                  WE_INDEX = [ indgen(ginfo.imx-I[0]+1)+I[0],  $
                               indgen(I[1])+1 ] - 1
               ; ... and of requests for the total globe
               if ( (I(0) EQ I(1)) AND $
                    (abs(EDGE(1)-EDGE(3)) GT ginfo.di) ) then $
                  WE_INDEX = indgen(ginfo.imx)
               
            endelse

        endelse
        return
     endif

 
     ; ==================================================================  
     ; this is interactive mode: check if device allows windows
     ; open one and plot a global map
     ; ==================================================================  
 
     if ((!d.flags AND 256) eq 0) then return
 
     if (n_elements(xsize) eq 0) then xsize=900
     if (n_elements(ysize) eq 0) then ysize=600
     if (n_elements(window_nr) eq 0) then $
        window,/free,xsize=xsize,ysize=ysize  $
     else $
        wset,window_nr

     windex = !d.window

     if (n_elements(window_nr) eq 0) then !p.position = [ 0., 0., 1., 1. ]
     if (n_elements(mapc) eq 0) then mapc=[0,0]
 
     map_set,mapc(0),mapc(1),color=1,/noborder,_extra=e,noerase=noerase
     if (dxdim le 0 OR dydim le 0) then map_continents,/fill,color=15
     map_continents,color=1
     if (keyword_set(countries)) then $
         map_continents,color=1,/countries
     map_grid,color=1
 
     ; copy window into pixmap
     window,/free,xsize=!d.x_size,ysize=!d.y_size,/pixmap
     pixwin = !d.window
     device,copy=[0,0,!d.x_size,!d.y_size,0,0,windex]
     wset,windex
 
     !mouse.button = 0
 
     print,'------------------------------------------------------------'
     print,'Use left mouse button to select a box, right button to exit.'
     print,'------------------------------------------------------------'
     if (dxdim ge 0 AND dydim ge 0) then begin
        print,'     LAT     LON       INDEX     DATA(I,J)     '+ $
              'MEAN(shell)    MIN,MAX(shell)'
     endif else begin
        print,'     LAT     LON       INDEX'
     endelse
 
     while (!mouse.button lt 4) do begin
        ; use mouse to select a point
        cursor,mx1,my1,/down,/data
 
        ; restore original map 
        device,copy=[0,0,!d.x_size,!d.y_size,0,0,pixwin]
 
        if (!mouse.button eq 1 AND finite(mx1) AND $
             finite(my1) ) then begin
           ; find index of coordinates (recursive call)
           ctm_index,ginfo,i,j,center=[my1,mx1],/non_interactive

           if (dxdim ge i AND dydim ge j) then begin
              dmean = 0.0 
              dmin = 0.0
              dmax = 0.0
              ; compute statistics for neighbouring boxes ****
              tmp = data[(i-shells)>0:(i+shells)<dxdim, (j-shells)>0:(j+shells)<dydim]
              dmin = min(tmp, max=dmax)
              dmean = total(tmp)/n_elements(tmp)
              print,my1,mx1,i,j,data[i,j],dmean,dmin,dmax,format='(2f8.1,5X,2i5,4e12.4)'
           endif else begin
              print,my1,mx1,i,j,format='(2f8.1,5X,2i5)'
           endelse

           ; plot index (IDL array convention)
           pi = i-1 
           pj = j-1 

           ; plot rectangle with grid box edges
           px = xedge(pi)
           py = ginfo.yedge(pj) > (-89.8)
           dx = ginfo.di
           dy = ginfo.dj
           py2 = (py+dy) < 89.8

           plots,[px,px+dx,px+dx,px,px],[py,py,py2,py2,py], $
               color=2

           ; store coordinate info in CENTER and EDGE variables
           ctm_index,ginfo,i,j,center=center,edge=edge,/get_coordinates, $
                 /non_interactive

        endif
 
     endwhile
 
     ; delete window
     wdelete,windex
     wdelete,pixwin

     !p.position=0
 
     return
end
 

