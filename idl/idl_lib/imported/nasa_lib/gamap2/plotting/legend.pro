; $Id: legend.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        LEGEND
;
; PURPOSE:
;        Annotate a plot with a legend.  Make it as simple as possible
;        for the user.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        LEGEND, [several keywords]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        HALIGN, VALIGN -> horizontal and vertical alignment of legend 
;             with respect to plot window. Ranges from 0 to 1, and is 
;             interpreted "dynamically": e.g. a value of 0.3 places 
;             30% of the box left (below) 0.3*plotwindow size.
;             Defaults are 0.98 and 0.03, i.e. the lower right corner.
;
;        WIDTH -> width of the legend box. This parameter is defaulted
;             to 40% of the plot area or may be adjusted to hold the
;             longest LABEL string if CHARSIZE is given. If WIDTH is
;             specified, it is used to determine the CHARSIZE. However,
;             if both are given, they are both used and may lead to
;             ugly results.
;
;        POSITION -> a four element vector that gives complete control
;             over the position of the legend box. Normally, you don't 
;             need this keyword, but it may be handy in a multi-plot 
;             situation where you want to place a legend independently
;             of any individual plotting area. It can also be convenient 
;             if you want to place legends interactively: simply call
;             a rubberband program that returns the region coordinates 
;             in normalized units, and pass this vector to the LEGEND 
;             program.
;
;        PLOTPOSITION -> 4 element vector that specifies the plotting 
;             area.  Default is taken from !P.POSITION if set, otherwise 
;             [0.2,0.1,0.9,0.9] is used as default. As noted above, 
;             sizing and positioning of the legend box is with respect 
;             to the plot position unless POSITION is specified.
;
;        SYMBOL -> a vector (or one integer) containing symbol numbers 
;             to plot. -1 can be used to skip one entry.  These values 
;             are arguments to the SYM() function. If you like to
;             label plain IDL symbols, use the PSYM keyword instead.
; 
;        PSYM -> same as symbol, but passes its values directly to PSYM
;             in the plots command, i.e. produces generic IDL symbols.
;
;        SYMSIZE -> symbol size. Normally, this value is adjusted auto-
;             matically to match the character size. 
;        
;        COLOR -> a number or vector of color values for the symbols. 
;             One entry is used per symbol. If only one entry is 
;             provided, all symbols are plotted in the same color. 
;             Default is black.
;
;        LINE -> a vector with linestyles. Symbols and lines can be 
;             used together. Entries with -1 are skipped.
;
;        LCOLOR -> color values for the lines
;
;        THICK -> line thickness
;
;        LABEL -> a string array containing the legend text lines. 
;             One line should correspond to one symbol. If you have a 
;             two line entry, you can either pass it as two lines or
;             use the '!C' carriage return command. In both cases you 
;             have to set the SYMBOL and LINE values that correspond
;             to the second line to -1 in order to skip the symbol for 
;             it. If you use '!C', your next LABEL should be blank.
;
;        TEXTCOLOR -> A color value for the label and title output.
;             Default is black.
;
;        TITLE -> a title string for the legend. 
;
;        CHARSIZE -> character size for all labelling. Default is to 
;             determine the character size automatically so that the largest
;             LABEL and TITLE fit into the legend box. On the other hand you
;             can specify CHARSIZE and have the legend size itself. 
;
;        SPACING -> spacing between legend lines. Default is 2, lower values
;             produce narrower spacing and may be useful for extensive 
;             legends. You can set the IDL default line spacing by setting
;             SPACING to float(!D.Y_CH_SIZE)/!D.X_CH_SIZE.
;
;        NLINES -> number of lines the legend box shall hold. Normally,
;             this value is determined automatically from the maximum number
;             of entries in SYMBOL, PSYM, LINE, and LABEL. It may however
;             be useful to set NLINES manually if you want to ADD extra
;             curve identifiers lateron (see ADD keyword), or if your
;             last LABEL is a multi line entry (using the '!C' character).
;
;        FRAME -> draw a frame around the legend box. The value of FRAME
;             is equal to the color index that will be used to draw the
;             FRAME (hence /FRAME draws a black frame with MYCT).
;
;        BOXCOLOR -> a background fill color for the legend box. Default is
;             0 (which corresponds to white in MYCT). If you specify a
;             negative number, no background box is drawn and your legend 
;             may interfere with part of the plot.
;
;        ADD -> set this keyword to add one or more entries to an existing 
;             legend. All positioning and size keywords are ignored in this
;             case, and the new entries are appended at the bottom. You 
;             should use the NLINES keyword in the first call to legend in
;             order to properly size your legend box, or (if you draw
;             no FRAME and have a neutral BOXCOLOR) you can set VALIGN to 
;             e.g. 0.98 to start from the top of the plotting area. 
;             Technical NOTE: adding entries to an existing legend is 
;             most flexible with the use of the LEGSTRU keyword which will
;             return a structure with all necessary parameters to continue
;             labelling at the next call. It is also accomplished by means 
;             of a common block to facilitate its use. In this case, you can
;             only continue the legend you last worked on. 
;
;        LEGSTRU -> a named variable that will contain information to
;             continue labelling with the /ADD keyword. Needs to be passed
;             back into LEGEND if it shall be used. Otherwise, information
;             is taken from a common block.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        DRAWLEGSYM : plots a single plot symbol and line.
;
; REQUIREMENTS:
;        LEGEND uses the STR_SIZE function by David Fanning 
;        and FORMSTRLEN to determine "true" size of label strings.
;        If ADD keyword is used, you also need CHKSTRU.
;
;        A plot must have been produced prior to calling LEGEND
;
; NOTES:
;        A few color statements require MYCT in the present form
;        of this program. See definitions of variables Black and
;        White at the beginning of the program.
;
; EXAMPLES:
;        (1) 
;        PLOT, FINDGEN(60),              $
;              SIN(FINDGEN(60)*!PI/15.), $
;              COLOR=!MYCT.BLACK
;
;        LEGEND, SYMBOL=[1,2,3], $
;                LABEL=['Curve A','Curve B','Curve C']
;
;             ; Plot a simple data curve and produce 
;             ; legend at lower right corner
;
;
;        (2)
;        LEGEND, SYMBOL=[4,5,6],                        $
;                LABEL=['Curve D','Curve E','Curve F'], $
;                HALIGN=0.5,                            $
;                VALIGN=0.98,                           $
;                BOXCOLOR=-1,                           $
;                CHARSIZE=1.2
;
;             ; Place legend at center of x and at top of y, don't 
;             ; draw a background box, write the labels with charsize 
;             ; 1.2 and size the legend box automatically
;
;
;        (4) 
;        LEGEND, SYMBOL=[1,-1,6,-1,2,-1],      $
;                LINE=[-1,0,-1,2,-1,3],        $
;                COLOR=[1,1,2,2,3,3],          $
;                LCOLOR=[1,1,2,2,3,3],         $
;                LABEL=['PEM-West A','model',  $
;                       'PEM-West B','model',  $
;                        'TRACE-A','model'],   $
;                NLINES=8,                     $
;                FRAME=1,                      $
;                BOXCOLOR=5,                   $
;                TITLE='GTE missions',         $
;                HALIGN=0.1,                   $
;                VALIGN=0.06,                  $
;                CHARSIZE=1.2
;
;              ; Draw a legend on a yellow background.  It has 6
;              ; entries but leaves room for 2 more lines which 
;              ; will be filled later.  Use different colors for 
;              ; symbols and lines. Symbols and lines are alternating.
;              ; Draw a frame around legend and add a title.
;
;        (5)
;        LEGEND, SYMBOL=[4,-1],                   $
;                LINE=[-1,4],                     $
;                COLOR=4,                         $
;                LCOLOR=4,                        $
;                LABEL=['PEM-Tropics A','model'], $ 
;                /ADD
; 
;             ; Now add two extra entries to the last legend
;             ; (This will use the structure stored in the 
;             ; common block)
;             ;
;             ; To make use of the more flexible "widget-proof" 
;             ; structure, simply add legstru=legstru to the last
;             ; two calls.
;
;
;        (6)
;        !P.POSITION = [0.6,0.5,0.93,0.93] 
;        RECTANGLE, !P.POSITION, XBOX, YBOX     ; Get rectangle coordinates
;        POLYFILL, XBOX, YBOX, /NORM, COLOR=0   ; Clear rectangle
;
;        PLOT, FINDGEN(60), SIN(FINDGEN(60)*!PI/15.),$
;             COLOR=!MYCT.BLACK, /NOERASE
;
;        LEGEND, SYMBOL=[1,2,3],$
;                LABEL=['Curve A','Curve B','Curve C']
;
;        !P.POSITION = 0                        ; reset !p.position
;
;             ; Produce an inset plot positioned via !P.POSITION 
;             ; and add a legend.  The same effect can be reached 
;             ; by passing the position=[..] parameter to the plot 
;             ; command and the same vector as PLOTPOSITION to legend.
;
; MODIFICATION HISTORY:
;        mgs, 23 Jun 1998: VERSION 1.00
;        mgs, 24 Jun 1998: - now uses !X.Window and !Y.Window to get
;               default size of the plotting window (thanks DWF)
;        mgs, 25 Jun 1998: - added THICK keyword
;        mgs, 27 Oct 1998: - more room for lines
;                          - now uses formstrlen instead of strlen
;        mgs, 28 Nov 1998: - box width not incremented by 1 if plotmode=0
;        mgs, 25 Jun 1999: - added TEXTCOLOR keyword
;  dbm & bmy, 23 Aug 2005: TOOLS VERSION 2.04
;                          - now pass _EXTRA=e to XYOUTS 
;                          - cosmetic changes
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine legend"
;-----------------------------------------------------------------------


