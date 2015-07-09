; $Id: errorbar.pro,v 1.1.1.1 2007/07/17 20:41:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;	 ERRORBAR
;
; PURPOSE:
;        Plots error bars atop data points, 
;        along the X or Y dimension.
;  
; CATEGORY:
;	 Plotting
;
; CALLING SEQUENCE:
;	 ERRORBAR, XARR, YARR, ERROR [ , Keywords ]
;
; INPUTS:
;        XARR, YARR -> Arrays of X and Y values correspoinding
;             to the location of the data points.  XARR and YARR
;             must have the same number of elements.
;
;        ERROR -> An array (or scalar) of error values.  If ERROR
;             is a scalar, its value will be used for all data
;             points.  If ERROR is an array, it must be of the
;             same dimension as XARR and YARR, or else an error
;             message will be generated.
;
; KEYWORD PARAMETERS:
;        /X -> If set, will plot error bars along the X-dimension.
;             Default is to plot error bars along the Y-dimension.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS
;        None
;
; NOTES: 
;        ERRORBAR just plots the error bars, but not the
;        data points.  This is useful if you want to use 
;        different colors for data points and error bars.
;
; MODIFICATION HISTORY:
;        bmy, 21 Jul 1999: VERSION 1.01
;                          - based on IDL routine OPLOTERR
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine errorbar"
;-----------------------------------------------------------------------


pro ErrorBar, XArr, YArr, Error, X=X, _EXTRA=e

   ;====================================================================
   ; Make sure XARR and YARR have the same # of elements!
   ;====================================================================
   if ( N_Elements( XArr ) ne N_Elements( YArr ) ) then begin
      Message, 'XARR and YARR have different dimensions!', /Continue
      return
   endif
  
   ;====================================================================
   ; ERROR was not passed!
   ;====================================================================
   if ( N_Elements( Error ) eq 0 ) then begin
      Message, 'Must supply ERROR!', /Continue
      return
   endif

   ;====================================================================
   ; If ERROR is a scalar, then expand it so that it has the 
   ; same # of elements as XARR and YARR.  If ERROR is an array,
   ; then first make sure that it has the same # of elements as
   ; XARR and YARR.  Save to temporary variable TMPERROR.
   ;====================================================================
   if ( Size( Error, /N_Dim ) eq 0 ) then begin
      TmpError = Replicate( Error, N_Elements( XArr ) )  
 
   endif else begin

      if ( N_Elements( Error ) ne N_Elements( XArr ) ) then begin
         Message, 'ERROR does not have the same dimensions as XARR, YARR!', $
            /Continue
         return
      endif

      TmpError = Error
   endelse

   ;====================================================================
   ; If /X is set, plot error bars along the X-dimension
   ; Otherwise, plot error bars along the Y-dimension. 
   ;====================================================================
   if ( Keyword_Set( X ) ) then begin
   
      ; Plot error bars on X-axis
      for I = 0, N_Elements( XArr ) - 1 do begin
         TmpX = [ XArr[I] - TmpError[I], XArr[I] + TmpError[I] ]
         TmpY = [ YArr[I]              , YArr[I]               ]

         OPlot, TmpX, TmpY, _EXTRA=e
      endfor

   endif else begin

      ; Plot error bars on Y-axis (default)
      for I = 0, N_Elements( XArr ) - 1 do begin
         TmpX = [ XArr[I]               , XArr[I]               ]
         TmpY = [ YArr[I] - TmpError[I] , YArr[I] + TmpError[I] ]

         OPlot, TmpX, TmpY, _EXTRA=e
      endfor

   endelse
      
   ; Return to calling program
   return
end
