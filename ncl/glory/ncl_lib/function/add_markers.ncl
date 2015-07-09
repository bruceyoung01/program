;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE 1 : ADD_MARKERS                                           ;
; PURPOSE OF THIS PROCEDURE :                                         ;
; PLOT MARKERS ON THE IMAGE                                           ;
; BRUCE                                                               ;
; JULY 14 21:56 2011                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure adds markers to a plot, making sure that each
; set is returned to a unique variable name, and that this
; variable is retained even outside this procedure call.
;
procedure add_markers(wks,plot,x,y,color,type,size,thick)
local pmres, str
begin
  pmres = True
  pmres@gsMarkerColor = color
  pmres@gsMarkerIndex = type
  pmres@gsMarkerSizeF = size
  pmres@gsMarkerThicknessF=thick
  str = unique_string("polymarker")  ; "unique_string" will return a unique
                                     ; string every time it is called from
                                     ;  within a single NCL session.
;
; You can then use this unique string as an attribute variable name
; that gets attached to the plot variable. This ensures that this
; value will live for the duration of the script.
;
  plot@$str$ = gsn_add_polymarker(wks, plot, x, y, pmres)
end