pro drawlegsym,X0,X1,Y,symbol,psym,line,plotmode, $
               color=color,lcolor=lcolor,symsize=symsize, $
               thick=thick
 
    ; draw a single symbol with optional line
   
; print,'PLOTSYM: plotmode,x0,x1,y',plotmode,x0,x1,y 
    ; test for line first
    if ((plotmode AND 1) GT 0 AND line ge 0) then $
        plots,[X0,X1],[Y,Y],/norm,color=lcolor,line=line,thick=thick
 
    ; overlay symbol or psym
    if ((plotmode AND 2) GT 0 AND symbol ge 0) then $
        plots,(X0+X1)/2.,Y,/norm,color=color,  $
            psym=sym(symbol),symsize=symsize
    if ((plotmode AND 4) GT 0 AND psym ge 0) then $
        plots,(X0+X1)/2.,Y,/norm,color=color,  $
            psym=psym,symsize=symsize
 
    return
end

;------------------------------------------------------------------------------
 
pro legend, halign=halign,             valign=valign,     $
            width=width,               position=position, $
            plotposition=plotposition, symbol=symbol,     $
            psym=psym,                 symsize=symsize,   $
            color=color,               line=line,         $
            lcolor=lcolor,             thick=thick,       $
            label=label,               title=title,       $
            textcolor=textcolor,       charsize=charsize, $
            spacing=spacing,           nlines=nlines,     $
            frame=frame,               boxcolor=boxcolor, $
            add=add,                   legstru=legstru,   $
            _EXTRA=e


    ; --- declare functions
    FORWARD_FUNCTION str_size,formstrlen,chkstru


    ; --- define color constants (for MYCT)
    Black = 1
    White = 0
 
    ; --- common block holds information for continuation
    common legcontinfo, comlegstru

 
    ; ------------------------------------------------------------ 
    ; set keyword defaults
    ; ------------------------------------------------------------ 
   
    ; --- plot mode: 0=nothing, 1=only nlines, 2=symbols, 3=both,
    ;                4=use psyms (original IDL symbols), 5=psym+line
    ; --- NOTE: values 6 and 7 are not allowed !
    plotmode = 0
    if (n_elements(line) gt 0) then plotmode = plotmode + 1
    if (n_elements(symbol) gt 0) then plotmode = plotmode + 2
    if (n_elements(psym) gt 0) then plotmode = plotmode + 4
 
    if (plotmode eq 6 OR plotmode eq 7) then plotmode = plotmode - 4
 
 
    ; --- determine number of nlines
    truenlines = max([n_elements(symbol),n_elements(psym), $
                     n_elements(line),n_elements(label) ])
    if (n_elements(nlines) eq 0) then nlines = truenlines
 
    ; --- adjust dimensions:
    ; --- - make sure, each field contains at least one element
    ; --- - blow them up to truenlines values
    if ( n_elements( symbol    ) eq 0 ) then symbol    = -1       ; none
    if ( n_elements( psym      ) eq 0 ) then psym      = -1       ; none
    if ( n_elements( line      ) eq 0 ) then line      = -1       ; none
    if ( n_elements( color     ) eq 0 ) then color     = Black
    if ( n_elements( lcolor    ) eq 0 ) then lcolor    = Black
    if ( n_elements( thick     ) eq 0 ) then thick     = !p.thick
    if ( n_elements( label     ) eq 0 ) then label     = ' '      ; 1 blank !
    if ( n_elements( charthick ) ne 1)  then charthick = 1 
 
    if (n_elements(symbol) lt truenlines) then $
          symbol = [ symbol, intarr(truenlines)-1 ]
    if (n_elements(psym) lt truenlines) then $
          psym = [ psym, intarr(truenlines)-1 ]
    if (n_elements(line) lt truenlines) then $
          line = [ line, intarr(truenlines)-1 ]
    if (n_elements(color) lt truenlines) then $
          color = [ color, intarr(truenlines)+1 ]
    if (n_elements(lcolor) lt truenlines) then $
          lcolor = [ lcolor, intarr(truenlines)+color[0] ]
    if (n_elements(label) lt truenlines) then $
          label = [ label, replicate(' ',truenlines) ]
    if (n_elements(textcolor) ne 1) then $
          textcolor = BLACK

    ; --- that's all we need if we want to add labels 
    if (keyword_set(add)) then begin
        ; -- take structure from keyword or common block
        if (n_elements(legstru) eq 0) then begin
           if (n_elements(comlegstru) eq 0) then return $
           else legstru = comlegstru
        endif
        ; -- test validity of structure
        if (not chkstru(legstru,['POSITION','XCH','YCH'])) then return
        ; --- extract needed parameters from structure
        position = legstru.position
        symwidth = legstru.symwidth
        xch = legstru.xch
        ych = legstru.ych
        spacing = legstru.spacing
        yoffset = legstru.yoffset
        charsize = legstru.charsize
        symsize = legstru.symsize
        thick = legstru.thick
        goto,legend_cont   ; add additional labels at the bottom
    endif

    ; --- other goodies
    if (n_elements(charsize) eq 0)   then charsize = 1.
    if (n_elements(spacing) eq 0)    then spacing = 2.0 
    if (n_elements(title) eq 0) then title = ''
    plotframe = keyword_set(frame)
    if (n_elements(boxcolor) eq 0)   then boxcolor = White
 
    ; --- alignment (only used if position not given)
    ; "floating" alignment: determines position AND alignment
    ; e.g. 0.3 will place 30% of size below 0.3 and 70% above
    if (n_elements(halign) eq 0) then halign = 0.98 ; right
    if (n_elements(valign) eq 0) then valign = 0.04 ; bottom
 
    ; --- create teststring for determination of charsize
    slen = max(formstrlen([label,title]))    ; *** changed 27 Oct 1998
    teststr = string(replicate('X',round(slen)),format='(255A1)')
 
    ; --- size of one character in norm coordinates
    ; ysize includes extra spacing between nlines
    ; value will be multiplied by charsize before use
    xch = float(!d.x_ch_size)/!d.x_size
    ych = float(!d.x_ch_size)/!d.y_size  ;  X_SIZE !!

    ; --- space for lines and symbols
    ; use 6 characters if lines shall be plotted
    symspace = 6
    if (plotmode eq 2 OR plotmode eq 4) then symspace = 4
    if (plotmode eq 0) then symspace = 0
    
    ; --- offset for first line
    yoffset = 0.75 + 0.75*(title ne '')
 
