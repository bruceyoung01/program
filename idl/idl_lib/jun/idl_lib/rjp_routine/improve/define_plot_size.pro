
;+
;define_plot_size
;     thick     = 2    ; line thickness
;     charthick = 2    ; character thickness
;     charsize  = 1.5  ; character size
;     symsize   = 2    ; symbol size
;     symthick  = 2    ; symbol thickness
;-

     thin      = 1.
     dthin     = 1.2
     thick     = 1.5    ; line thickness
     dthick    = 3.
     charthick = 1    ; character thickness
     dcharthick= 1
     charsize  = 1.5  ; character size
     symsize   = 1.5  ; symbol size
     symthick  = 1.5  ; symbol thickness
     tcharsize = 1.5
     csfac     = 1.2
 if (!D.NAME eq 'PS') then thin      = 2
 if (!D.NAME eq 'PS') then dthin     = 4
 if (!D.NAME eq 'PS') then thick     = 6    ; line thickness
 if (!D.NAME eq 'PS') then dthick    = 8
 if (!D.NAME eq 'PS') then charthick = 4    ; character thickness
 if (!D.NAME eq 'PS') then dcharthick = 6    ; character thickness
 if (!D.NAME eq 'PS') then charsize  = 1.4  ; character size
 if (!D.NAME eq 'PS') then Tcharsize = 1.8  ; Title character size
 if (!D.NAME eq 'PS') then symsize   = 1.3  ; symbol size
 if (!D.NAME eq 'PS') then symthick  = 6    ; symbol thickness
 if (!D.NAME eq 'PS') then csfac     = 1.2  ; 

   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A), /FILL
