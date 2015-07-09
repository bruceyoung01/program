; $Id: schmidtdriver.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SCHMIDTDRIVER
;
; PURPOSE:
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SCHMIDTDRIVER
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        bmy, 27 Jun 2003: VERSION 1.00
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine schmidtdriver"
;-----------------------------------------------------------------------


Pro Driver, _Extra=e
 
Open_Device, Bits=8, /Color, NColors = 200, _Extra=e
 
Forward_Function Schmidt
 
;
; This program estimates the Schmidt number for CH3Br to which a
; polynomial is fitted
; 
; Author: P. I. Palmer 6/27/03
;
 
!P.Color = 1
!P.Font  = 2
 
Temperature = FindGen(41) + 273.15
 
; Molar volume of CH3Br is taken from "The propertes of gases and liquids"
; Reid, Prausnitz, and Sherwood, 
CH3BrMV = 59.5
;CH3BrMV = 77.5 ; acetone
 
; Compute the schmidt number as a function of sea surface temperature
Output = FltArr(N_Elements(Temperature),2)
 
Result = Schmidt(Temperature, CH3BrMV, 1)
Output(*,1) = Result
 
Print, Result
 
; Plot data
Plot, Temperature-273.15, Output(*,1), $
  XTitle = 'Temperature [C]',$
  YTitle = 'Schmidt Number [unitless]',$
  Color = 1
 
; Fit 3rd order polynomial to curve
FitCoef = POLY_FIT( Temperature-273.15,$
                    Output(*,1), 3, /Double)
 
; Overplot the fitted polynomial
FitCurve = FitCoef(0) + $
  FitCoef(1)*Temperature + $
  FitCoef(2)*Temperature^2 + $
  FitCoef(3)*Temperature^3
 
; CH3Br fitted coefficients
;       2805.5650
;      -116.24219
;       1.8828771
;    -0.012038030
 
OPlot, Temperature, FitCurve, Color = 2
 
OutString = String(Format='((f6.1), (f6.1), "T", "+", (f8.5), "T!U2!N", (f8.5), "T!U3!N" )',FitCoef(0),FitCoef(1),FitCoef(2),FitCoef(3))
 
XYOutS,[10],[500],OutString, CharSize = 2.0
 
Print, FitCoef
 
Close_Device, _Extra=e
 
End