; help,plotmode,truenlines,symbol,psym,label,line,color,lcolor
 
    ; ------------------------------------------------------------ 
    ; determine position and size of legend box
    ; - need to set the following variables:
    ;   position (4 element vector)
    ;   xsize, ysize (textbox size in normal coordinates)
    ;   symwidth     (width for symbol, nlines in normal coordinates)
    ;   NOTE: symwidth+xsize = position[2]-position[0]
    ;   charsize     (character size value for xyouts)
    ; ------------------------------------------------------------ 
 
    ; --- determine default plot position
    if (n_elements(plotposition) ne 4) then $
        plotposition = [ !x.window[0], !y.window[0], !x.window[1], $
                         !y.window[1] ]

; OLD:  plotposition = !p.position
 
    ; --- see if position is valid (e.g. if !p.position is reset to 0)
    if (plotposition[2] le plotposition[0]) then begin
        if (plotposition[0] eq 0) then plotposition[0] = 0.2
        plotposition[2] = ( plotposition[0] + 0.7 ) < 1.
    endif
    if (plotposition[3] le plotposition[1]) then begin
        if (plotposition[1] eq 0) then plotposition[1] = 0.1
        plotposition[3] = ( plotposition[1] + 0.8 ) < 1.
    endif
 
    plotwidth  = plotposition[2]-plotposition[0]
    plotheight = plotposition[3]-plotposition[1]
 
 
    ; --- if legend position is given, determine xsize and symwidth
    ; --- no error checking on position !!
    if (n_elements(position) eq 4) then begin
       xsize = position[2]-position[0] 
       ysize = position[3]-position[1] 
       symwidth = 0
 
       ; -- determine character size
       if (n_elements(charsize) eq 0) then $
           charsize = (str_size(teststr,xsize) < 2.5) > 0.5
 
    endif else begin
 
    ; --- determine size and position of legend automatically
    ; --- NOTE: xsize and charsize are quite intertwined
       ; -- determine width of box in norm coordinates
       if (n_elements(width) eq 0) then begin
           if (n_elements(charsize) eq 0) then $
              xsize = 0.4*(plotposition[2]-plotposition[0])  $
           else $
              xsize = (strlen(teststr)+symspace+(plotmode gt 0)) $
                      *charsize*xch
       endif else  $
           xsize = width

 
       ; -- determine character size
       if (n_elements(charsize) eq 0) then $
           charsize = (str_size(teststr,0.8*xsize) < 2.5) > 0.5

       ; -- determine height of box in norm coordinates
       ysize = (nlines+(title ne ''))*ych*charsize*spacing 
 
       ; --- position the box
       position = [ 0., 0., xsize, ysize ]  ; initialize at lower left

       position[[0,2]] = position[[0,2]] + $
          plotposition[0]+halign*(plotwidth-xsize) 
       position[[1,3]] = position[[1,3]] + $
          plotposition[1]+valign*(plotheight-ysize) 

    endelse
 
    ; --- make room for symbol and/or line
