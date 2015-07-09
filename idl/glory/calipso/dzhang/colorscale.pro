pro colorscale,LUTR,LUTG,LUTB

;*************************************************************************
; Name: colorscale
;
; Purpose:
;   This routine sets up the colorscale to be used for byte scaling the data
;    and defines the colors to be used for black (255) and white (254).  The
;    data will be scaled, in some form, between 0 and 253, based upon the
;    min and max specified.
;
; Inputs:
;  Environmental:
;   None.
;
;  Passed:
;   None.
;
; Outputs:
;  LUTR, LUTG, LUTB:    These are the color assignments form Red, Green, and Blue.
;
; Required Programs:
;  None.
;
; Modification history:
;  11/08/2001
;    Initial Release.
;
; Credits:
;  Written by Eric G. Moody and Paul Hubanks.
;  eric.moody@gsfc.nasa.gov
;  Code 913 NASA/GSFC
;  Greenbelt, MD 20771
;
; Color Scheme created by Paul Hubanks.
;
; License:
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software and to alter
; it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;*************************************************************************
; example to call it
; common colors,r_orig,G_orig, B_orig, R_CURR, G_CURR, B_CURR
;  colorscale,r,g,b;LUTR,LUTG,LUTB
;    NCOLORS=256
;    r[250:255]=255 & g[250:255]=255 & b[250:255]=255
;    R_CURR=R &  G_CURR=G & B_CURR=B

;Create the arrays for the color scale:
LUTR=BYTARR(256)
LUTG=BYTARR(256)
LUTB=BYTARR(256)


;;;;;;;;;;;;;;;;;;
; RED
;;;;;;;;;;;;;;;;;;

FOR INDEX = 0,50 DO BEGIN
 DYDX = 173.0 - ((173.0*INDEX)/50.0)
 LUTR(INDEX) = BYTE(DYDX)
END

LUTR(51:113)=0

FOR I=114,145 DO BEGIN
 DX=FLOAT(I)-113.
 DYDX=(255.-0.)/(146.-113.)
 LUTR(I)=BYTE((DYDX*DX)+0.)
END

LUTR(146:230)=255

FOR I=231,255 DO BEGIN
 DYDX=255.0 - 75.0*(I-231.0)/(22.0)
 LUTR(I)=BYTE((DYDX))
END


;;;;;;;;;;;;;;;;;;
; GREEN
;;;;;;;;;;;;;;;;;;

LUTG(0:36)=0

FOR I=37,129 DO BEGIN
 DX=FLOAT(I)-36.
 DYDX=(255.-0.)/(130.-36.)
 LUTG(I)=BYTE((DYDX*DX)+0.)
END

LUTG(130:154)=255

FOR I=155,250 DO BEGIN
 DX=FLOAT(I)-154.
 DYDX=(0.-255.)/(251.-154.)
 LUTG(I)=BYTE((DYDX*DX)+255.)
END

LUTG(251:255)=0

;;;;;;;;;;;;;;;;;;
; BLUE
;;;;;;;;;;;;;;;;;;

FOR I=0,60 DO BEGIN
 DYDX = 255.0 - (85.0*(60-I)/60.0)
 LUTB(I)=BYTE(DYDX)
END

LUTB(61)=255

FOR I=62,64 DO BEGIN
 DX=FLOAT(I)-61.
 DYDX=(238.-255.)/(65.-61.)
 LUTB(I)=BYTE((DYDX*DX)+255.)

END

LUTB(65:77)=238

FOR I=78,124 DO BEGIN
 DX=FLOAT(I)-77.
 DYDX=(0.-238.)/(125.-77.)
 LUTB(I)=BYTE((DYDX*DX)+238.)
END

LUTB(125:255)=0


;;;;;;;;;;;;;;;;;;
; GREY-for greater than top limit.
;;;;;;;;;;;;;;;;;;
LUTR(253)=255;150
LUTG(253)=255;150
LUTB(253)=255;150

;;;;;;;;;;;;;;;;;;
; DARK GREY-for less than bottom limit.
;;;;;;;;;;;;;;;;;;
LUTR(0)=0;75
LUTG(0)=0;75
LUTB(0)=0;75
;print,LUTR[0:1],LUTg[0:1],LUTb[0:1]
;;;;;;;;;;;;;;;;;;
; WHITE
;;;;;;;;;;;;;;;;;;
;reserve 254 (white) - background and coastlines
LUTR(254)  = 255
LUTG(254)  = 255
LUTB(254)  = 255


;;;;;;;;;;;;;;;;;;
; BLACK
;;;;;;;;;;;;;;;;;;
;reserve 255 (black) - text
LUTR(255)  =255;0
LUTG(255)  =255;0
LUTB(255)  =255;0

TVLCT,LUTR,LUTG,LUTB
;print,'good'

end
