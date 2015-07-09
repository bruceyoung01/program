Pro CleanPlot		;Set System Plot Variables to Default Values
;----------------------------------------------------------------------------
;+
; NAME:
;	CLEANPLOT
; PURPOSE:
;	Reset all system variables (!P,!X,!Y,!Z) to their default values
; EXPLANATION:
;	Reset all system variables (!P,!X,!Y,!Z) which are set by the user 
;	and which affect plotting to their default values.
;
; CALLING SEQUENCE:
;	Cleanplot
;
; INPUTS:	
;	None
;
; OUTPUTS:	
;	None
;
; SIDE EFFECTS:	
;	The system variables that concern plotting are reset
;	to their default values.  A message is output for each
;	variable changed.   The CRANGE, S, WINDOW, and REGION fields of the
;	!X, !Y, and !Z system variables are not checked since these are 
;	set by the graphics device and not by the user.    
;
; PROCEDURE:
;	This does NOT reset the plotting device.
;	This does not change any system variables that don't control plotting.
;
; RESTRICTIONS:
;	If user default values for !P, !X, !Y and !Z are different from
;	the defaults adopted below, user should change P_old etc accordingly
;
; MODIFICATION HISTORY:
;     Written IDL Version 2.3.0  W. Landsman & K. Venkatakrishna May '92
;     Handle new system variables in V3.0.0     W. Landsman   Dec 92
;     Assume user has at least V3.0.0           W. Landsman   August 95
;     V5.0 has 60 instead of 30 TICKV values    W. Landsman   Sep. 97
;-
;	
;----------------------------------------------------------------------------
   On_error,2

   if !VERSION.RELEASE GT '5.0' then nt = 60 else nt = 30

   P_old = { BACKGROUND: 0L,CHARSIZE:0.0, CHARTHICK:0.0,  $
             CLIP:[0L,0,639,511,0,0], $ ;Not used
             COLOR : !D.N_COLORS-1, FONT: -1L, LINESTYLE: 0L, MULTI:lonarr(5),$
             NOCLIP: 0L, NOERASE: 0L, NSUM: 0L, POSITION: fltarr(4),$
             PSYM: 0L, REGION: fltarr(4), SUBTITLE:'', SYMSIZE:0.0, T:fltarr(4,4),$
             T3D:0L, THICK: 0.0, TITLE:'', TICKLEN:0.02, CHANNEL:0L }
   
   X_old = { TITLE: '', TYPE: 0L, STYLE:0L, TICKS:0L, TICKLEN:0.0, $
             THICK: 0.0, RANGE:fltarr(2), CRANGE:fltarr(2), S:fltarr(2), $
             MARGIN: [10.0 ,3.0], OMARGIN: fltarr(2), WINDOW: fltarr(2), $
             REGION: fltarr(2), CHARSIZE:0.0, MINOR: 0L, TICKV:fltarr(nt), $
             TICKNAME: strarr(nt), GRIDSTYLE: 0L, TICKFORMAT: '' } 

   Y_old = X_old
   Y_old.MARGIN = [4.0, 2.0]
   
   Z_old = X_old
   Z_old.MARGIN = [0.0, 0.0]

   P_var = tag_names(!P)
;                               Reset !P to its default value

   if !D.NAME EQ 'PS' then P_old.color = 0
   for i=0, N_elements(P_var)-1 do begin
      if i NE 3 then begin
         n = N_elements(!P.(i))
         if ( total( (!P.(i) EQ P_old.(i))) NE n ) then Begin
   ; ###    Print, 'Clearing !P.'+P_var(i)+', old value =',!P.(i)
            !P.(i) = P_old.(i)
         EndIf
      endif
   endfor
;                               Reset !X !Y and !Z to their default values
   X_var = tag_names(!X)
   Y_var = tag_names(!Y)
   Z_var = tag_names(!Z)

   for i = 0, N_elements(X_var)-1 do begin
      if total( i EQ [7,8,11,12] ) EQ 0 then begin ;Skip S,CRANGE,WINDOW,REGION
         n = N_elements(!X.(i))

         if ( total( (!X.(i) EQ X_old.(i))) NE n ) then Begin 
   ; ###    Print,'Clearing !X.'+X_var(i)+' old value = ', !X.(i)
            !X.(i) = X_old.(i)
         EndIf
 
         if (total( (!Y.(i) EQ Y_old.(i))) NE n ) then Begin
   ; ###    Print,'Clearing !Y.'+Y_var(i)+' old value = ', !Y.(i)
            !Y.(i) = Y_old.(i)
         EndIf

         if (total( (!Z.(i) EQ Z_old.(i))) NE n) then Begin
   ; ###    Print,'Clearing !Z.'+Z_var(i)+' old value = ', !Z.(i)
            !Z.(i) = Z_old.(i)
         EndIf
      endif
   endfor

   Return                       ;Completed
End