;   if (plotmode gt 0) then begin
       symwidth = symspace*charsize*xch 
       xsize = xsize - symwidth
;   endif
 
    ; --- adjust character size xch and ych
    xch = xch*charsize
    ych = ych*charsize
 
    ; set symsize accordingly
    if (n_elements(symsize) eq 0) then symsize = charsize*0.9
 
; print,'position:',position
; help,position,xsize,ysize,symwidth,charsize
 
    ; ------------------------------------------------------------ 
    ; draw frame and symbols
    ; ------------------------------------------------------------ 
 
    ; --- empty box
    if (boxcolor ge 0) then begin
       rectangle,position,xbox,ybox,expand=0.6*charsize*ych
       polyfill,xbox,ybox,/norm,color=boxcolor
    endif
 
    ; --- frame
    rectangle,position,xbox,ybox
    if (plotframe) then plots,xbox,ybox,/norm,color=frame
 
    ; --- title
    ; draw box at title position
    if (title ne '') then begin
       tx = position[0]+symwidth-xch/2.
       ty = position[3]-0.65*ych
       rectangle,[tx,ty,tx+(strlen(title)+1)*xch,ty+ych],xbox,ybox
       polyfill,xbox,ybox,/norm,color=boxcolor
 
       xyouts,tx+0.5*xch,ty,title,/norm,color=textcolor,charsize=charsize, $
              align=0.0, _EXTRA=e
    endif

