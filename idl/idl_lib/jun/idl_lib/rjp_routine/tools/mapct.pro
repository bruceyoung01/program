; $Id: mapct.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        MAPCT
;
; PURPOSE:
;        define a good looking colro scheme for color contour
;        plots 
;
; CATEGORY:
;        COLOR TABLE modifying function
;
; CALLING SEQUENCE:
;        c_ind = MAPCT()
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        DEFAULTTABLE -> specifies color table which is loaded prior
;                 to modification by MAPCT
;
; OUTPUTS:
;        c_ind: a 10 element integer array containing the color indices of
;        the 10 standard contour level colors
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        uses procedure MYCT in order to define plotting colors 0-16
;        for all routines by mgs which use mapct, index 0 must be white 
;        and index 1 must be black (which is established by myct)
;
; NOTES:
;        The color modifications are made on top of the linear black/white
;        scale, so one should be able to overlay e.g. satellite images
;        or put them into another plot on the same page.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 23 Sep 1997: VERSION 1.00
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine mapct"
;-------------------------------------------------------------


function mapct,defaulttable=defaulttable
 
on_error,2    ; return to caller

; load default color table (grey shades) and define first 16 colors
; as plotting colors
; index 0 = white, index 1 = black
if(not keyword_set(defaulttable)) then defaulttable = 0 
myct,defaulttable 
 
ctmax=!d.table_size
 
; now define colors from index 20 as
; purple, blue, light blue, green, light green, yellow, orange, 
; light red, dark red, and pink
; these should be used to display 8 levels of data + below lower limit
; or above upper limit
 
; These RGB values have been chosen to yield good results on an X terminal
; as well as on the QMS color printer that we have
 
;         prp blu lb  gr  lg  ye  or  lrd rd  pink
red =   [  70,  0, 40, 40,120,250,255,255,200,255 ]
green = [   0,  0,100,200,250,250,170, 40, 30,  0 ]
blue =  [ 180,255,220, 40, 40,  0,  0, 40, 50,255 ]
 
; load the modified color table
TVLCT, red, green, blue, 20
 
; create color index field
c_ind = indgen(10)+20
 
 
return,c_ind
end
 
