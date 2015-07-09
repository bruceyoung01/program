PRO cgHistoplot, $                    ; The program name.
   dataToHistogram, $               ; The data to draw a histogram of.
   ADDCMD=addcmd, $                 ; Add this command to an cgWindow.
   AXISCOLORNAME=axisColorName, $   ; The axis color.
   BACKCOLORNAME=backcolorName, $   ; The background color.
   CHARSIZE=charsize, $
   DATACOLORNAME=datacolorName, $   ; The data color.
   _REF_EXTRA=extra, $              ; For passing extra keywords.
   FILE=file, $                     ; For specifying a color name file.
   FREQUENCY=frequency, $           ; Plot relative frequency, rather than density.
   LAYOUT=layout, $                 ; Select the grid layout.
   MAX_VALUE=max_value, $           ; The maximum value to plot.
   MIN_VALUE=min_value, $           ; The minimum value to plot.
   NOERASE=noerase, $               ; Set this keyword to avoid erasing when plot is drawn.
   MISSING=missing, $               ; The value that indicates "missing" data to be excluded from the histgram.
   OPLOT=overplot, $                ; Set if you want overplotting.
   OPROBABILITY=oprob, $            ; Overplot the cummulative probability distribution.
   OUTLINE=outline, $               ; Set this keyword if you wish to draw only the outline of the plot.
   PROBCOLORNAME=probColorName, $   ; The color for the probability plot, if it is used. By default, "blue".
   ROTATE=rotate, $                 ; Rotate plot so histogram bars are drawn left to right.
   THICK=thick, $                   ; Set to draw thicker lines and axes.
   XTITLE=xtitle, $
   YTITLE=ytitle, $                 ; The Y title.
   ;
   ; POLYFILL KEYWORDS
   ;
   FILLPOLYGON=fillpolygon, $       ; Set if you want filled polygons
   LINE_FILL=line_fill, $           ; Set if you want line-filled polygons.
   ORIENTATION=orientation, $       ; The orientation of the lines.
   PATTERN=pattern, $               ; The fill pattern.
   POLYCOLOR=polycolorname, $           ; The name of the polygon draw/fill color.
   SPACING=spacing, $               ; The spacing of filled lines.
   ;
   ; HISTOGRAM OUTPUT KEYWORDS
   ;
   HISTDATA=histdata, $
   LOCATIONS=locations, $
   OMAX=omax, $
   OMIN=omin, $
   PROBABILITY_FUNCTION=probability, $
   REVERSE_INDICES=ri, $
   ;
   ; HISTOGRAM INPUT KEYWORDS
   ;
   BINSIZE=binsize, $               ; The histogram bin size.
   L64=l64, $                       ; Input for HISTOGRAM.
   MAXINPUT=maxinput, $             ; The maximum value to HISTOGRAM.
   MININPUT=mininput, $             ; The minimum value to HISTOGRAM.
   NAN=nan, $                       ; Check for NAN.
   NBINS=nbins, $                   ; The number of bins to display.
   
   WINDOW=window                    ; Display this in an cgWindow.


   ; Catch any error in the cgHistoplot program.
   Catch, theError
   IF theError NE 0 THEN BEGIN
      Catch, /Cancel
      ok = Error_Message(!Error_State.Msg + '. Returning...')
      IF N_Elements(nancount) EQ 0 THEN BEGIN
            IF N_Elements(_dataToHistogram) NE 0 THEN dataToHistogram = Temporary(_dataToHistogram)
      ENDIF ELSE BEGIN
            IF nancount EQ 0 THEN BEGIN
                IF N_Elements(_dataToHistogram) NE 0 THEN dataToHistogram = Temporary(_dataToHistogram)
            ENDIF
      ENDELSE
      IF N_Elements(thisMulti) NE 0 THEN !P.Multi = thisMulti
      RETURN
   ENDIF

    ; Should this be added to a resizeable graphics window?
    IF Keyword_Set(addcmd) THEN window = 1
    IF Keyword_Set(window) AND ((!D.Flags AND 256) NE 0) THEN BEGIN
    
        ; If you are using a layout, you can't ever erase.
        IF N_Elements(layout) NE 0 THEN noerase = 1
        
        ; Have to do something different if we are overplotting or adding a command.
        IF Keyword_Set(overplot) OR Keyword_Set(addcmd) THEN BEGIN
            cgWindow, 'cgHistoplot', $          ; The program name.
               dataToHistogram, $               ; The data to draw a histogram of.
               AXISCOLORNAME=axisColorName, $   ; The axis color.
               BACKCOLORNAME=backcolorName, $   ; The background color.
               CHARSIZE=charsize, $
               DATACOLORNAME=datacolorName, $   ; The data color.
               _EXTRA=extra, $                  ; For passing extra keywords.
               FILE=file, $                     ; For specifying a color name file.
               FREQUENCY=frequency, $           ; Plot relative frequency, rather than density.
               LAYOUT=layout, $
               MAX_VALUE=max_value, $           ; The maximum value to plot.
               MIN_VALUE=min_value, $           ; The minimum value to plot.
               MISSING=missing, $               ; The value that indicates "missing" data to be excluded from the histgram.
               NOERASE=noerase, $               ; Set this keyword to avoid erasing when plot is drawn.               OPLOT=overplot, $                ; Set if you want overplotting.
               OPROBABILITY=oprob, $            ; Overplot the cummulative probability distribution.
               OUTLINE=outline, $               ; Set this keyword if you wish to draw only the outline of the plot.
               PROBCOLORNAME=probColorName, $   ; The color for the probability plot, if it is used. By default, "blue".
               ROTATE=rotate, $
               THICK=thick, $                   ; Set to draw thicker lines and axes.
               XTITLE=xtitle, $
               YTITLE=ytitle, $                 ; The Y title.
               ;
               ; POLYFILL KEYWORDS
               ;
               FILLPOLYGON=fillpolygon, $       ; Set if you want filled polygons
               LINE_FILL=line_fill, $           ; Set if you want line-filled polygons.
               ORIENTATION=orientation, $       ; The orientation of the lines.
               PATTERN=pattern, $               ; The fill pattern.
               POLYCOLOR=polycolorname, $           ; The name of the polygon draw/fill color.
               SPACING=spacing, $               ; The spacing of filled lines.
               ;
               ; HISTOGRAM OUTPUT KEYWORDS
               ;
               HISTDATA=histdata, $
               LOCATIONS=locations, $
               OMAX=omax, $
               OMIN=omin, $
               PROBABILITY_FUNCTION=probability, $
               REVERSE_INDICES=ri, $
               ;
               ; HISTOGRAM INPUT KEYWORDS
               ;
               BINSIZE=binsize, $               ; The histogram bin size.
               L64=l64, $                       ; Input for HISTOGRAM.
               MAXINPUT=maxinput, $             ; The maximum value to HISTOGRAM.
               MININPUT=mininput, $             ; The minimum value to HISTOGRAM.
               NAN=nan, $                       ; Check for NAN.
               NBINS=nbins, $                   ; The number of bins to display.
               ADDCMD=1
            RETURN
        ENDIF 
        
        ; Otherwise, we are just replacing the commands in a new or existing window.
            void = cgQuery(COUNT=wincnt)
            IF wincnt EQ 0 THEN replaceCmd=0 ELSE replaceCmd=1
            cgWindow, 'cgHistoplot', $          ; The program name.
               dataToHistogram, $               ; The data to draw a histogram of.
               AXISCOLORNAME=axisColorName, $   ; The axis color.
               BACKCOLORNAME=backcolorName, $   ; The background color.
               CHARSIZE=charsize, $
               DATACOLORNAME=datacolorName, $   ; The data color.
               _EXTRA=extra, $                  ; For passing extra keywords.
               FILE=file, $                     ; For specifying a color name file.
               FREQUENCY=frequency, $           ; Plot relative frequency, rather than density.
               LAYOUT=layout, $
               MAX_VALUE=max_value, $           ; The maximum value to plot.
               MIN_VALUE=min_value, $           ; The minimum value to plot.
               MISSING=missing, $               ; The value that indicates "missing" data to be excluded from the histgram.
               NOERASE=noerase, $               ; Set this keyword to avoid erasing when plot is drawn.               OPLOT=overplot, $                ; Set if you want overplotting.
               OPLOT=overplot, $                ; Set if you want overplotting.
               OPROBABILITY=oprob, $            ; Overplot the cummulative probability distribution.
               OUTLINE=outline, $               ; Set this keyword if you wish to draw only the outline of the plot.
               PROBCOLORNAME=probColorName, $   ; The color for the probability plot, if it is used. By default, "blue".
               ROTATE=rotate, $
               THICK=thick, $                   ; Set to draw thicker lines and axes.
               XTITLE=xtitle, $
               YTITLE=ytitle, $                 ; The Y title.
               ;
               ; POLYFILL KEYWORDS
               ;
               FILLPOLYGON=fillpolygon, $       ; Set if you want filled polygons
               LINE_FILL=line_fill, $           ; Set if you want line-filled polygons.
               ORIENTATION=orientation, $       ; The orientation of the lines.
               PATTERN=pattern, $               ; The fill pattern.
               POLYCOLOR=polycolorname, $           ; The name of the polygon draw/fill color.
               SPACING=spacing, $               ; The spacing of filled lines.
               ;
               ; HISTOGRAM OUTPUT KEYWORDS
               ;
               HISTDATA=histdata, $
               LOCATIONS=locations, $
               OMAX=omax, $
               OMIN=omin, $
               PROBABILITY_FUNCTION=probability, $
               REVERSE_INDICES=ri, $
               ;
               ; HISTOGRAM INPUT KEYWORDS
               ;
               BINSIZE=binsize, $               ; The histogram bin size.
               L64=l64, $                       ; Input for HISTOGRAM.
               MAXINPUT=maxinput, $             ; The maximum value to HISTOGRAM.
               MININPUT=mininput, $             ; The minimum value to HISTOGRAM.
               NAN=nan, $                       ; Check for NAN.
               NBINS=nbins, $                   ; The number of bins to display.
               REPLACECMD=replaceCmd
            RETURN
    ENDIF
    
   ; Set up PostScript device for working with colors.
   IF !D.Name EQ 'PS' THEN Device, COLOR=1, BITS_PER_PIXEL=8
    
   ; Check for positional parameter.
   IF N_Elements(dataToHistogram) EQ 0 THEN Message, 'Must pass data to histogram.'
   IF N_Elements(charsize) EQ 0 THEN charsize = cgDefCharSize()
   
   ; What kind of data are we doing a HISTOGRAM on?
   dataType = Size(dataToHistogram, /TYPE)
      
   ; Check the data for NANs and alert the user if the NAN keyword is not set.
   IF dataType EQ 4 OR datatype EQ 5 THEN BEGIN
        goodIndices = Where(Finite(dataToHistogram), count, NCOMPLEMENT=nancount, COMPLEMENT=nanIndices)
        IF nancount GT 0 THEN BEGIN
           IF ~Keyword_Set(nan) THEN BEGIN
               Message, 'NANs found in the data. NAN keyword is set to 1.', /INFORMATIONAL
               nan = 1
           ENDIF
        ENDIF 
   ENDIF 
   
   ; The only sensible way to proceed is to make a copy of the data. Otherwise, I'll have
   ; a devil of a time putting it back together again at the end. There is a bug in
   ; HISTOGRAM when using BYTE data, so convert that here
   IF N_Elements(_dataToHistogram) EQ 0 THEN BEGIN
      IF Size(dataToHistogram, /TNAME) EQ 'BYTE' THEN BEGIN
          _dataToHistogram = Fix(dataToHistogram) 
       ENDIF ELSE BEGIN
          _dataToHistogram = dataToHistogram
       ENDELSE
   ENDIF
   
   ; If you have any "missing" data, then the data needs to be converted to float
   ; and the missing data set to F_NAN.
   IF N_Elements(missing) NE 0 THEN BEGIN
      missingIndices = Where(_dataToHistogram EQ missing, missingCount)
      IF missingCount GT 0 THEN BEGIN
         CASE datatype OF
            4: _dataToHistogram[missingIndices] = !Values.F_NAN
            5: _dataToHistogram[missingIndices] = !Values.D_NAN
            ELSE: BEGIN
                _dataToHistogram = Float(_dataToHistogram)
                dataType = 4
                _dataToHistogram[missingIndices] = !Values.F_NAN
                END
         ENDCASE
         nan = 1
      ENDIF ELSE BEGIN
        IF missingCount EQ N_Elements(_dataToHistogram) THEN $
            Message, 'All values are "missing"!'
      ENDELSE
   ENDIF
   
   ; Check for histogram keywords.
   IF N_Elements(binsize) EQ 0 THEN BEGIN
      range = Max(_dataToHistogram, /NAN) - Min(_dataToHistogram, /NAN)
      IF N_Elements(nbins) EQ 0 THEN BEGIN  ; Scott's Choice
         binsize = (3.5D * StdDev(_dataToHistogram, /NAN))/N_Elements(_dataToHistogram)^(1./3.0D) 
         IF (dataType LE 3) OR (dataType GE 12) THEN binsize = Round(binsize) > 1
         binsize = Convert_To_Type(binsize, dataType)
      ENDIF ELSE BEGIN
         binsize = range / (nbins -1)
         IF dataType LE 3 THEN binsize = Round(binsize) > 1
         binsize = Convert_To_Type(binsize, dataType)
      ENDELSE
   ENDIF ELSE BEGIN
       IF Size(binsize, /TYPE) NE dataType THEN BEGIN
          IF dataType LE 3 THEN binsize = Round(binsize) > 1
          binsize = Convert_To_Type(binsize, dataType)
       ENDIF
   ENDELSE

   ; Check for keywords.
   IF N_Elements(backColorName) EQ 0 THEN backColorName = "White"
   IF N_Elements(dataColorName) EQ 0 THEN dataColorName = "Indian Red"
   
    ; Set up the layout, if necessary.
    IF N_Elements(layout) NE 0 THEN BEGIN
       thisMulti = !P.Multi
       totalPlots = layout[0]*layout[1]
       !P.Multi = [0,layout[0], layout[1], 0, 0]
       IF layout[2] EQ 1 THEN BEGIN
            noerase = 1
            !P.Multi[0] = 0
       ENDIF ELSE BEGIN
            !P.Multi[0] = totalPlots - layout[2] + 1
       ENDELSE
    ENDIF

   ; Choose an axis color.
   IF N_Elements(axisColorName) EQ 0 AND N_Elements(saxescolor) NE 0 THEN axisColorName = saxescolor
   IF N_Elements(axisColorName) EQ 0 THEN BEGIN
       IF (Size(backColorName, /TNAME) EQ 'STRING') && (StrUpCase(backColorName) EQ 'WHITE') THEN BEGIN
            IF !P.Multi[0] EQ 0 THEN axisColorName = 'BLACK'
       ENDIF
       IF N_Elements(axisColorName) EQ 0 THEN BEGIN
           IF !D.Name EQ 'PS' THEN BEGIN
                axisColorName = 'BLACK' 
           ENDIF ELSE BEGIN
                IF (!D.Window GE 0) AND ((!D.Flags AND 256) NE 0) THEN BEGIN
                    pixel = cgSnapshot(!D.X_Size-1,  !D.Y_Size-1, 1, 1)
                    IF Total(pixel) EQ 765 THEN axisColorName = 'BLACK'
                    IF Total(pixel) EQ 0 THEN axisColorName = 'WHITE'
                    IF N_Elements(axisColorName) EQ 0 THEN axisColorName = 'OPPOSITE'
                ENDIF ELSE axisColorName = 'OPPOSITE'
           ENDELSE
       ENDIF
   ENDIF
   IF N_Elements(axisColorName) EQ 0 THEN axisColor = !P.Color ELSE axisColor = axisColorName
    
   IF N_Elements(polycolorname) EQ 0 THEN polycolorname = "Rose"
   IF N_Elements(probColorname) EQ 0 THEN probColorname = "Blue"
   frequency = Keyword_Set(frequency)
   line_fill = Keyword_Set(line_fill)
   IF line_fill THEN fillpolygon = 1
   fillpolygon = Keyword_Set(fillpolygon)
   IF fillpolygon THEN BEGIN
      IF N_Elements(orientation) EQ 0 THEN orientation = 0
      IF N_Elements(spacing) EQ 0 THEN spacing = 0
   ENDIF
   IF N_Elements(mininput) EQ 0 THEN mininput = Min(_dataToHistogram, NAN=nan)
   IF N_Elements(maxinput) EQ 0 THEN maxinput = Max(_dataToHistogram, NAN=nan)
   IF N_Elements(thick) EQ 0 THEN thick = 1.0

   ; Load plot colors.
   TVLCT, r, g, b, /GET
   axisColor = cgColor(axisColorName, FILE=file)
   dataColor = cgColor(datacolorName, FILE=file)
   backColor = cgColor(backColorName, FILE=file)
   polyColor = cgColor(polyColorName, FILE=file)
   probColor = cgColor(probColorName, FILE=file)

   ; Set up some labels.
   IF frequency THEN BEGIN
      IF Keyword_Set(rotate) THEN BEGIN
          IF N_Elements(xtitle) EQ 0 THEN xtitle = 'Relative Frequency'
          xtickformat = '(F6.4)'
      ENDIF ELSE BEGIN
          IF N_Elements(ytitle) EQ 0 THEN ytitle = 'Relative Frequency'
          ytickformat = '(F6.4)'
      ENDELSE
   ENDIF ELSE BEGIN
      IF Keyword_Set(rotate) THEN BEGIN
          IF N_Elements(xtitle) EQ 0 THEN xtitle = 'Histogram Density'
          xtickformat = '(I)'
      ENDIF ELSE BEGIN
          IF N_Elements(ytitle) EQ 0 THEN ytitle = 'Histogram Density'
          ytickformat = '(I)'
      ENDELSE
   ENDELSE
   
  ; Calculate the histogram.
   histdata = Histogram(_dataToHistogram, $
      BINSIZE=binsize, $
      L64=l64, $
      MAX=maxinput, $
      MIN=mininput, $
      NAN=nan, $
      LOCATIONS=locations, $
      OMAX=omax, $
      OMIN=omin, $
      REVERSE_INDICES=ri)
   IF frequency THEN histdata = Float(histdata)/N_Elements(_dataToHistogram)
   
   ; Need a probability distribution?
   IF Arg_Present(probablity) OR Keyword_Set(oprob) THEN BEGIN
       cumTotal = Total(histData, /CUMULATIVE)
       probability = Scale_Vector(cumTotal, 0, 1)
   ENDIF

   ; Calculate the range of the plot output.
   IF N_Elements(min_value) EQ 0 THEN min_value = 0
   IF N_Elements(max_value) EQ 0 THEN max_value = Max(histData) * 1.05
   IF Keyword_Set(rotate) THEN BEGIN
       xmin = min_value
       xmax = max_value
       ymin = Double(omin) - binsize
       ymax = Double(omax) + (binsize * 2)
   ENDIF ELSE BEGIN
       ymin = min_value
       ymax = max_value
       xmin = Double(omin) - binsize
       xmax = Double(omax) + (binsize * 2)
   ENDELSE
   
   ; Save the current system variables, if doing multiple plots.
   IF Total(!P.MULTI) NE 0 THEN BEGIN
      bangp = !P
      bangx = !X
      bangy = !Y
      bangmap = !MAP
   ENDIF
   
   ; Unless we are overplotting, draw the plot to establish a data coordinate system.
   ; Don't actually display anything yet, because we may have to repair damage caused
   ; by polygon filling.
   xrange = [xmin, xmax]
   yrange = [ymin, ymax]
   IF ~Keyword_Set(overplot) THEN BEGIN
       Plot, [0,0], xrange=xrange, yrange=yrange, $             
             Background=backColor, $
             Color=axisColor, $                       ; The color of the axes.
             Charsize=charsize, $
             NoData=1, $                              ; Draw the axes only. No data.
             NOERASE=noerase, $
             XTHICK=thick, $                          ; Axes thicker, if needed.
             YTHICK=thick, $
             XStyle=5, $                              ; Exact axis scaling. No autoscaled axes.
             YMinor=0, $                              ; No minor tick mark on X axis.
             YStyle=5, $                              ; Exact axis scaling. No autoscaled axes.
             XTickformat='(A1)', $                    ; No format. Nothing drawn
             YTickformat='(A1)', $                    ; No format. Nothing drawn
             _Strict_Extra=extra                      ; Pass any extra PLOT keywords.
   ENDIF

   ; Save the after-plot system variables, if doing multiple plots.
   ; You will need it to advance the plots in !P.MULTI, since you draw
   ; the plots with NOERASE.
   IF Total(!P.MULTI) NE 0 THEN BEGIN
       bangAfterp = !P
       bangAfterx = !X
       bangAftery = !Y
       bangAftermap = !MAP
   ENDIF

   ; Do we need to have things be filled?
   IF Keyword_Set(fillpolygon) THEN BEGIN

       ncolors = N_Elements(polycolor)

      ; Are we line filling?
      IF line_fill THEN BEGIN

         norient = N_Elements(orientation)
         nspace = N_Elements(spacing)
         step = (xrange[1] - xrange[0]) / (binsize + 1)
         IF Keyword_Set(rotate) THEN BEGIN
            start = yrange[0] + binsize
         ENDIF ELSE BEGIN
            start = xrange[0] + binsize
         ENDELSE

         endpt = start + binsize

         FOR j=0,N_Elements(histdata)-1 DO BEGIN
            IF Keyword_Set(rotate) THEN BEGIN
               y = [start, start, endpt, endpt, start]
               x = [0, histdata[j], histdata[j], 0, 0]
            ENDIF ELSE BEGIN
               x = [start, start, endpt, endpt, start]
               y = [0, histdata[j], histdata[j], 0, 0]
            ENDELSE
            fillcolor = polycolor[j MOD ncolors]
            orient = orientation[j MOD norient]
            space = spacing[j MOD nspace]
            PolyFill, x, y, COLOR=fillColor, /LINE_FILL, ORIENTATION=orient, $
               PATTERN=pattern, SPACING=space, NOCLIP=0
            start = start + binsize
            endpt = start + binsize
         ENDFOR

      ENDIF ELSE BEGIN ; Normal polygon color fill.

         step = (xrange[1] - xrange[0]) / (binsize + 1)
         IF Keyword_Set(rotate) THEN BEGIN
            start = yrange[0] + binsize
         ENDIF ELSE BEGIN
            start = xrange[0] + binsize
         ENDELSE
         endpt = start + binsize
         FOR j=0,N_Elements(histdata)-1 DO BEGIN
            IF Keyword_Set(rotate) THEN BEGIN
               y = [start, start, endpt, endpt, start]
               x = [0, histdata[j], histdata[j], 0, 0]
            ENDIF ELSE BEGIN
               x = [start, start, endpt, endpt, start]
               y = [0, histdata[j], histdata[j], 0, 0]
            ENDELSE
            fillcolor = polycolor[j MOD ncolors]
            PolyFill, x, y, COLOR=fillColor, NOCLIP=0
            start = start + binsize
            endpt = start + binsize
         ENDFOR

      ENDELSE
   ENDIF
      
   ; Restore the pre-plot system variables.
   IF Total(!P.MULTI) NE 0 THEN BEGIN
       !P = bangp
       !X = bangx
       !Y = bangy
       !MAP = bangmap
    ENDIF

   IF ~Keyword_Set(overplot) THEN BEGIN
       xrange = [xmin, xmax]
       yrange = [ymin, ymax]
       IF Keyword_Set(rotate) THEN BEGIN
       Plot, [0,0], xrange=xrange, yrange=yrange, $             
             Background=backColor, $
             Charsize=charsize, $
             Color=axisColor, $                       ; The color of the axes.
             NoData=1, $                              ; Draw the axes only. No data.
             XThick=thick, $  
             YThick=thick, $
             YStyle=9, $                              ; Exact axis scaling. No autoscaled axes.
             XMinor=1, $                              ; No minor tick mark on X axis.
             XStyle=1, $                              ; Exact axis scaling. No autoscaled axes.
             XTickformat=xtickformat, $               ; Y Tickformat
             YTickformat=ytickformat, $
             XTitle=xtitle, $                         ; Y Title
             YTitle=ytitle, $
             NoErase=1, $
             YTicklen=-0.025, $
             _Strict_Extra=extra                      ; Pass any extra PLOT keywords.
       ENDIF ELSE BEGIN
       Plot, [0,0], xrange=xrange, yrange=yrange, $             
             Background=backColor, $
             Charsize=charsize, $
             Color=axisColor, $                       ; The color of the axes.
             NoData=1, $                              ; Draw the axes only. No data.
             XThick=thick, $  
             YThick=thick, $
             XStyle=9, $                              ; Exact axis scaling. No autoscaled axes.
             YMinor=1, $                              ; No minor tick mark on X axis.
             YStyle=1, $                              ; Exact axis scaling. No autoscaled axes.
             XTickformat=xtickformat, $               ; Y Tickformat
             YTickformat=ytickformat, $
             XTitle=xtitle, $                         ; Y Title
             YTitle=ytitle, $
             NoErase=1, $
             XTicklen=-0.025, $
             _Strict_Extra=extra                      ; Pass any extra PLOT keywords.
        ENDELSE
             
        IF Keyword_Set(rotate) THEN BEGIN
            Axis, !X.CRange[1], !Y.CRange[0], YAXIS=1, YTickformat='(A1)', YMINOR=1, $
                COLOR=axisColor, YSTYLE=1, YTHICK=thick, CHARSIZE=charsize
        ENDIF ELSE BEGIN
            Axis, !X.CRange[0], !Y.CRange[1], XAXIS=1, XTickformat='(A1)', XMINOR=1, $
                COLOR=axisColor, XSTYLE=1, XTHICK=thick, CHARSIZE=charsize
        ENDELSE
    ENDIF
    
    step = (xrange[1] - xrange[0]) / (binsize + 1)
    IF Keyword_Set(rotate) THEN BEGIN
        start = yrange[0] + binsize
    ENDIF ELSE BEGIN
        start = xrange[0] + binsize
    ENDELSE
    endpt = start + binsize
    ystart = 0
    jend = N_Elements(histdata)-1
    FOR j=0,jend DO BEGIN
        IF Keyword_Set(outline) THEN BEGIN
           IF Keyword_Set(rotate) THEN BEGIN
               PLOTS, [ystart, histdata[j]], [start, start], COLOR=dataColor, THICK=thick, NOCLIP=0
               PLOTS, [histdata[j], histdata[j]], [start, endpt], COLOR=dataColor, THICK=thick, NOCLIP=0
               IF j EQ jend THEN $
                  Plots, [histdata[j], 0], [endpt, endpt], COLOR=dataColor, THICK=thick, NOCLIP=0
           ENDIF ELSE BEGIN
               PLOTS, [start, start], [ystart, histdata[j]], COLOR=dataColor, THICK=thick, NOCLIP=0
               PLOTS, [start, endpt], [histdata[j], histdata[j]], COLOR=dataColor, THICK=thick, NOCLIP=0
               IF j EQ jend THEN $
                  Plots, [endpt, endpt], [histdata[j], 0], COLOR=dataColor, THICK=thick, NOCLIP=0
           ENDELSE
           start = start + binsize
           endpt = start + binsize
           ystart = histdata[j]
        ENDIF ELSE BEGIN
           x = [start, start, endpt, endpt, start]
           y = [0, histdata[j], histdata[j], 0, 0]
           IF Keyword_Set(rotate) THEN BEGIN
              PLOTS, y, x, COLOR=dataColor, NOCLIP=0, THICK=thick
           ENDIF ELSE BEGIN
              PLOTS, x, y, COLOR=dataColor, NOCLIP=0, THICK=thick
           ENDELSE
           start = start + binsize
           endpt = start + binsize
        ENDELSE
    ENDFOR
   
   ; Need to overplot probability function?
   IF Keyword_Set(oprob) THEN BEGIN
        IF Keyword_Set(rotate) THEN BEGIN
            probx = Scale_Vector(cumTotal, !X.CRange[0], !X.CRange[1])
            IF Keyword_Set(oplot) THEN bsize = 0 ELSE bsize = binsize
            proby = Scale_Vector(Findgen(N_Elements(probx)), !Y.CRange[0] + bsize, !Y.CRange[1] - bsize)
            Oplot, probx, proby, COLOR=probcolor
        ENDIF ELSE BEGIN
            proby = Scale_Vector(cumTotal, !Y.CRange[0], !Y.CRange[1])
            IF Keyword_Set(oplot) THEN bsize = 0 ELSE bsize = binsize
            probx = Scale_Vector(Findgen(N_Elements(proby)), !X.CRange[0] + bsize, !X.CRange[1] - bsize)
            Oplot, probx, proby, COLOR=probcolor
        ENDELSE
   ENDIF

   ; Advance the plot for !P.Multi purposes.
   IF Total(!P.MULTI) NE 0 THEN BEGIN
       !P = bangAfterp 
       !X = bangAfterx 
       !Y = bangAftery
       !MAP = bangAftermap
   ENDIF

   ; Clean up. But you really can't do this in the Z-buffer. 
   IF !D.Name NE 'Z' THEN TVLCT, r, g, b
   
    ; Clean up if you are using a layout.
    IF N_Elements(layout) NE 0 THEN !P.Multi = thisMulti

END

