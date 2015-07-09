; $Id: ctm_draw_cube.pro,v 1.50 2002/05/24 14:03:52 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_DRAW_CUBE
;
; PURPOSE:
;        Interface between CTM_PLOT.PRO and CTM_SLICER3.PRO.
;        Calls CTM_SLICER3 to visualize a 3-D data cube.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        CTM_DRAW_CUBE
;
; INPUTS:
;        DATA -> The data array to be visualized.  Data must have
;             3 dimensions, and be of at least size (2,2,2).
;
; KEYWORD PARAMETERS:
;        XSCALE, YSCALE, ZSCALE -> Scale factors by which to stretch
;             the size of the visualized data cube in X, Y, and Z 
;             dimensions.  The rescaling is done via the CONGRID 
;             function, hence XSCALE, YSCALE, and ZSCALE may be
;             floating point numbers.  Defaults are XSCALE=1, YSCALE=1
;             and ZSCALE=2 (to stretch the Z-axis).
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        CTM_SLICER3 
;
; REQUIREMENTS:
;        Requires GAMAP package subroutines.
;
; NOTES:
;        Based on program DCUBE.PRO by Stein Vidar Hagfors Haugan, 12/04/98
;
; EXAMPLE:
;        CTM_DRAW_CUBE, Data, ZScale=4
;
;            ; will invoke CTM_SLICER3 to visualize the DATA array,
;            ; and will stretch the Z-axis by a factor of 4.
;
; MODIFICATION HISTORY:
;        bmy, 15 Jan 1999: VERSION 1.00
;        bmy, 19 Jan 1999: - now calls CTM_SLICER3, which was 
;                            renamed from SLICER3
;        bmy, 20 Jan 1999: - use TVLCT to save the old color table
;                            and to restore it before quitting.
;                          - Free the PDATA pointer before exiting
;        mgs, 22 Jan 1999: - also saves !X, !Y, !P, and !D.Window now
;
;-
; Copyright (C) 1999, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_draw_cube"
;-------------------------------------------------------------
 

pro CTM_Draw_Cube, Data,                         $
                   XScale=XScale, YScale=YScale, $
                   ZScale=ZScale, _EXTRA=e
 
   ;===================================================
   ; Set default scale factors to 1 (X,Y) and 3 (Z)
   ;===================================================
   if ( N_Elements( XScale ) eq 0 ) then XScale = 1
   if ( N_Elements( YScale ) eq 0 ) then YScale = 1
   if ( N_Elements( ZScale ) eq 0 ) then ZScale = 2

   ;===================================================
   ; Make sure DATA is 3-D...otherwise return
   ;===================================================   
   SData = Size( Data )
  
   if ( SData[0] ne 3 ) then begin
      Message, 'Data must have 3 dimensions!', /Continue
      return
   endif
 
   ;===================================================
   ; Stretch the DATA block along the X, Y, Z axes
   ; according to XSCALE, YSCALE, ZSCALE
   ;===================================================
   NewData = ConGrid( Data, SData[1] * XScale, $
                            SData[2] * YScale, $
                            SData[3] * ZScale  )

   ;===================================================
   ; Construct a pointer to the stretched DATA block
   ;===================================================
   PData = Ptr_New( BytScl( NewData ) )
  
   ;===================================================
   ; Call TVLCT to save the original color table
   ; Call CTM_SLICER3 to visualize the data
   ; Call TVLCT to restore the original color table
; ### If we use the /MODAL keyword to slicer (with the 
; XMANAGER /MODAL commented out as is), we should have
; colors AND system variables !P, !X, !Y, !Z, !D.Window
; restored upon exit. But doesn't do it ...
   ;===================================================
   XSave = !X
   YSave = !Y
   PSave = !P
   WinSave = !D.Window

   TVLct, R_Old, G_Old, B_Old, /Get

   CTM_Slicer3, PData, _EXTRA=e   ; ,/MODAL

   TVLct, R_Old, G_Old, B_Old
   WSet,WinSave
   !P = PSave
   !Y = YSave
   !X = XSave

   ;===================================================
   ; Free the pointer and exit
   ;===================================================
   Ptr_Free, PData

end
 