; ----- jump here to continue labelling -----
legend_cont: 
    ; --- labels 
    lx = fltarr(truenlines)+position[0]+symwidth
    ly = position[3]-ych*spacing*(findgen(truenlines)+yoffset)
    xyouts,lx,ly,label,/norm,color=textcolor,charsize=charsize,align=0., $
       _EXTRA=e

    ; --- adjust yoffset for ADDing later entries
    yoffset = yoffset+ truenlines
   

    ; --- symbols
    ; here we have to loop because they are somewhat special 
    for i=0,truenlines-1 do $
       drawlegsym,position[0]+xch,position[0]+symwidth-xch,ly[i]+0.5*ych,  $
               symbol[i],psym[i],line[i],plotmode, $
               color=color[i],lcolor=lcolor[i],symsize=symsize, $
               thick=thick
 

    ; --- create new legstru structure and store it in common block 
    legstru = { position:position, symwidth:symwidth, $
                xch:xch, ych:ych, spacing:spacing, yoffset:yoffset, $
                charsize:charsize, symsize:symsize, thick:thick }

    comlegstru = legstru

 
    return
end
 
 
pro testleg
 
;   ; plot a simple data curve
   plot,findgen(60),sin(findgen(60)*!pi/15.),color=1
;
;   ; simplest call: produces legend at lower right corner
   legend,symbol=[1,2,3],label=['Curve A','Curve B','Curve C']
