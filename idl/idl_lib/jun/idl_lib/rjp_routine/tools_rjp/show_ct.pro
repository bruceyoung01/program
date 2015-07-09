;+
; NAME:
;
;       SHOW_CT
;       
; PURPOSE:
;
;       Make a window and show the first 32 colors in the current
;       color table.
;	    
; CATEGORY:
;       Colors
;
; CALLING SEQUENCE:
; 
;	SHOW_CT
;	
; MODIFICATION HISTORY:
; 
;	David L. Windt, Bell Labs, November 1989
;	windt@bell-labs.com
;
;	DLW, November, 1997 - Removed default window position values, so
;                             that the window is now visible on any
;                             size display.
;	
;-
pro show_ct
on_error,2
old_window=!d.window
old_background=!p.background

!p.background=0			; use black background
window,xsiz=100,ysize=500,title='Color Table',/free
plot,[0,0],xmar=[0,0],ymar=[0,0],xrange=[0,1.5], $
  yrange=[0,32],/yst,color=0,thick=10
for i=1,31 do oplot,[0,0]+i,color=i,thick=10
for i=1,31 do xyouts,.8,i,i,size=.75

wset,old_window
!p.background=old_background
finish:
return
end
