; $Id: boxplot.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BOXPLOT
;
; PURPOSE:
;        Produce a box and whisker plot of a data vector
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        BOXPLOT,DATA [,keywords]
;
; INPUTS:
;        DATA  --> the data vector
;
; KEYWORD PARAMETERS:
;        GROUP --> array of the same dimension as DATA which contains
;             grouping information. One box is plotted for each group.
;             If MINGROUP or MAXGROUP are given, boxes and whiskers are
;             only plotted for group values within this range.
;             GROUP may not contain more than 28 different values.
;             Group can also be a string array. In this case MINGROUP
;             and MAXGROUP make no sense of course.
;
;        MINGROUP --> the minimum group value for which a box shall be
;             plotted
;
;        MAXGROUP --> the maximum group value for which a box shall be
;             plotted
;
;        LABEL --> string array containing labels for *different* groups.
;             NOTE: The user must take care that one label is passed for
;             each group to be plotted. If label is not specified, the
;             group values will be used as axis labels
;
;        COLOR --> plotting color for axis (default : 1, i.e. black in MYCT
;             color scheme). Will also be used as default for BOXCOLOR.
;
;        BOXCOLOR --> color of the boxes (frames). Default is the COLOR
;             value, i.e. 1 if not specified. This color will also be used as
;             default for MEDIANCOLOR and MEANCOLOR. If you want boxes that 
;             are only filled but have no frame, you must specify BOXCOLOR=-1.
;             In this case the default for MEDIANCOLOR and MEANCOLOR will
;             be the COLOR value.
;
;        BOXWIDTH --> relative width of boxes (default: 0.8).
;
;        BOXPOSITION --> relative position of box on x axis (default: 0.).
;             This parameter can be used together with the OVERPLOT keyword
;             to plot multiple groups of boxes in one graph.
;
;        MEDIANCOLOR --> a color value for the median bar
;             (default: value of BOXCOLOR)
;
;        MEANSYMBOL --> symbol to be used for mean values. If no symbol
;             is given, no mean values will be drawn.
;
;        MEANCOLOR --> color for mean symbols (default: value of BOXCOLOR)
;
;        FILLCOLOR --> a value or an array containing the colorindex for all
;             boxes or each box, respectively. If a single value is given,
;             *all* boxes will be filled with this color. If an array is 
;             passed that has less elements than there are groups to plot, 
;             the remaining colors will be filled with 15 (grey in MYCT 
;             standard-scheme). If no FILLCOLOR is specified, the boxes will 
;             be empty.
;
;        MISSING --> a value that represents missing data. If given, any data
;             with a value of missing will be filtered out before plotting.
;
;        PRINTN --> print number of elements on top of each box/whisker
;
;        CHARSIZE --> character size of the PRINTN labels (default: 0.8)
;
;        /OVERPLOT --> do not draw a new coordinate system but overlay new
;             data. For 2 sets of data you should use BOXWIDTH=0.4 and
;             BOXPOSITION=-0.25 and 0.25, respectively.
;
;        ORIENTATION -> orientation for axis labels (see XYOUTS procedure)
;
;        /IS_PERCENTILE --> data are already processed percentiles. In this
;             case data must be an array with dimensions 5,N. The GROUP keyword
;             is ignored, and each set of the N percentiles will be treated as
;             one group.
;
;        PERCVAL --> float array with 5 elements denoting the percentile
;             values (default: 0.05, 0.25, 0.5, 0.75, 0.95)
;
;        Further keywords are passed to the PLOT routine and can be used
;        to determine the appearance of the plot (e.g. XTITLE,YTITLE,
;        YSTYLE,YRANGE,/YLOG,COLOR,THICK)
;
; OUTPUTS:
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        PERCENTILES (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLES:
;        (1)
;        O3   = DATA( WHERE( HEADER EQ 'O3'  ), * )
;        ALT  = DATA( WHERE( HEADER EQ 'ALT' ), * )
;        IALT = 2.0* FIX( ALT / 2.0 )
;        BOXPLOT, O3, GROUP=IALT
;
;             ; Produces a boxplot with ozone percentiles in 
;             ; altitude bins of 2 (km).  Axis, box frames and 
;             ; labels will be black, boxes are not color filled.
;
;        (2)
;        BOXPLOT, O3, GROUP=IALT, FILLC=15, MEANSYM=SYM(1), $
;           MEANCOL=2, BOXWIDTH=0.6, YTITLE='O3',           $
;           XTITLE='alt. bin', MISSING=-999.99, /PRINTN
;
;             ; Produces boxes that are filled with light grey and 
;             ; have a black frame and median line.  A red filled 
;             ; circle denotes the mean value, titles are assigned 
;             ; to the x and y axis. The number of valid observations 
;             ; is printed on top of each box. The boxes are reduced 
;             ; in size.
;
;        CO = DATA( WHERE( HEADER EQ 'CO' ), * )
;        BOXPLOT, O3, GROUP=IALT, MISSING=-999.99, BOXCOL=4, $
;            BOXWIDTH=0.4, BOXPOS=-0.25
;        BOXPLOT, CO, GROUP=IALT, MISSING=-999.99, BOXCOL=2, $
;            BOXWIDTH=0.4, BOXPOS=+0.25, /OVERPLOT
;
;             ; Produces a plot with blue box frames for ozone 
;             ; and red frames for CO data.
;            
; MODIFICATION HISTORY:
;        mgs, 30 Jul 1997: VERSION 1.00
;        mgs, 03 Aug 1997: added template
;        mgs, 27 Nov 1997: some revisions and suggested changes by T.Brauers:
;             - better color handling (NOTE: meaning of BOXCOLOR has changed)
;             - optional overlay of mean value
;             - box frames
;             - variable boxwidth
;             - error fixing lower upper boundaries in log plots
;             - bug fix with label keyword
;             - added OVERPLOT and BOXPOSITION keywords
;        mgs, 22 Jan 1998: added IS_PERCENTILE keyword to allow
;               plotting of data that has been processed already
;        mgs, 17 Apr 1998: 
;             - x-axis handling improved (now uses axis command and xyouts)
;             - orientation and medianthick keywords added
;        mgs, 21 May 1998:
;             - added percval keyword
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine boxplot"
;-----------------------------------------------------------------------


pro boxplot,data,group=group,mingroup=mingroup,maxgroup=maxgroup,  $
    label=label,color=color,boxcolor=boxcolor,boxwidth=boxwidth,  $
    boxposition=boxposition, $
    mediancolor=mediancolor,medianthick=medianthick, $
    meansymbol=meansymbol,meancolor=meancolor, $
    fillcolor=fillcolor,missing=missing,  $
    printn=printn,charsize=charsize,overplot=overplot,  $
    orientation=orientation, $
    is_percentile=is_percentile, percval=percval, $
    _EXTRA=e


    empty = 0   ; will be set to 1 if error occurs, so that only 
                ; empty plot is drawn


; analyze parameters (color etc.)
    if (n_elements(color) le 0) then color=1   ; main color

    if (n_elements(boxcolor) le 0) then boxcolor=color

    if(n_elements(mediancolor) le 0) then begin
        if(boxcolor lt 0) then mediancolor=color $
        else mediancolor=boxcolor
    endif

    if(n_elements(medianthick) le 0) then $
          medianthick=!p.thick

    if(n_elements(meancolor) le 0) then begin
        if(boxcolor lt 0) then meancolor=color $
        else meancolor=boxcolor
    endif

    if(boxcolor lt 0) then limitcolor=color $
    else limitcolor=boxcolor

    if (n_elements(boxwidth) le 0) then boxwidth = 0.8
    if (n_elements(boxposition) le 0) then boxposition = 0.

    if (n_elements(charsize) le 0) then charsize = 0.8

    if (n_elements(percval) ne 5) then $
          percval = [ 0.05, 0.25, 0.5, 0.75, 0.95 ]

; analyze groups
    if(keyword_set(is_percentile)) then begin
        ; check data dimensions, each member is a group
        ds = size(data)
        if (ds(1) ne 5) then message,'Data must have dimensions 5,N !'
        if (ds(0) eq 1) then data = reform(data,5,1)  ; make it an array
        ds = size(data)
        ; construct "group" variable (named s)
        s = findgen(ds(2))+1.
        gisstring = 0
    endif else begin   ; normal handling of data
        
        if(keyword_set(group)) then begin
            if(n_elements(data) ne n_elements(group)) then begin
              print,'*** BOXPLOT: n_elements(data) NE n_elements(group) ! ***'
              return
            endif

        ; determine type of groupdata
            test = size(group)
            test = test(n_elements(test)-2)
            gisstring = (test eq 7)

        ; determine number of uniq group elements and construct a sorted array
        ; with these uniq elements within mingroup and maxgroup.
            s = group(sort(group))
            s = s(uniq(s))
            s = s(sort(s))
            if(keyword_set(mingroup)) then begin
               ind = where(s ge mingroup,c)
               if(c le 0) then empty=1  $   ; no valid data, draw empty plot
               else s = s(ind)
            endif
            if(keyword_set(maxgroup)) then begin
               ind = where(s le maxgroup,c)
               if(c le 0) then empty=1  $   ; no valid data, draw empty plot
               else s = s(ind)
            endif
        endif
    endelse   ; group handling

    ngiven = n_elements(s)

    ; determine group labeling
    if(not keyword_set(label)) then $
       if(ngiven gt 0) then begin     ; group array was passed
          if(not gisstring) then label = strtrim(string(s,format='(i8)'),2) $
          else label = s               ; group array consists of strings
       endif else label = ' '          ; no groups, only one box
    uselabel = [ label ]
    
; set up plot
    ngroups = ngiven
    if(ngroups eq 0) then ngroups = 1   ; there is always AT LEAST 1 group
    xrange = [-0.5,ngroups-0.5]
    tmpdat = data
    if (keyword_set(missing)) then begin
      ind = where(data ne missing,c)
      if (c gt 0) then tmpdat = tmpdat(ind)
    endif

    yrange = [min(tmpdat),max(tmpdat)]
    xtickval = findgen(ngroups)
 ;  xtickval = [-0.5,xtickval,ngroups-0.5]
    xtickval = [xtickval]
    nticks = n_elements(xtickval)-1
    
    ; print,'Diagnostics: ngroups=',ngroups,' nticks=',nticks,$
    ;     'xtickval=',xtickval,' uselabel=',uselabel

if (ngroups gt 29) then begin
; re-set tick control to default
   uselabel=''
   nticks=0
   xtickval=0
endif

    ; plot axis frame
    if (not keyword_set(overplot)) then begin
       plot,[0],[0],/nodata,xstyle=5,xrange=xrange,   $
           color=color,yrange=yrange,_EXTRA=e

    ; draw and annotate x-axis
       axis,0,!y.window(0),xaxis=1,/norm,color=color, $
             xticks=nticks,xtickv=xtickval, $
             xtickname=replicate(' ',nticks+1), $
             xminor=-1,_EXTRA=e

   ;   plots,xrange,[!y.crange(1),!y.crange(1)],color=color,thick=!x.thick
       plots,!x.window,[!y.window(1),!y.window(1)],/norm, $
             color=color,thick=!x.thick
    
       normval = convert_coord(xtickval,0.*xtickval,/data,/to_normal)
       yval = fltarr(n_elements(normval))+!y.window(0)

       if(n_elements(orientation) eq 0) then orientation = 0
       align = 0.5
       xshift = 0.
       yshift = -0.02
       if (orientation gt 0) then begin
          align=1
          xshift=0.01
          yshift = -0.02
       endif
       if (orientation lt 0) then begin
          align=0
          xshift=-0.01
       endif

       xyouts,normval(0,*)+xshift,yval+yshift, $
             uselabel,/norm,color=color,charsize=charsize, $
             align=align,orientation=orientation
    endif


    ; if error occured while analyzing the given groups, exit here
    if empty then return

; overlay boxes and whiskers
    ; determine half thickness of median bar and extreme lines
    mth = (!y.crange(1)-!y.crange(0))*0.005
    xth = (!x.crange(1)-!x.crange(0))*0.005
    ; determine y position of N marks
    ylp = !y.crange(1)-0.07*(!y.crange(1)-!y.crange(0))
    ; take care of logarithmic plots
    if (!y.type eq 1) then ylp = exp(ylp * alog(10.D))

    ; make up or expand array with fillcolors (if necessary)
    if(n_elements(fillcolor) le 0) then $
        fillcolor = -1  $
    else begin
       nmc=ngroups-n_elements(fillcolor)    ; number of missing colorcodes
       if (nmc gt 0) then $
          if (n_elements(fillcolor) eq 1) then $
               fillcolor = [ replicate(fillcolor(0),ngroups) ]  $
          else fillcolor = [ fillcolor, replicate(15,nmc) ]
    endelse

    ; loop through groups OR plot box and whisker of all data
    for gg=0,ngroups-1 do begin
       ; determine percentiles and mean of data subsets
       if (keyword_set(is_percentile)) then begin
           p = data(*,gg)    ; extract 1 set of percentiles
           mv = !values.F_NAN  ; set mean to NaN
       endif else begin
           if (ngiven eq 0) then begin
                p=percentiles(data,value=percval)
                mv=TOTAL(data)/n_elements(data)
           endif else begin
              ind = where(group eq s(gg),c)
              tmpdat = data(ind)
              if(keyword_set(missing)) then begin
                 ind = where(tmpdat ne missing,c)
                 if(c gt 0) then tmpdat = tmpdat(ind)
              endif
              if(c gt 0) then begin
                p=percentiles(tmpdat,value=percval)
                mv=TOTAL(tmpdat)/n_elements(tmpdat)
              endif else begin
                p=[0,0,0,0,0] & mv = 0
              endelse
           endelse
       endelse   ; keyword is_percentile
    print,'Statistics for group ',gg+1,':',p

    ; produce box 
    ; 25%-75%
        left = gg-0.5*boxwidth+boxposition
        right= gg+0.5*boxwidth+boxposition
        center= gg+boxposition

        if (fillcolor(0) ge 0) then $
           polyfill,[left,left,right,right,left],  $
                [p(1),p(3),p(3),p(1),p(1)],color=fillcolor(gg)

        if (boxcolor(0) ge 0) then $
        plots,[left,left,right,right,left],  $
              [p(1),p(3),p(3),p(1),p(1)],color=boxcolor

    ; overlay median
        plots,[left,right], $
              [p(2),p(2)],color=mediancolor,thick=medianthick

    ; overlay mean as symbol
        if (n_elements(meansymbol) gt 0) then $
             oplot, [center], [mv], psym=meansymbol(0), color=meancolor

    ; lower and upper extremes
    ; cut values if they exceed plot boundaries by more than 10 %
        lowbound = !y.crange(0)-0.1*(!y.crange(1)-!y.crange(0))
        upbound  = !y.crange(1)+0.1*(!y.crange(1)-!y.crange(0))
    ; take care of logarithmic plots
        if (!y.type eq 1) then begin
            lowbound=exp(lowbound*alog(10.D))
            upbound=exp(upbound*alog(10.D))
        endif

        if(p(0) lt lowbound) then p(0) = lowbound
        if(p(4) gt upbound) then p(4) = upbound

        if(p(0) lt p(1)) then $
        plots, [center,center],  $
               [p(0),p(1)],color=limitcolor
        if(p(4) gt p(3)) then $
        plots, [center,center],  $
               [p(3),p(4)],color=limitcolor
    
       ; write number of cases
    
       if(keyword_set(printn)) then $
          xyouts,center,ylp,strtrim(c,2),align=0.5, $
                 color=color,charsize=charsize
    endfor
    

return
end