;
;   ; place legend at center of x and at top of y, don't draw a
;   ; background box, write the labels with charsize 1.2  and size the
;   ; legend box automatically
   legend,symbol=[4,5,6],label=['Curve D','Curve E','Curve F'], $
          halign=0.5,valign=0.98,boxcolor=-1,charsize=1.2
;
;   ; Draw a legend on a yellow background. It has 6 entries but leaves
;   ; room for 2 more lines which will be filled later. Use different
;   ; colors for symbols and lines. Symbols and lines are alternating.
;   ; Draw a frame around legend and add a title.
   legend,symbol=[1,-1,6,-1,2,-1],line=[-1,0,-1,2,-1,3], $
          color=[1,1,2,2,3,3],lcolor=[1,1,2,2,3,3], $
          label=['PEM-West A','model','PEM-West B','model', $
                 'TRACE-A','model'],nlines=8,frame=1,boxcolor=5, $
          title='GTE missions',halign=0.1,valign=0.06,charsize=1.2

;   ; Now add two extra entries to the last legend
;   ; (This will use the structure stored in the common block)
   legend,symbol=[4,-1],line=[-1,4],color=4,lcolor=4, $
          label=['PEM-Tropics A','model'],/ADD
;

   !p.position = [0.6,0.5,0.93,0.93] 
   rectangle,!p.position,xbox,ybox
   polyfill,xbox,ybox,/norm,color=0
   plot,findgen(60),sin(findgen(60)*!pi/15.),color=1,/noerase
;
;   ; simplest call: produces legend at lower right corner
   legend,symbol=[1,2,3],label=['Curve A','Curve B','Curve C']
;
   !p.position = 0
 
return
end
 
